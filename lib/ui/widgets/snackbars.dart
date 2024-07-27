import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SnackBars {
  static void showErrorSnackBar(
      {required BuildContext context, required String error}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.backgroundColor,
      content: Text(
        error,
        style: semibold(
          size: 12,
          color: AppColors.red,
        ),
      ),
    ));
  }

  static void showSnackBar(
      {required BuildContext context, required String message}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.backgroundColor,
      content: Text(
        message,
        style: semibold(
          size: 12,
          color: AppColors.mainWhite,
        ),
      ),
    ));
  }
}
