import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import 'news_check.dart';

/// Thin wrapper around flutter_local_notifications (Android only).
abstract final class NotificationService {
  static final _plugin = FlutterLocalNotificationsPlugin();

  static const _channel = AndroidNotificationDetails(
    'new_articles',
    'New articles',
    channelDescription: 'New articles from the sources you follow',
  );

  // One summary notification that is replaced on every check.
  static const _notificationId = 1;

  static Future<void> init({void Function(String? payload)? onTap}) async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
      onDidReceiveNotificationResponse: onTap == null
          ? null
          : (response) => onTap(response.payload),
    );
  }

  /// Payload of the notification that launched the app, if any.
  static Future<String?> launchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return details.notificationResponse?.payload;
  }

  /// Asks for POST_NOTIFICATIONS (Android 13+). True when allowed.
  static Future<bool> requestPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (android == null) return false;
    return await android.requestNotificationsPermission() ?? false;
  }

  static Future<void> show(NotificationContent content) {
    return _plugin.show(
      id: _notificationId,
      title: content.title,
      body: content.body,
      payload: content.payload,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.channelId,
          _channel.channelName,
          channelDescription: _channel.channelDescription,
          styleInformation: content.lines.isEmpty
              ? BigTextStyleInformation(content.body)
              : InboxStyleInformation(
                  content.lines,
                  contentTitle: content.title,
                  summaryText: content.summary,
                ),
        ),
      ),
    );
  }
}
