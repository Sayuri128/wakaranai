import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SnackBarActionData {
  const SnackBarActionData({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;
}

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

  static void showAttentionSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarActionData action,
  }) {
    _show(
      context,
      message: message,
      accent: AppColors.red,
      icon: Icons.lock_outline_rounded,
      duration: const Duration(seconds: 8),
      action: action,
    );
  }

  static void showActionSnackBar({
    required BuildContext context,
    required String message,
    required IconData icon,
    required SnackBarActionData action,
  }) {
    _show(
      context,
      message: message,
      accent: AppColors.primary,
      icon: icon,
      duration: const Duration(seconds: 8),
      action: action,
    );
  }

  static void _show(
    BuildContext context, {
    required String message,
    required Color accent,
    required IconData icon,
    required Duration duration,
    SnackBarActionData? action,
  }) {
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);

    SnackBarActionData? dismissingAction;
    if (action != null) {
      dismissingAction = SnackBarActionData(
        label: action.label,
        onPressed: () {
          messenger.hideCurrentSnackBar();
          action.onPressed();
        },
      );
    }

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
        content: _SnackBarBody(
          message: message,
          accent: accent,
          icon: icon,
          action: dismissingAction,
        ),
      ),
    );
  }
}

class _SnackBarBody extends StatelessWidget {
  const _SnackBarBody({
    required this.message,
    required this.accent,
    required this.icon,
    this.action,
  });

  final String message;
  final Color accent;
  final IconData icon;
  final SnackBarActionData? action;

  @override
  Widget build(BuildContext context) {
    final SnackBarActionData? action = this.action;
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
          if (action != null) ...<Widget>[
            const SizedBox(width: 8),
            _SnackBarActionButton(action: action),
          ],
        ],
      ),
    );
  }
}

class _SnackBarActionButton extends StatelessWidget {
  const _SnackBarActionButton({required this.action});

  final SnackBarActionData action;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: action.onPressed,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            action.label,
            style: semibold(size: 13, color: AppColors.mainBlack),
          ),
        ),
      ),
    );
  }
}
