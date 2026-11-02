import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/core/settings/category_settings.dart';
import 'package:news_bucket/core/settings/preferences.dart';
import 'package:news_bucket/data/models/news_category.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> container(Map<String, Object> prefs) async {
    SharedPreferences.setMockInitialValues(prefs);
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('reads stored categories and ignores unknown ids', () async {
    final c = await container({
      'hidden_categories': ['crypto', 'gone'],
    });
    expect(c.read(hiddenCategoriesProvider), {NewsCategory.crypto});
    expect(c.read(visibleCategoriesProvider), [
      for (final category in NewsCategory.values)
        if (category != NewsCategory.crypto) category,
    ]);
  });

  test('hiding and showing persists', () async {
    final c = await container({});
    final notifier = c.read(hiddenCategoriesProvider.notifier)
      ..setVisible(NewsCategory.gaming, visible: false);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('hidden_categories'), ['gaming']);

    notifier.setVisible(NewsCategory.gaming, visible: true);
    expect(c.read(hiddenCategoriesProvider), isEmpty);
    expect(prefs.getStringList('hidden_categories'), isEmpty);
  });

  test('the last visible category stays visible', () async {
    final c = await container({});
    final notifier = c.read(hiddenCategoriesProvider.notifier);
    for (final category in NewsCategory.values) {
      notifier.setVisible(category, visible: false);
    }
    expect(c.read(visibleCategoriesProvider), [NewsCategory.values.last]);
  });
}
