import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakaranai/data/domain/database/library_update_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/library_updates/source_attention_text.dart';

class LibraryUpdateNotificationService {
  static const int _updatesId = 8821;
  static const int _attentionId = 8822;
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

  Future<void> showSourceAttention(
    List<SourceNeedsAttention> attentions,
  ) async {
    if (attentions.isEmpty) {
      return;
    }

    try {
      await _ensureInitialized();

      final String title = SourceAttentionText.notificationTitle(attentions);
      final String body = S.current.updates_attention_notification_body;

      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.updates_notification_channel_name,
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        autoCancel: true,
        styleInformation: BigTextStyleInformation(body, contentTitle: title),
      );

      await _plugin.show(
        _attentionId,
        title,
        body,
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show source attention notification: $e');
      logger.w(s);
    }
  }

  Future<void> showUpdates(
    List<LibraryUpdateDomain> updates, {
    Map<String, int> autoQueuedByEntry = const <String, int>{},
  }) async {
    if (updates.isEmpty) return;

    try {
      await _ensureInitialized();

      final List<_TitleUpdates> perTitle = _groupByTitle(updates);
      final List<String> lines = perTitle
          .take(_maxLines)
          .map((_TitleUpdates title) =>
              title.line(autoQueuedByEntry[title.entryUid] ?? 0))
          .toList();

      if (perTitle.length > _maxLines) {
        lines.add(S.current.updates_notification_more(
            perTitle.length - _maxLines));
      }

      final int autoQueued = _queuedFor(perTitle, autoQueuedByEntry);
      if (autoQueued > 0) {
        lines.add(S.current.auto_download_notification_pending(autoQueued));
      }

      final String title = S.current.updates_notification_title(updates.length);
      final String summary =
          S.current.updates_notification_summary(perTitle.length);
      final String body = autoQueued > 0
          ? S.current.auto_download_notification_pending(autoQueued)
          : summary;

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
        body,
        NotificationDetails(android: android),
      );
    } catch (e, s) {
      logger.w('Failed to show library update notification: $e');
      logger.w(s);
    }
  }

  static List<_TitleUpdates> _groupByTitle(List<LibraryUpdateDomain> updates) {
    final Map<String, _TitleUpdates> byEntry = <String, _TitleUpdates>{};
    for (final LibraryUpdateDomain update in updates) {
      byEntry
          .putIfAbsent(
            update.libraryEntryUid,
            () => _TitleUpdates(
              entryUid: update.libraryEntryUid,
              title: update.concreteTitle,
            ),
          )
          .count++;
    }
    return byEntry.values.toList();
  }

  static int _queuedFor(
    List<_TitleUpdates> titles,
    Map<String, int> autoQueuedByEntry,
  ) {
    int total = 0;
    for (final _TitleUpdates title in titles) {
      total += autoQueuedByEntry[title.entryUid] ?? 0;
    }
    return total;
  }
}

class _TitleUpdates {
  _TitleUpdates({required this.entryUid, required this.title});

  final String entryUid;
  final String title;
  int count = 0;

  String line(int queued) {
    if (queued > 0) {
      return S.current.auto_download_notification_line(title, count, queued);
    }
    return S.current.updates_notification_line(title, count);
  }
}
