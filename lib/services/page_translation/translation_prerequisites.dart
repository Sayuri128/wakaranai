import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_variant.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

PageTranslationSettings effectiveTranslationSettings(
  PageTranslationSettings settings,
  GemmaModelState gemma,
) {
  final GemmaVariant? variant = gemmaVariantOf(settings);
  if (variant != null && !gemma.supports(variant)) {
    return settings.copyWith(translator: '');
  }
  return settings;
}

GemmaVariant? gemmaVariantOf(PageTranslationSettings settings) {
  return GemmaVariant.forEngine(settings.translatorId);
}

bool usesGemma(PageTranslationSettings settings) {
  return gemmaVariantOf(settings) != null;
}

bool usesDeepL(PageTranslationSettings settings) {
  return settings.translatorId == deepLEngineId;
}

Future<bool> ensureTranslationReady({
  required PageTranslationSettings settings,
  required LanguagePacksCubit packs,
  required GemmaModelCubit gemma,
  required TitleLanguages languages,
}) async {
  final GemmaVariant? variant = gemmaVariantOf(settings);
  if (variant != null) {
    return gemma.ensure(variant);
  }
  if (usesDeepL(settings)) {
    return await DeepLApiKeyStore.read() != null;
  }
  return packs.ensure(languages.packs);
}
