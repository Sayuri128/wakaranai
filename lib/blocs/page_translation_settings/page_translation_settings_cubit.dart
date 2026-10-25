import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/translation_overlay_style.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';

class PageTranslationSettingsCubit extends Cubit<PageTranslationSettings> {
  PageTranslationSettingsCubit({SettingsService? settingsService})
    : _settingsService = settingsService ?? SettingsService(),
      super(const PageTranslationSettings());

  final SettingsService _settingsService;

  Future<void> init() async {
    emit(await _settingsService.getPageTranslationSettings());
  }

  Future<void> setEnabled(bool value) =>
      _update(state.copyWith(enabled: value));

  Future<void> setTarget(PageLanguage language) =>
      _update(state.copyWith(target: language));

  Future<void> setTranslator(String id) =>
      _update(state.copyWith(translator: id));

  Future<void> setWifiOnly(bool value) =>
      _update(state.copyWith(wifiOnly: value));

  Future<void> setOverlay(TranslationOverlayStyle overlay) =>
      _update(state.copyWith(overlay: overlay));

  Future<void> _update(PageTranslationSettings settings) async {
    if (settings == state) {
      return;
    }
    emit(settings);
    await _settingsService.setPageTranslationSettings(settings);
  }
}
