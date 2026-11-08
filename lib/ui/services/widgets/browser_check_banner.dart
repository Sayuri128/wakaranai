import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class BrowserCheckBanner extends StatelessWidget {
  const BrowserCheckBanner({
    super.key,
    required this.reconnecting,
    required this.onOpenBrowser,
    required this.onDismiss,
  });

  final bool reconnecting;
  final VoidCallback onOpenBrowser;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dialogSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.overlay(0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.bottomCenter,
          child: reconnecting
              ? _buildReconnecting(context)
              : _buildPrompt(context),
        ),
      ),
    );
  }

  Widget _buildReconnecting(BuildContext context) {
    return Row(
      children: <Widget>[
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            S.of(context).browser_check_reconnecting,
            style: medium(size: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildPrompt(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.verified_user_rounded,
                size: 22,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    S.of(context).browser_check_required_title,
                    style: semibold(size: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    S.of(context).browser_check_required_message,
                    style: regular(size: 13, color: AppColors.mainGrey),
                  ),
                ],
              ),
            ),
            IconButton(
              visualDensity: VisualDensity.compact,
              tooltip: S.of(context).browser_check_dismiss,
              onPressed: onDismiss,
              icon: Icon(
                Icons.close_rounded,
                size: 20,
                color: AppColors.mainGrey,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onOpenBrowser,
            icon: const Icon(Icons.open_in_browser_rounded, size: 20),
            label: Text(
              S.of(context).browser_check_open_button,
              style: semibold(size: 15, color: AppColors.mainBlack),
            ),
          ),
        ),
      ],
    );
  }
}
