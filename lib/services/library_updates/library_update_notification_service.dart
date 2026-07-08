import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';

class LibraryUpdateNotificationService {
  static const int _updatesId = 8821;
  static const String _channelId = 'library_updates';
  static const int _maxLines = 5;

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

  Future<void> showUpdates(List<LibraryUpdateDomain> updates) async {
    if (updates.isEmpty) return;

    try {
      await _ensureInitialized();

      final Map<String, int> perTitle = <String, int>{};
      for (final LibraryUpdateDomain update in updates) {
        perTitle.update(update.concreteTitle, (int value) => value + 1,
            ifAbsent: () => 1);
      }

      final List<String> lines = perTitle.entries
          .take(_maxLines)
          .map((MapEntry<String, int> e) =>
              S.current.updates_notification_line(e.key, e.value))
          .toList();

      if (perTitle.length > _maxLines) {
        lines.add(S.current.updates_notification_more(
            perTitle.length - _maxLines));
      }

      final String title = S.current.updates_notification_title(updates.length);
      final String summary =
          S.current.updates_notification_summary(perTitle.length);

      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.updates_notification_channel_name,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        styleInformation: InboxStyleInformation(
          lines,
          contentTitle: title,
          summaryText: summary,
        ),
      );

      await _plugin.show(
        _updatesId,
        title,
        summary,
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show library update notification: $e');
      logger.w(s);
    }
  }
}
