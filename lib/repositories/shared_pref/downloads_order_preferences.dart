import 'package:shared_preferences/shared_preferences.dart';

class DownloadsOrderPreferences {
  static const String newestFirstKey = 'DOWNLOADS_NEWEST_FIRST';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<bool> isNewestFirst() async {
    final SharedPreferences preferences = await _load();
    return preferences.getBool(newestFirstKey) ?? true;
  }

  Future<void> setNewestFirst(bool newestFirst) async {
    final SharedPreferences preferences = await _load();
    await preferences.setBool(newestFirstKey, newestFirst);
  }
}
