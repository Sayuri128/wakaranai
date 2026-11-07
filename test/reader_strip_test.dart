import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';

Chapter _chapter(String uid) =>
    Chapter(uid: uid, title: 'Chapter $uid', data: const <String, dynamic>{});

LoadedChapter _loaded(String uid, int pages, {bool local = false}) {
  return LoadedChapter(
    chapter: _chapter(uid),
    pages: Pages(
      chapterUid: uid,
      value: List<String>.generate(
        pages,
        (int index) =>
            local ? '/data/$uid/$index.png' : 'https://cdn/$uid/$index.png',
      ),
    ),
    headers: const <String, String>{},
  );
}

void main() {
  final List<Chapter> order = <Chapter>[
    _chapter('1'),
    _chapter('2'),
    _chapter('3'),
  ];

  test('lays out pages with a divider after every chapter', () {
    final ReaderStrip strip = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('1', 2), _loaded('2', 3)],
      order: order,
    );

    expect(strip.items.map((ReaderStripItem item) => item.runtimeType), <Type>[
      ReaderStripPage,
      ReaderStripPage,
      ReaderStripDivider,
      ReaderStripPage,
      ReaderStripPage,
      ReaderStripPage,
      ReaderStripDivider,
    ]);
    final ReaderStripDivider between = strip.items[2] as ReaderStripDivider;
    expect(between.finished.uid, '1');
    expect(between.next?.uid, '2');
    expect(between.nextLoaded?.uid, '2');
    final ReaderStripDivider trailing = strip.items.last as ReaderStripDivider;
    expect(trailing.next?.uid, '3');
    expect(trailing.nextLoaded, isNull);
  });

  test('starts with a previous card when an earlier chapter exists', () {
    final ReaderStrip strip = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('2', 1)],
      order: order,
      previousLoad: ChapterLoad.loading,
    );

    final ReaderStripPrevious previous =
        strip.items.first as ReaderStripPrevious;
    expect(previous.previous.uid, '1');
    expect(previous.load, ChapterLoad.loading);
    expect(strip.indexOfPage('2', 0), 1);
  });

  test('marks the end after the last chapter of the group', () {
    final ReaderStrip strip = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('3', 1)],
      order: order,
    );

    final ReaderStripDivider end = strip.items.last as ReaderStripDivider;
    expect(end.isEnd, isTrue);
  });

  test('only the trailing divider carries the next chapter load state', () {
    final ReaderStrip strip = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('1', 1), _loaded('2', 1)],
      order: order,
      nextLoad: ChapterLoad.failed,
    );

    expect((strip.items[1] as ReaderStripDivider).load, ChapterLoad.idle);
    expect((strip.items.last as ReaderStripDivider).load, ChapterLoad.failed);
  });

  test('appending a chapter keeps every earlier index stable', () {
    final ReaderStrip before = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('1', 3)],
      order: order,
    );
    final ReaderStrip after = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('1', 3), _loaded('2', 2)],
      order: order,
    );

    for (int index = 0; index < before.length; index++) {
      expect(after.items[index].key, before.items[index].key);
    }
  });

  test('finds a page again after a chapter is prepended', () {
    final ReaderStrip before = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('2', 3)],
      order: order,
    );
    final String key = before.items[before.indexOfPage('2', 1)!].key;
    final ReaderStrip after = ReaderStrip.build(
      chapters: <LoadedChapter>[_loaded('1', 4), _loaded('2', 3)],
      order: order,
    );

    expect(after.indexOfKey(key), after.indexOfPage('2', 1));
    expect(after.indexOfPage('2', 1), 4 + 1 + 1);
  });

  test('knows whether a chapter was downloaded', () {
    expect(_loaded('1', 2, local: true).isDownloaded, isTrue);
    expect(_loaded('1', 2).isDownloaded, isFalse);
  });

  test('looks up neighbouring chapters in reading order', () {
    expect(chapterAfter(order, '1')?.uid, '2');
    expect(chapterAfter(order, '3'), isNull);
    expect(chapterBefore(order, '1'), isNull);
    expect(chapterBefore(order, '3')?.uid, '2');
    expect(chapterAfter(order, 'missing'), isNull);
  });
}
