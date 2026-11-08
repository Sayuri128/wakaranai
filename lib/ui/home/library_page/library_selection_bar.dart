import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/library_page/library_buttons.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class LibrarySelectionBar extends StatelessWidget {
  const LibrarySelectionBar({
    super.key,
    required this.visible,
    required this.selectedCount,
    required this.onSelectAll,
    required this.onClear,
    required this.onMoveToCategory,
    required this.onMoreActions,
    required this.onRemove,
  });

  final bool visible;
  final int selectedCount;
  final VoidCallback onSelectAll;
  final VoidCallback onClear;
  final VoidCallback onMoveToCategory;
  final VoidCallback onMoreActions;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      offset: visible ? Offset.zero : const Offset(0, 1.6),
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 180),
        opacity: visible ? 1 : 0,
        child: IgnorePointer(
          ignoring: !visible,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Material(
                color: AppColors.dialogSurface,
                elevation: 10,
                shadowColor: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(18),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    _buildCountRow(),
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: AppColors.overlay(0.06),
                    ),
                    _buildActionsRow(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCountRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              S.current.library_selected_count(selectedCount),
              style: semibold(size: 15),
            ),
          ),
          LibraryCircleIconButton(
            icon: Icons.select_all_rounded,
            small: true,
            onTap: onSelectAll,
          ),
          const SizedBox(width: 6),
          LibraryCircleIconButton(
            icon: Icons.close_rounded,
            small: true,
            onTap: onClear,
          ),
        ],
      ),
    );
  }

  Widget _buildActionsRow() {
    return Padding(
      padding: const EdgeInsets.all(6),
      child: Row(
        children: <Widget>[
          Expanded(
            child: LibrarySelectionAction(
              icon: Icons.drive_file_move_outline,
              label: S.current.library_move_to_category,
              color: AppColors.primary,
              onTap: onMoveToCategory,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: LibrarySelectionAction(
              icon: Icons.more_horiz_rounded,
              label: S.current.library_more_actions,
              color: AppColors.mainWhite,
              onTap: onMoreActions,
            ),
          ),
          _buildDivider(),
          Expanded(
            child: LibrarySelectionAction(
              icon: Icons.delete_outline_rounded,
              label: S.current.library_remove,
              color: AppColors.red,
              onTap: onRemove,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 28,
      color: AppColors.overlay(0.08),
    );
  }
}
