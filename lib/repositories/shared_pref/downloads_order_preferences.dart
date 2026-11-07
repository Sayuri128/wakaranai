import 'package:shared_preferences/shared_preferences.dart';

class DownloadsOrderPreferences {
  static const String _newestFirstKey = 'DOWNLOADS_NEWEST_FIRST';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> isNewestFirst() async {
    final SharedPreferences preferences = await _load();
    return preferences.getBool(_newestFirstKey) ?? true;
  }

  Future<void> setNewestFirst(bool newestFirst) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(_newestFirstKey, newestFirst);
  }
}
