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

/// How far back the feed reaches, by publication date.
enum FeedPeriod {
  any('Any time', null),
  day('Last 24 hours', Duration(days: 1)),
  threeDays('Last 3 days', Duration(days: 3)),
  week('Last week', Duration(days: 7));

  const FeedPeriod(this.label, this.duration);

  final String label;
  final Duration? duration;

  /// Oldest publication time that passes, or null for [any].
  DateTime? cutoff(DateTime now) =>
      duration == null ? null : now.toUtc().subtract(duration!);
}

class FeedFilter {
  const FeedFilter({
    this.categories = const {},
    this.sourceIds = const {},
    this.period = FeedPeriod.any,
    this.query = '',
  });

  /// Empty means "all".
  final Set<NewsCategory> categories;
  final Set<String> sourceIds;
  final FeedPeriod period;

  /// Text typed into the search field; empty means no search.
  final String query;

  bool get isActive =>
      categories.isNotEmpty ||
      sourceIds.isNotEmpty ||
      period != FeedPeriod.any ||
      query.isNotEmpty;

  /// Filters set in the filter sheet, for the badge on its button.
  int get sheetFilterCount =>
      sourceIds.length + (period == FeedPeriod.any ? 0 : 1);

  FeedFilter copyWith({
    Set<NewsCategory>? categories,
    Set<String>? sourceIds,
    FeedPeriod? period,
    String? query,
  }) {
    return FeedFilter(
      categories: categories ?? this.categories,
      sourceIds: sourceIds ?? this.sourceIds,
      period: period ?? this.period,
      query: query ?? this.query,
    );
  }
}

final feedFilterProvider = NotifierProvider<FeedFilterNotifier, FeedFilter>(
  FeedFilterNotifier.new,
);

class FeedFilterNotifier extends Notifier<FeedFilter> {
  @override
  FeedFilter build() {
    // A source switched off in Settings disappears from the filter sheet, so
    // drop it from the filter too or the feed would stay stuck on it.
    ref.listen(disabledSourcesProvider, (_, disabled) {
      if (state.sourceIds.any(disabled.contains)) {
        state = state.copyWith(sourceIds: state.sourceIds.difference(disabled));
      }
    });
    return const FeedFilter();
  }

  void toggleCategory(NewsCategory category) {
    final next = {...state.categories};
    if (!next.remove(category)) next.add(category);
    state = state.copyWith(categories: next);
  }

  void toggleSource(String sourceId) {
    final next = {...state.sourceIds};
    if (!next.remove(sourceId)) next.add(sourceId);
    state = state.copyWith(sourceIds: next);
  }

  void setPeriod(FeedPeriod period) => state = state.copyWith(period: period);

  void setQuery(String query) => state = state.copyWith(query: query.trim());

  /// Resets what the filter sheet controls: sources and period.
  void clearSheetFilters() =>
      state = FeedFilter(categories: state.categories, query: state.query);

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
        publishedAfter: filter.period.cutoff(DateTime.now()),
        query: filter.query,
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
