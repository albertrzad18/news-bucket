import 'dart:convert';

import '../../core/utils/date_utils.dart';
import '../../core/utils/text_utils.dart';
import '../../core/utils/url_utils.dart';
import '../models/article.dart';
import '../models/source_config.dart';

/// Parses a Hacker News Algolia search response (`/api/v1/search*`).
List<Article> parseHnAlgolia(String body, SourceConfig source) {
  final hits = (jsonDecode(body) as Map<String, dynamic>)['hits'] as List;
  final articles = <Article>[];
  for (final hit in hits.cast<Map<String, dynamic>>()) {
    final title = hit['title'] as String?;
    final id = hit['objectID'] as String?;
    if (title == null || id == null) continue;

    final discussion = 'https://news.ycombinator.com/item?id=$id';
    // Ask HN / Show HN posts without an external link point to the thread.
    final url = (hit['url'] as String?)?.trim();
    final link = url == null || url.isEmpty ? discussion : url;
    final createdAt = hit['created_at_i'] as int?;

    articles.add(
      Article(
        id: normalizeUrl(link),
        sourceId: source.id,
        category: source.category,
        title: collapseWhitespace(title),
        url: link,
        publishedAt: createdAt != null
            ? DateTime.fromMillisecondsSinceEpoch(createdAt * 1000, isUtc: true)
            : parseFeedDate(hit['created_at'] as String?) ??
                  DateTime.now().toUtc(),
        snippet: makeSnippet(hit['story_text'] as String?),
        author: hit['author'] as String?,
        score: hit['points'] as int?,
        commentCount: hit['num_comments'] as int?,
        commentsUrl: discussion,
      ),
    );
  }
  return articles;
}

/// Parses a DEV.to `/api/articles` response.
List<Article> parseDevTo(String body, SourceConfig source) {
  final items = (jsonDecode(body) as List).cast<Map<String, dynamic>>();
  final articles = <Article>[];
  for (final item in items) {
    final title = item['title'] as String?;
    final url = item['url'] as String?;
    if (title == null || url == null) continue;

    final user = item['user'] as Map<String, dynamic>?;
    articles.add(
      Article(
        id: normalizeUrl(url),
        sourceId: source.id,
        category: source.category,
        title: collapseWhitespace(title),
        url: url,
        publishedAt:
            parseFeedDate(item['published_at'] as String?) ??
            DateTime.now().toUtc(),
        snippet: makeSnippet(item['description'] as String?),
        imageUrl: item['cover_image'] as String?,
        author: user?['name'] as String?,
        score:
            item['public_reactions_count'] as int? ??
            item['positive_reactions_count'] as int?,
        commentCount: item['comments_count'] as int?,
        commentsUrl: url,
      ),
    );
  }
  return articles;
}
