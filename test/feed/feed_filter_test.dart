import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/core/settings/preferences.dart';
import 'package:news_bucket/core/settings/source_settings.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:news_bucket/features/feed/feed_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('switching a source off removes it from the source filter', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final filter = container.read(feedFilterProvider.notifier)
      ..toggleSource('a')
      ..toggleSource('b');
    container
        .read(disabledSourcesProvider.notifier)
        .setEnabled('a', enabled: false);

    expect(container.read(feedFilterProvider).sourceIds, {'b'});
    filter.toggleSource('b');
    expect(container.read(feedFilterProvider).isActive, isFalse);
  });

  test('the sheet clears sources and period but keeps category and search', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final filter = container.read(feedFilterProvider.notifier)
      ..toggleCategory(NewsCategory.ai)
      ..toggleSource('a')
      ..setPeriod(FeedPeriod.week)
      ..setQuery('  claude ');

    expect(container.read(feedFilterProvider).sheetFilterCount, 2);
    expect(container.read(feedFilterProvider).query, 'claude');

    filter.clearSheetFilters();
    final state = container.read(feedFilterProvider);
    expect(state.sheetFilterCount, 0);
    expect(state.categories, {NewsCategory.ai});
    expect(state.query, 'claude');
  });

  test('period cutoff is relative to now', () {
    final now = DateTime.utc(2026, 10, 31, 12);
    expect(FeedPeriod.any.cutoff(now), isNull);
    expect(FeedPeriod.day.cutoff(now), DateTime.utc(2026, 10, 30, 12));
    expect(FeedPeriod.week.cutoff(now), DateTime.utc(2026, 10, 24, 12));
  });
}
