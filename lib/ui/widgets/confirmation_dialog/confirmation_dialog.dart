import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfirmationDialog extends StatelessWidget {
  const ConfirmationDialog({
    super.key,
    required this.title,
    required this.message,
    required this.yesText,
    required this.noText,
    this.destructive = false,
  });

  final String title;
  final String message;

  final String yesText;
  final String noText;

  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color confirmColor = destructive ? AppColors.red : AppColors.primary;
    return AlertDialog(
      backgroundColor: const Color(0xFF3A3A3A),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text(title, style: semibold(size: 18)),
      content:
          Text(message, style: regular(size: 14, color: AppColors.mainGrey)),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(noText, style: semibold(color: AppColors.mainGrey)),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(yesText, style: semibold(color: confirmColor)),
        ),
      ],
    );
  }
}
