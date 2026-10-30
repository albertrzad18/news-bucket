import 'news_category.dart';

/// How a source's response should be parsed.
enum SourceType {
  /// RSS 2.0, RSS 1.0 (RDF) or Atom.
  feed('feed'),

  /// Hacker News search API by Algolia.
  hnAlgolia('hn_algolia'),

  /// DEV.to (Forem) articles API.
  devto('devto');

  const SourceType(this.id);

  final String id;

  static SourceType fromId(String id) =>
      values.firstWhere((type) => type.id == id);
}

/// One entry of `assets/sources.json`.
class SourceConfig {
  const SourceConfig({
    required this.id,
    required this.name,
    required this.category,
    required this.type,
    required this.url,
    this.limit = 15,
    this.notify = false,
    this.keywords = const [],
  });

  factory SourceConfig.fromJson(Map<String, dynamic> json) {
    return SourceConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      category: NewsCategory.fromId(json['category'] as String),
      type: SourceType.fromId(json['type'] as String),
      url: json['url'] as String,
      limit: json['limit'] as int? ?? 15,
      notify: json['notify'] as bool? ?? false,
      keywords: (json['keywords'] as List?)?.cast<String>() ?? const [],
    );
  }

  final String id;
  final String name;
  final NewsCategory category;
  final SourceType type;
  final String url;

  /// Maximum number of items kept per refresh.
  final int limit;

  /// Whether new items from this source trigger a notification by default.
  final bool notify;

  /// When non-empty, only items whose title or snippet contains one of these
  /// words (case-insensitive) are kept.
  final List<String> keywords;
}
