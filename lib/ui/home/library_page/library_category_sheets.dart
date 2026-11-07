import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/library_page/library_buttons.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

void showLibraryMoveToCategorySheet(
  BuildContext context,
  LibraryState state,
  List<LibraryEntryDomain> entries, {
  VoidCallback? onMoved,
}) {
  final LibraryCubit library = context.read<LibraryCubit>();
  bool allIn(int? categoryId) =>
      entries.every((LibraryEntryDomain e) => e.categoryId == categoryId);

  void move(BuildContext sheetContext, int? categoryId) {
    library.moveManyToCategory(entries, categoryId);
    Navigator.of(sheetContext).pop();
    onMoved?.call();
  }

  showActionSheet(
    context,
    title: S.current.library_move_to_category,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ActionSheetRow(
            label: S.current.library_no_category,
            selected: allIn(null),
            onTap: () => move(sheetContext, null),
          ),
          for (final CategoryDomain c in state.categories)
            ActionSheetRow(
              label: c.name,
              selected: allIn(c.id),
              onTap: () => move(sheetContext, c.id),
            ),
        ],
      ),
    ),
  );
}

void showLibraryManageCategoriesSheet(
  BuildContext context,
  LibraryState state,
) {
  showActionSheet(
    context,
    title: S.current.library_manage_categories,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        for (final CategoryDomain c in state.categories)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: Row(
              children: <Widget>[
                Expanded(child: Text(c.name, style: medium(size: 15))),
                LibraryCircleIconButton(
                  icon: Icons.edit_outlined,
                  small: true,
                  onTap: () {
                    Navigator.of(context).pop();
                    showLibraryCategoryNameDialog(context, category: c);
                  },
                ),
                const SizedBox(width: 8),
                LibraryCircleIconButton(
                  icon: Icons.delete_outline_rounded,
                  small: true,
                  destructive: true,
                  onTap: () => context.read<LibraryCubit>().deleteCategory(c),
                ),
              ],
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
          child: LibraryPrimaryPillButton(
            icon: Icons.add_rounded,
            label: S.current.library_add_category,
            onTap: () {
              Navigator.of(context).pop();
              showLibraryCategoryNameDialog(context);
            },
          ),
        ),
      ],
    ),
  );
}

void showLibraryCategoryNameDialog(
  BuildContext context, {
  CategoryDomain? category,
}) {
  final TextEditingController controller = TextEditingController(
    text: category?.name ?? '',
  );
  showDialog<void>(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        backgroundColor: AppColors.dialogSurface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.symmetric(
          horizontal: 32,
          vertical: 24,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                category == null
                    ? S.current.library_add_category
                    : S.current.library_rename_category,
                style: semibold(size: 18),
              ),
              const SizedBox(height: 16),
              _buildCategoryNameField(controller),
              const SizedBox(height: 20),
              _buildCategoryNameButtons(
                context,
                dialogContext,
                controller,
                category,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildCategoryNameField(TextEditingController controller) {
  return TextField(
    controller: controller,
    autofocus: true,
    cursorColor: AppColors.primary,
    style: medium(size: 15),
    decoration: InputDecoration(
      hintText: S.current.library_category_name_hint,
      hintStyle: regular(size: 15, color: AppColors.mainGrey),
      filled: true,
      fillColor: AppColors.overlay(0.06),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget _buildCategoryNameButtons(
  BuildContext context,
  BuildContext dialogContext,
  TextEditingController controller,
  CategoryDomain? category,
) {
  return Row(
    children: <Widget>[
      Expanded(
        child: LibraryPillButton(
          label: S.current.common_cancel,
          background: AppColors.overlay(0.06),
          foreground: AppColors.mainWhite,
          onTap: () => Navigator.of(dialogContext).pop(),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: LibraryPillButton(
          label: category == null
              ? S.current.common_add
              : S.current.common_save,
          background: AppColors.primary,
          foreground: AppColors.mainBlack,
          onTap: () {
            final String name = controller.text.trim();
            if (name.isEmpty) {
              return;
            }
            if (category == null) {
              context.read<LibraryCubit>().addCategory(name);
            } else {
              context.read<LibraryCubit>().renameCategory(
                category,
                name,
              );
            }
            Navigator.of(dialogContext).pop();
          },
        ),
      ),
    ],
  );
}
