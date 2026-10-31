import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/data/db/app_database.dart';
import 'package:news_bucket/data/models/article.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:news_bucket/data/models/source_config.dart';
import 'package:news_bucket/data/repositories/news_repository.dart';
import 'package:news_bucket/data/sources/source_fetcher.dart';

class FakeFetcher extends SourceFetcher {
  FakeFetcher() : super(Dio());

  final Map<String, List<Article>> responses = {};
  final Set<String> failing = {};

  @override
  Future<List<Article>> fetch(SourceConfig source) async {
    if (failing.contains(source.id)) throw Exception('boom');
    return responses[source.id] ?? const [];
  }
}

SourceConfig src(String id, [NewsCategory category = NewsCategory.ai]) {
  return SourceConfig(
    id: id,
    name: id,
    category: category,
    type: SourceType.feed,
    url: 'https://example.com/$id',
  );
}

Article art(
  String id, {
  String sourceId = 'a',
  NewsCategory category = NewsCategory.ai,
  String? title,
  int day = 1,
  String? snippet,
}) {
  return Article(
    id: 'https://example.com/$id',
    sourceId: sourceId,
    category: category,
    title: title ?? 'Title $id',
    snippet: snippet,
    url: 'https://example.com/$id',
    publishedAt: DateTime.utc(2026, 10, day),
  );
}

void main() {
  late AppDatabase db;
  late FakeFetcher fetcher;
  late NewsRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fetcher = FakeFetcher();
    repo = NewsRepository(db, fetcher);
  });

  tearDown(() => db.close());

  test('refresh stores articles and reports only new ones', () async {
    fetcher.responses['a'] = [art('1'), art('2')];
    final first = await repo.refresh([src('a')]);
    expect(first.newArticles, hasLength(2));

    fetcher.responses['a'] = [art('2'), art('3')];
    final second = await repo.refresh([src('a')]);
    expect(second.newArticles.map((a) => a.id), ['https://example.com/3']);

    final all = await repo.watchArticles().first;
    expect(all, hasLength(3));
  });

  test('articles are ordered newest first', () async {
    fetcher.responses['a'] = [art('old', day: 1), art('new', day: 9)];
    await repo.refresh([src('a')]);
    final all = await repo.watchArticles().first;
    expect(all.map((a) => a.title), ['Title new', 'Title old']);
  });

  test(
    'a failing source does not block the others and records its error',
    () async {
      fetcher
        ..failing.add('bad')
        ..responses['good'] = [art('1', sourceId: 'good')];

      final summary = await repo.refresh([src('bad'), src('good')]);

      expect(summary.failures.single.source.id, 'bad');
      expect(summary.newArticles, hasLength(1));

      final states = {
        for (final s in await repo.watchSourceStates().first) s.sourceId: s,
      };
      expect(states['bad']!.lastError, contains('boom'));
      expect(states['bad']!.lastSuccessAt, isNull);
      expect(states['good']!.lastError, isNull);
      expect(states['good']!.lastItemCount, 1);
    },
  );

  test('a later failure keeps the previous success time', () async {
    fetcher.responses['a'] = [art('1')];
    await repo.refresh([src('a')]);
    final before = (await repo.watchSourceStates().first).single.lastSuccessAt;

    fetcher.failing.add('a');
    await repo.refresh([src('a')]);
    final after = (await repo.watchSourceStates().first).single;

    expect(after.lastError, isNotNull);
    expect(after.lastSuccessAt, before);
    expect(after.lastItemCount, 1);
  });

  test('re-fetching keeps saved/read flags and refreshes the title', () async {
    fetcher.responses['a'] = [art('1', title: 'Old')];
    await repo.refresh([src('a')]);
    await repo.setSaved('https://example.com/1', saved: true);
    await repo.markRead('https://example.com/1');

    fetcher.responses['a'] = [art('1', title: 'New')];
    await repo.refresh([src('a')]);

    final article = (await repo.watchArticles().first).single;
    expect(article.title, 'New');
    expect(article.isSaved, isTrue);
    expect(article.isRead, isTrue);
  });

  test(
    'the same story from another source does not overwrite the first',
    () async {
      fetcher
        ..responses['a'] = [art('1', sourceId: 'a', title: 'From A')]
        ..responses['b'] = [art('1', sourceId: 'b', title: 'From B')];
      await repo.refresh([src('a')]);
      final second = await repo.refresh([src('b')]);

      expect(second.newArticles, isEmpty);
      final article = (await repo.watchArticles().first).single;
      expect(article.sourceId, 'a');
      expect(article.title, 'From A');
    },
  );

  test('filters by category, source, exclusion and saved', () async {
    fetcher
      ..responses['a'] = [art('1', sourceId: 'a')]
      ..responses['b'] = [
        art('2', sourceId: 'b', category: NewsCategory.crypto),
      ];
    await repo.refresh([src('a'), src('b', NewsCategory.crypto)]);

    expect(
      await repo.watchArticles(categories: {NewsCategory.crypto}).first,
      hasLength(1),
    );
    expect(await repo.watchArticles(sourceIds: {'a'}).first, hasLength(1));
    expect(
      await repo.watchArticles(excludedSourceIds: {'a'}).first,
      hasLength(1),
    );
    expect(await repo.watchArticles(savedOnly: true).first, isEmpty);

    await repo.setSaved('https://example.com/2', saved: true);
    final saved = await repo.watchArticles(savedOnly: true).first;
    expect(saved.single.id, 'https://example.com/2');
  });

  test('prune removes old unsaved articles but never saved ones', () async {
    final oldRepo = NewsRepository(
      db,
      fetcher,
      retention: const Duration(days: -1), // everything counts as expired
    );
    fetcher.responses['a'] = [art('keep'), art('drop')];
    await repo.refresh([src('a')]);
    await repo.setSaved('https://example.com/keep', saved: true);

    final removed = await oldRepo.pruneOldArticles();

    expect(removed, 1);
    final left = await repo.watchArticles().first;
    expect(left.single.id, 'https://example.com/keep');
  });

  test('lastRefreshAt is null before and set after a refresh', () async {
    expect(await repo.lastRefreshAt(), isNull);
    await repo.refresh([src('a')]);
    expect(await repo.lastRefreshAt(), isNotNull);
  });

  test(
    'search matches every word in title or snippet, case-insensitive',
    () async {
      fetcher.responses['a'] = [
        art('1', title: 'Claude Code 2.1 released'),
        art('2', title: 'Rust news', snippet: 'A new claude integration'),
        art('3', title: 'Unrelated'),
        art('4', title: 'Up 50% in a week'),
        art('5', title: 'Up 500 points'),
      ];
      await repo.refresh([src('a')]);

      Future<List<String>> ids(String query) async => [
        for (final a in await repo.watchArticles(query: query).first)
          a.id.split('/').last,
      ];

      expect(await ids('CLAUDE'), unorderedEquals(['1', '2']));
      expect(await ids('claude  released'), ['1']);
      expect(await ids('50%'), ['4'], reason: '% is not a wildcard');
      expect(await ids(''), hasLength(5));
    },
  );

  test('publishedAfter keeps only newer articles', () async {
    fetcher.responses['a'] = [art('old', day: 1), art('new', day: 20)];
    await repo.refresh([src('a')]);

    final recent = await repo
        .watchArticles(publishedAfter: DateTime.utc(2026, 10, 10))
        .first;
    expect(recent.single.id, 'https://example.com/new');
  });
}
