import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:news_bucket/core/settings/preferences.dart';
import 'package:news_bucket/core/settings/source_settings.dart';
import 'package:news_bucket/features/feed/feed_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('switching a source off removes it from the source filter', () async {
    SharedPreferences.setMockInitialValues({});
    final container = ProviderContainer(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          await SharedPreferences.getInstance(),
        ),
      ],
    );
    addTearDown(container.dispose);

    final filter = container.read(feedFilterProvider.notifier)
      ..toggleSource('a')
      ..toggleSource('b');
    container
        .read(disabledSourcesProvider.notifier)
        .setEnabled('a', enabled: false);

    expect(container.read(feedFilterProvider).sourceIds, {'b'});
    filter.toggleSource('b');
    expect(container.read(feedFilterProvider).isActive, isFalse);
  });
}
