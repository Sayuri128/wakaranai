import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

TextStyle regular({double size = 14, Color? color}) {
  return TextStyle(fontSize: size, color: color ?? AppColors.mainWhite);
}

TextStyle semibold({double size = 14, Color? color}) {
  return TextStyle(
      fontSize: size, color: color ?? AppColors.mainWhite, fontWeight: FontWeight.w600);
}

TextStyle medium({double size = 14, Color? color}) {
  return TextStyle(
      fontSize: size, color: color ?? AppColors.mainWhite, fontWeight: FontWeight.w500);
}

extension StringX on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();
}
