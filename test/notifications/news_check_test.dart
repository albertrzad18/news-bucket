import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/core/settings/notification_settings.dart';
import 'package:news_bucket/data/db/app_database.dart';
import 'package:news_bucket/data/models/article.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:news_bucket/data/models/source_config.dart';
import 'package:news_bucket/data/repositories/news_repository.dart';
import 'package:news_bucket/data/sources/source_fetcher.dart';
import 'package:news_bucket/features/notifications/news_check.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFetcher extends SourceFetcher {
  FakeFetcher() : super(Dio());

  final Map<String, List<String>> titles = {};

  @override
  Future<List<Article>> fetch(SourceConfig source) async => [
    for (final (i, title) in (titles[source.id] ?? const <String>[]).indexed)
      Article(
        id: 'https://example.com/${source.id}/$title',
        sourceId: source.id,
        category: source.category,
        title: title,
        url: 'https://example.com/${source.id}/$title',
        publishedAt: DateTime.utc(2026, 10, 1, i),
      ),
  ];
}

SourceConfig src(String id, {bool notify = false}) => SourceConfig(
  id: id,
  name: 'Source $id',
  category: NewsCategory.claude,
  type: SourceType.feed,
  url: 'https://example.com/$id',
  notify: notify,
);

Article art(String title, {String sourceId = 'a'}) => Article(
  id: title,
  sourceId: sourceId,
  category: NewsCategory.claude,
  title: title,
  url: 'https://example.com/$title',
  publishedAt: DateTime.utc(2026),
);

void main() {
  group('checkForNews', () {
    late AppDatabase db;
    late FakeFetcher fetcher;
    late NewsRepository repo;

    setUp(() {
      db = AppDatabase(NativeDatabase.memory());
      fetcher = FakeFetcher();
      repo = NewsRepository(db, fetcher);
    });
    tearDown(() => db.close());

    test('the first successful load is a silent baseline', () async {
      fetcher.titles['a'] = ['one', 'two'];
      expect(await checkForNews(repo, [src('a')]), isEmpty);

      fetcher.titles['a'] = ['one', 'two', 'three'];
      final fresh = await checkForNews(repo, [src('a')]);
      expect(fresh.map((a) => a.title), ['three']);
    });

    test('nothing new means nothing to announce', () async {
      fetcher.titles['a'] = ['one'];
      await checkForNews(repo, [src('a')]);
      expect(await checkForNews(repo, [src('a')]), isEmpty);
    });

    test(
      'articles already found by an app refresh are not announced again',
      () async {
        fetcher.titles['a'] = ['one'];
        await checkForNews(repo, [src('a')]);
        fetcher.titles['a'] = ['one', 'two'];
        await repo.refresh([src('a')]); // foreground refresh sees "two" first
        expect(await checkForNews(repo, [src('a')]), isEmpty);
      },
    );

    test('no sources means no network work', () async {
      expect(await checkForNews(repo, const []), isEmpty);
      expect(await repo.getSourceStates(), isEmpty);
    });
  });

  test('notificationSources keeps chosen, enabled sources', () {
    final catalog = [src('a'), src('b'), src('c')];
    final result = notificationSources(
      catalog,
      notifyIds: {'a', 'b'},
      disabledIds: {'b'},
    );
    expect(result.map((s) => s.id), ['a']);
  });

  group('buildNotificationContent', () {
    final names = {'a': 'Claude Code releases', 'b': 'HN'};

    test('single article: source as title, opens the article', () {
      final content = buildNotificationContent([art('v2.1.0')], names);
      expect(content.title, 'Claude Code releases');
      expect(content.body, 'v2.1.0');
      expect(content.payload, 'https://example.com/v2.1.0');
      expect(content.lines, isEmpty);
    });

    test('several articles: count, inbox lines and overflow summary', () {
      final articles = [
        for (var i = 0; i < 7; i++) art('t$i', sourceId: i.isEven ? 'a' : 'b'),
      ];
      final content = buildNotificationContent(articles, names);
      expect(content.title, '7 new articles');
      expect(content.body, 't0 · t1 · t2');
      expect(content.lines, hasLength(5));
      expect(content.lines.first, 'Claude Code releases: t0');
      expect(content.summary, '+2 more');
      expect(content.payload, isNull);
    });
  });

  group('NotificationPrefs', () {
    final catalog = [src('a', notify: true), src('b')];

    test('defaults to the notify flags from sources.json', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = NotificationPrefs(await SharedPreferences.getInstance());
      expect(prefs.enabled, isFalse);
      expect(prefs.sourceIds(catalog), {'a'});
    });

    test('an explicit choice overrides the defaults', () async {
      SharedPreferences.setMockInitialValues({
        NotificationPrefs.enabledKey: true,
        NotificationPrefs.sourcesKey: ['b'],
      });
      final prefs = NotificationPrefs(await SharedPreferences.getInstance());
      expect(prefs.enabled, isTrue);
      expect(prefs.sourceIds(catalog), {'b'});
    });
  });
}
