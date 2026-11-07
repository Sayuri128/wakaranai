import 'package:screen_brightness/screen_brightness.dart';
import 'package:volume_controller/volume_controller.dart';
import 'package:wakaranai/main.dart';

abstract class PlayerDeviceControls {
  Future<double?> readBrightness();

  Future<void> setBrightness(double brightness);

  Future<void> restoreBrightness();

  Future<double?> readVolume();

  Future<void> setVolume(double volume);
}

class PluginPlayerDeviceControls implements PlayerDeviceControls {
  bool _brightnessChanged = false;

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
    try {
      VolumeController.instance.showSystemUI = false;
      await VolumeController.instance.setVolume(volume.clamp(0.0, 1.0));
    } catch (error) {
      logger.w('Failed to set media volume: $error');
    }
  }
}
