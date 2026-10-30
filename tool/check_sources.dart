// Fetches every source in assets/sources.json with the real HTTP client and
// parser, and prints how many articles each one yields.
//
//   dart run tool/check_sources.dart
import 'dart:convert';
import 'dart:io';

import 'package:news_bucket/core/network/http_client.dart';
import 'package:news_bucket/data/models/source_config.dart';
import 'package:news_bucket/data/sources/source_fetcher.dart';

Future<void> main() async {
  final json = jsonDecode(File('assets/sources.json').readAsStringSync());
  final sources = (json['sources'] as List)
      .cast<Map<String, dynamic>>()
      .map(SourceConfig.fromJson)
      .toList();

  final dio = createHttpClient();
  final fetcher = SourceFetcher(dio);
  var failures = 0;

  await Future.wait(
    sources.map((source) async {
      final watch = Stopwatch()..start();
      try {
        final articles = await fetcher.fetch(source);
        final newest = articles.isEmpty ? '-' : articles.first.title;
        stdout.writeln(
          '${articles.isEmpty ? 'EMPTY' : 'ok   '} '
          '${source.id.padRight(22)} ${articles.length.toString().padLeft(3)} '
          '${watch.elapsedMilliseconds.toString().padLeft(5)}ms  '
          '${newest.length > 60 ? '${newest.substring(0, 60)}…' : newest}',
        );
        if (articles.isEmpty) failures++;
      } catch (error) {
        failures++;
        stdout.writeln('FAIL  ${source.id.padRight(22)} $error');
      }
    }),
  );

  dio.close();
  stdout.writeln('\n${sources.length - failures}/${sources.length} sources ok');
  exit(failures == 0 ? 0 : 1);
}
