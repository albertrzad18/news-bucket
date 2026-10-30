import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/news_category.dart';
import 'article_tile.dart';
import 'feed_providers.dart';
import 'source_filter_sheet.dart';

class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  Future<void> _refresh(BuildContext context, WidgetRef ref) async {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final articles = ref.watch(feedArticlesProvider);
    final filter = ref.watch(feedFilterProvider);
    final isRefreshing = ref.watch(refreshProvider).isRefreshing;

    return Scaffold(
      appBar: AppBar(
        title: const Text('News Bucket'),
        actions: [
          IconButton(
            tooltip: 'Filter sources',
            icon: Badge(
              isLabelVisible: filter.sourceIds.isNotEmpty,
              label: Text('${filter.sourceIds.length}'),
              child: const Icon(Icons.tune),
            ),
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              isScrollControlled: true,
              builder: (_) => const SourceFilterSheet(),
            ),
          ),
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
                      onSelected: (_) => ref
                          .read(feedFilterProvider.notifier)
                          .toggleCategory(category),
                    ),
                  ),
              ],
            ),
          ),
          if (isRefreshing) const LinearProgressIndicator(minHeight: 2),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => _refresh(context, ref),
              child: articles.when(
                data: (items) => items.isEmpty
                    ? _EmptyState(
                        message: isRefreshing
                            ? 'Loading news…'
                            : filter.isActive
                            ? 'Nothing matches the current filters.'
                            : 'No articles yet. Pull down to refresh.',
                        onClear: filter.isActive && !isRefreshing
                            ? ref.read(feedFilterProvider.notifier).clear
                            : null,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(bottom: 16),
                        itemCount: items.length,
                        itemBuilder: (_, i) => ArticleTile(
                          key: ValueKey(items[i].id),
                          article: items[i],
                        ),
                      ),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, _) => _EmptyState(message: 'Error: $error'),
              ),
            ),
          ),
        ],
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
        Center(child: Text(message)),
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
