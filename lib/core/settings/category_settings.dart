import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/news_category.dart';
import 'preferences.dart';

/// Categories the user hid from the feed in Settings. Their sources are not
/// fetched either.
final hiddenCategoriesProvider =
    NotifierProvider<HiddenCategoriesNotifier, Set<NewsCategory>>(
      HiddenCategoriesNotifier.new,
    );

class HiddenCategoriesNotifier extends Notifier<Set<NewsCategory>> {
  static const key = 'hidden_categories';

  /// Also used by the background isolate, which has no Riverpod.
  static Set<NewsCategory> read(SharedPreferences prefs) {
    final ids = (prefs.getStringList(key) ?? const []).toSet();
    return {
      for (final category in NewsCategory.values)
        if (ids.contains(category.id)) category,
    };
  }

  @override
  Set<NewsCategory> build() => read(ref.read(sharedPreferencesProvider));

  void setVisible(NewsCategory category, {required bool visible}) {
    final next = {...state};
    visible ? next.remove(category) : next.add(category);
    // The feed needs at least one category.
    if (next.length == NewsCategory.values.length) return;
    state = next;
    ref.read(sharedPreferencesProvider).setStringList(key, [
      for (final c in next) c.id,
    ]);
  }
}

/// Categories shown on the feed, in their usual order.
final visibleCategoriesProvider = Provider<List<NewsCategory>>((ref) {
  final hidden = ref.watch(hiddenCategoriesProvider);
  return [
    for (final category in NewsCategory.values)
      if (!hidden.contains(category)) category,
  ];
});
