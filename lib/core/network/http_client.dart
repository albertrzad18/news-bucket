import 'package:dio/dio.dart';

const userAgent =
    'NewsBucket/0.1 (+https://github.com/albertrzad18/news-bucket)';

Dio createHttpClient() {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      // Bytes, so we decode as UTF-8 ourselves regardless of what the server
      // claims in Content-Type.
      responseType: ResponseType.bytes,
      headers: {
        'User-Agent': userAgent,
        'Accept':
            'application/rss+xml, application/atom+xml, application/xml, '
            'application/json;q=0.9, */*;q=0.8',
      },
    ),
  );
}
