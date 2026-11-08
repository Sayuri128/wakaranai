import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

abstract class PageTranslator {
  String get id;

  bool get isLocal;

  Future<bool> isReady(PageLanguage from, PageLanguage to);

  Future<List<String>> translate(
    List<String> texts, {
    required PageLanguage from,
    required PageLanguage to,
    List<GlossaryEntry> glossary,
  });

  Future<void> close();
}

abstract class TranslationModelStore {
  Future<bool> isDownloaded(PageLanguage language);

  Future<void> download(PageLanguage language, {required bool wifiOnly});

  Future<void> delete(PageLanguage language);
}
