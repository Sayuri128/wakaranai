import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';

String readerPageFitLabel(ReaderPageFit fit) {
  switch (fit) {
    case ReaderPageFit.screen:
      return S.current.reader_page_fit_screen;
    case ReaderPageFit.width:
      return S.current.reader_page_fit_width;
    case ReaderPageFit.height:
      return S.current.reader_page_fit_height;
  }
}

String readerBackgroundLabel(ReaderBackground background) {
  switch (background) {
    case ReaderBackground.black:
      return S.current.reader_background_black;
    case ReaderBackground.grey:
      return S.current.reader_background_grey;
    case ReaderBackground.white:
      return S.current.reader_background_white;
    case ReaderBackground.theme:
      return S.current.reader_background_theme;
  }
}

IconData readerPageFitIcon(ReaderPageFit fit) {
  switch (fit) {
    case ReaderPageFit.screen:
      return Icons.fit_screen_rounded;
    case ReaderPageFit.width:
      return Icons.swap_horiz_rounded;
    case ReaderPageFit.height:
      return Icons.swap_vert_rounded;
  }
}

IconData readerBackgroundIcon(ReaderBackground background) {
  switch (background) {
    case ReaderBackground.black:
      return Icons.dark_mode_rounded;
    case ReaderBackground.grey:
      return Icons.contrast_rounded;
    case ReaderBackground.white:
      return Icons.light_mode_rounded;
    case ReaderBackground.theme:
      return Icons.palette_rounded;
  }
}
