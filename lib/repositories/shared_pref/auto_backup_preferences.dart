import 'package:shared_preferences/shared_preferences.dart';

class AutoBackupPreferences {
  static const String _enabledKey = 'AUTO_BACKUP_ENABLED';
  static const String _lastBackupKey = 'AUTO_BACKUP_LAST_AT';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> isEnabled() async {
    final SharedPreferences preferences = await _load();
    return preferences.getBool(_enabledKey) ?? true;
  }

  Future<void> setEnabled(bool enabled) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(_enabledKey, enabled);
  }

  Future<DateTime?> lastBackupAt() async {
    final SharedPreferences preferences = await _load();
    final int? milliseconds = preferences.getInt(_lastBackupKey);
    if (milliseconds == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(milliseconds);
  }

  Future<void> setLastBackupAt(DateTime time) async {
    final SharedPreferences preferences = await _load();
    await preferences.setInt(_lastBackupKey, time.millisecondsSinceEpoch);
  }
}
