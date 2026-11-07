import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakaranai/main.dart';

const double kVolumeMatchTolerance = 0.005;

bool shouldRestoreVolume({
  required double? openingVolume,
  required double? lastGestureVolume,
  required double? currentVolume,
}) {
  if (openingVolume == null ||
      lastGestureVolume == null ||
      currentVolume == null) {
    return false;
  }
  final bool changedOutsideGestures =
      (currentVolume - lastGestureVolume).abs() > kVolumeMatchTolerance;
  if (changedOutsideGestures) {
    return false;
  }
  return (currentVolume - openingVolume).abs() > kVolumeMatchTolerance;
}

abstract class PlayerDeviceControls {
  Future<double?> readBrightness();

  Future<void> setBrightness(double brightness);

  Future<void> restoreBrightness();

  Future<double?> readVolume();

  Future<void> setVolume(double volume);

  Future<void> rememberOpeningVolume();

  Future<void> restoreVolume();
}

class PluginPlayerDeviceControls implements PlayerDeviceControls {
  bool _brightnessChanged = false;
  double? _openingVolume;
  double? _lastGestureVolume;

  @override
  Future<double?> readBrightness() async {
    try {
      return await ScreenBrightness.instance.application;
    } catch (error) {
      logger.w('Failed to read screen brightness: $error');
      return null;
    }
  }

  @override
  Future<void> setBrightness(double brightness) async {
    try {
      _brightnessChanged = true;
      await ScreenBrightness.instance.setApplicationScreenBrightness(
        brightness.clamp(0.0, 1.0),
      );
    } catch (error) {
      logger.w('Failed to set screen brightness: $error');
    }
  }

  @override
  Future<void> restoreBrightness() async {
    if (!_brightnessChanged) {
      return;
    }
    _brightnessChanged = false;
    try {
      await ScreenBrightness.instance.resetApplicationScreenBrightness();
    } catch (error) {
      logger.w('Failed to restore screen brightness: $error');
    }
  }

  @override
  Future<double?> readVolume() async {
    try {
      return await VolumeController.instance.getVolume();
    } catch (error) {
      logger.w('Failed to read media volume: $error');
      return null;
    }
  }

  @override
  Future<void> setVolume(double volume) async {
    final double target = volume.clamp(0.0, 1.0);
    try {
      VolumeController.instance.showSystemUI = false;
      await VolumeController.instance.setVolume(target);
    } catch (error) {
      logger.w('Failed to set media volume: $error');
      return;
    }
    _lastGestureVolume = await readVolume() ?? target;
  }

  @override
  Future<void> rememberOpeningVolume() async {
    _openingVolume = await readVolume();
  }

  @override
  Future<void> restoreVolume() async {
    final double? openingVolume = _openingVolume;
    final bool restore = shouldRestoreVolume(
      openingVolume: openingVolume,
      lastGestureVolume: _lastGestureVolume,
      currentVolume: await readVolume(),
    );
    _lastGestureVolume = null;
    if (!restore || openingVolume == null) {
      return;
    }
    try {
      VolumeController.instance.showSystemUI = false;
      await VolumeController.instance.setVolume(openingVolume);
    } catch (error) {
      logger.w('Failed to restore media volume: $error');
    }
  }
}
