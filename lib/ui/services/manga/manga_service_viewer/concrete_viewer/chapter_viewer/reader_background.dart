import 'package:flutter/material.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';
import 'package:wakaranai/utils/app_colors.dart';

Color readerBackgroundColor(ReaderBackground background) {
  switch (background) {
    case ReaderBackground.black:
      return Colors.black;
    case ReaderBackground.grey:
      return const Color(0xFF2B2B2B);
    case ReaderBackground.white:
      return Colors.white;
    case ReaderBackground.theme:
      return AppColors.backgroundColor;
  }
}
