import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showActionSheet(
  BuildContext context, {
  required String title,
  required Widget child,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.overlay(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                title,
                style: semibold(size: 18),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Flexible(child: SingleChildScrollView(child: child)),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class ActionSheetRow extends StatelessWidget {
  const ActionSheetRow({
    super.key,
    required this.label,
    this.icon,
    this.leading,
    this.selected = false,
    this.destructive = false,
    required this.onTap,
  });

  final String label;
  final IconData? icon;
  final Widget? leading;
  final bool selected;
  final bool destructive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color color = destructive
        ? AppColors.red
        : (selected ? AppColors.primary : AppColors.mainWhite);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: <Widget>[
            if (leading != null) ...<Widget>[
              leading!,
              const SizedBox(width: 14),
            ] else if (icon != null) ...<Widget>[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 14),
            ],
            Expanded(child: Text(label, style: medium(size: 15, color: color))),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
