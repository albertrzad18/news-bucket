import 'dart:convert';

import 'package:dio/dio.dart';

import '../models/article.dart';
import '../models/source_config.dart';
import '../parsers/feed_parser.dart';
import '../parsers/json_parsers.dart';

/// Downloads one source and turns it into articles: parses, filters by
/// keywords, sorts newest first and applies the source's limit.
class SourceFetcher {
  SourceFetcher(this._dio);

  final Dio _dio;

  Future<List<Article>> fetch(SourceConfig source) async {
    final response = await _dio.get<List<int>>(source.url);
    final body = utf8.decode(response.data ?? const [], allowMalformed: true);
    return parseSource(body, source, fetchedAt: DateTime.now().toUtc());
  }
}

List<Article> parseSource(
  String body,
  SourceConfig source, {
  required DateTime fetchedAt,
}) {
  final parsed = switch (source.type) {
    SourceType.feed => parseFeed(body, source, fetchedAt: fetchedAt),
    SourceType.hnAlgolia => parseHnAlgolia(body, source),
    SourceType.devto => parseDevTo(body, source),
  };

  final keywords = source.keywords.map((k) => k.toLowerCase()).toList();
  final filtered = keywords.isEmpty
      ? parsed
      : parsed.where((article) {
          final haystack = '${article.title} ${article.snippet ?? ''}'
              .toLowerCase();
          return keywords.any(haystack.contains);
        }).toList();

  filtered.sort((a, b) => b.publishedAt.compareTo(a.publishedAt));
  return filtered.take(source.limit).toList();
}
