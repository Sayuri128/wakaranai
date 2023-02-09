import 'package:flutter/cupertino.dart';

import 'app_colors.dart';

TextStyle thin({double size = 16, Color? color}) {
  return TextStyle(
      fontSize: size,
      fontFamily: 'Ubuntu',
      fontWeight: FontWeight.w100,
      color: color ?? AppColors.mainWhite);
}


TextStyle bold({double size = 16, Color? color}) {
  return TextStyle(
      fontSize: size,
      fontFamily: 'Ubuntu',
      fontWeight: FontWeight.w700,
      color: color ?? AppColors.mainWhite);
}


TextStyle regular({double size = 14, Color? color}) {
  return TextStyle(
      fontSize: size,
      fontFamily: 'Ubuntu',
      fontWeight: FontWeight.w400,
      color: color ?? AppColors.mainWhite);
}

TextStyle semibold({double size = 14, Color? color}) {
  return TextStyle(
      fontSize: size,
      fontFamily: 'Ubuntu',
      color: color ?? AppColors.mainWhite,
      fontWeight: FontWeight.w600);
}

TextStyle medium({double size = 14, Color? color}) {
  return TextStyle(
      fontSize: size,
      fontFamily: "Ubuntu",
      color: color ?? AppColors.mainWhite,
      fontWeight: FontWeight.w500);
}

extension StringX on String {
  String get overflow => Characters(this)
      .replaceAll(Characters(''), Characters('\u{200B}'))
      .toString();
}
