import 'dart:async';

import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/runtime/download_runtime.dart';

enum DownloadRuntimeStatus { inactive, active, startNotAllowed, timedOut }

class DownloadRuntimeCoordinator {
  DownloadRuntimeCoordinator({
    required DownloadRuntime runtime,
    required bool Function() isOwnerClosed,
    required DownloadRuntimeStatus Function() readStatus,
    required void Function(DownloadRuntimeStatus status) publishStatus,
  })  : _runtime = runtime,
        _isOwnerClosed = isOwnerClosed,
        _readStatus = readStatus,
        _publishStatus = publishStatus {
    _events = runtime.events.listen(_onRuntimeEvent);
  }

  final DownloadRuntime _runtime;
  final bool Function() _isOwnerClosed;
  final DownloadRuntimeStatus Function() _readStatus;
  final void Function(DownloadRuntimeStatus status) _publishStatus;
  late final StreamSubscription<DownloadRuntimeEvent> _events;
  bool _wanted = false;
  bool _running = false;
  Future<void> _sync = Future<void>.value();

  Future<void> setWanted(bool wanted) {
    _wanted = wanted;
    return _sync = _sync.then((_) => _syncRuntime());
  }

  Future<void> stopListening() => _events.cancel();

  Future<void> dispose() => _runtime.dispose();

  Future<void> _syncRuntime() async {
    try {
      final bool wanted = _wanted && !_isOwnerClosed();
      if (!wanted) {
        await _stopRuntime();
        return;
      }
      if (_running) {
        return;
      }
      _onRuntimeStart(await _runtime.start());
    } catch (e, s) {
      logger.w('Could not update the download service: $e');
      logger.w(s);
    }
  }

  Future<void> _stopRuntime() async {
    if (_running) {
      _running = false;
      await _runtime.stop();
    }
    _publishStatus(DownloadRuntimeStatus.inactive);
  }

  void _onRuntimeStart(DownloadRuntimeStart outcome) {
    switch (outcome) {
      case DownloadRuntimeStart.started:
      case DownloadRuntimeStart.alreadyRunning:
        _running = true;
        _publishStatus(DownloadRuntimeStatus.active);
        break;
      case DownloadRuntimeStart.notAllowed:
        logger.w('Downloads could not enter the foreground; they continue '
            'only while the app stays open');
        _markRestricted(DownloadRuntimeStatus.startNotAllowed);
        break;
      case DownloadRuntimeStart.unsupported:
        break;
    }
  }

  void _onRuntimeEvent(DownloadRuntimeEvent event) {
    switch (event) {
      case DownloadRuntimeEvent.startNotAllowed:
        logger.w('The download service was refused the foreground; '
            'downloads continue only while the app stays open');
        _markRestricted(DownloadRuntimeStatus.startNotAllowed);
        break;
      case DownloadRuntimeEvent.timedOut:
        logger.w('The download service reached its Android time limit; '
            'downloads continue only while the app stays open');
        _markRestricted(DownloadRuntimeStatus.timedOut);
        break;
    }
  }

  void _markRestricted(DownloadRuntimeStatus status) {
    _running = false;
    if (_readStatus() == DownloadRuntimeStatus.timedOut) {
      return;
    }
    _publishStatus(status);
  }
}
