import 'package:collection/collection.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/translation_overlay_style.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
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
  static const String useLocalExtensionServerPrefsKey =
      'USE_LOCAL_EXTENSION_SERVER';
  static const String pageTranslationEnabledPrefsKey =
      'PAGE_TRANSLATION_ENABLED';
  static const String pageTranslationTargetPrefsKey = 'PAGE_TRANSLATION_TARGET';
  static const String pageTranslationWifiOnlyPrefsKey =
      'PAGE_TRANSLATION_WIFI_ONLY';
  static const String pageTranslationOcrEnginePrefsKey =
      'PAGE_TRANSLATION_OCR_ENGINE';
  static const String pageTranslationTranslatorPrefsKey =
      'PAGE_TRANSLATION_TRANSLATOR';
  static const String pageTranslationMaxTextPixelsPrefsKey =
      'PAGE_TRANSLATION_MAX_TEXT_PIXELS';
  static const String pageTranslationFontPrefsKey = 'PAGE_TRANSLATION_FONT';
  static const String pageTranslationLabelOpacityPrefsKey =
      'PAGE_TRANSLATION_LABEL_OPACITY';
  static const String videoPlayerPreferencePrefsKey = 'VIDEO_PLAYER_PREFERENCE';

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

  Future<bool> getUseLocalExtensionServer() async {
    _prefs ??= await SharedPreferences.getInstance();

    return _prefs!.getBool(useLocalExtensionServerPrefsKey) ?? false;
  }

  Future<void> setUseLocalExtensionServer(bool value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(useLocalExtensionServerPrefsKey, value);
  }

  Future<PageTranslationSettings> getPageTranslationSettings() async {
    _prefs ??= await SharedPreferences.getInstance();

    return PageTranslationSettings(
      enabled: _prefs!.getBool(pageTranslationEnabledPrefsKey) ?? false,
      target: PageLanguage.targetByCode(
              _prefs!.getString(pageTranslationTargetPrefsKey)) ??
          PageLanguage.english,
      wifiOnly: _prefs!.getBool(pageTranslationWifiOnlyPrefsKey) ?? true,
      ocrEngine: _prefs!.getString(pageTranslationOcrEnginePrefsKey),
      translator: _legacyTranslator(
          _prefs!.getString(pageTranslationTranslatorPrefsKey)),
      overlay: TranslationOverlayStyle(
        maxTextPixels:
            _prefs!.getDouble(pageTranslationMaxTextPixelsPrefsKey),
        font: TranslationFont.byId(
            _prefs!.getString(pageTranslationFontPrefsKey)),
        labelOpacity:
            _prefs!.getDouble(pageTranslationLabelOpacityPrefsKey) ??
                TranslationOverlayStyle.defaultLabelOpacity,
      ),
    );
  }

  static String? _legacyTranslator(String? id) =>
      id == 'gemma-vision' ? 'gemma' : id;

  Future<void> setPageTranslationSettings(
      PageTranslationSettings settings) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setBool(pageTranslationEnabledPrefsKey, settings.enabled);
    await _prefs!
        .setString(pageTranslationTargetPrefsKey, settings.target.code);
    await _prefs!.setBool(pageTranslationWifiOnlyPrefsKey, settings.wifiOnly);
    await _prefs!
        .setString(pageTranslationOcrEnginePrefsKey, settings.ocrEngineId);
    await _prefs!
        .setString(pageTranslationTranslatorPrefsKey, settings.translatorId);
    final double? maxTextPixels = settings.overlay.maxTextPixels;
    if (maxTextPixels == null) {
      await _prefs!.remove(pageTranslationMaxTextPixelsPrefsKey);
    } else {
      await _prefs!
          .setDouble(pageTranslationMaxTextPixelsPrefsKey, maxTextPixels);
    }
    await _prefs!
        .setString(pageTranslationFontPrefsKey, settings.overlay.font.id);
    await _prefs!.setDouble(
        pageTranslationLabelOpacityPrefsKey, settings.overlay.labelOpacity);
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
    await _prefs!.setString(
        defaultReaderModePrefsKey, ChapterViewMode.rightToLeft.toString());

    return defaultMode;
  }

  Future<void> setDefaultReaderMode(ChapterViewMode mode) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setString(defaultReaderModePrefsKey, mode.toString());
  }

  Future<VideoPlayerPreference> getVideoPlayerPreference() async {
    _prefs ??= await SharedPreferences.getInstance();

    final String? stored = _prefs!.getString(videoPlayerPreferencePrefsKey);

    return VideoPlayerPreference.values.firstWhereOrNull(
          (VideoPlayerPreference preference) => preference.name == stored,
        ) ??
        VideoPlayerPreference.auto;
  }

  Future<void> setVideoPlayerPreference(VideoPlayerPreference value) async {
    _prefs ??= await SharedPreferences.getInstance();

    await _prefs!.setString(videoPlayerPreferencePrefsKey, value.name);
  }
}
