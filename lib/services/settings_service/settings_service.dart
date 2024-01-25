import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:collection/collection.dart';

class SettingsService {
  static const defaultReaderModePrefsKey = 'DEFAULT_CHAPTER_READER_MODE';
  static const defaultConfigsSourceIdKey = 'DEFAULT_CONFIGS_SOURCE_ID';

  SharedPreferences? _prefs;

  Future<ChapterViewMode> getDefaultReaderMode() async {
    _prefs ??= await SharedPreferences.getInstance();

    final defaultModeStr = _prefs!.getString(defaultReaderModePrefsKey);

    late ChapterViewMode defaultMode;

    if (defaultModeStr != null) {
      try {
        return ChapterViewMode.values.firstWhereOrNull(
            (element) => element.toString() == defaultModeStr)!;
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

  Future<int?> getDefaultConfigsSourceId() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!.getInt(defaultConfigsSourceIdKey);
  }

  Future<void> setDefaultConfigsSourceId(int id) async {
    _prefs ??= await SharedPreferences.getInstance();
    _prefs!.setInt(defaultConfigsSourceIdKey, id);
  }
}
