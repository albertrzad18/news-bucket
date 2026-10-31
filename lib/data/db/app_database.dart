import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

@DataClassName('ArticleRow')
class Articles extends Table {
  /// Normalized URL.
  TextColumn get id => text()();
  TextColumn get sourceId => text()();
  TextColumn get category => text()();
  TextColumn get title => text()();
  TextColumn get url => text()();
  TextColumn get snippet => text().nullable()();
  TextColumn get author => text().nullable()();
  IntColumn get score => integer().nullable()();
  IntColumn get commentCount => integer().nullable()();
  TextColumn get commentsUrl => text().nullable()();
  DateTimeColumn get publishedAt => dateTime()();

  /// When the article was first seen; drives retention.
  DateTimeColumn get fetchedAt => dateTime()();
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();
  BoolColumn get isSaved => boolean().withDefault(const Constant(false))();

  /// Set once a notification mentioned this article (used in a later phase).
  BoolColumn get notified => boolean().withDefault(const Constant(false))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Result of the last refresh of one source.
@DataClassName('SourceStateRow')
class SourceStates extends Table {
  TextColumn get sourceId => text()();
  DateTimeColumn get lastAttemptAt => dateTime()();
  DateTimeColumn get lastSuccessAt => dateTime().nullable()();
  TextColumn get lastError => text().nullable()();
  IntColumn get lastItemCount => integer().withDefault(const Constant(0))();

  @override
  Set<Column<Object>> get primaryKey => {sourceId};
}

@DriftDatabase(tables: [Articles, SourceStates])
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(
        executor ??
            driftDatabase(
              name: 'news_bucket',
              // The background news check runs in another isolate.
              native: const DriftNativeOptions(shareAcrossIsolates: true),
            ),
      );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement(
        'CREATE INDEX articles_published_at ON articles (published_at)',
      );
    },
    onUpgrade: (m, from, to) async {
      // v2: the app no longer loads images.
      if (from < 2) await m.dropColumn(articles, 'image_url');
    },
  );
}
