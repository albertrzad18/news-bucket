import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/data/db/app_database.dart';

/// Schema 1 as shipped in v0.1.0 (still had image_url).
const _v1Schema = [
  'CREATE TABLE articles (id TEXT NOT NULL, source_id TEXT NOT NULL, '
      'category TEXT NOT NULL, title TEXT NOT NULL, url TEXT NOT NULL, '
      'snippet TEXT NULL, image_url TEXT NULL, author TEXT NULL, '
      'score INTEGER NULL, comment_count INTEGER NULL, '
      'comments_url TEXT NULL, published_at INTEGER NOT NULL, '
      'fetched_at INTEGER NOT NULL, is_read INTEGER NOT NULL DEFAULT 0, '
      'is_saved INTEGER NOT NULL DEFAULT 0, '
      'notified INTEGER NOT NULL DEFAULT 0, PRIMARY KEY (id))',
  'CREATE TABLE source_states (source_id TEXT NOT NULL, '
      'last_attempt_at INTEGER NOT NULL, last_success_at INTEGER NULL, '
      'last_error TEXT NULL, last_item_count INTEGER NOT NULL DEFAULT 0, '
      'PRIMARY KEY (source_id))',
  'CREATE INDEX articles_published_at ON articles (published_at)',
  'INSERT INTO articles (id, source_id, category, title, url, image_url, '
      "published_at, fetched_at, is_saved) VALUES ('https://example.com/a', "
      "'src', 'claude', 'Saved before the update', 'https://example.com/a', "
      "'https://example.com/a.png', 1793400000, 1793400000, 1)",
  'PRAGMA user_version = 1',
];

void main() {
  test(
    'upgrading from v1 drops image_url, moves Claude to AI, keeps articles',
    () async {
      final db = AppDatabase(
        NativeDatabase.memory(
          setup: (raw) {
            for (final statement in _v1Schema) {
              raw.execute(statement);
            }
          },
        ),
      );
      addTearDown(db.close);

      final rows = await db.select(db.articles).get();
      expect(rows.single.title, 'Saved before the update');
      expect(rows.single.isSaved, isTrue);
      expect(rows.single.category, 'ai');

      final columns = await db
          .customSelect('PRAGMA table_info(articles)')
          .map((row) => row.read<String>('name'))
          .get();
      expect(columns, isNot(contains('image_url')));
      expect(
        await db.customSelect('PRAGMA user_version').getSingle(),
        isA<QueryRow>().having((r) => r.read<int>('user_version'), 'v', 3),
      );
    },
  );
}
