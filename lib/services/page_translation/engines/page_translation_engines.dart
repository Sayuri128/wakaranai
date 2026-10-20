import 'package:collection/collection.dart';
import 'package:wakaranai/services/page_translation/engines/mlkit_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/engines/mlkit_translator.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';

class EngineDescriptor<T> {
  const EngineDescriptor({
    required this.id,
    required this.name,
    required this.isLocal,
    required this.create,
    this.requiresApiKey = false,
    this.models,
  });

  final String id;
  final String name;
  final bool isLocal;
  final bool requiresApiKey;
  final T Function() create;
  final TranslationModelStore Function()? models;
}

class PageTranslationEngines {
  static final List<EngineDescriptor<PageOcrEngine>> ocr =
      <EngineDescriptor<PageOcrEngine>>[
        EngineDescriptor<PageOcrEngine>(
          id: MlKitOcrEngine.engineId,
          name: 'ML Kit',
          isLocal: true,
          create: MlKitOcrEngine.new,
        ),
      ];

  static final List<EngineDescriptor<PageTranslator>> translators =
      <EngineDescriptor<PageTranslator>>[
        EngineDescriptor<PageTranslator>(
          id: MlKitTranslator.engineId,
          name: 'ML Kit',
          isLocal: true,
          create: MlKitTranslator.new,
          models: MlKitModelStore.new,
        ),
      ];

  static EngineDescriptor<PageOcrEngine> ocrById(String? id) =>
      ocr.firstWhereOrNull((EngineDescriptor<PageOcrEngine> e) => e.id == id) ??
      ocr.first;

  static EngineDescriptor<PageTranslator> translatorById(String? id) =>
      translators.firstWhereOrNull(
        (EngineDescriptor<PageTranslator> e) => e.id == id,
      ) ??
      translators.first;
}
