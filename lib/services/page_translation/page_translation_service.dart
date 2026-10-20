import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/services/page_translation/bubble_analyzer.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/ocr_correction.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/text_grouping.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/utils/page_bitmap_cache.dart';
import 'package:wakaranai/utils/page_image.dart';

class PageTile {
  const PageTile(this.top, this.height);

  final int top;
  final int height;

  @override
  bool operator ==(Object other) =>
      other is PageTile && other.top == top && other.height == height;

  @override
  int get hashCode => Object.hash(top, height);

  @override
  String toString() => 'PageTile($top, $height)';
}

List<PageTile> pageTiles(int width, int height) {
  final int maxTile = max(1024, width * 2);
  if (height <= maxTile * 1.25) return <PageTile>[PageTile(0, height)];

  final int overlap = (maxTile * 0.15).round();
  final List<PageTile> tiles = <PageTile>[];
  int top = 0;
  while (true) {
    final int tileHeight = min(maxTile, height - top);
    tiles.add(PageTile(top, tileHeight));
    if (top + tileHeight >= height) break;
    top += maxTile - overlap;
  }
  return tiles;
}

List<BubbleLayout> dropDuplicateBubbles(List<BubbleLayout> layouts) {
  final List<BubbleLayout> kept = <BubbleLayout>[];
  for (final BubbleLayout layout in layouts) {
    final double area = layout.textBox.width * layout.textBox.height;
    final bool duplicate = kept.any((BubbleLayout other) {
      final ui.Rect overlap = other.textBox.intersect(layout.textBox);
      if (overlap.width <= 0 || overlap.height <= 0) return false;
      final double otherArea = other.textBox.width * other.textBox.height;
      return overlap.width * overlap.height > 0.6 * min(area, otherArea);
    });
    if (!duplicate) kept.add(layout);
  }
  return kept;
}

abstract class PageTranslationBackend {
  Future<bool> isReady();

  Future<PageTranslationResult?> cached(String path);

  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  );

  Future<void> dispose();
}

double ocrUpscaleFor(int width) => width < 1600 ? 2 : 1;

class PageTranslationService implements PageTranslationBackend {
  PageTranslationService({
    required this.repository,
    required this.settings,
    required this.languages,
    PageBitmapCache? bitmaps,
  }) : _bitmaps = bitmaps ?? PageBitmapCache.instance,
       _ocr = PageTranslationEngines.ocrById(settings.ocrEngine).create(),
       _translator = PageTranslationEngines.translatorById(
         settings.translator,
       ).create();

  final PageTranslationRepository repository;
  final PageTranslationSettings settings;
  final TitleLanguages languages;
  final PageBitmapCache _bitmaps;
  final PageOcrEngine _ocr;
  final PageTranslator _translator;

  @override
  Future<bool> isReady() =>
      _translator.isReady(languages.source, languages.target);

  String _key(String path) => PageTranslationRepository.keyFor(
    pagePath: path,
    engine: settings.engineKey,
    source: languages.source.code,
    target: languages.target.code,
  );

  @override
  Future<PageTranslationResult?> cached(String path) =>
      repository.get(_key(path));

