import 'news_category.dart';

class Article {
  const Article({
    required this.id,
    required this.sourceId,
    required this.category,
    required this.title,
    required this.url,
    required this.publishedAt,
    this.snippet,
    this.author,
    this.score,
    this.commentCount,
    this.commentsUrl,
    this.isRead = false,
    this.isSaved = false,
  });

  /// Normalized URL; used for de-duplication across sources.
  final String id;
  final String sourceId;
  final NewsCategory category;
  final String title;
  final String url;
  final DateTime publishedAt;
  final String? snippet;
  final String? author;

  /// Points/reactions for sources that have them (Hacker News, DEV).
  final int? score;
  final int? commentCount;
  final String? commentsUrl;

  final bool isRead;
  final bool isSaved;
}
