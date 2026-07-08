import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_palette.dart';

class AppColors {
  AppColors._();

  static AppPalette _active = AppPalette.midnight;

  static AppPalette get palette => _active;

  static void apply(AppPalette palette) {
    _active = palette;
  }

  static Brightness get brightness => _active.brightness;

  static Color get backgroundColor => _active.background;
  static Color get mainWhite => _active.onBackground;
  static Color get mainGrey => _active.secondaryText;
  static Color get mainBlack => _active.onPrimary;

  static Color get primary => _active.primary;
  static Color get secondary => _active.secondary;
  static Color get mediumLight => _active.mediumLight;
  static Color get mediumLight2 => _active.mediumLight2;
  static Color get mediumDark => _active.mediumDark;
  static Color get mediumDark2 => _active.mediumDark2;
  static Color get red => _active.red;

  static Color get shadowColor => _active.shadow;
  static Color get dialogSurface => _active.dialogSurface;
  static Color get shimmerBase => _active.shimmerBase;
  static Color get shimmerHighlight => _active.shimmerHighlight;
  static Color get onMedia => _active.onMedia;

  static Color overlay(double alpha) =>
      _active.overlayBase.withValues(alpha: alpha);
}
