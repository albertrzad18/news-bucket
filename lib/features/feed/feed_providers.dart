import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/source_settings.dart';
import '../../data/db/app_database.dart';
import '../../data/models/article.dart';
import '../../data/models/news_category.dart';
import '../../data/models/source_config.dart';
import '../../data/providers.dart';
import '../../data/repositories/news_repository.dart';

/// Sources from the catalog that the user has not switched off.
final enabledSourcesProvider = FutureProvider<List<SourceConfig>>((ref) async {
  final catalog = await ref.watch(sourceCatalogProvider.future);
  final disabled = ref.watch(disabledSourcesProvider);
  return catalog.where((source) => !disabled.contains(source.id)).toList();
});

/// Source id to display name.
final sourceNamesProvider = FutureProvider<Map<String, String>>((ref) async {
  final catalog = await ref.watch(sourceCatalogProvider.future);
  return {for (final source in catalog) source.id: source.name};
});

final sourceStatesProvider = StreamProvider<List<SourceStateRow>>((ref) {
  return ref.watch(newsRepositoryProvider).watchSourceStates();
});

class FeedFilter {
  const FeedFilter({this.categories = const {}, this.sourceIds = const {}});

  /// Empty means "all".
  final Set<NewsCategory> categories;
  final Set<String> sourceIds;

  bool get isActive => categories.isNotEmpty || sourceIds.isNotEmpty;
}

final feedFilterProvider = NotifierProvider<FeedFilterNotifier, FeedFilter>(
  FeedFilterNotifier.new,
);

class FeedFilterNotifier extends Notifier<FeedFilter> {
  @override
  FeedFilter build() => const FeedFilter();

  void toggleCategory(NewsCategory category) {
    final next = {...state.categories};
    if (!next.remove(category)) next.add(category);
    state = FeedFilter(categories: next, sourceIds: state.sourceIds);
  }

  void toggleSource(String sourceId) {
    final next = {...state.sourceIds};
    if (!next.remove(sourceId)) next.add(sourceId);
    state = FeedFilter(categories: state.categories, sourceIds: next);
  }

  void clearSources() => state = FeedFilter(categories: state.categories);

  void clear() => state = const FeedFilter();
}

final feedArticlesProvider = StreamProvider<List<Article>>((ref) {
  final filter = ref.watch(feedFilterProvider);
  final disabled = ref.watch(disabledSourcesProvider);
  return ref
      .watch(newsRepositoryProvider)
      .watchArticles(
        categories: filter.categories,
        sourceIds: filter.sourceIds,
        excludedSourceIds: disabled,
      );
});

final savedArticlesProvider = StreamProvider<List<Article>>((ref) {
  return ref.watch(newsRepositoryProvider).watchArticles(savedOnly: true);
});

class RefreshState {
  const RefreshState({this.isRefreshing = false, this.lastSummary});

  final bool isRefreshing;
  final RefreshSummary? lastSummary;
}

final refreshProvider = NotifierProvider<RefreshNotifier, RefreshState>(
  RefreshNotifier.new,
);

class RefreshNotifier extends Notifier<RefreshState> {
  static const staleAfter = Duration(minutes: 15);

  @override
  RefreshState build() {
    Future.microtask(_refreshIfStale);
    return const RefreshState();
  }

  Future<void> _refreshIfStale() async {
    final last = await ref.read(newsRepositoryProvider).lastRefreshAt();
    if (last == null || DateTime.now().difference(last) > staleAfter) {
      await refresh();
    }
  }

  /// Refreshes all enabled sources. Returns null if a refresh is already
  /// running.
  Future<RefreshSummary?> refresh() async {
    if (state.isRefreshing) return null;
    state = RefreshState(isRefreshing: true, lastSummary: state.lastSummary);
    RefreshSummary? summary;
    try {
      final sources = await ref.read(enabledSourcesProvider.future);
      summary = await ref.read(newsRepositoryProvider).refresh(sources);
    } finally {
      state = RefreshState(lastSummary: summary ?? state.lastSummary);
    }
    return summary;
  }
}
