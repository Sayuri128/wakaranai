import 'package:shared_preferences/shared_preferences.dart';

class AudiobookPlayerPreferences {
  static const String speedKey = 'PLAYER_AUDIOBOOK_SPEED';
  static const double defaultSpeed = 1.0;
  static const double minSpeed = 0.5;
  static const double maxSpeed = 3.0;

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  static double clampSpeed(double speed) {
    if (speed.isNaN) {
      return defaultSpeed;
    }
    return speed.clamp(minSpeed, maxSpeed).toDouble();
  }

  Future<double> getSpeed() async {
    final SharedPreferences preferences = await _load();
    final double? stored = preferences.getDouble(speedKey);
    if (stored == null) {
      return defaultSpeed;
    }
    return clampSpeed(stored);
  }

  Future<void> setSpeed(double speed) async {
    final SharedPreferences preferences = await _load();
    await preferences.setDouble(speedKey, clampSpeed(speed));
  }
}
