import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/auto_download/auto_download_settings_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

String autoDownloadLimitLabel(int maxPerTitle) {
  if (maxPerTitle <= kAutoDownloadUnlimited) {
    return S.current.auto_download_limit_unlimited;
  }
  return S.current.auto_download_limit_value(maxPerTitle);
}

String autoDownloadScopeLabel(AutoDownloadSettings settings) {
  switch (settings.scope) {
    case AutoDownloadScope.allTitles:
      return S.current.auto_download_scope_all;
    case AutoDownloadScope.selectedCategories:
      return S.current
          .auto_download_scope_categories_count(settings.categoryIds.length);
  }
}

List<Widget> buildAutoDownloadSettingsTiles(
  BuildContext context,
  AutoDownloadSettings settings,
) {
  final AutoDownloadSettingsCubit cubit =
      context.read<AutoDownloadSettingsCubit>();
  return <Widget>[
    SettingsTile(
      icon: Icons.downloading_rounded,
      title: S.of(context).auto_download_title,
      subtitle: S.of(context).auto_download_subtitle,
      trailing: Switch(
        value: settings.enabled,
        activeThumbColor: AppColors.mainBlack,
        activeTrackColor: AppColors.primary,
        onChanged: cubit.setEnabled,
      ),
      onTap: () => cubit.setEnabled(!settings.enabled),
    ),
    if (settings.enabled)
      SettingsTile(
        icon: Icons.folder_special_outlined,
        title: S.of(context).auto_download_scope_title,
        trailing: SettingsValueTrailing(
          value: autoDownloadScopeLabel(settings),
        ),
        onTap: () => _showScopeSheet(context),
      ),
    if (settings.enabled)
      SettingsTile(
        icon: Icons.format_list_numbered_rounded,
        title: S.of(context).auto_download_limit_title,
        subtitle: S.of(context).auto_download_limit_subtitle,
        trailing: SettingsValueTrailing(
          value: autoDownloadLimitLabel(settings.maxPerTitle),
        ),
        onTap: () => _showLimitSheet(context),
      ),
  ];
}

void _showScopeSheet(BuildContext context) {
  final AutoDownloadSettingsCubit cubit =
      context.read<AutoDownloadSettingsCubit>();
  final AutoDownloadScope current = cubit.state.scope;
  unawaited(showActionSheet(
    context,
    title: S.of(context).auto_download_scope_title,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ActionSheetRow(
            icon: Icons.collections_bookmark_outlined,
            label: S.of(context).auto_download_scope_all,
            selected: current == AutoDownloadScope.allTitles,
            onTap: () {
              Navigator.of(sheetContext).pop();
              cubit.setScope(AutoDownloadScope.allTitles);
            },
          ),
          ActionSheetRow(
            icon: Icons.label_outline_rounded,
            label: S.of(context).auto_download_scope_categories,
            selected: current == AutoDownloadScope.selectedCategories,
            onTap: () {
              Navigator.of(sheetContext).pop();
              cubit.setScope(AutoDownloadScope.selectedCategories);
              showAutoDownloadCategoriesSheet(context);
            },
          ),
        ],
      ),
    ),
  ));
}

void showAutoDownloadCategoriesSheet(BuildContext context) {
  unawaited(showActionSheet(
    context,
    title: S.of(context).auto_download_categories_title,
    child: _AutoDownloadCategoriesList(),
  ));
}

class _AutoDownloadCategoriesList extends StatelessWidget {
  const _AutoDownloadCategoriesList();

  @override
  Widget build(BuildContext context) {
    final List<CategoryDomain> categories =
        context.select((LibraryCubit library) => library.state.categories);
    final Set<int> selected = context.select(
      (AutoDownloadSettingsCubit settings) => settings.state.categoryIds,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              S.of(context).auto_download_categories_empty,
              style: regular(size: 14, color: AppColors.mainGrey),
            ),
          ),
        for (final CategoryDomain category in categories)
          ActionSheetRow(
            icon: Icons.label_rounded,
            label: category.name,
            selected: selected.contains(category.id),
            onTap: () => context
                .read<AutoDownloadSettingsCubit>()
                .toggleCategory(category.id),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.mainBlack,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                S.of(context).auto_download_categories_done,
                style: semibold(size: 15, color: AppColors.mainBlack),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

void _showLimitSheet(BuildContext context) {
  final AutoDownloadSettingsCubit cubit =
      context.read<AutoDownloadSettingsCubit>();
  final int current = cubit.state.maxPerTitle;
  unawaited(showActionSheet(
    context,
    title: S.of(context).auto_download_limit_title,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final int choice in kAutoDownloadMaxPerTitleChoices)
            ActionSheetRow(
              label: autoDownloadLimitLabel(choice),
              selected: choice == current,
              onTap: () {
                Navigator.of(sheetContext).pop();
                cubit.setMaxPerTitle(choice);
              },
            ),
        ],
      ),
    ),
  ));
}
