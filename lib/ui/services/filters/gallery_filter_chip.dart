import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GalleryFilterChip extends StatelessWidget {
  const GalleryFilterChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.trailingIcon,
    this.tooltip,
  });

  static const double height = 36;

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? trailingIcon;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);
    final Color foreground =
        selected ? AppColors.mainBlack : AppColors.mainWhite;
    final Widget chip = Semantics(
      button: true,
      selected: selected,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        curve: Curves.easeOut,
        height: height,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.overlay(0.06),
          borderRadius: radius,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.overlay(0.06),
          ),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: radius,
            splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.only(
                left: selected && trailingIcon == null ? 10 : 14,
                right: trailingIcon == null ? 14 : 10,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  if (selected && trailingIcon == null) ...<Widget>[
                    Icon(Icons.check_rounded, size: 16, color: foreground),
                    const SizedBox(width: 6),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: medium(size: 13, color: foreground),
                    ),
                  ),
                  if (trailingIcon != null) ...<Widget>[
                    const SizedBox(width: 6),
                    Icon(trailingIcon, size: 16, color: foreground),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final String? tooltipText = tooltip;
    if (tooltipText == null) {
      return chip;
    }
    return Tooltip(message: tooltipText, child: chip);
  }
}

class GalleryFilterLinkChip extends StatelessWidget {
  const GalleryFilterLinkChip({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius = BorderRadius.circular(12);
    return Semantics(
      button: true,
      child: Material(
        color: AppColors.primary.withValues(alpha: 0.10),
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: onTap,
          child: SizedBox(
            height: GalleryFilterChip.height,
            child: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(label, style: medium(size: 13, color: AppColors.primary)),
                  const SizedBox(width: 4),
                  Icon(icon, size: 18, color: AppColors.primary),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class GalleryFilterCountBadge extends StatelessWidget {
  const GalleryFilterCountBadge({
    super.key,
    required this.count,
    this.size = 20,
  });

  final int count;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: size),
      height: size,
      padding: const EdgeInsets.symmetric(horizontal: 6),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size / 2),
      ),
      child: Text(
        '$count',
        style: semibold(size: size * 0.6, color: AppColors.mainBlack),
      ),
    );
  }
}
