import 'dart:typed_data';

import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_spreads.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';
import 'package:wakaranai/utils/page_border_trim.dart';

Chapter _chapter(String uid) =>
    Chapter(uid: uid, title: 'Chapter $uid', data: const <String, dynamic>{});

LoadedChapter _loaded(String uid, int pages) {
  return LoadedChapter(
    chapter: _chapter(uid),
    pages: Pages(
      chapterUid: uid,
      value: List<String>.generate(
        pages,
        (int index) => 'https://cdn/$uid/$index.png',
      ),
    ),
    headers: const <String, String>{},
  );
}

Uint8List _canvas(int width, int height, int background) {
  final Uint8List pixels = Uint8List(width * height * 4);
  for (int index = 0; index < width * height; index++) {
    pixels[index * 4] = background;
    pixels[index * 4 + 1] = background;
    pixels[index * 4 + 2] = background;
    pixels[index * 4 + 3] = 255;
  }
  return pixels;
}

void _paint(Uint8List pixels, int width, int left, int top, int right,
    int bottom, int value) {
  for (int y = top; y < bottom; y++) {
    for (int x = left; x < right; x++) {
      final int offset = (y * width + x) * 4;
      pixels[offset] = value;
      pixels[offset + 1] = value;
      pixels[offset + 2] = value;
    }
  }
}

void main() {
  group('ReaderSpreads', () {
    final List<Chapter> order = <Chapter>[_chapter('1'), _chapter('2')];
    final ReaderStrip strip = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('1', 5)],
      order: order,
    );

    test('keeps the first page alone and pairs the rest', () {
      final ReaderSpreads spreads = ReaderSpreads.pair(
        strip.items,
        isWide: (_) => false,
      );
      expect(spreads.spreads, <List<int>>[
        <int>[0],
        <int>[1, 2],
        <int>[3, 4],
        <int>[5],
      ]);
      expect(spreads.spreadOfItem(4), 2);
      expect(spreads.lastItemOf(1), 2);
    });

    test('never pairs a wide page', () {
      final ReaderSpreads spreads = ReaderSpreads.pair(
        strip.items,
        isWide: (ReaderStripPage page) => page.pageIndex == 2,
      );
      expect(spreads.spreads, <List<int>>[
        <int>[0],
        <int>[1],
        <int>[2],
        <int>[3, 4],
        <int>[5],
      ]);
    });

    test('maps one item per spread when pairing is off', () {
      final ReaderSpreads spreads = ReaderSpreads.single(strip.length);
      expect(spreads.length, strip.length);
      expect(spreads.spreadOfItem(3), 3);
    });
  });

  group('PageBorderTrimmer', () {
    test('trims a white margin around the art', () {
      final Uint8List pixels = _canvas(100, 100, 255);
      _paint(pixels, 100, 10, 5, 90, 95, 0);
      final PageTrim trim = PageBorderTrimmer.computeTrim(pixels, 100, 100);
      expect(trim.left, closeTo(0.09, 0.02));
      expect(trim.top, closeTo(0.04, 0.02));
      expect(trim.right, closeTo(0.91, 0.02));
      expect(trim.bottom, closeTo(0.96, 0.02));
    });

    test('leaves pages without a plain margin untouched', () {
      final Uint8List pixels = _canvas(100, 100, 128);
      expect(PageBorderTrimmer.computeTrim(pixels, 100, 100).isNone, isTrue);
    });

    test('refuses to crop away most of the page', () {
      final Uint8List pixels = _canvas(100, 100, 255);
      _paint(pixels, 100, 45, 45, 55, 55, 0);
      expect(PageBorderTrimmer.computeTrim(pixels, 100, 100).isNone, isTrue);
    });
  });

  test('reader preferences survive a round trip', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final ReaderPreferencesStore store = ReaderPreferencesStore();
    const ReaderPreferences preferences = ReaderPreferences(
      volumeKeys: true,
      pageFit: ReaderPageFit.width,
      background: ReaderBackground.white,
      cropBorders: true,
      doublePageSpread: true,
      incognito: true,
    );
    await store.write(preferences);
    expect(await ReaderPreferencesStore().read(), preferences);
  });
}
