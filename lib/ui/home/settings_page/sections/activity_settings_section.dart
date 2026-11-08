import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_sheet.dart';
import 'package:wakaranai/ui/home/settings_page/sections/auto_backup_tiles.dart';
import 'package:wakaranai/ui/home/settings_page/sections/reader_display_tiles.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ActivitySettingsSection extends StatelessWidget {
  const ActivitySettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: S.current.home_navigation_bar_activity_history_title,
      action: _InfoButton(onTap: () => _showImportExportInfo(context)),
      tiles: <Widget>[
        IncognitoTile(),
        AutoBackupTiles(),
        SettingsTile(
          icon: Icons.file_upload_outlined,
          title: S.current.settings_export_data_button,
          onTap: () => _startExport(context),
        ),
        SettingsTile(
          icon: Icons.file_download_outlined,
          title: S.current.settings_import_data_button,
          onTap: () => _startImport(context),
        ),
        SettingsTile(
          icon: Icons.cleaning_services_rounded,
          title: S.current.settings_clear_cookies_cache,
          onTap: () => _confirmClearCookies(context),
        ),
        SettingsTile(
          icon: Icons.delete_outline_rounded,
          title: S.current.settings_clear_activity_history,
          destructive: true,
          onTap: () => _confirmClearHistory(context),
        ),
      ],
    );
  }

  Future<void> _startExport(BuildContext context) async {
    final SettingsCubit cubit = context.read<SettingsCubit>();

    final Set<ExportSection>? sections = await showImportExportSheet(
      context,
      available: ExportSection.values.toSet(),
      title: S.current.settings_export_sheet_title,
      confirmLabel: S.current.settings_export_sheet_confirm,
    );

    if (sections == null || sections.isEmpty || !context.mounted) {
      return;
    }
    await cubit.exportData(context, sections);
  }

  Future<void> _startImport(BuildContext context) async {
    final SettingsCubit cubit = context.read<SettingsCubit>();

    final PickedImport? picked = await cubit.pickImport(context);
    if (picked == null || !context.mounted) {
      return;
    }

    if (picked.legacy != null) {
      await cubit.importLegacy(context, picked.legacy!);
      return;
    }

    final ExportBundle bundle = picked.bundle!;
    final Set<ExportSection> available = bundle.availableSections;

    if (available.isEmpty) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.settings_import_nothing_to_import,
      );
      return;
    }

    final Set<ExportSection>? sections = await showImportExportSheet(
      context,
      available: available,
      title: S.current.settings_import_sheet_title,
      confirmLabel: S.current.settings_import_sheet_confirm,
    );

    if (sections == null || sections.isEmpty || !context.mounted) {
      return;
    }

    await cubit.importBundle(context, bundle, sections);
  }

  void _showImportExportInfo(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.overlay(0.18),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(
                  S.current.settings_import_export_info_title,
                  style: semibold(size: 18),
                ),
                const SizedBox(height: 16),
                _InfoParagraph(
                  icon: Icons.file_upload_outlined,
                  title: S.current.settings_import_export_info_export_title,
                  body: S.current.settings_import_export_info_export_body,
                ),
                const SizedBox(height: 16),
                _InfoParagraph(
                  icon: Icons.file_download_outlined,
                  title: S.current.settings_import_export_info_import_title,
                  body: S.current.settings_import_export_info_import_body,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmClearCookies(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        destructive: true,
        icon: Icons.cleaning_services_rounded,
        title: S.current.settings_clear_cookies_cache_dialog_confirmation_title,
        message:
            S.current.settings_clear_cookies_cache_dialog_confirmation_message,
        yesText:
            S.current.settings_clear_cookies_cache_dialog_confirmation_ok_label,
        noText: S
            .current
            .settings_clear_cookies_cache_dialog_confirmation_cancel_label,
      ),
    ).then((bool? confirmed) {
      if (confirmed == true) {
        ProtectorStorageService().clear().then((_) {
          if (!context.mounted) {
            return;
          }
          showDialog<void>(
            context: context,
            builder: (BuildContext dialogContext) => InfoDialog(
              title: S.current.settings_clear_cookies_dialog_success,
              okText: S.current.common_ok_button,
            ),
          );
        });
      }
    });
  }

  void _confirmClearHistory(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        destructive: true,
        icon: Icons.delete_outline_rounded,
        title:
            S.current.settings_clear_activity_history_dialog_confirmation_title,
        message: S
            .current
            .settings_clear_activity_history_dialog_confirmation_message,
        yesText: S
            .current
            .settings_clear_activity_history_dialog_confirmation_ok_label,
        noText: S
            .current
            .settings_clear_activity_history_dialog_confirmation_cancel_label,
      ),
    ).then((bool? confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<SettingsCubit>().deleteActivityHistory(context);
      }
    });
  }
}

class _InfoButton extends StatelessWidget {
  const _InfoButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: AppColors.mainGrey,
          ),
        ),
      ),
    );
  }
}

class _InfoParagraph extends StatelessWidget {
  const _InfoParagraph({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: semibold(size: 15)),
              const SizedBox(height: 4),
              Text(body, style: regular(size: 13, color: AppColors.mainGrey)),
            ],
          ),
        ),
      ],
    );
  }
}
