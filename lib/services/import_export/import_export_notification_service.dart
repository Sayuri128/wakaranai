import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';

class ImportExportNotificationService {
  static const int _progressId = 8811;
  static const int _completeId = 8812;
  static const String _channelId = 'import_export';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    const AndroidInitializationSettings android =
        AndroidInitializationSettings('ic_stat_download');
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
    required String body,
    required int processed,
    required int total,
  }) async {
    try {
      await _ensureInitialized();
      final bool indeterminate = total <= 0;
      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.settings_transfer_notification_channel_name,
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        indeterminate: indeterminate,
        maxProgress: indeterminate ? 0 : total,
        progress: indeterminate ? 0 : processed.clamp(0, total),
        subText: indeterminate ? null : '$processed/$total',
      );
      await _plugin.show(
        _progressId,
        title,
        body,
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show transfer progress notification: $e');
      logger.w(s);
    }
  }

  Future<void> showComplete({required String title, String? body}) async {
    try {
      await _ensureInitialized();
      await cancelProgress();
      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.settings_transfer_notification_channel_name,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
      );
      await _plugin.show(
        _completeId,
        title,
        body,
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show transfer complete notification: $e');
      logger.w(s);
    }
  }

  Future<void> cancelProgress() async {
    try {
      await _ensureInitialized();
      await _plugin.cancel(_progressId);
    } catch (e, s) {
      logger.w('Failed to cancel transfer notification: $e');
      logger.w(s);
    }
  }
}
