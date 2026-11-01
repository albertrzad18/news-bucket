import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/category_marker.dart';
import '../../data/models/news_category.dart';
import 'feed_providers.dart';

/// Bottom sheet to narrow the feed by publication date and source. Lists the
/// sources of [category], the open feed tab, or all of them for null (All).
class FeedFilterSheet extends ConsumerWidget {
  const FeedFilterSheet({this.category, super.key});

  final NewsCategory? category;

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
        if (this.category == null || this.category == category)
          (category, sources.where((s) => s.category == category).toList()),
    ].where((group) => group.$2.isNotEmpty);
    final selected = filter
        .sourcesIn(ref.watch(tabSourceIdsProvider(category)))
        .length;
    final active = selected + (filter.period == FeedPeriod.any ? 0 : 1);

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
                    onPressed: active == 0 ? null : notifier.clearSheetFilters,
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
                        runSpacing: 0, // chips are already padded to 48dp
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
                      child: Text(subtitle(category, selected), style: muted),
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
                          runSpacing: 0, // chips are already padded to 48dp
                          children: [
                            for (final source in items)
                              FilterChip(
                                // Chips default to one faded line; long names
                                // at large font sizes wrap instead.
                                label: Text(
                                  source.name,
                                  maxLines: 2,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
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

  /// "Sources in Crypto · 2 selected".
  @visibleForTesting
  static String subtitle(NewsCategory? category, int selected) {
    final scope = category == null
        ? 'All categories'
        : 'Sources in ${category.label}';
    return selected == 0 ? scope : '$scope · $selected selected';
  }
}
