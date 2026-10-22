import 'dart:isolate';
import 'dart:ui';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:wakaranai/blocs/chapter_translation/chapter_translation_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';

const String _portName = 'wakaranai.translation_actions';
const String translationActionToggle = 'translation_toggle';
const String translationActionCancel = 'translation_cancel';

@pragma('vm:entry-point')
void translationNotificationBackgroundAction(NotificationResponse response) {
  final String? action = response.actionId;
  if (action == null) {
    return;
  }
  IsolateNameServer.lookupPortByName(_portName)?.send(action);
}

class TranslationNotificationService implements ChapterTranslationNotifier {
  TranslationNotificationService({required void Function(String) onAction})
    : _onAction = onAction {
    IsolateNameServer.removePortNameMapping(_portName);
    IsolateNameServer.registerPortWithName(_port.sendPort, _portName);
    _port.listen((dynamic message) {
      if (message is String) {
        _onAction(message);
      }
    });
  }

  static const int _progressId = 8811;
  static const int _completeId = 8812;
  static const String _channelId = 'translations';

  final void Function(String) _onAction;
  final ReceivePort _port = ReceivePort();
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  Future<void> _initialize() async {
    const AndroidInitializationSettings android = AndroidInitializationSettings(
      'ic_stat_download',
    );
    const DarwinInitializationSettings darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        final String? action = response.actionId;
        if (action != null) {
          _onAction(action);
        }
      },
      onDidReceiveBackgroundNotificationResponse:
          translationNotificationBackgroundAction,
    );
  }

  @override
  Future<void> showProgress({
    required String title,
    required int done,
    required int total,
    required int remainingChapters,
    required bool paused,
  }) async {
    try {
      await _initialize();
      final bool indeterminate = total <= 0;
      final String status = paused
          ? S.current.chapter_translation_notification_paused
          : S.current.chapter_translation_progress(done, total);
      final AndroidNotificationDetails android = AndroidNotificationDetails(
        _channelId,
        S.current.chapter_translation_notification_channel,
        importance: Importance.low,
        priority: Priority.low,
        onlyAlertOnce: true,
        ongoing: true,
        autoCancel: false,
        showProgress: true,
        indeterminate: indeterminate,
        maxProgress: indeterminate ? 0 : total,
        progress: indeterminate ? 0 : done.clamp(0, total),
        subText: remainingChapters > 1
            ? S.current.chapter_translation_notification_remaining(
                remainingChapters,
              )
            : null,
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            translationActionToggle,
            paused
                ? S.current.chapter_translation_resume
                : S.current.chapter_translation_pause,
            cancelNotification: false,
          ),
          AndroidNotificationAction(
            translationActionCancel,
            S.current.chapter_translation_cancel_all,
            cancelNotification: false,
          ),
        ],
      );
      await _plugin.show(
        _progressId,
        title,
        status,
        NotificationDetails(android: android),
      );
    } catch (e) {
      logger.w('Failed to show translation notification: $e');
    }
  }

  @override
  Future<void> showFinished(int chapters) async {
    try {
      await _initialize();
      await _plugin.cancel(_progressId);
      await _plugin.show(
        _completeId,
        S.current.chapter_translation_notification_done_title,
        S.current.chapter_translation_notification_done_body(chapters),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            S.current.chapter_translation_notification_channel,
            autoCancel: true,
          ),
        ),
      );
    } catch (e) {
      logger.w('Failed to show translation finished notification: $e');
    }
  }

  @override
  Future<void> clear() async {
    try {
      await _initialize();
      await _plugin.cancel(_progressId);
    } catch (e) {
      logger.w('Failed to clear translation notification: $e');
    }
  }

  void dispose() {
    IsolateNameServer.removePortNameMapping(_portName);
    _port.close();
  }
}
