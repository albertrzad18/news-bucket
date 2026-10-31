import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/category_marker.dart';
import '../../core/widgets/empty_state.dart';
import '../../data/models/news_category.dart';
import 'article_tile.dart';
import 'feed_filter_sheet.dart';
import 'feed_providers.dart';

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  bool _searching = false;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
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
    final articles = ref.watch(feedArticlesProvider);
    final filter = ref.watch(feedFilterProvider);
    final isRefreshing = ref.watch(refreshProvider).isRefreshing;

    // "Clear filters" also resets the search; keep the field in sync.
    ref.listen(feedFilterProvider, (previous, next) {
      if (previous?.query.isNotEmpty == true && next.query.isEmpty) {
        _searchController.clear();
      }
    });

    final filterButton = IconButton(
      tooltip: 'Filters',
      icon: Badge(
        isLabelVisible: filter.sheetFilterCount > 0,
        label: Text('${filter.sheetFilterCount}'),
        child: const Icon(Icons.tune),
      ),
      onPressed: () => showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        builder: (_) => const FeedFilterSheet(),
      ),
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
              ),
        body: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
              child: Row(
                spacing: 8,
                children: [
                  for (final category in NewsCategory.values)
                    _CategoryChip(
                      category: category,
                      selected: filter.categories.contains(category),
                      onSelected: () => _filter.toggleCategory(category),
                    ),
                ],
              ),
            ),
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
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: articles.when(
                  data: (items) => items.isEmpty
                      ? _emptyFeed(filter, isRefreshing)
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 16),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: items.length,
                          itemBuilder: (_, i) => ArticleTile(
                            key: ValueKey(items[i].id),
                            article: items[i],
                          ),
                        ),
                  loading: () => const EmptyState(title: 'Loading news…'),
                  error: (error, _) => EmptyState(
                    title: "Couldn't load articles.",
                    body: '$error',
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emptyFeed(FeedFilter filter, bool isRefreshing) {
    if (isRefreshing) return const EmptyState(title: 'Loading news…');
    if (!filter.isActive) {
      return const EmptyState(
        title: 'No articles yet.',
        body: 'Pull down to refresh.',
      );
    }
    return EmptyState(
      title: filter.query.isNotEmpty
          ? 'No articles match "${filter.query}".'
          : 'Nothing matches the current filters.',
      action: TextButton(
        onPressed: _filter.clear,
        child: const Text('Clear filters'),
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.category,
    required this.selected,
    required this.onSelected,
  });

  final NewsCategory category;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      // Without an avatar the checkmark takes its place when selected;
      // with one, the chip would paint the check on top of the marker.
      avatar: selected ? null : Center(child: CategoryMarker(category)),
      label: Text(category.label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
