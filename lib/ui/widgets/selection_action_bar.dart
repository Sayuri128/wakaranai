import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SelectionAction {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  const SelectionAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });
}

/// A contextual bottom bar for multi-selection actions. Slides up from the
/// bottom of the screen when [visible] is true and shows a "N selected" count
/// above a row of labeled action buttons.
class SelectionActionBar extends StatelessWidget {
  const SelectionActionBar({
    super.key,
    required this.visible,
    required this.countLabel,
    required this.actions,
  });

  final bool visible;
  final String countLabel;
  final List<SelectionAction> actions;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, 1),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: Material(
            color: AppColors.backgroundColor,
            elevation: 12,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8, top: 4, bottom: 8),
                      child: Text(
                        countLabel,
                        style: medium(size: 14, color: AppColors.mainWhite),
                      ),
                    ),
                    Row(
                      children: actions
                          .map((SelectionAction action) =>
                              Expanded(child: _buildAction(action)))
                          .toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAction(SelectionAction action) {
    final Color color = action.color ?? AppColors.mainWhite;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: action.onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(action.icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(
              action.label,
              style: regular(size: 12, color: color),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
