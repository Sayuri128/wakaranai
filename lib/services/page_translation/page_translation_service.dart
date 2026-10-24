import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/page_translation_repository.dart';
import 'package:wakaranai/services/page_translation/bubble_analyzer.dart';
import 'package:wakaranai/services/page_translation/engines/page_ocr_engine.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/engines/page_translator.dart';
import 'package:wakaranai/services/page_translation/ocr_correction.dart';
import 'package:wakaranai/services/page_translation/page_translation_backend.dart';
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

const int _minTileHeight = 1024;
const double _singleTileAllowance = 1.25;
const double _tileOverlap = 0.15;
const double _duplicateOverlapShare = 0.6;
const int _upscaleBelowWidth = 1600;

List<PageTile> pageTiles(int width, int height) {
  final int maxTile = max(_minTileHeight, width * 2);
  if (height <= maxTile * _singleTileAllowance) {
    return <PageTile>[PageTile(0, height)];
  }

  final int overlap = (maxTile * _tileOverlap).round();
  final List<PageTile> tiles = <PageTile>[];
  int top = 0;
  while (true) {
    final int tileHeight = min(maxTile, height - top);
    tiles.add(PageTile(top, tileHeight));
    if (top + tileHeight >= height) {
      break;
    }
    top += maxTile - overlap;
  }
  return tiles;
}

List<BubbleLayout> dropDuplicateBubbles(List<BubbleLayout> layouts) {
  final List<BubbleLayout> kept = <BubbleLayout>[];
  for (final BubbleLayout layout in layouts) {
    final bool duplicate = kept.any(
      (BubbleLayout other) => _mostlyOverlap(layout.textBox, other.textBox),
    );
    if (!duplicate) {
      kept.add(layout);
    }
  }
  return kept;
}

bool _mostlyOverlap(ui.Rect a, ui.Rect b) {
  final ui.Rect overlap = a.intersect(b);
  if (overlap.width <= 0 || overlap.height <= 0) {
    return false;
  }
  final double smallerArea = min(_area(a), _area(b));
  return _area(overlap) > _duplicateOverlapShare * smallerArea;
}

double _area(ui.Rect rect) => rect.width * rect.height;

double ocrUpscaleFor(int width) {
  if (width < _upscaleBelowWidth) {
    return 2;
  }
  return 1;
}

typedef _RecognizedBubble = ({BubbleLayout layout, String text});

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
  Future<PageTranslationResult?> olderVersion(String path) {
    return repository.findOlderVersion(
      pagePath: path,
      engine: settings.engineKey,
      source: languages.source.code,
      target: languages.target.code,
    );
  }

  @override
  Future<String> translateText(String text) async {
    final List<String> translations = await _translate(<String>[text]);
    return translations.single;
  }

  @override
  Future<void> save(String path, PageTranslationResult result) {
    return repository.put(
      pagePath: path,
      engine: settings.engineKey,
      source: languages.source.code,
      target: languages.target.code,
      result: result,
    );
  }

  @override
  Future<PageTranslationResult> translate(
    String path,
    Map<String, String> headers,
  ) async {
    final PageBitmapLease lease = _bitmaps.acquire(path, headers);
    try {
      final PageBitmap bitmap = await lease.bitmap;
      final ui.Image image = bitmap.image;
      final Stopwatch watch = Stopwatch()..start();

      final Map<BubbleLayout, String> textByLayout = <BubbleLayout, String>{};
      for (final PageTile tile in pageTiles(image.width, image.height)) {
        final List<_RecognizedBubble> recognized = await _processTile(
          image,
          tile,
        );
        for (final _RecognizedBubble bubble in recognized) {
          textByLayout[bubble.layout] = bubble.text;
        }
      }

      final List<BubbleLayout> unique = dropDuplicateBubbles(
        textByLayout.keys.toList(),
      );
      final OcrTextCorrector? corrector = await OcrCorrectors.forLanguage(
        languages.source,
      );
      final List<String> sources = <String>[];
      for (final BubbleLayout layout in unique) {
        final String text = textByLayout[layout]!;
        sources.add(corrector?.correct(text) ?? text);
      }

      final int ocrMilliseconds = watch.elapsedMilliseconds;
      final List<String> translations = await _translate(sources);
      final int totalMilliseconds = watch.elapsedMilliseconds;
      logger.i(
        '[page-translation] engine=${settings.engineKey} '
        'bubbles=${sources.length} ocr=${ocrMilliseconds}ms '
        'translate=${totalMilliseconds - ocrMilliseconds}ms '
        'total=${totalMilliseconds}ms',
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

      await save(path, result);
      return result;
    } finally {
      lease.release();
    }
  }

  Future<List<String>> _translate(List<String> sources) async {
    if (sources.isEmpty) {
      return const <String>[];
    }
    return _translator.translate(
      sources,
      from: languages.source,
      to: languages.target,
    );
  }

  Future<List<_RecognizedBubble>> _processTile(
    ui.Image image,
    PageTile tile,
  ) async {
    final bool wholePage = tile.top == 0 && tile.height == image.height;
    final ui.Image tileImage = wholePage
        ? image
        : await _render(image, tile, 1);
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
        return const <_RecognizedBubble>[];
      }
      await png.writeAsBytes(encoded.buffer.asUint8List(), flush: true);

      final PagePixels pixels = PagePixels(
        rgba: raw.buffer.asUint8List(),
        width: tileImage.width,
        height: tileImage.height,
      );
      final List<OcrBlock> recognized = await _ocr.recognize(
        OcrInput(
          pngPath: png.path,
          rgba: pixels.rgba,
          width: pixels.width,
          height: pixels.height,
        ),
        languages.source,
      );
      final List<OcrBlock> blocks = recognized
          .map((OcrBlock block) => block.scale(1 / ocrScale))
          .toList();
      final List<TextGroup> groups = groupOcrBlocks(
        blocks,
        languages.source,
        hasBorderBetween: (ui.Rect a, ui.Rect b) =>
            hasBorderBetween(pixels, a, b),
      );
      if (groups.isEmpty) {
        return const <_RecognizedBubble>[];
      }

      final List<BubbleLayout> layouts = await compute(
        analyzeBubbles,
        BubbleAnalysisRequest(
          pixels: pixels,
          boxes: groups.map((TextGroup group) => group.box).toList(),
        ),
      );
      final ui.Offset offset = ui.Offset(0, tile.top.toDouble());
      return <_RecognizedBubble>[
        for (int i = 0; i < groups.length; i++)
          (layout: _shiftLayout(layouts[i], offset), text: groups[i].text),
      ];
    } finally {
      if (!identical(ocrImage, tileImage)) {
        ocrImage.dispose();
      }
      if (!wholePage) {
        tileImage.dispose();
      }
      if (await png.exists()) {
        await png.delete();
      }
    }
  }

  BubbleLayout _shiftLayout(BubbleLayout layout, ui.Offset offset) {
    return BubbleLayout(
      textBox: layout.textBox.shift(offset),
      layoutBox: layout.layoutBox.shift(offset),
      fillColor: layout.fillColor,
      erase: layout.erase,
    );
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
    final Directory temporary = await getTemporaryDirectory();
    final Directory directory = Directory(p.join(temporary.path, 'page_ocr'));
    await directory.create(recursive: true);
    final int stamp = DateTime.now().microsecondsSinceEpoch;
    return File(p.join(directory.path, 'tile_$stamp.png'));
  }

  @override
  Future<void> dispose() async {
    await _ocr.close();
    await _translator.close();
  }
}
