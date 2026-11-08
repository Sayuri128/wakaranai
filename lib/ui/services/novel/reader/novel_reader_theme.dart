import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/novel_reader_preferences.dart';
import 'package:wakaranai/utils/app_colors.dart';

class NovelReaderColors {
  const NovelReaderColors({required this.background, required this.text});

  final Color background;
  final Color text;

  static const Color _blackText = Color(0xFFD6D6D6);
  static const Color _sepiaBackground = Color(0xFFF4ECD8);
  static const Color _sepiaText = Color(0xFF5B4636);
  static const Color _whiteText = Color(0xFF1F1F1F);

  factory NovelReaderColors.of(NovelReaderBackground background) {
    switch (background) {
      case NovelReaderBackground.theme:
        return NovelReaderColors(
          background: AppColors.backgroundColor,
          text: AppColors.mainWhite,
        );
      case NovelReaderBackground.black:
        return const NovelReaderColors(
          background: Colors.black,
          text: _blackText,
        );
      case NovelReaderBackground.sepia:
        return const NovelReaderColors(
          background: _sepiaBackground,
          text: _sepiaText,
        );
      case NovelReaderBackground.white:
        return const NovelReaderColors(
          background: Colors.white,
          text: _whiteText,
        );
    }
  }
}

String novelReaderFontFamily(NovelReaderFont font) {
  switch (font) {
    case NovelReaderFont.ubuntu:
      return 'Ubuntu';
    case NovelReaderFont.serif:
      return 'serif';
  }
}

String novelReaderFontLabel(NovelReaderFont font) {
  switch (font) {
    case NovelReaderFont.ubuntu:
      return S.current.novel_reader_font_ubuntu;
    case NovelReaderFont.serif:
      return S.current.novel_reader_font_serif;
  }
}

String novelReaderBackgroundLabel(NovelReaderBackground background) {
  switch (background) {
    case NovelReaderBackground.theme:
      return S.current.reader_background_theme;
    case NovelReaderBackground.black:
      return S.current.reader_background_black;
    case NovelReaderBackground.sepia:
      return S.current.novel_reader_background_sepia;
    case NovelReaderBackground.white:
      return S.current.reader_background_white;
  }
}

TextStyle novelReaderTextStyle(NovelReaderPreferences preferences) {
  final NovelReaderColors colors =
      NovelReaderColors.of(preferences.background);
  return TextStyle(
    fontFamily: novelReaderFontFamily(preferences.font),
    fontSize: preferences.fontSize,
    height: preferences.lineHeight,
    color: colors.text,
    fontWeight: FontWeight.w400,
  );
}

Map<String, String>? novelReaderElementStyles(
  String tagName, {
  required bool justify,
}) {
  if (!justify) {
    return null;
  }
  if (tagName == 'p' || tagName == 'div') {
    return const <String, String>{'text-align': 'justify'};
  }
  return null;
}
