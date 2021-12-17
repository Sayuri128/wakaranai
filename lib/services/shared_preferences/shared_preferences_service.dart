import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesService {
  Future<void> saveOption(String key, dynamic value) async {
    final SharedPreferences sharedPreferences = await _getSharedPreferences();
    if (value is int) {
      await sharedPreferences.setInt(key, value);
    } else if (value is double) {
      await sharedPreferences.setDouble(key, value);
    } else if (value is String) {
      await sharedPreferences.setString(key, value);
    } else if (value is bool) {
      await sharedPreferences.setBool(key, value);
    } else if (value is List<String>) {
      await sharedPreferences.setStringList(key, value);
    }
  }

  Future<dynamic> getOptions(String key) async {
    final SharedPreferences sharedPreferences = await _getSharedPreferences();
    return sharedPreferences.get(key);
  }

  Future<SharedPreferences> _getSharedPreferences() async => await SharedPreferences.getInstance();
}
