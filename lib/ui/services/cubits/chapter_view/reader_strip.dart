import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:wakaranai/utils/page_image.dart';

enum ChapterLoad { idle, loading, failed }

class LoadedChapter {
  const LoadedChapter({
    required this.chapter,
    required this.pages,
    required this.headers,
  });

  final Chapter chapter;
  final Pages pages;
  final Map<String, String> headers;

  String get uid => chapter.uid;

  int get pageCount => pages.value.length;

  bool get isDownloaded =>
      pages.value.isNotEmpty && isLocalPagePath(pages.value.first);
}

sealed class ReaderStripItem {
  const ReaderStripItem();

  String get key;
}

class ReaderStripPage extends ReaderStripItem {
  const ReaderStripPage({required this.chapter, required this.pageIndex});

  final LoadedChapter chapter;
  final int pageIndex;

  String get path => chapter.pages.value[pageIndex];

  bool get isLastOfChapter => pageIndex == chapter.pageCount - 1;

  @override
  String get key => 'page:${chapter.uid}:$pageIndex';
}

class ReaderStripDivider extends ReaderStripItem {
  const ReaderStripDivider({
    required this.finished,
    required this.next,
    this.nextLoaded,
    this.load = ChapterLoad.idle,
  });

  final LoadedChapter finished;
  final Chapter? next;
  final LoadedChapter? nextLoaded;
  final ChapterLoad load;

  bool get isEnd => next == null;

  @override
  String get key => 'divider:${finished.uid}';
}

class ReaderStripPrevious extends ReaderStripItem {
  const ReaderStripPrevious({required this.previous, required this.load});

  final Chapter previous;
  final ChapterLoad load;

  @override
  String get key => 'previous:${previous.uid}';
}

class ReaderStrip {
  ReaderStrip._(this.items, this._pageOffsets);

  factory ReaderStrip.build({
    required List<LoadedChapter> chapters,
    required List<Chapter> order,
    ChapterLoad nextLoad = ChapterLoad.idle,
    ChapterLoad previousLoad = ChapterLoad.idle,
  }) {
    final List<ReaderStripItem> items = <ReaderStripItem>[];
    final Map<String, int> pageOffsets = <String, int>{};
    if (chapters.isEmpty) {
      return ReaderStrip._(items, pageOffsets);
    }

    final Chapter? previous = chapterBefore(order, chapters.first.uid);
    if (previous != null) {
      items.add(ReaderStripPrevious(previous: previous, load: previousLoad));
    }

    for (int index = 0; index < chapters.length; index++) {
      final LoadedChapter chapter = chapters[index];
      pageOffsets[chapter.uid] = items.length;
      for (int page = 0; page < chapter.pageCount; page++) {
        items.add(ReaderStripPage(chapter: chapter, pageIndex: page));
      }
      final bool isLast = index == chapters.length - 1;
      items.add(
        ReaderStripDivider(
          finished: chapter,
          next: isLast
              ? chapterAfter(order, chapter.uid)
              : chapters[index + 1].chapter,
          nextLoaded: isLast ? null : chapters[index + 1],
          load: isLast ? nextLoad : ChapterLoad.idle,
        ),
      );
    }
    return ReaderStrip._(items, pageOffsets);
  }

  final List<ReaderStripItem> items;
  final Map<String, int> _pageOffsets;

  int get length => items.length;

  int? indexOfPage(String chapterUid, int pageIndex) {
    final int? offset = _pageOffsets[chapterUid];
    if (offset == null) {
      return null;
    }
    return offset + pageIndex;
  }

  int? indexOfKey(String key) {
    for (int index = 0; index < items.length; index++) {
      if (items[index].key == key) {
        return index;
      }
    }
    return null;
  }
}

Chapter? chapterAfter(List<Chapter> order, String uid) {
  final int index = order.indexWhere((Chapter chapter) => chapter.uid == uid);
  if (index < 0 || index + 1 >= order.length) {
    return null;
  }
  return order[index + 1];
}

Chapter? chapterBefore(List<Chapter> order, String uid) {
  final int index = order.indexWhere((Chapter chapter) => chapter.uid == uid);
  if (index <= 0) {
    return null;
  }
  return order[index - 1];
}
