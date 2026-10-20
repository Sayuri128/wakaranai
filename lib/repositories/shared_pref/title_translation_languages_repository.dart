import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

class TitleTranslationLanguagesRepository {
  SharedPreferences? _preferences;

  Future<SharedPreferences> _loadPreferences() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  String _key(String extensionUid, String concreteUid) =>
      'page_translation_languages_${extensionUid}_$concreteUid';

  Future<TitleLanguages?> get(String extensionUid, String concreteUid) async {
    final SharedPreferences preferences = await _loadPreferences();
    final String? stored = preferences.getString(
      _key(extensionUid, concreteUid),
    );
    return TitleLanguages.decode(stored);
  }

  Future<void> set(
    String extensionUid,
    String concreteUid,
    TitleLanguages languages,
  ) async {
    final SharedPreferences preferences = await _loadPreferences();
    await preferences.setString(
      _key(extensionUid, concreteUid),
      languages.encode(),
    );
  }
}
