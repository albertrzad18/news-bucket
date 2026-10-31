import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/core/network/http_client.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:news_bucket/data/models/source_config.dart';
import 'package:news_bucket/data/sources/source_fetcher.dart';

/// Answers with the queued results in order: an [int] is an HTTP status with
/// an empty feed, a [DioExceptionType] is thrown as a network error.
class QueueAdapter implements HttpClientAdapter {
  QueueAdapter(this.results);

  final List<Object> results;
  int calls = 0;

  static const _feed =
      '<rss><channel><item><title>A</title>'
      '<link>https://example.com/a</link></item></channel></rss>';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final result = results[calls++];
    if (result is DioExceptionType) {
      throw DioException(requestOptions: options, type: result);
    }
    return ResponseBody.fromBytes(utf8.encode(_feed), result as int);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  const source = SourceConfig(
    id: 'test',
    name: 'Test',
    category: NewsCategory.ai,
    type: SourceType.feed,
    url: 'https://example.com/feed',
  );

  SourceFetcher fetcherWith(QueueAdapter adapter) => SourceFetcher(
    createHttpClient()..httpClientAdapter = adapter,
    retryDelay: Duration.zero,
  );

  test('retries once after a timeout', () async {
    final adapter = QueueAdapter([DioExceptionType.receiveTimeout, 200]);
    final articles = await fetcherWith(adapter).fetch(source);
    expect(articles.single.title, 'A');
    expect(adapter.calls, 2);
  });

  test(
    'retries a server error but gives up after the second failure',
    () async {
      final adapter = QueueAdapter([503, 502, 200]);
      await expectLater(
        fetcherWith(adapter).fetch(source),
        throwsA(isA<DioException>()),
      );
      expect(adapter.calls, 2);
    },
  );

  test('does not retry a client error', () async {
    final adapter = QueueAdapter([404, 200]);
    await expectLater(
      fetcherWith(adapter).fetch(source),
      throwsA(isA<DioException>()),
    );
    expect(adapter.calls, 1);
  });
}
