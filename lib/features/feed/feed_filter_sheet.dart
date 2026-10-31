import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_providers.dart';

/// Bottom sheet to narrow the feed by publication date and source.
class FeedFilterSheet extends ConsumerWidget {
  const FeedFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final notifier = ref.read(feedFilterProvider.notifier);
    final sources = ref.watch(enabledSourcesProvider).value ?? const [];
    final visible = sources
        .where(
          (s) =>
              filter.categories.isEmpty ||
              filter.categories.contains(s.category),
        )
        .toList();
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Filters', style: textTheme.titleLarge)),
                TextButton(
                  onPressed: filter.sheetFilterCount == 0
                      ? null
                      : notifier.clearSheetFilters,
                  child: const Text('Clear'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Published', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (final period in FeedPeriod.values)
                  ChoiceChip(
                    label: Text(period.label),
                    selected: filter.period == period,
                    onSelected: (_) => notifier.setPeriod(period),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text('Sources', style: textTheme.titleSmall),
            const SizedBox(height: 8),
            Flexible(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final source in visible)
                      FilterChip(
                        label: Text(source.name),
                        selected: filter.sourceIds.contains(source.id),
                        onSelected: (_) => notifier.toggleSource(source.id),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
