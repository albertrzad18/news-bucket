import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'preferences.dart';

/// Ids of sources the user switched off in Settings.
final disabledSourcesProvider =
    NotifierProvider<DisabledSourcesNotifier, Set<String>>(
      DisabledSourcesNotifier.new,
    );

class DisabledSourcesNotifier extends Notifier<Set<String>> {
  static const _key = 'disabled_sources';

  @override
  Set<String> build() =>
      (ref.read(sharedPreferencesProvider).getStringList(_key) ?? const [])
          .toSet();

  void setEnabled(String sourceId, {required bool enabled}) {
    final next = {...state};
    enabled ? next.remove(sourceId) : next.add(sourceId);
    state = next;
    ref.read(sharedPreferencesProvider).setStringList(_key, next.toList());
  }
}
