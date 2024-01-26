import 'package:wakaranai/generated/l10n.dart';

enum ChapterViewMode { rightToLeft, leftToRight, webtoon }

String chapterViewModelToString(ChapterViewMode mode) {
  switch (mode) {
    case ChapterViewMode.rightToLeft:
      return S.current.chapter_viewer_right_to_left_read_mode;
    case ChapterViewMode.leftToRight:
      return S.current.chapter_viewer_left_to_right_read_mode;
    case ChapterViewMode.webtoon:
      return S.current.chapter_viewer_webtoon;
  }
}
