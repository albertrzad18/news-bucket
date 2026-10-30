import '../../data/models/article.dart';
import '../../data/models/source_config.dart';
import '../../data/repositories/news_repository.dart';

/// Sources the background check should fetch: chosen for notifications and
/// not switched off.
List<SourceConfig> notificationSources(
  List<SourceConfig> catalog, {
  required Set<String> notifyIds,
  required Set<String> disabledIds,
}) {
  return catalog
      .where((s) => notifyIds.contains(s.id) && !disabledIds.contains(s.id))
      .toList();
}

/// Refreshes [sources] and returns the articles worth a notification, newest
/// first.
///
/// A source that has never loaded successfully before only establishes a
/// baseline: otherwise the very first check would announce every item in
/// its feed.
Future<List<Article>> checkForNews(
  NewsRepository repo,
  List<SourceConfig> sources,
) async {
  if (sources.isEmpty) return const [];
  final seenBefore = {
    for (final state in await repo.getSourceStates())
      if (state.lastSuccessAt != null) state.sourceId,
  };
  final summary = await repo.refresh(sources);
  return [
    for (final result in summary.results)
      if (seenBefore.contains(result.source.id)) ...result.newArticles,
  ]..sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
}

class NotificationContent {
  const NotificationContent({
    required this.title,
    required this.body,
    this.lines = const [],
    this.summary,
    this.payload,
  });

  final String title;
  final String body;

  /// Expanded view lines (Android inbox style); empty for a single article.
  final List<String> lines;
  final String? summary;

  /// URL to open when the notification is tapped (single article only).
  final String? payload;
}

NotificationContent buildNotificationContent(
  List<Article> articles,
  Map<String, String> sourceNames, {
  int maxLines = 5,
}) {
  assert(articles.isNotEmpty);
  String name(Article a) => sourceNames[a.sourceId] ?? a.sourceId;

  if (articles.length == 1) {
    final article = articles.single;
    return NotificationContent(
      title: name(article),
      body: article.title,
      payload: article.url,
    );
  }

  final extra = articles.length - maxLines;
  return NotificationContent(
    title: '${articles.length} new articles',
    body: articles.take(3).map((a) => a.title).join(' · '),
    lines: [for (final a in articles.take(maxLines)) '${name(a)}: ${a.title}'],
    summary: extra > 0 ? '+$extra more' : null,
  );
}
