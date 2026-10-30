import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/network/http_client.dart';
import '../../core/settings/notification_settings.dart';
import '../../core/settings/source_settings.dart';
import '../../data/db/app_database.dart';
import '../../data/models/article.dart';
import '../../data/models/source_config.dart';
import '../../data/repositories/news_repository.dart';
import '../../data/sources/source_catalog.dart';
import '../../data/sources/source_fetcher.dart';
import 'news_check.dart';
import 'notification_service.dart';

const _taskName = 'newsCheck';
const _uniqueName = 'news-bucket-periodic-check';

/// Background work runs only on Android in this app.
bool get supportsBackgroundChecks =>
    !kIsWeb && defaultTargetPlatform == TargetPlatform.android;

Future<void> initBackgroundTasks() =>
    Workmanager().initialize(callbackDispatcher);

/// Schedules the hourly check. [replace] re-applies changed settings; on
/// app start we keep the existing schedule.
Future<void> scheduleNewsCheck({bool replace = false}) {
  return Workmanager().registerPeriodicTask(
    _uniqueName,
    _taskName,
    frequency: const Duration(hours: 1),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: replace
        ? ExistingPeriodicWorkPolicy.update
        : ExistingPeriodicWorkPolicy.keep,
  );
}

Future<void> cancelNewsCheck() => Workmanager().cancelByUniqueName(_uniqueName);

/// Runs one check with the given repository and shows a notification when
/// something new turned up. Returns the articles that were announced.
Future<List<Article>> runNewsCheck({
  required NewsRepository repo,
  required List<SourceConfig> catalog,
  required SharedPreferences prefs,
}) async {
  final sources = notificationSources(
    catalog,
    notifyIds: NotificationPrefs(prefs).sourceIds(catalog),
    disabledIds: (prefs.getStringList(DisabledSourcesNotifier.key) ?? const [])
        .toSet(),
  );
  final fresh = await checkForNews(repo, sources);
  if (fresh.isNotEmpty) {
    await NotificationService.show(
      buildNotificationContent(fresh, {for (final s in catalog) s.id: s.name}),
    );
  }
  return fresh;
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, _) async {
    if (task != _taskName) return true;

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload(); // pick up changes made in the app's isolate
    if (!NotificationPrefs(prefs).enabled) return true;

    final db = AppDatabase();
    final dio = createHttpClient();
    try {
      await NotificationService.init();
      await runNewsCheck(
        repo: NewsRepository(db, SourceFetcher(dio)),
        catalog: await loadSourceCatalog(),
        prefs: prefs,
      );
      return true;
    } catch (error, stack) {
      debugPrint('Background news check failed: $error\n$stack');
      return false; // let WorkManager retry with backoff
    } finally {
      dio.close();
      await db.close();
    }
  });
}
