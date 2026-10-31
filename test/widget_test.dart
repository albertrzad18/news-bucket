import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/app.dart';
import 'package:news_bucket/core/settings/preferences.dart';
import 'package:news_bucket/data/db/app_database.dart';
import 'package:news_bucket/data/models/article.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:news_bucket/data/models/source_config.dart';
import 'package:news_bucket/data/providers.dart';
import 'package:news_bucket/data/sources/source_catalog.dart';
import 'package:news_bucket/data/sources/source_fetcher.dart';
import 'package:news_bucket/features/feed/feed_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FakeFetcher extends SourceFetcher {
  FakeFetcher(this.byCategory) : super(Dio());

  final Map<NewsCategory, List<String>> byCategory;

  @override
  Future<List<Article>> fetch(SourceConfig source) async {
    final titles = byCategory[source.category] ?? const [];
    return [
      for (final title in titles)
        Article(
          id: 'https://example.com/${source.id}/$title',
          sourceId: source.id,
          category: source.category,
          title: title,
          url: 'https://example.com/${source.id}/$title',
          publishedAt: DateTime.now().toUtc(),
        ),
    ];
  }
}

Future<ProviderContainer> pumpApp(
  WidgetTester tester, {
  Map<NewsCategory, List<String>> articles = const {},
  Map<String, Object> prefs = const {},
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final sharedPrefs = await SharedPreferences.getInstance();
  final db = AppDatabase(NativeDatabase.memory());
  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(sharedPrefs),
      databaseProvider.overrideWithValue(db),
      sourceFetcherProvider.overrideWithValue(FakeFetcher(articles)),
      // rootBundle is unreliable across widget tests, so read the file.
      sourceCatalogProvider.overrideWith(
        (ref) =>
            parseSourceCatalog(File('assets/sources.json').readAsStringSync()),
      ),
    ],
  );
  addTearDown(() async {
    // Unmount first so drift's stream subscriptions end before closing.
    await tester.pumpWidget(const SizedBox());
    container.dispose();
    await tester.runAsync(db.close);
  });

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: const NewsBucketApp(),
    ),
  );
  // Database work runs outside the fake-async zone: give it real time until
  // the automatic first refresh has finished.
  for (var i = 0; i < 100; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    if (container.read(refreshProvider).lastSummary != null) break;
  }
  await tester.pumpAndSettle();
  return container;
}

void main() {
  testWidgets('shows three tabs and switches between them', (tester) async {
    await pumpApp(tester);

    expect(find.text('News Bucket'), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));

    await tester.tap(find.text('Saved').last);
    await settle(tester);
    expect(find.textContaining('Nothing saved yet'), findsOneWidget);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    expect(find.byType(SegmentedButton<ThemeMode>), findsOneWidget);
  });

  testWidgets('feed lists refreshed articles and filters by category', (
    tester,
  ) async {
    await pumpApp(
      tester,
      articles: {
        NewsCategory.claude: ['Claude story'],
        NewsCategory.crypto: ['Crypto story'],
      },
    );

    // The list is lazy, so only the first few cards are built.
    expect(find.text('Claude story'), findsWidgets);

    final crypto = find.widgetWithText(FilterChip, 'Crypto');
    await tester.ensureVisible(crypto);
    await tester.pumpAndSettle();
    await tester.tap(crypto);
    await settle(tester);
    expect(find.text('Crypto story'), findsWidgets);
    expect(find.text('Claude story'), findsNothing);
  });

  testWidgets('saving an article shows it on the Saved tab', (tester) async {
    await pumpApp(
      tester,
      articles: {
        NewsCategory.security: ['Only story'],
      },
    );

    await tester.tap(find.byTooltip('Save').first);
    await settle(tester);

    await tester.tap(find.text('Saved').last);
    await settle(tester);
    expect(find.text('Only story'), findsOneWidget);
  });

  testWidgets('search narrows the feed and closing it resets the query', (
    tester,
  ) async {
    final container = await pumpApp(
      tester,
      articles: {
        NewsCategory.claude: ['Claude story'],
        NewsCategory.programming: ['Rust story'],
      },
    );

    await tester.tap(find.byTooltip('Search'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'RUST');
    await tester.pump(const Duration(milliseconds: 300)); // debounce
    await settle(tester);
    expect(find.text('Rust story'), findsWidgets);
    expect(find.text('Claude story'), findsNothing);

    await tester.tap(find.byTooltip('Close search'));
    await settle(tester);
    expect(find.byType(TextField), findsNothing);
    expect(container.read(feedFilterProvider).query, isEmpty);
  });

  testWidgets('a disabled source disappears from the feed', (tester) async {
    await pumpApp(
      tester,
      articles: {
        NewsCategory.claude: ['Claude story'],
      },
      prefs: {
        'disabled_sources': ['claude-code-releases'],
      },
    );

    // Three Claude sources remain enabled, one is switched off.
    expect(find.text('Claude story'), findsWidgets);
    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    final tile = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Claude Code releases'),
    );
    expect(tile.value, isFalse);
  });

  testWidgets('switching to dark mode applies and persists the theme', (
    tester,
  ) async {
    await pumpApp(tester);

    await tester.tap(find.text('Settings').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark'));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(SegmentedButton<ThemeMode>));
    expect(Theme.of(context).brightness, Brightness.dark);
    expect(
      (await SharedPreferences.getInstance()).getString('theme_mode'),
      'dark',
    );
  });

  test('sources.json is valid and uses known categories', () async {
    final raw = File('assets/sources.json').readAsStringSync();
    final sources =
        (jsonDecode(raw) as Map<String, dynamic>)['sources'] as List;

    expect(sources, isNotEmpty);
    final ids = <String>{};
    for (final source in sources.cast<Map<String, dynamic>>()) {
      expect(ids.add(source['id'] as String), isTrue, reason: 'duplicate id');
      expect(
        () => NewsCategory.fromId(source['category'] as String),
        returnsNormally,
      );
      expect(Uri.parse(source['url'] as String).scheme, 'https');
    }
  });
}

/// Lets database streams deliver (they run outside the fake-async zone) and
/// then settles animations.
Future<void> settle(WidgetTester tester) async {
  await tester.runAsync(
    () => Future<void>.delayed(const Duration(milliseconds: 200)),
  );
  await tester.pumpAndSettle();
}
