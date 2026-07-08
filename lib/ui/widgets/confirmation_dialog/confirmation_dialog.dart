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
    this.icon,
  });

  final String title;
  final String message;

  final String yesText;
  final String noText;

  final bool destructive;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final Color accent = destructive ? AppColors.red : AppColors.primary;
    final IconData resolvedIcon =
        icon ?? (destructive ? Icons.warning_amber_rounded : Icons.help_outline_rounded);

    return Dialog(
      backgroundColor: AppColors.dialogSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(resolvedIcon, color: accent, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title, style: semibold(size: 18), textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Text(
              message,
              style: regular(size: 14, color: AppColors.mainGrey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: _DialogButton(
                    label: noText,
                    onPressed: () => Navigator.of(context).pop(false),
                    background: AppColors.overlay(0.06),
                    foreground: AppColors.mainWhite,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DialogButton(
                    label: yesText,
                    onPressed: () => Navigator.of(context).pop(true),
                    background: accent,
                    foreground: destructive
                        ? AppColors.mainWhite
                        : AppColors.mainBlack,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// A themed single-action informational dialog matching [ConfirmationDialog].
class InfoDialog extends StatelessWidget {
  const InfoDialog({
    super.key,
    required this.title,
    required this.okText,
    this.message,
    this.icon = Icons.check_circle_rounded,
  });

  final String title;
  final String? message;
  final String okText;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.dialogSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.primary, size: 26),
            ),
            const SizedBox(height: 16),
            Text(title, style: semibold(size: 18), textAlign: TextAlign.center),
            if (message != null) ...<Widget>[
              const SizedBox(height: 10),
              Text(
                message!,
                style: regular(size: 14, color: AppColors.mainGrey),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 24),
            _DialogButton(
              label: okText,
              onPressed: () => Navigator.of(context).pop(),
              background: AppColors.primary,
              foreground: AppColors.mainBlack,
            ),
          ],
        ),
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.onPressed,
    required this.background,
    required this.foreground,
  });

  final String label;
  final VoidCallback onPressed;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 48,
          alignment: Alignment.center,
          child: Text(label, style: semibold(size: 15, color: foreground)),
        ),
      ),
    );
  }
}
