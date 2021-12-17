import 'package:flutter/material.dart';
import 'package:h_reader/utils/app_colors.dart';

AppBar buildAppBar({required String title}) {
  return AppBar(
    toolbarHeight: 50,
    shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.only(bottomLeft: Radius.circular(8.0), bottomRight: Radius.circular(8.0))),
    backgroundColor: AppColors.accentGreen,
    centerTitle: true,
    title: Text(title),
  );
}
