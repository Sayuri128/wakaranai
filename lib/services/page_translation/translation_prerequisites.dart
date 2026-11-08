import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

PageTranslationSettings effectiveTranslationSettings(
  PageTranslationSettings settings,
  OnDeviceModelState gemma,
) {
  final OnDeviceModel? variant = onDeviceModelOf(settings);
  if (variant != null && !gemma.supports(variant)) {
    return settings.copyWith(translator: '');
  }
  return settings;
}

OnDeviceModel? onDeviceModelOf(PageTranslationSettings settings) {
  return OnDeviceModel.forEngine(settings.translatorId);
}

bool usesOnDeviceModel(PageTranslationSettings settings) {
  return onDeviceModelOf(settings) != null;
}

bool usesDeepL(PageTranslationSettings settings) {
  return settings.translatorId == deepLEngineId;
}

Future<bool> ensureTranslationReady({
  required PageTranslationSettings settings,
  required LanguagePacksCubit packs,
  required OnDeviceModelCubit gemma,
  required TitleLanguages languages,
}) async {
  final OnDeviceModel? variant = onDeviceModelOf(settings);
  if (variant != null) {
    return gemma.ensure(variant);
  }
  if (usesDeepL(settings)) {
    return await DeepLApiKeyStore.read() != null;
  }
  return packs.ensure(languages.packs);
}
