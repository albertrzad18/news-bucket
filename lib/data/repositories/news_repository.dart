import 'package:drift/drift.dart';

import '../db/app_database.dart';
import '../models/article.dart';
import '../models/news_category.dart';
import '../models/source_config.dart';
import '../sources/source_fetcher.dart';

class SourceRefreshResult {
  const SourceRefreshResult({
    required this.source,
    this.newArticles = const [],
    this.error,
  });

  final SourceConfig source;
  final List<Article> newArticles;
  final Object? error;

  bool get failed => error != null;
}

class RefreshSummary {
  const RefreshSummary(this.results);

  final List<SourceRefreshResult> results;

  List<Article> get newArticles => [
    for (final result in results) ...result.newArticles,
  ];

  List<SourceRefreshResult> get failures =>
      results.where((result) => result.failed).toList();
}

class NewsRepository {
  NewsRepository(
    this._db,
    this._fetcher, {
    this.retention = const Duration(days: 30),
    this.maxConcurrentRequests = 6,
  });

  final AppDatabase _db;
  final SourceFetcher _fetcher;
  final Duration retention;
  final int maxConcurrentRequests;

  /// Fetches [sources] in parallel (bounded) and stores the results. A failing
  /// source never aborts the others; its error is reported in the summary and
  /// saved in the source state table.
  Future<RefreshSummary> refresh(List<SourceConfig> sources) async {
    final results = <SourceRefreshResult>[];
    final queue = List.of(sources);

    Future<void> worker() async {
      while (queue.isNotEmpty) {
        results.add(await _refreshSource(queue.removeLast()));
      }
    }

    await Future.wait(
      List.generate(maxConcurrentRequests.clamp(1, sources.length), (_) {
        return worker();
      }),
    );
    await pruneOldArticles();
    return RefreshSummary(results);
  }

  Future<SourceRefreshResult> _refreshSource(SourceConfig source) async {
    final now = DateTime.now().toUtc();
    try {
      final articles = await _fetcher.fetch(source);
      final fresh = await _store(articles, now);
      await _saveState(source.id, now, itemCount: articles.length);
      return SourceRefreshResult(source: source, newArticles: fresh);
    } catch (error) {
      await _saveState(source.id, now, error: error);
      return SourceRefreshResult(source: source, error: error);
    }
  }

  /// Upserts [articles] and returns the ones that were not stored before.
  /// User flags (read/saved/notified) and the original date are kept. Only
  /// the source that first stored an article may update it, so a story found
  /// on HN and Lobsters doesn't flip-flop between them.
  Future<List<Article>> _store(List<Article> articles, DateTime now) {
    final byId = {for (final article in articles) article.id: article};
    if (byId.isEmpty) return Future.value(const []);

    return _db.transaction(() async {
      final existing =
          await (_db.selectOnly(_db.articles)
                ..addColumns([_db.articles.id])
                ..where(_db.articles.id.isIn(byId.keys)))
              .map((row) => row.read(_db.articles.id)!)
              .get();

      await _db.batch((batch) {
        for (final article in byId.values) {
          batch.insert(
            _db.articles,
            _toCompanion(article, now),
            onConflict: DoUpdate<$ArticlesTable, ArticleRow>(
              (old) => ArticlesCompanion(
                title: Value(article.title),
                snippet: Value(article.snippet),
                imageUrl: Value(article.imageUrl),
                score: Value(article.score),
                commentCount: Value(article.commentCount),
              ),
              where: (old) => old.sourceId.equals(article.sourceId),
            ),
          );
        }
      });

      final known = existing.toSet();
      return byId.values.where((a) => !known.contains(a.id)).toList();
    });
  }

