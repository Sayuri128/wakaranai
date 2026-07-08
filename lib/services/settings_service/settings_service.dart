import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_palette.dart';

class SettingsService {
  static const String defaultReaderModePrefsKey = 'DEFAULT_CHAPTER_READER_MODE';
  static const String defaultConfigsSourceIdKey = 'DEFAULT_CONFIGS_SOURCE_ID';
  static const String themeIdPrefsKey = 'APP_THEME_ID';
  static const String showNsfwPrefsKey = 'SHOW_NSFW';
  static const String collectStatisticsPrefsKey = 'COLLECT_STATISTICS';
  static const String checkUpdatesPrefsKey = 'CHECK_LIBRARY_UPDATES';
  static const String updateNotificationsPrefsKey = 'UPDATE_NOTIFICATIONS';
  static const String updateFrequencyPrefsKey = 'UPDATE_FREQUENCY_HOURS';

  static const int defaultUpdateFrequencyHours = 12;

  SharedPreferences? _prefs;

  Future<bool> getCheckUpdates() async {
    _prefs ??= await SharedPreferences.getInstance();

    return _prefs!.getBool(checkUpdatesPrefsKey) ?? false;
  }

  Future<void> setCheckUpdates(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(checkUpdatesPrefsKey, value);
  }

  Future<bool> getUpdateNotifications({bool reload = false}) async {
    _prefs ??= await SharedPreferences.getInstance();
    if (reload) {
      await _prefs!.reload();
    }

    return _prefs!.getBool(updateNotificationsPrefsKey) ?? true;
  }

  Future<void> setUpdateNotifications(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(updateNotificationsPrefsKey, value);
  }

  Future<int> getUpdateFrequencyHours() async {
    _prefs ??= await SharedPreferences.getInstance();

    return _prefs!.getInt(updateFrequencyPrefsKey) ??
        defaultUpdateFrequencyHours;
  }

  Future<void> setUpdateFrequencyHours(int value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setInt(updateFrequencyPrefsKey, value);
  }

  Future<bool> getShowNsfw() async {
    _prefs ??= await SharedPreferences.getInstance();

    return _prefs!.getBool(showNsfwPrefsKey) ?? false;
  }

  Future<void> setShowNsfw(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(showNsfwPrefsKey, value);
  }

  Future<bool> getCollectStatistics() async {
    _prefs ??= await SharedPreferences.getInstance();

    return _prefs!.getBool(collectStatisticsPrefsKey) ?? true;
  }

  Future<void> setCollectStatistics(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(collectStatisticsPrefsKey, value);
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
