import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/notification_settings.dart';
import '../../core/settings/preferences.dart';
import '../../core/settings/source_settings.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/utils/time_utils.dart';
import '../../core/widgets/category_marker.dart';
import '../../data/db/app_database.dart';
import '../../data/models/news_category.dart';
import '../../data/models/source_config.dart';
import '../../data/providers.dart';
import '../feed/feed_providers.dart';
import '../notifications/background_tasks.dart';
import '../notifications/notification_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final catalog = ref.watch(sourceCatalogProvider).value ?? const [];
    final disabled = ref.watch(disabledSourcesProvider);
    final notifications = ref.watch(notificationSettingsProvider);
    final states = {
      for (final s in ref.watch(sourceStatesProvider).value ?? const [])
        s.sourceId: s,
    };
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        shape: Border(bottom: BorderSide(color: scheme.outlineVariant)),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 16),
        children: [
          const _SectionLabel('Theme', EdgeInsets.fromLTRB(16, 20, 16, 10)),
          SegmentedButton<ThemeMode>(
            expandedInsets: const EdgeInsets.symmetric(horizontal: 16),
            segments: const [
              ButtonSegment(value: ThemeMode.system, label: Text('System')),
              ButtonSegment(value: ThemeMode.light, label: Text('Light')),
              ButtonSegment(value: ThemeMode.dark, label: Text('Dark')),
            ],
            selected: {themeMode},
            onSelectionChanged: (selection) =>
                ref.read(themeModeProvider.notifier).set(selection.first),
          ),
          if (supportsBackgroundChecks) ...[
            const _SectionLabel(
              'Notifications',
              EdgeInsets.fromLTRB(16, 28, 16, 4),
            ),
            SwitchListTile(
              title: const Text('Notify about new articles'),
              subtitle: const Text(
                'Checks sources marked with a bell about once an hour.',
              ),
              value: notifications.enabled,
              onChanged: (enabled) =>
                  _setNotificationsEnabled(context, ref, enabled),
            ),
            if (notifications.enabled)
              Padding(
                // The button's own 12dp padding puts the icon on the 16dp edge.
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Check now'),
                    onPressed: () => _checkNow(context, ref, catalog),
                  ),
                ),
              ),
          ],
          _SectionLabel(
            'Sources · ${catalog.length}',
            const EdgeInsets.fromLTRB(16, 28, 16, 0),
          ),
          for (final category in NewsCategory.values) ...[
            _CategoryHeader(
              category: category,
              sources: [
                for (final source in catalog)
                  if (source.category == category) source,
              ],
              disabled: disabled,
            ),
            const Divider(),
            for (final source in catalog.where((s) => s.category == category))
              _SourceRow(
                source: source,
                catalog: catalog,
                status: _status(states[source.id]),
                failed: states[source.id]?.lastError != null,
                enabled: !disabled.contains(source.id),
                notificationsOn: notifications.enabled,
                bellOn: notifications.notifiesFor(source),
              ),
          ],
        ],
      ),
    );
  }

  Future<void> _setNotificationsEnabled(
    BuildContext context,
    WidgetRef ref,
    bool enabled,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    if (!enabled) {
      await notifier.setEnabled(false);
      await cancelNewsCheck();
      return;
    }
    if (!await NotificationService.requestPermission()) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Notifications are blocked in Android settings.'),
        ),
      );
      return;
    }
    await notifier.setEnabled(true);
    await scheduleNewsCheck(replace: true);
  }

  Future<void> _checkNow(
    BuildContext context,
    WidgetRef ref,
    List<SourceConfig> catalog,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final fresh = await runNewsCheck(
      repo: ref.read(newsRepositoryProvider),
      catalog: catalog,
      prefs: ref.read(sharedPreferencesProvider),
    );
    messenger.showSnackBar(
      SnackBar(
        content: Text(
          fresh.isEmpty
              ? 'Nothing new since the last check.'
              : '${fresh.length} new articles',
        ),
      ),
    );
  }

  String _status(SourceStateRow? state) {
    if (state == null) return 'Not loaded yet';
    final ok = state.lastSuccessAt;
    final ago = ok == null ? null : timeAgo(ok);
    final updated = switch (ago) {
      null => null,
      'now' => 'updated just now',
      // Older than a month: timeAgo returns a date.
      _ when ago.contains('-') => 'updated on $ago',
      _ => 'updated $ago ago',
    };
    if (state.lastError != null) {
      return updated == null ? 'Failed to load' : 'Failed to load, $updated';
    }
    return '${state.lastItemCount} items, ${updated ?? 'never updated'}';
  }
}

/// Uppercase label above a group of settings.
class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text, this.padding);

  final String text;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(text.toUpperCase(), style: context.nbText.sectionLabel),
    );
  }
}

/// Category name with how many of its sources are switched on.
class _CategoryHeader extends StatelessWidget {
  const _CategoryHeader({
    required this.category,
    required this.sources,
    required this.disabled,
  });

  final NewsCategory category;
  final List<SourceConfig> sources;
  final Set<String> disabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final on = sources.where((s) => !disabled.contains(s.id)).length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Row(
        children: [
          CategoryMarker(category),
          const SizedBox(width: 8),
          Expanded(
            child: Text(category.label, style: theme.textTheme.titleMedium),
          ),
          const SizedBox(width: 8),
          Text(
            '$on of ${sources.length} on',
            style: context.nbText.meta.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Source name and status, with the bell next to the on/off switch.
class _SourceRow extends ConsumerWidget {
  const _SourceRow({
    required this.source,
    required this.catalog,
    required this.status,
    required this.failed,
    required this.enabled,
    required this.notificationsOn,
    required this.bellOn,
  });

  final SourceConfig source;
  final List<SourceConfig> catalog;
  final String status;
  final bool failed;
  final bool enabled;
  final bool notificationsOn;
  final bool bellOn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final read = context.nb.read;
    void toggle() => ref
        .read(disabledSourcesProvider.notifier)
        .setEnabled(source.id, enabled: !enabled);

    final statusStyle = theme.textTheme.bodySmall!.copyWith(
      color: failed
          ? scheme.error
          : enabled
          ? scheme.onSurfaceVariant
          : read,
    );

    return InkWell(
      onTap: toggle,
      child: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: scheme.outlineVariant)),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            source.name,
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: enabled ? scheme.onSurface : read,
                            ),
                          ),
                          Row(
                            children: [
                              if (failed) ...[
                                Icon(
                                  Icons.error_outline,
                                  size: 15,
                                  color: scheme.error,
                                ),
                                const SizedBox(width: 4),
                              ],
                              Flexible(child: Text(status, style: statusStyle)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (supportsBackgroundChecks)
                    IconButton(
                      tooltip: bellOn
                          ? 'Stop notifying'
                          : 'Notify about new articles',
                      iconSize: 22,
                      isSelected: bellOn,
                      color: bellOn ? scheme.primary : scheme.outline,
                      icon: const Icon(Icons.notifications_none),
                      selectedIcon: const Icon(Icons.notifications),
                      onPressed: notificationsOn && enabled
                          ? () => ref
                                .read(notificationSettingsProvider.notifier)
                                .toggleSource(source, catalog)
                          : null,
                    ),
                  Switch(value: enabled, onChanged: (_) => toggle()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
