import 'package:wakaranai/generated/l10n.dart';

enum ChapterViewMode { RIGHT_TO_LEFT, LEFT_TO_RIGHT, WEBTOON }

String chapterViewModelToString(ChapterViewMode mode) {
  switch (mode) {
    case ChapterViewMode.RIGHT_TO_LEFT:
      return S.current.right_to_left_read_mode;
    case ChapterViewMode.LEFT_TO_RIGHT:
      return S.current.left_to_right_read_mode;
    case ChapterViewMode.WEBTOON:
      return S.current.webtoon;
  }
}
