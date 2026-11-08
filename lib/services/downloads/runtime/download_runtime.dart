import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';

const String kDownloadRuntimeChannel = 'wakaranai/download_runtime';

enum DownloadRuntimeStart { started, alreadyRunning, notAllowed, unsupported }

enum DownloadRuntimeEvent { startNotAllowed, timedOut }

abstract class DownloadRuntime {
  Stream<DownloadRuntimeEvent> get events;

  Future<DownloadRuntimeStart> start();

  Future<void> stop();

  Future<void> dispose();
}

DownloadRuntime createDownloadRuntime() {
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
    return MethodChannelDownloadRuntime();
  }
  return NoopDownloadRuntime();
}

class NoopDownloadRuntime implements DownloadRuntime {
  @override
  Stream<DownloadRuntimeEvent> get events =>
      const Stream<DownloadRuntimeEvent>.empty();

  @override
  Future<DownloadRuntimeStart> start() async =>
      DownloadRuntimeStart.unsupported;

  @override
  Future<void> stop() async {}

  @override
  Future<void> dispose() async {}
}

class MethodChannelDownloadRuntime implements DownloadRuntime {
  MethodChannelDownloadRuntime({
    MethodChannel channel = const MethodChannel(kDownloadRuntimeChannel),
  }) : _channel = channel {
    _channel.setMethodCallHandler(_handleCall);
  }

  final MethodChannel _channel;
  final StreamController<DownloadRuntimeEvent> _events =
      StreamController<DownloadRuntimeEvent>.broadcast();

  @override
  Stream<DownloadRuntimeEvent> get events => _events.stream;

  @override
  Future<DownloadRuntimeStart> start() async {
    try {
      final String? outcome = await _channel.invokeMethod<String>(
        'start',
        _notificationLabels(),
      );
      return _parseStart(outcome);
    } on MissingPluginException {
      return DownloadRuntimeStart.unsupported;
    } catch (error) {
      logger.w('Failed to start the download service: $error');
      return DownloadRuntimeStart.notAllowed;
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _channel.invokeMethod<void>('stop');
    } on MissingPluginException {
      return;
    } catch (error) {
      logger.w('Failed to stop the download service: $error');
    }
  }

  @override
  Future<void> dispose() async {
    _channel.setMethodCallHandler(null);
    await _events.close();
  }

  Future<void> _handleCall(MethodCall call) async {
    final DownloadRuntimeEvent? event = _parseEvent(call.method);
    if (event == null || _events.isClosed) {
      return;
    }
    _events.add(event);
  }

  static Map<String, String> _notificationLabels() {
    try {
      return <String, String>{
        'title': S.current.downloads_notification_downloading_title,
        'channelName': S.current.downloads_notification_channel_name,
      };
    } catch (_) {
      return const <String, String>{};
    }
  }

  static DownloadRuntimeStart _parseStart(String? outcome) {
    switch (outcome) {
      case 'started':
        return DownloadRuntimeStart.started;
      case 'alreadyRunning':
        return DownloadRuntimeStart.alreadyRunning;
      case 'notAllowed':
        return DownloadRuntimeStart.notAllowed;
      default:
        return DownloadRuntimeStart.unsupported;
    }
  }

  static DownloadRuntimeEvent? _parseEvent(String method) {
    switch (method) {
      case 'onStartNotAllowed':
        return DownloadRuntimeEvent.startNotAllowed;
      case 'onTimeout':
        return DownloadRuntimeEvent.timedOut;
      default:
        return null;
    }
  }
}
