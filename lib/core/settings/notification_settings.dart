import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../data/models/source_config.dart';
import 'preferences.dart';

/// Notification preferences stored in shared_preferences. Plain class so the
/// background isolate can use it without Riverpod.
class NotificationPrefs {
  const NotificationPrefs(this._prefs);

  static const enabledKey = 'notifications_enabled';
  static const sourcesKey = 'notify_sources';

  final SharedPreferences _prefs;

  bool get enabled => _prefs.getBool(enabledKey) ?? false;

  /// Explicit choice, or null when the user never changed it (then the
  /// `notify` flags from sources.json apply).
  Set<String>? get explicitSourceIds =>
      _prefs.getStringList(sourcesKey)?.toSet();

  Set<String> sourceIds(List<SourceConfig> catalog) =>
      explicitSourceIds ??
      {
        for (final source in catalog)
          if (source.notify) source.id,
      };

  Future<void> setEnabled(bool enabled) => _prefs.setBool(enabledKey, enabled);

  Future<void> setSourceIds(Set<String> ids) =>
      _prefs.setStringList(sourcesKey, ids.toList());
}

class NotificationSettings {
  const NotificationSettings({required this.enabled, this.explicitSourceIds});

  final bool enabled;
  final Set<String>? explicitSourceIds;

  bool notifiesFor(SourceConfig source) =>
      explicitSourceIds?.contains(source.id) ?? source.notify;
}

final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
      NotificationSettingsNotifier.new,
    );

class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  NotificationPrefs get _store =>
      NotificationPrefs(ref.read(sharedPreferencesProvider));

  @override
  NotificationSettings build() => NotificationSettings(
    enabled: _store.enabled,
    explicitSourceIds: _store.explicitSourceIds,
  );

  Future<void> setEnabled(bool enabled) async {
    state = NotificationSettings(
      enabled: enabled,
      explicitSourceIds: state.explicitSourceIds,
    );
    await _store.setEnabled(enabled);
  }

  Future<void> toggleSource(
    SourceConfig source,
    List<SourceConfig> catalog,
  ) async {
    final ids = _store.sourceIds(catalog);
    if (!ids.remove(source.id)) ids.add(source.id);
    state = NotificationSettings(
      enabled: state.enabled,
      explicitSourceIds: ids,
    );
    await _store.setSourceIds(ids);
  }
}
