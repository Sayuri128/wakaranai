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
      (BubbleLayout other) => mostlyOverlap(layout.textBox, other.textBox),
    );
    if (!duplicate) {
      kept.add(layout);
    }
  }
  return kept;
}

bool mostlyOverlap(ui.Rect a, ui.Rect b) {
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

typedef _RecognizedArea = ({PagePixels pixels, List<OcrBlock> blocks});

const double _minRegionSide = 8;
const double _regionOcrWidth = 900;
const double _maxRegionUpscale = 3;

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
      glossary: languages.glossary,
    );
  }

  Future<List<_RecognizedBubble>> _processTile(
    ui.Image image,
    PageTile tile,
  ) async {
    final ui.Rect area = ui.Rect.fromLTWH(
      0,
      tile.top.toDouble(),
      image.width.toDouble(),
      tile.height.toDouble(),
    );
    final _RecognizedArea? recognized = await _recognizeArea(
      image,
      area,
      ocrUpscaleFor(image.width),
    );
    if (recognized == null) {
      return const <_RecognizedBubble>[];
    }
    final List<TextGroup> groups = groupOcrBlocks(
      recognized.blocks,
      languages.source,
      hasBorderBetween: (ui.Rect a, ui.Rect b) =>
          hasBorderBetween(recognized.pixels, a, b),
    );
    if (groups.isEmpty) {
      return const <_RecognizedBubble>[];
    }

    final List<BubbleLayout> layouts = await compute(
      analyzeBubbles,
      BubbleAnalysisRequest(
        pixels: recognized.pixels,
        boxes: groups.map((TextGroup group) => group.box).toList(),
      ),
    );
    return <_RecognizedBubble>[
      for (int i = 0; i < groups.length; i++)
        (layout: _shiftLayout(layouts[i], area.topLeft), text: groups[i].text),
    ];
  }

  @override
  Future<PageTranslationResult?> translateRegion(
    String path,
    Map<String, String> headers,
    ui.Rect region,
    PageTranslationResult current,
  ) async {
    final PageBitmapLease lease = _bitmaps.acquire(path, headers);
    try {
      final PageBitmap bitmap = await lease.bitmap;
      final ui.Image image = bitmap.image;
      final ui.Rect area = _roundOut(
        region.intersect(
          ui.Rect.fromLTWH(
            0,
            0,
            image.width.toDouble(),
            image.height.toDouble(),
          ),
        ),
      );
      if (area.width < _minRegionSide || area.height < _minRegionSide) {
        return null;
      }

      final _RecognizedArea? recognized = await _recognizeArea(
        image,
        area,
        _regionUpscale(area),
      );
      if (recognized == null) {
        return null;
      }
      final List<TextGroup> groups = groupOcrBlocks(
        recognized.blocks,
        languages.source,
      );
      if (groups.isEmpty) {
        return null;
      }

      final ui.Rect textBox = groups
          .map((TextGroup group) => group.box)
          .reduce((ui.Rect a, ui.Rect b) => a.expandToInclude(b));
      final String joiner = languages.source.usesSpaces ? ' ' : '';
      final String recognizedText = groups
          .map((TextGroup group) => group.text)
          .join(joiner);
      final OcrTextCorrector? corrector = await OcrCorrectors.forLanguage(
        languages.source,
      );
      final String source =
          corrector?.correct(recognizedText) ?? recognizedText;

      final List<BubbleLayout> layouts = await compute(
        analyzeBubbles,
        BubbleAnalysisRequest(
          pixels: recognized.pixels,
          boxes: <ui.Rect>[textBox],
        ),
      );
      final BubbleLayout layout = _shiftLayout(layouts.single, area.topLeft);
      final List<String> translations = await _translate(<String>[source]);

      final TranslatedBubble added = TranslatedBubble(
        textBox: layout.textBox,
        layoutBox: layout.layoutBox,
        fillColor: layout.fillColor,
        erase: layout.erase,
        source: source,
        translation: translations.single,
      );
      final PageTranslationResult result = PageTranslationResult(
        width: current.width,
        height: current.height,
        bubbles: <TranslatedBubble>[
          for (final TranslatedBubble bubble in current.bubbles)
            if (!mostlyOverlap(bubble.textBox, added.textBox)) bubble,
          added,
        ],
      );
      await save(path, result);
      return result;
    } finally {
      lease.release();
    }
  }

  double _regionUpscale(ui.Rect area) {
    final double wanted = _regionOcrWidth / area.width;
    return wanted.clamp(1, _maxRegionUpscale).toDouble();
  }

  ui.Rect _roundOut(ui.Rect rect) {
    return ui.Rect.fromLTRB(
      rect.left.floorToDouble(),
      rect.top.floorToDouble(),
      rect.right.ceilToDouble(),
      rect.bottom.ceilToDouble(),
    );
  }

  Future<_RecognizedArea?> _recognizeArea(
    ui.Image image,
    ui.Rect area,
    double ocrScale,
  ) async {
    final bool wholeImage =
        area.left == 0 &&
        area.top == 0 &&
        area.width == image.width &&
        area.height == image.height;
    final ui.Image areaImage = wholeImage
        ? image
        : await _render(image, area, 1);
    final ui.Image ocrImage = ocrScale == 1
        ? areaImage
        : await _render(image, area, ocrScale);
    final File png = await _tempPng();
    try {
      final ByteData? encoded = await ocrImage.toByteData(
        format: ui.ImageByteFormat.png,
      );
      final ByteData? raw = await areaImage.toByteData(
        format: ui.ImageByteFormat.rawRgba,
      );
      if (encoded == null || raw == null) {
        return null;
      }
      await png.writeAsBytes(encoded.buffer.asUint8List(), flush: true);

      final PagePixels pixels = PagePixels(
        rgba: raw.buffer.asUint8List(),
        width: areaImage.width,
        height: areaImage.height,
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
      return (
        pixels: pixels,
        blocks: recognized
            .map((OcrBlock block) => block.scale(1 / ocrScale))
            .toList(),
      );
    } finally {
      if (!identical(ocrImage, areaImage)) {
        ocrImage.dispose();
      }
      if (!wholeImage) {
        areaImage.dispose();
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

  Future<ui.Image> _render(ui.Image image, ui.Rect area, double scale) {
    final int width = (area.width * scale).round();
    final int height = (area.height * scale).round();
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      area,
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
