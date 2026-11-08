import 'dart:typed_data';
import 'dart:ui';

import 'package:wakaranai/services/page_translation/page_language.dart';

class OcrInput {
  const OcrInput({
    required this.pngPath,
    required this.rgba,
    required this.width,
    required this.height,
  });

  final String pngPath;
  final Uint8List rgba;
  final int width;
  final int height;
}

class OcrBlock {
  const OcrBlock({required this.box, required this.text, required this.lines});

  final Rect box;
  final String text;
  final List<Rect> lines;

  OcrBlock scale(double factor) {
    if (factor == 1) {
      return this;
    }
    Rect scaled(Rect rect) => Rect.fromLTRB(
      rect.left * factor,
      rect.top * factor,
      rect.right * factor,
      rect.bottom * factor,
    );
    return OcrBlock(
      box: scaled(box),
      text: text,
      lines: lines.map(scaled).toList(),
    );
  }

  OcrBlock translate(double dx, double dy) {
    final Offset offset = Offset(dx, dy);
    return OcrBlock(
      box: box.shift(offset),
      text: text,
      lines: lines.map((Rect line) => line.shift(offset)).toList(),
    );
  }
}

class OcrModelPendingException implements Exception {
  const OcrModelPendingException();
}

abstract class PageOcrEngine {
  String get id;

  Future<List<OcrBlock>> recognize(OcrInput input, PageLanguage language);

  Future<void> close();
}
