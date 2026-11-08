import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFiltersActionBar extends StatelessWidget {
  const GalleryFiltersActionBar({
    super.key,
    required this.activeCount,
    required this.onReset,
    required this.onApply,
  });

  final int activeCount;
  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.overlay(0.08))),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(child: _buildResetButton()),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildApplyButton()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResetButton() {
    final bool enabled = activeCount > 0;
    return _ActionButton(
      color: AppColors.overlay(enabled ? 0.08 : 0.04),
      onTap: enabled ? onReset : null,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.restart_alt_rounded,
            size: 20,
            color: enabled ? AppColors.mainWhite : AppColors.mainGrey,
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              S.current.gallery_filters_reset_button,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: semibold(
                size: 15,
                color: enabled ? AppColors.mainWhite : AppColors.mainGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplyButton() {
    return _ActionButton(
      color: AppColors.primary,
      onTap: onApply,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              S.current.gallery_filters_apply_button,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: semibold(size: 15, color: AppColors.mainBlack),
            ),
          ),
          if (activeCount > 0) ...<Widget>[
            const SizedBox(width: 8),
            _buildApplyCount(),
          ],
        ],
      ),
    );
  }

  Widget _buildApplyCount() {
    return Container(
      constraints: const BoxConstraints(minWidth: 22),
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.mainBlack.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(11),
      ),
      child: Text(
        '$activeCount',
        style: semibold(size: 13, color: AppColors.mainBlack),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.color,
    required this.onTap,
    required this.child,
  });

  final Color color;
  final VoidCallback? onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        child: SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: child,
          ),
        ),
      ),
    );
  }
}
