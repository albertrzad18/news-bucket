import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/settings/notification_settings.dart';
import 'core/settings/preferences.dart';
import 'features/feed/article_actions.dart';
import 'features/notifications/background_tasks.dart';
import 'features/notifications/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  if (supportsBackgroundChecks) await _initNotifications(prefs);
  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const NewsBucketApp(),
    ),
  );
}

Future<void> _initNotifications(SharedPreferences prefs) async {
  try {
    await NotificationService.init(
      onTap: (url) {
        if (url != null) openUrl(url);
      },
    );
    await initBackgroundTasks();
    if (NotificationPrefs(prefs).enabled) await scheduleNewsCheck();

    // App was started by tapping a notification about a single article.
    final url = await NotificationService.launchPayload();
    if (url != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => openUrl(url));
    }
  } catch (error) {
    // Notifications are optional; never block the app from starting.
    debugPrint('Notification setup failed: $error');
  }
}
