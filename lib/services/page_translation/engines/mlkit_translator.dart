import 'package:collection/collection.dart';
import 'package:google_mlkit_translation/google_mlkit_translation.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class MlKitTranslator implements PageTranslator {
  MlKitTranslator({MlKitModelStore? models})
    : _models = models ?? MlKitModelStore();

  static const String engineId = 'mlkit';

  final MlKitModelStore _models;
  final Map<String, OnDeviceTranslator> _translators =
      <String, OnDeviceTranslator>{};

  @override
  String get id => engineId;

  @override
  bool get isLocal => true;

  @override
  Future<bool> isReady(PageLanguage from, PageLanguage to) async {
    return await _models.isDownloaded(from) && await _models.isDownloaded(to);
  }

  @override
  Future<List<String>> translate(
    List<String> texts, {
    required PageLanguage from,
    required PageLanguage to,
    List<GlossaryEntry> glossary = const <GlossaryEntry>[],
  }) async {
    if (from == to) {
      return texts;
    }
    final OnDeviceTranslator translator = _translators.putIfAbsent(
      '${from.code}>${to.code}',
      () => OnDeviceTranslator(
        sourceLanguage: MlKitModelStore.languageOf(from),
        targetLanguage: MlKitModelStore.languageOf(to),
      ),
    );
    final List<String> translated = <String>[];
    for (final String text in texts) {
      final String result = await translator.translateText(text);
      translated.add(result.trim());
    }
    return translated;
  }

  @override
  Future<void> close() async {
    for (final OnDeviceTranslator translator in _translators.values) {
      await translator.close();
    }
    _translators.clear();
  }
}

class MlKitModelStore implements TranslationModelStore {
  final OnDeviceTranslatorModelManager _manager =
      OnDeviceTranslatorModelManager();

  static TranslateLanguage languageOf(PageLanguage language) {
    final TranslateLanguage? resolved = TranslateLanguage.values
        .firstWhereOrNull(
          (TranslateLanguage candidate) => candidate.bcpCode == language.code,
        );
    if (resolved == null) {
      throw ArgumentError.value(language.code, 'language');
    }
    return resolved;
  }

  @override
  Future<bool> isDownloaded(PageLanguage language) =>
      _manager.isModelDownloaded(languageOf(language).bcpCode);

  @override
  Future<void> download(PageLanguage language, {required bool wifiOnly}) async {
    final bool downloaded = await _manager.downloadModel(
      languageOf(language).bcpCode,
      isWifiRequired: wifiOnly,
    );
    if (!downloaded) {
      throw StateError('Model download failed for ${language.code}');
    }
  }

  @override
  Future<void> delete(PageLanguage language) async {
    await _manager.deleteModel(languageOf(language).bcpCode);
  }
}
