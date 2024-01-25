import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SnackBars {
  static void showErrorSnackBar(
      {required BuildContext context, required String error}) {
    SnackBar(
      backgroundColor: AppColors.backgroundColor,
      content: Text(
        error,
        style: semibold(
          size: 24,
          color: AppColors.red,
        ),
      ),
    );
  }
}
