import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SnackBars {
  static void showErrorSnackBar(
      {required BuildContext context, required String error}) {
    _show(
      context,
      message: error,
      accent: AppColors.red,
      icon: Icons.error_outline_rounded,
      duration: const Duration(seconds: 4),
    );
  }

  static void showSnackBar(
      {required BuildContext context, required String message}) {
    _show(
      context,
      message: message,
      accent: AppColors.primary,
      icon: Icons.check_circle_rounded,
      duration: const Duration(seconds: 3),
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color accent,
    required IconData icon,
    required Duration duration,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        elevation: 0,
        duration: duration,
        padding: EdgeInsets.zero,
        margin: const EdgeInsets.all(16),
        dismissDirection: DismissDirection.horizontal,
        content: _SnackBarBody(message: message, accent: accent, icon: icon),
      ),
    );
  }
}

class _SnackBarBody extends StatelessWidget {
  const _SnackBarBody({
    required this.message,
    required this.accent,
    required this.icon,
  });

  final String message;
  final Color accent;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dialogSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.overlay(0.08)),
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accent, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: medium(size: 13, color: AppColors.mainWhite),
            ),
          ),
        ],
      ),
    );
  }
}
