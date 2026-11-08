import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:wakaranai/main.dart';

enum VolumeKey { up, down }

class VolumeKeyEvents {
  VolumeKeyEvents._();

  static const MethodChannel _channel = MethodChannel('wakaranai/volume_keys');

  static final StreamController<VolumeKey> _keys =
      StreamController<VolumeKey>.broadcast();

  static bool _handlerSet = false;

  static Stream<VolumeKey> get keys => _keys.stream;

  static Future<void> setIntercepting(bool intercepting) async {
    if (!Platform.isAndroid) {
      return;
    }
    _ensureHandler();
    try {
      await _channel.invokeMethod<void>('setIntercepting', intercepting);
    } on PlatformException catch (error) {
      logger.w('Failed to toggle volume key paging: $error');
    } on MissingPluginException catch (error) {
      logger.w('Volume key paging is unavailable: $error');
    }
  }

  static void _ensureHandler() {
    if (_handlerSet) {
      return;
    }
    _handlerSet = true;
    _channel.setMethodCallHandler((MethodCall call) async {
      if (call.method != 'volumeKey') {
        return;
      }
      if (call.arguments == 'up') {
        _keys.add(VolumeKey.up);
      } else if (call.arguments == 'down') {
        _keys.add(VolumeKey.down);
      }
    });
  }
}
