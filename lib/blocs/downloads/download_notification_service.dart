import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';

class DownloadNotificationService {
  static const int _progressId = 8801;
  static const int _completeId = 8802;
  static const String _channelId = 'downloads';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(const InitializationSettings(
      android: android,
      iOS: darwin,
    ));
    _initialized = true;
  }

  Future<void> requestPermission() async {
    try {
      await _ensureInitialized();
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e, s) {
      logger.w('Failed to request notification permission: $e');
      logger.w(s);
    }
  }

  Future<void> showProgress({
    required String title,
    required String chapterTitle,
    required int progress,
    required int max,
  }) async {
    try {
      await _ensureInitialized();
      final bool indeterminate = max <= 0;
      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.downloads_notification_channel_name,
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        indeterminate: indeterminate,
        maxProgress: indeterminate ? 0 : max,
        progress: indeterminate ? 0 : progress.clamp(0, max),
      );
      await _plugin.show(
        _progressId,
        title,
        chapterTitle,
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show download progress notification: $e');
      logger.w(s);
    }
  }

  Future<void> showComplete(int count) async {
    try {
      await _ensureInitialized();
      await cancelProgress();
      if (count <= 0) return;
      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.downloads_notification_channel_name,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
      );
      await _plugin.show(
        _completeId,
        S.current.downloads_notification_complete_title,
        S.current.downloads_notification_complete_body(count),
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show download complete notification: $e');
      logger.w(s);
    }
  }

  Future<void> cancelProgress() async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(_progressId);
    } catch (e, s) {
      logger.w('Failed to cancel download notification: $e');
      logger.w(s);
    }
  }
}
