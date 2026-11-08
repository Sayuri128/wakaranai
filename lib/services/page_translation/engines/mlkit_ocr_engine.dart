import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';

class MlKitOcrEngine implements PageOcrEngine {
  static const String engineId = 'mlkit';

  final Map<OcrScript, TextRecognizer> _recognizers =
      <OcrScript, TextRecognizer>{};

  @override
  String get id => engineId;

  @override
  Future<List<OcrBlock>> recognize(
    OcrInput input,
    PageLanguage language,
  ) async {
    final TextRecognizer recognizer = _recognizers.putIfAbsent(
      language.script,
      () => TextRecognizer(script: _script(language.script)),
    );
    try {
      final RecognizedText result = await recognizer.processImage(
        InputImage.fromFilePath(input.pngPath),
      );
      return result.blocks
          .map(
            (TextBlock block) => OcrBlock(
              box: block.boundingBox,
              text: block.text,
              lines: block.lines
                  .map((TextLine line) => line.boundingBox)
                  .toList(),
            ),
          )
          .toList();
    } on PlatformException catch (e) {
      final String message = '${e.code} ${e.message}'.toLowerCase();
      if (message.contains('download') || message.contains('waiting')) {
        throw const OcrModelPendingException();
      }
      rethrow;
    }
  }

  @override
  Future<void> close() async {
    for (final TextRecognizer recognizer in _recognizers.values) {
      await recognizer.close();
    }
    _recognizers.clear();
  }

  static TextRecognitionScript _script(OcrScript script) {
    switch (script) {
      case OcrScript.japanese:
        return TextRecognitionScript.japanese;
      case OcrScript.korean:
        return TextRecognitionScript.korean;
      case OcrScript.chinese:
        return TextRecognitionScript.chinese;
      case OcrScript.latin:
        return TextRecognitionScript.latin;
    }
  }
}