  Future<void> _saveState(
    String sourceId,
    DateTime now, {
    int itemCount = 0,
    Object? error,
  }) {
    final ok = error == null;
    return _db
        .into(_db.sourceStates)
        .insert(
          SourceStatesCompanion.insert(
            sourceId: sourceId,
            lastAttemptAt: now,
            lastSuccessAt: Value(ok ? now : null),
            lastError: Value(ok ? null : error.toString()),
            lastItemCount: Value(itemCount),
          ),
          onConflict: DoUpdate(
            (old) => SourceStatesCompanion(
              lastAttemptAt: Value(now),
              // Keep the previous success time when this attempt failed.
              lastSuccessAt: ok ? Value(now) : const Value.absent(),
              lastError: Value(ok ? null : error.toString()),
              lastItemCount: ok ? Value(itemCount) : const Value.absent(),
            ),
          ),
        );
  }

  /// Newest first. Empty filter sets mean "no filter".
  Stream<List<Article>> watchArticles({
    Set<NewsCategory> categories = const {},
    Set<String> sourceIds = const {},
    Set<String> excludedSourceIds = const {},
    bool savedOnly = false,
    int limit = 500,
  }) {
    final query = _db.select(_db.articles)
      ..where((t) {
        final conditions = <Expression<bool>>[
          if (categories.isNotEmpty)
            t.category.isIn(categories.map((c) => c.id)),
          if (sourceIds.isNotEmpty) t.sourceId.isIn(sourceIds),
          if (excludedSourceIds.isNotEmpty)
            t.sourceId.isNotIn(excludedSourceIds),
          if (savedOnly) t.isSaved.equals(true),
        ];
        return conditions.isEmpty
            ? const Constant(true)
            : Expression.and(conditions);
      })
      ..orderBy([(t) => OrderingTerm.desc(t.publishedAt)])
      ..limit(limit);
    return query.watch().map((rows) => rows.map(_toArticle).toList());
  }

  Stream<List<SourceStateRow>> watchSourceStates() =>
      _db.select(_db.sourceStates).watch();

  Future<List<SourceStateRow>> getSourceStates() =>
      _db.select(_db.sourceStates).get();

  Future<DateTime?> lastRefreshAt() async {
    final max = _db.sourceStates.lastAttemptAt.max();
    final row = await (_db.selectOnly(
      _db.sourceStates,
    )..addColumns([max])).getSingle();
    return row.read(max);
  }

  Future<void> setSaved(String articleId, {required bool saved}) =>
      (_db.update(_db.articles)..where((t) => t.id.equals(articleId))).write(
        ArticlesCompanion(isSaved: Value(saved)),
      );

  Future<void> markRead(String articleId, {bool read = true}) =>
      (_db.update(_db.articles)..where((t) => t.id.equals(articleId))).write(
        ArticlesCompanion(isRead: Value(read)),
      );

  /// Deletes unsaved articles first seen longer than [retention] ago.
  Future<int> pruneOldArticles() {
    final cutoff = DateTime.now().toUtc().subtract(retention);
    return (_db.delete(_db.articles)..where(
          (t) =>
              t.isSaved.equals(false) & t.fetchedAt.isSmallerThanValue(cutoff),
        ))
        .go();
  }

  static ArticlesCompanion _toCompanion(Article article, DateTime now) {
    return ArticlesCompanion.insert(
      id: article.id,
      sourceId: article.sourceId,
      category: article.category.id,
      title: article.title,
      url: article.url,
      snippet: Value(article.snippet),
      imageUrl: Value(article.imageUrl),
      author: Value(article.author),
      score: Value(article.score),
      commentCount: Value(article.commentCount),
      commentsUrl: Value(article.commentsUrl),
      publishedAt: article.publishedAt,
      fetchedAt: now,
    );
  }

  static Article _toArticle(ArticleRow row) {
    return Article(
      id: row.id,
      sourceId: row.sourceId,
      category: NewsCategory.fromId(row.category),
      title: row.title,
      url: row.url,
      publishedAt: row.publishedAt,
      snippet: row.snippet,
      imageUrl: row.imageUrl,
      author: row.author,
      score: row.score,
      commentCount: row.commentCount,
      commentsUrl: row.commentsUrl,
      isRead: row.isRead,
      isSaved: row.isSaved,
    );
  }
}
