import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_prompt.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';

PageTranslationSettings effectiveTranslationSettings(
  PageTranslationSettings settings,
  GemmaModelState gemma,
) {
  if (settings.translatorId == gemmaEngineId && !gemma.supported) {
    return settings.copyWith(translator: '');
  }
  return settings;
}

bool usesGemma(PageTranslationSettings settings) =>
    settings.translatorId == gemmaEngineId;

Future<bool> ensureTranslationReady({
  required PageTranslationSettings settings,
  required LanguagePacksCubit packs,
  required GemmaModelCubit gemma,
  required TitleLanguages languages,
}) {
  if (usesGemma(settings)) {
    return gemma.ensure();
  }
  return packs.ensure(languages.packs);
}
