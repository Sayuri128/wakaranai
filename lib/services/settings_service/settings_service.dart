import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_palette.dart';

class SettingsService {
  static const String defaultReaderModePrefsKey = 'DEFAULT_CHAPTER_READER_MODE';
  static const String defaultConfigsSourceIdKey = 'DEFAULT_CONFIGS_SOURCE_ID';
  static const String themeIdPrefsKey = 'APP_THEME_ID';
  static const String showNsfwPrefsKey = 'SHOW_NSFW';

  SharedPreferences? _prefs;

  Future<bool> getShowNsfw() async {
    _prefs ??= await SharedPreferences.getInstance();

    return _prefs!.getBool(showNsfwPrefsKey) ?? false;
  }

  Future<void> setShowNsfw(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(showNsfwPrefsKey, value);
  }

  Future<AppThemeId> getThemeId() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String? stored = _prefs!.getString(themeIdPrefsKey);

    return AppThemeId.values.firstWhereOrNull(
          (AppThemeId id) => id.name == stored,
        ) ??
        AppThemeId.midnight;
  }

  Future<void> setThemeId(AppThemeId id) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setString(themeIdPrefsKey, id.name);
  }

  Future<ChapterViewMode> getDefaultReaderMode() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String? defaultModeStr = _prefs!.getString(defaultReaderModePrefsKey);

    late ChapterViewMode defaultMode;

    if (defaultModeStr != null) {
      try {
        return ChapterViewMode.values.firstWhereOrNull(
            (ChapterViewMode element) => element.toString() == defaultModeStr)!;
      } catch (_) {
        // ignore
      }
    }

    defaultMode = ChapterViewMode.rightToLeft;
    _prefs!.setString(
        defaultReaderModePrefsKey, ChapterViewMode.rightToLeft.toString());

    return defaultMode;
  }

  Future<void> setDefaultReaderMode(ChapterViewMode mode) async {
    _prefs ??= await SharedPreferences.getInstance();

    _prefs!.setString(defaultReaderModePrefsKey, mode.toString());
  }
}
