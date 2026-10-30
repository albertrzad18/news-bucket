import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/source_settings.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/utils/time_utils.dart';
import '../../data/db/app_database.dart';
import '../../data/models/news_category.dart';
import '../../data/providers.dart';
import '../feed/feed_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final catalog = ref.watch(sourceCatalogProvider).value ?? const [];
    final disabled = ref.watch(disabledSourcesProvider);
    final states = {
      for (final s in ref.watch(sourceStatesProvider).value ?? const [])
        s.sourceId: s,
    };
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Theme', style: textTheme.titleMedium),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).set(selection.first),
            ),
          ),
          const SizedBox(height: 16),
          for (final category in NewsCategory.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(category.label, style: textTheme.titleMedium),
            ),
            for (final source in catalog.where((s) => s.category == category))
              SwitchListTile(
                title: Text(source.name),
                subtitle: Text(_status(states[source.id])),
                value: !disabled.contains(source.id),
                onChanged: (enabled) => ref
                    .read(disabledSourcesProvider.notifier)
                    .setEnabled(source.id, enabled: enabled),
              ),
          ],
        ],
      ),
    );
  }

  String _status(SourceStateRow? state) {
    if (state == null) return 'Not loaded yet';
    final ok = state.lastSuccessAt;
    final updated = ok == null ? null : 'updated ${timeAgo(ok)} ago';
    if (state.lastError != null) {
      return updated == null
          ? 'Failed to load'
          : 'Last attempt failed, $updated';
    }
    return '${state.lastItemCount} items, ${updated ?? 'never updated'}';
  }
}