  @override
  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  ) async {
    final PageBitmapLease lease = _bitmaps.acquire(path, headers);
    try {
      final PageBitmap bitmap = await lease.bitmap;
      final ui.Image image = bitmap.image;
      final List<BubbleLayout> layouts = <BubbleLayout>[];
      final List<String> texts = <String>[];

      for (final PageTile tile in pageTiles(image.width, image.height)) {
        final List<(BubbleLayout, String)> found = await _processTile(
          image,
          tile,
        );
        for (final (BubbleLayout layout, String text) in found) {
          layouts.add(layout);
          texts.add(text);
        }
      }

      final List<BubbleLayout> unique = dropDuplicateBubbles(layouts);
      final OcrTextCorrector? corrector = await OcrCorrectors.forLanguage(
        languages.source,
      );
      final List<String> sources = unique.map((BubbleLayout l) {
        final String text = texts[layouts.indexOf(l)];
        return corrector?.correct(text) ?? text;
      }).toList();
      final List<String> translations = sources.isEmpty
          ? const <String>[]
          : await _translator.translate(
              sources,
              from: languages.source,
              to: languages.target,
            );

      final PageTranslationResult result = PageTranslationResult(
        width: image.width,
        height: image.height,
        bubbles: <TranslatedBubble>[
          for (int i = 0; i < unique.length; i++)
            TranslatedBubble(
              textBox: unique[i].textBox,
              layoutBox: unique[i].layoutBox,
              fillColor: unique[i].fillColor,
              erase: unique[i].erase,
              source: sources[i],
              translation: translations[i],
            ),
        ],
      );

      await repository.put(
        pagePath: path,
        engine: settings.engineKey,
        source: languages.source.code,
        target: languages.target.code,
        result: result,
      );
      return result;
    } finally {
      lease.release();
    }
  }

  Future<List<(BubbleLayout, String)>> _processTile(
    ui.Image image,
    PageTile tile,
  ) async {
    final bool whole = tile.top == 0 && tile.height == image.height;
    final ui.Image tileImage = whole ? image : await _render(image, tile, 1);
    final double ocrScale = ocrUpscaleFor(tileImage.width);
    final ui.Image ocrImage = ocrScale == 1
        ? tileImage
        : await _render(image, tile, ocrScale);
    final File png = await _tempPng();
    try {
      final ByteData? encoded = await ocrImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final ByteData? raw = await tileImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (encoded == null || raw == null) {
        return const <(BubbleLayout, String)>[];
      }
      await png.writeAsBytes(encoded.buffer.asUint8List(), flush: true);

      final Uint8List rgba = raw.buffer.asUint8List();
      final List<OcrBlock> blocks = (await _ocr.recognize(
        OcrInput(
          pngPath: png.path,
          rgba: rgba,
          width: tileImage.width,
          height: tileImage.height,
        ),
        languages.source,
      )).map((OcrBlock b) => b.scale(1 / ocrScale)).toList();
      final List<TextGroup> groups = groupOcrBlocks(blocks, languages.source);
      if (groups.isEmpty) return const <(BubbleLayout, String)>[];

      final List<BubbleLayout> layouts = await compute(
        analyzeBubbles,
        BubbleAnalysisRequest(
          rgba: rgba,
          width: tileImage.width,
          height: tileImage.height,
          boxes: groups.map((TextGroup g) => g.box).toList(),
        ),
      );
      final ui.Offset offset = ui.Offset(0, tile.top.toDouble());
      return <(BubbleLayout, String)>[
        for (int i = 0; i < groups.length; i++)
          (
            BubbleLayout(
              textBox: layouts[i].textBox.shift(offset),
              layoutBox: layouts[i].layoutBox.shift(offset),
              fillColor: layouts[i].fillColor,
              erase: layouts[i].erase,
            ),
            groups[i].text,
          ),
      ];
    } finally {
      if (!identical(ocrImage, tileImage)) ocrImage.dispose();
      if (!whole) tileImage.dispose();
      if (await png.exists()) await png.delete();
    }
  }

  Future<ui.Image> _render(ui.Image image, PageTile tile, double scale) {
    final int width = (image.width * scale).round();
    final int height = (tile.height * scale).round();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(
        0,
        tile.top.toDouble(),
        image.width.toDouble(),
        tile.height.toDouble(),
      ),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.high,
    );
    final ui.Picture picture = recorder.endRecording();
    return picture.toImage(width, height).whenComplete(picture.dispose);
  }

  Future<File> _tempPng() async {
    final Directory dir = Directory(
      p.join((await getTemporaryDirectory()).path, 'page_ocr'),
    );
    await dir.create(recursive: true);
    return File(
      p.join(dir.path, 'tile_${DateTime.now().microsecondsSinceEpoch}.png'),
    );
  }

  @override
  Future<void> dispose() async {
    await _ocr.close();
    await _translator.close();
  }
}
