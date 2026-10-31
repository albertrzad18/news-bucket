import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                  ? '1 source failed to load'
                  : '$failures sources failed to load',
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
        showDragHandle: true,
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
            SizedBox(
              height: 56,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  for (final category in NewsCategory.values)
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 10,
                      ),
                      child: FilterChip(
                        label: Text(category.label),
                        selected: filter.categories.contains(category),
                        onSelected: (_) => _filter.toggleCategory(category),
                      ),
                    ),
                ],
              ),
            ),
            if (isRefreshing) const LinearProgressIndicator(minHeight: 2),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _refresh,
                child: articles.when(
                  data: (items) => items.isEmpty
                      ? _EmptyState(
                          message: isRefreshing
                              ? 'Loading news…'
                              : filter.query.isNotEmpty
                              ? 'No articles match "${filter.query}".'
                              : filter.isActive
                              ? 'Nothing matches the current filters.'
                              : 'No articles yet. Pull down to refresh.',
                          onClear: filter.isActive && !isRefreshing
                              ? _filter.clear
                              : null,
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          keyboardDismissBehavior:
                              ScrollViewKeyboardDismissBehavior.onDrag,
                          itemCount: items.length,
                          itemBuilder: (_, i) => ArticleTile(
                            key: ValueKey(items[i].id),
                            article: items[i],
                          ),
                        ),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => _EmptyState(message: 'Error: $error'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Scrollable so pull-to-refresh also works on an empty list.
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.message, this.onClear});

  final String message;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 120),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(message, textAlign: TextAlign.center),
          ),
        ),
        if (onClear != null)
          Center(
            child: TextButton(
              onPressed: onClear,
              child: const Text('Clear filters'),
            ),
          ),
      ],
    );
  }
}
