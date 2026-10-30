import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/network/http_client.dart';
import 'db/app_database.dart';
import 'models/source_config.dart';
import 'repositories/news_repository.dart';
import 'sources/source_catalog.dart';
import 'sources/source_fetcher.dart';

final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final sourceFetcherProvider = Provider<SourceFetcher>((ref) {
  final dio = createHttpClient();
  ref.onDispose(dio.close);
  return SourceFetcher(dio);
});

final newsRepositoryProvider = Provider<NewsRepository>((ref) {
  return NewsRepository(
    ref.watch(databaseProvider),
    ref.watch(sourceFetcherProvider),
  );
});

/// All sources defined in `assets/sources.json`.
final sourceCatalogProvider = FutureProvider<List<SourceConfig>>((ref) {
  return loadSourceCatalog();
});
