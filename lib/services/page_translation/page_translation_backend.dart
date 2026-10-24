import 'package:wakaranai/services/page_translation/page_translation_result.dart';

abstract class PageTranslationBackend {
  Future<bool> isReady();

  Future<PageTranslationResult?> cached(String path);

  Future<PageTranslationResult?> olderVersion(String path);

  Future<String> translateText(String text);

  Future<void> save(String path, PageTranslationResult result);

  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  );

  Future<void> dispose();
}
