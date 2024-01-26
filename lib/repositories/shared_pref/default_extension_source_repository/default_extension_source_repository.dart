import 'package:shared_preferences/shared_preferences.dart';

class DefaultExtensionRepository {
  SharedPreferences? _prefs;

  static const String prefix = 'default_extension_';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> setDefaultExtensionId(int? extensionId) async {
    if (extensionId == null) {
      await _prefs!.remove('${prefix}id');
    } else {
      await _prefs!.setInt('${prefix}id', extensionId);
    }
  }

  Future<int?> getDefaultExtensionId() async {
    return _prefs!.getInt('${prefix}id');
  }
}
