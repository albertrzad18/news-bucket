import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/category_marker.dart';
import '../../data/models/news_category.dart';
import 'feed_providers.dart';

/// Bottom sheet to narrow the feed by publication date and source.
class FeedFilterSheet extends ConsumerWidget {
  const FeedFilterSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(feedFilterProvider);
    final notifier = ref.read(feedFilterProvider.notifier);
    final sources = ref.watch(enabledSourcesProvider).value ?? const [];
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final muted = textTheme.bodySmall!.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    final groups = [
      for (final category in NewsCategory.values)
        if (filter.categories.isEmpty || filter.categories.contains(category))
          (category, sources.where((s) => s.category == category).toList()),
    ].where((group) => group.$2.isNotEmpty);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text('Filters', style: textTheme.headlineMedium),
                  ),
                  TextButton(
                    onPressed: filter.sheetFilterCount == 0
                        ? null
                        : notifier.clearSheetFilters,
                    child: const Text('Clear'),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _heading(context, 'Published'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final period in FeedPeriod.values)
                            ChoiceChip(
                              label: Text(period.label),
                              selected: filter.period == period,
                              onSelected: (_) => notifier.setPeriod(period),
                            ),
                        ],
                      ),
                    ),
                    _heading(context, 'Sources'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Text(subtitle(filter), style: muted),
                    ),
                    for (final (category, items) in groups) ...[
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                        child: Row(
                          children: [
                            CategoryMarker(category),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                category.label.toUpperCase(),
                                style: context.nbText.sectionLabel,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final source in items)
                              FilterChip(
                                label: Text(source.name),
                                selected: filter.sourceIds.contains(source.id),
                                onSelected: (_) =>
                                    notifier.toggleSource(source.id),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _heading(BuildContext context, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
    child: Text(text, style: Theme.of(context).textTheme.titleMedium),
  );

  /// "Showing sources in Security and Crypto · 2 selected".
  @visibleForTesting
  static String subtitle(FeedFilter filter) {
    final labels = [
      for (final category in NewsCategory.values)
        if (filter.categories.contains(category)) category.label,
    ];
    final scope = switch (labels.length) {
      0 => 'All categories',
      1 => 'Showing sources in ${labels.single}',
      _ =>
        'Showing sources in ${labels.sublist(0, labels.length - 1).join(', ')}'
            ' and ${labels.last}',
    };
    final selected = filter.sourceIds.length;
    return selected == 0 ? scope : '$scope · $selected selected';
  }
}
