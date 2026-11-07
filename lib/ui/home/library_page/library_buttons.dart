import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class LibrarySelectionAction extends StatelessWidget {
  const LibrarySelectionAction({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  style: medium(size: 14, color: color),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LibrarySelectablePill extends StatelessWidget {
  const LibrarySelectablePill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Center(
            child: Text(
              label,
              style: medium(
                size: 14,
                color: selected ? AppColors.mainBlack : AppColors.mainWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LibraryUpdatesButton extends StatelessWidget {
  const LibraryUpdatesButton({
    super.key,
    required this.unseenCount,
    required this.onTap,
  });

  final int unseenCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        LibraryCircleIconButton(
          icon: Icons.notifications_none_rounded,
          onTap: onTap,
        ),
        if (unseenCount > 0)
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
              constraints: const BoxConstraints(minWidth: 16),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.backgroundColor,
                  width: 1.5,
                ),
              ),
              child: Text(
                unseenCount > 99 ? '99+' : '$unseenCount',
                textAlign: TextAlign.center,
                style: medium(size: 10, color: AppColors.mainBlack),
              ),
            ),
          ),
      ],
    );
  }
}

class LibraryCircleIconButton extends StatelessWidget {
  const LibraryCircleIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.small = false,
    this.destructive = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool small;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(small ? 6 : 8),
          child: Icon(
            icon,
            size: small ? 18 : 22,
            color: destructive ? AppColors.red : AppColors.mainWhite,
          ),
        ),
      ),
    );
  }
}

class LibraryPrimaryPillButton extends StatelessWidget {
  const LibraryPrimaryPillButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(label, style: medium(size: 15, color: AppColors.primary)),
            ],
          ),
        ),
      ),
    );
  }
}

class LibraryPillButton extends StatelessWidget {
  const LibraryPillButton({
    super.key,
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 46,
          alignment: Alignment.center,
          child: Text(label, style: semibold(size: 15, color: foreground)),
        ),
      ),
    );
  }
}
