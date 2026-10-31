import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/settings/notification_settings.dart';
import '../../core/settings/preferences.dart';
import '../../core/settings/source_settings.dart';
import '../../core/theme/theme_mode_provider.dart';
import '../../core/utils/time_utils.dart';
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
          if (supportsBackgroundChecks) ...[
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text('Notifications', style: textTheme.titleMedium),
            ),
            SwitchListTile(
              title: const Text('Notify about new articles'),
              subtitle: const Text(
                'Checks the sources marked with a bell about once an hour. '
                'Android may delay checks to save battery.',
              ),
              value: notifications.enabled,
              onChanged: (enabled) =>
                  _setNotificationsEnabled(context, ref, enabled),
            ),
            if (notifications.enabled)
              ListTile(
                leading: const Icon(Icons.notifications_active_outlined),
                title: const Text('Check now'),
                onTap: () => _checkNow(context, ref, catalog),
              ),
          ],
          const SizedBox(height: 16),
          for (final category in NewsCategory.values) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
              child: Text(category.label, style: textTheme.titleMedium),
            ),
            for (final source in catalog.where((s) => s.category == category))
              SwitchListTile(
                secondary: supportsBackgroundChecks
                    ? _BellButton(
                        source: source,
                        catalog: catalog,
                        active:
                            notifications.enabled &&
                            !disabled.contains(source.id),
                        on: notifications.notifiesFor(source),
                      )
                    : null,
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
      return updated == null
          ? 'Failed to load'
          : 'Last attempt failed, $updated';
    }
    return '${state.lastItemCount} items, ${updated ?? 'never updated'}';
  }
}

class _BellButton extends ConsumerWidget {
  const _BellButton({
    required this.source,
    required this.catalog,
    required this.active,
    required this.on,
  });

  final SourceConfig source;
  final List<SourceConfig> catalog;
  final bool active;
  final bool on;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      tooltip: on ? 'Stop notifying' : 'Notify about new articles',
      isSelected: on,
      icon: const Icon(Icons.notifications_none),
      selectedIcon: const Icon(Icons.notifications_active),
      onPressed: active
          ? () => ref
                .read(notificationSettingsProvider.notifier)
                .toggleSource(source, catalog)
          : null,
    );
  }
}
