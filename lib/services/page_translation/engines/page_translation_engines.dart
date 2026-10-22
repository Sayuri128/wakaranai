import 'package:collection/collection.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_translator.dart';
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
        EngineDescriptor<PageTranslator>(
          id: GemmaTranslator.engineId,
          name: 'Gemma 4 E2B',
          isLocal: true,
          create: GemmaTranslator.new,
        ),
      ];

  static EngineDescriptor<PageOcrEngine> ocrById(String? id) {
    final EngineDescriptor<PageOcrEngine>? match = ocr.firstWhereOrNull(
      (EngineDescriptor<PageOcrEngine> engine) => engine.id == id,
    );
    return match ?? ocr.first;
  }

  static EngineDescriptor<PageTranslator> translatorById(String? id) {
    final EngineDescriptor<PageTranslator>? match = translators
        .firstWhereOrNull(
          (EngineDescriptor<PageTranslator> engine) => engine.id == id,
        );
    return match ?? translators.first;
  }
}
