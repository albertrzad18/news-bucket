import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'feed_providers.dart';

/// Bottom sheet to narrow the feed to specific sources.
class SourceFilterSheet extends ConsumerWidget {
  const SourceFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final sources = ref.watch(enabledSourcesProvider).value ?? const [];
    final visible = sources
        .where(
          (s) =>
              filter.categories.isEmpty ||
              filter.categories.contains(s.category),
        )
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Sources',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                TextButton(
                  onPressed: filter.sourceIds.isEmpty
                      ? null
                      : ref.read(feedFilterProvider.notifier).clearSources,
                  child: const Text('Clear'),
                ),
              ],
            ),
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
                        onSelected: (_) => ref
                            .read(feedFilterProvider.notifier)
                            .toggleSource(source.id),
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
