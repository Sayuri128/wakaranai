import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/services/app_language/app_language.dart';

class AppLanguagePreferences {
  static const String languageKey = 'APP_LANGUAGE';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<AppLanguage> read() async {
    final SharedPreferences preferences = await _load();
    return AppLanguage.fromStorage(preferences.getString(languageKey));
  }

  Future<void> write(AppLanguage language) async {
    final SharedPreferences preferences = await _load();
    await preferences.setString(languageKey, language.storageValue);
  }
}
