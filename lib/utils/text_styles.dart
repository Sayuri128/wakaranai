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
