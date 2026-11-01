import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/news_category.dart';
import 'article_tile.dart';
import 'feed_filter_sheet.dart';
import 'feed_providers.dart';

/// Feed tabs in order: All (null), then every category.
const _tabs = <NewsCategory?>[null, ...NewsCategory.values];

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen>
    with SingleTickerProviderStateMixin {
  late final _tabController = TabController(length: _tabs.length, vsync: this)
    ..addListener(_onTabChanged);
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _searching = false;

  NewsCategory? get _category => _tabs[_tabController.index];

  @override
  void dispose() {
    _tabController.dispose();
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Rebuilds for the tab colour and the filter badge of the new tab.
  void _onTabChanged() {
    if (mounted) setState(() {});
  }

  FeedFilterNotifier get _filter => ref.read(feedFilterProvider.notifier);

  /// Waits for a pause in typing so the database isn't queried per key.
  void _onSearchChanged(String text) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 300),
      () => _filter.setQuery(text),
    );
  }

  void _closeSearch() {
    _searchDebounce?.cancel();
    _searchController.clear();
    _filter.setQuery('');
    setState(() => _searching = false);
  }

  Future<void> _refresh() async {
    final messenger = ScaffoldMessenger.of(context);
    final summary = await ref.read(refreshProvider.notifier).refresh();
    final failures = summary?.failures.length ?? 0;
    if (failures > 0) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              failures == 1
                  ? '1 source failed to load. Cached articles are still shown.'
                  : '$failures sources failed to load. '
                        'Cached articles are still shown.',
            ),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(feedFilterProvider);
    final isRefreshing = ref.watch(refreshProvider).isRefreshing;
    final category = _category;

    // "Clear filters" also resets the search; keep the field in sync.
    ref.listen(feedFilterProvider, (previous, next) {
      if (previous?.query.isNotEmpty == true && next.query.isEmpty) {
        _searchController.clear();
      }
    });

    final sheetCount =
        filter.sourcesIn(ref.watch(tabSourceIdsProvider(category))).length +
        (filter.period == FeedPeriod.any ? 0 : 1);
    final filterButton = IconButton(
      tooltip: 'Filters',
      icon: Badge(
        isLabelVisible: sheetCount > 0,
        label: Text('$sheetCount'),
        child: const Icon(Icons.tune),
      ),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        builder: (_) => FeedFilterSheet(category: category),
      ),
    );

    final s = Theme.of(context).colorScheme;
    final tabColor = category == null
        ? s.onSurface
        : context.nb.category(category.id);
    final tabBar = TabBar(
      controller: _tabController,
      isScrollable: true,
      tabAlignment: TabAlignment.start,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      labelColor: tabColor,
      unselectedLabelColor: s.onSurfaceVariant,
      labelStyle: Theme.of(context).textTheme.labelLarge!
          .withWeight(FontWeight.w700),
      unselectedLabelStyle: Theme.of(context).textTheme.labelLarge,
      indicatorColor: tabColor,
      indicatorSize: TabBarIndicatorSize.label,
      // The 2dp slot below draws the divider and the refresh progress.
      dividerHeight: 0,
      tabs: [
        for (final tab in _tabs) Tab(text: tab?.label ?? 'All', height: 40),
      ],
    );

    return PopScope(
      // Back closes the search field before it leaves the app.
      canPop: !_searching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _closeSearch();
      },
      child: Scaffold(
        appBar: _searching
            ? AppBar(
                leading: IconButton(
                  tooltip: 'Close search',
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _closeSearch,
                ),
                title: TextField(
                  controller: _searchController,
                  autofocus: true,
                  textInputAction: TextInputAction.search,
                  decoration: const InputDecoration(
                    hintText: 'Search articles',
                    border: InputBorder.none,
                  ),
                  onChanged: _onSearchChanged,
                  onSubmitted: (text) {
                    _searchDebounce?.cancel();
                    _filter.setQuery(text);
                  },
                ),
                actions: [filterButton],
                bottom: tabBar,
              )
            : AppBar(
                title: const Text('News Bucket'),
                actions: [
                  IconButton(
                    tooltip: 'Search',
                    icon: const Icon(Icons.search),
                    onPressed: () => setState(() => _searching = true),
                  ),
                  filterButton,
                ],
                bottom: tabBar,
              ),
        body: Column(
          children: [
            // Fixed slot so the list doesn't jump when a refresh starts.
            SizedBox(
              height: 2,
              child: isRefreshing
                  ? const LinearProgressIndicator()
                  : const Align(
                      alignment: Alignment.bottomCenter,
                      child: Divider(),
                    ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  for (final tab in _tabs)
                    _FeedTab(category: tab, onRefresh: _refresh),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The article list of one category tab, or of all categories for null.
class _FeedTab extends ConsumerStatefulWidget {
  const _FeedTab({required this.category, required this.onRefresh});

  final NewsCategory? category;
  final Future<void> Function() onRefresh;

  @override
  ConsumerState<_FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<_FeedTab>
    with AutomaticKeepAliveClientMixin {
  // Keeps the scroll position when swiping to another tab and back.
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final articles = ref.watch(feedArticlesProvider(widget.category));
    return RefreshIndicator(
      onRefresh: widget.onRefresh,
      child: articles.when(
        data: (items) => items.isEmpty
            ? _empty()
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                itemCount: items.length,
                itemBuilder: (_, i) =>
                    ArticleTile(key: ValueKey(items[i].id), article: items[i]),
              ),
        loading: () => const EmptyState(title: 'Loading news…'),
        error: (error, _) =>
            EmptyState(title: "Couldn't load articles.", body: '$error'),
      ),
    );
  }

  Widget _empty() {
    final filter = ref.watch(feedFilterProvider);
    final sources = ref.watch(tabSourceIdsProvider(widget.category));
    final filtered =
        filter.query.isNotEmpty ||
        filter.period != FeedPeriod.any ||
        filter.sourcesIn(sources).isNotEmpty;

    if (ref.watch(refreshProvider).isRefreshing) {
      return const EmptyState(title: 'Loading news…');
    }
    if (!filtered) {
      return EmptyState(
        title: sources.isEmpty && widget.category != null
            ? 'All ${widget.category!.label} sources are off.'
            : 'No articles yet.',
        body: sources.isEmpty && widget.category != null
            ? 'Turn some on in Settings.'
            : 'Pull down to refresh.',
      );
    }
    return EmptyState(
      title: filter.query.isNotEmpty
          ? 'No articles match "${filter.query}".'
          : 'Nothing matches the current filters.',
      action: TextButton(
        onPressed: ref.read(feedFilterProvider.notifier).clear,
        child: const Text('Clear filters'),
      ),
    );
  }
}
