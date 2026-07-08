import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_palette.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_progress_overlay.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_sheet.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: BlocConsumer<SettingsCubit, SettingsState>(
        listenWhen: (SettingsState previous, SettingsState current) =>
            current is SettingsInitialized && current.outcome != null,
        listener: (BuildContext context, SettingsState state) {
          final ImportOutcome outcome = (state as SettingsInitialized).outcome!;
          context.read<SettingsCubit>().clearOutcome();

          if (!outcome.success) {
            SnackBars.showErrorSnackBar(
              context: context,
              error: S.current.settings_import_error,
            );
            return;
          }

          final String message = S.current.settings_import_success(
            outcome.imported,
            outcome.total,
          );
          SnackBars.showSnackBar(
            context: context,
            message: outcome.skipped > 0
                ? '$message · ${S.current.settings_import_skipped(outcome.skipped)}'
                : message,
          );
        },
        builder: (BuildContext context, SettingsState state) {
          if (state is! SettingsInitialized) {
            return Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          return Stack(
            fit: StackFit.expand,
            children: <Widget>[
              SafeArea(
                bottom: false,
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(bottom: 24),
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.fromLTRB(16, 12, 16, 4),
                      child: _SettingsHeader(),
                    ),
                    const _UpdateBanner(),
                    _buildAppearanceSection(context),
                    _buildReaderSection(context, state),
                    _buildContentSection(context, state),
                    _buildUpdatesSection(context, state),
                    _buildStatisticsSection(context, state),
                    _buildStorageSection(context),
                    _buildActivitySection(context),
                    _buildAboutSection(context),
                  ],
                ),
              ),
              if (state.loading)
                ImportExportProgressOverlay(progress: state.progress),
            ],
          );
        },
      ),
    );
  }

  Widget _buildAppearanceSection(BuildContext context) {
    final AppThemeId current = context.watch<ThemeCubit>().state.id;
    return _SettingsSection(
      title: S.current.settings_appearance_section_title,
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.palette_outlined,
          title: S.current.settings_theme_title,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                _themeName(current),
                style: medium(size: 13, color: AppColors.mainGrey),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
            ],
          ),
          onTap: () => _showThemePicker(context, current),
        ),
      ],
    );
  }

  Widget _buildContentSection(BuildContext context, SettingsInitialized state) {
    return _SettingsSection(
      title: S.current.settings_content_section_title,
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.explicit_rounded,
          title: S.current.settings_show_nsfw_title,
          subtitle: S.current.settings_show_nsfw_subtitle,
          trailing: Switch(
            value: state.showNsfw,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) =>
                context.read<SettingsCubit>().onChangedShowNsfw(value),
          ),
          onTap: () =>
              context.read<SettingsCubit>().onChangedShowNsfw(!state.showNsfw),
        ),
      ],
    );
  }

  Widget _buildUpdatesSection(BuildContext context, SettingsInitialized state) {
    final SettingsCubit cubit = context.read<SettingsCubit>();

    return _SettingsSection(
      title: S.current.settings_updates_section,
      tiles: <Widget>[
        if (cubit.backgroundUpdatesSupported)
          _SettingsTile(
            icon: Icons.autorenew_rounded,
            title: S.current.settings_check_updates,
            subtitle: S.current.settings_check_updates_subtitle,
            trailing: Switch(
              value: state.checkUpdates,
              activeThumbColor: AppColors.mainBlack,
              activeTrackColor: AppColors.primary,
              onChanged: (bool value) => cubit.onChangedCheckUpdates(value),
            ),
            onTap: () => cubit.onChangedCheckUpdates(!state.checkUpdates),
          ),
        if (cubit.backgroundUpdatesSupported && state.checkUpdates)
          _SettingsTile(
            icon: Icons.schedule_rounded,
            title: S.current.settings_update_frequency,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  S.current
                      .settings_update_frequency_value(state.updateFrequencyHours),
                  style: medium(size: 13, color: AppColors.mainGrey),
                ),
                const SizedBox(width: 4),
                Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
              ],
            ),
            onTap: () =>
                _showUpdateFrequencyPicker(context, state.updateFrequencyHours),
          ),
        _SettingsTile(
          icon: state.updateNotifications
              ? Icons.notifications_active_rounded
              : Icons.notifications_off_rounded,
          title: S.current.settings_update_notifications,
          subtitle: S.current.settings_update_notifications_subtitle,
          trailing: Switch(
            value: state.updateNotifications,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) => cubit.onChangedUpdateNotifications(value),
          ),
          onTap: () =>
              cubit.onChangedUpdateNotifications(!state.updateNotifications),
        ),
      ],
    );
  }

  void _showUpdateFrequencyPicker(BuildContext context, int current) {
    const List<int> options = <int>[6, 12, 24, 48];

    showModalBottomSheet<void>(
      context: context,
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
                  S.current.settings_update_frequency,
                  style: semibold(size: 18),
                ),
              ),
              for (final int hours in options)
                InkWell(
                  onTap: () {
                    context.read<SettingsCubit>().onChangedUpdateFrequency(hours);
                    Navigator.of(sheetContext).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            S.current.settings_update_frequency_value(hours),
                            style: medium(
                              size: 15,
                              color: hours == current
                                  ? AppColors.primary
                                  : AppColors.mainWhite,
                            ),
                          ),
                        ),
                        if (hours == current)
                          Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatisticsSection(
    BuildContext context,
    SettingsInitialized state,
  ) {
    return _SettingsSection(
      title: S.current.settings_statistics_section_title,
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.bar_chart_rounded,
          title: S.current.settings_reading_statistics_title,
          subtitle: S.current.settings_reading_statistics_subtitle,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mainGrey,
          ),
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.readingStatistics),
        ),
        _SettingsTile(
          icon: Icons.insights_rounded,
          title: S.current.settings_collect_statistics_title,
          subtitle: S.current.settings_collect_statistics_subtitle,
          trailing: Switch(
            value: state.collectStatistics,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) =>
                context.read<SettingsCubit>().onChangedCollectStatistics(value),
          ),
          onTap: () => context.read<SettingsCubit>().onChangedCollectStatistics(
            !state.collectStatistics,
          ),
        ),
      ],
    );
  }

  Widget _buildReaderSection(BuildContext context, SettingsInitialized state) {
    return _SettingsSection(
      title: S.current.settings_reader_section_title,
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.menu_book_rounded,
          title: S.current.settings_default_reader_mode_title,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                chapterViewModelToString(state.defaultMode),
                style: medium(size: 13, color: AppColors.mainGrey),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
            ],
          ),
          onTap: () => _showReaderModePicker(context, state.defaultMode),
        ),
      ],
    );
  }

  Widget _buildStorageSection(BuildContext context) {
    return _SettingsSection(
      title: S.current.settings_storage_section_title,
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.download_rounded,
          title: S.current.settings_downloads_title,
          subtitle: S.current.settings_downloads_subtitle,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mainGrey,
          ),
          onTap: () => Navigator.of(context).pushNamed(Routes.downloads),
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

    if (sections == null || sections.isEmpty || !context.mounted) return;
    await cubit.exportData(context, sections);
  }

  Future<void> _startImport(BuildContext context) async {
    final SettingsCubit cubit = context.read<SettingsCubit>();

    final PickedImport? picked = await cubit.pickImport(context);
    if (picked == null || !context.mounted) return;

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

    if (sections == null || sections.isEmpty || !context.mounted) return;

    final String? path = picked.path;
    if (path != null && cubit.backgroundImportSupported) {
      final bool started = await cubit.importInBackground(
        bundle,
        sections,
        path,
      );
      if (started) return;
    }

    if (!context.mounted) return;
    await cubit.importBundle(context, bundle, sections);
  }

  Widget _buildActivitySection(BuildContext context) {
    return _SettingsSection(
      title: S.current.home_navigation_bar_activity_history_title,
      action: _InfoButton(onTap: () => _showImportExportInfo(context)),
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.file_upload_outlined,
          title: S.current.settings_export_data_button,
          onTap: () => _startExport(context),
        ),
        _SettingsTile(
          icon: Icons.file_download_outlined,
          title: S.current.settings_import_data_button,
          onTap: () => _startImport(context),
        ),
        _SettingsTile(
          icon: Icons.cleaning_services_rounded,
          title: S.current.settings_clear_cookies_cache,
          onTap: () => _confirmClearCookies(context),
        ),
        _SettingsTile(
          icon: Icons.delete_outline_rounded,
          title: S.current.settings_clear_activity_history,
          destructive: true,
          onTap: () => _confirmClearHistory(context),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return _SettingsSection(
      title: S.current.settings_about_section_title,
      tiles: <Widget>[
        _SettingsTile(
          icon: Icons.bug_report_outlined,
          title: S.current.settings_submit_issue,
          trailing: Icon(Icons.open_in_new_rounded, color: AppColors.mainGrey),
          onTap: () => launchUrl(
            Uri.parse(
              "https://github.com/Sayuri128/wakaranai/issues/new/choose",
            ),
          ),
        ),
      ],
    );
  }

  String _themeName(AppThemeId id) {
    switch (id) {
      case AppThemeId.midnight:
        return S.current.settings_theme_midnight;
      case AppThemeId.amoled:
        return S.current.settings_theme_amoled;
      case AppThemeId.light:
        return S.current.settings_theme_light;
      case AppThemeId.ocean:
        return S.current.settings_theme_ocean;
      case AppThemeId.dracula:
        return S.current.settings_theme_dracula;
      case AppThemeId.ember:
        return S.current.settings_theme_ember;
      case AppThemeId.sky:
        return S.current.settings_theme_sky;
      case AppThemeId.sakura:
        return S.current.settings_theme_sakura;
      case AppThemeId.sepia:
        return S.current.settings_theme_sepia;
    }
  }

  void _showThemePicker(BuildContext context, AppThemeId current) {
    showModalBottomSheet<void>(
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
                  S.current.settings_theme_title,
                  style: semibold(size: 18),
                ),
              ),
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      for (final AppThemeId id in AppThemeId.values)
                        InkWell(
                          onTap: () {
                            context.read<ThemeCubit>().changeTheme(id);
                            Navigator.of(sheetContext).pop();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            child: Row(
                              children: <Widget>[
                                _ThemeSwatch(palette: AppPalette.fromId(id)),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    _themeName(id),
                                    style: medium(
                                      size: 15,
                                      color: id == current
                                          ? AppColors.primary
                                          : AppColors.mainWhite,
                                    ),
                                  ),
                                ),
                                if (id == current)
                                  Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showReaderModePicker(BuildContext context, ChapterViewMode current) {
    showModalBottomSheet<void>(
      context: context,
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
                  S.current.settings_default_reader_mode_title,
                  style: semibold(size: 18),
                ),
              ),
              for (final ChapterViewMode mode in ChapterViewMode.values)
                InkWell(
                  onTap: () {
                    context.read<SettingsCubit>().onChangedDefaultReadMode(
                      mode,
                    );
                    Navigator.of(sheetContext).pop();
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            chapterViewModelToString(mode),
                            style: medium(
                              size: 15,
                              color: mode == current
                                  ? AppColors.primary
                                  : AppColors.mainWhite,
                            ),
                          ),
                        ),
                        if (mode == current)
                          Icon(
                            Icons.check_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
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
          if (!context.mounted) return;
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

class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Text(
      S.current.home_navigation_bar_settings_title,
      style: semibold(size: 24),
    );
  }
}

class _UpdateBanner extends StatelessWidget {
  const _UpdateBanner();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LatestReleaseCubit, LatestReleaseState>(
      builder: (BuildContext context, LatestReleaseState state) {
        if (state is! LatestReleaseLoaded || !state.releaseData.needsUpdate) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => launchUrl(Uri.parse(state.releaseData.url)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.system_update_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        S.current.settings_download_latest_release(
                          state.releaseData.latestVersion,
                        ),
                        style: semibold(size: 15, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.download_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({
    required this.title,
    required this.tiles,
    this.action,
  });

  final String title;
  final List<Widget> tiles;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 10),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(title, style: semibold(size: 18))),
              if (action != null) action!,
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Material(
            color: AppColors.overlay(0.04),
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: <Widget>[
                for (int i = 0; i < tiles.length; i++) ...<Widget>[
                  if (i > 0)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.overlay(0.06),
                    ),
                  tiles[i],
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final Color tint = destructive ? AppColors.red : AppColors.primary;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(
          children: <Widget>[
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tint.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: tint, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: medium(
                      size: 15,
                      color: destructive ? AppColors.red : AppColors.mainWhite,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: 8),
              trailing!,
            ],
          ],
        ),
      ),
    );
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

class _ThemeSwatch extends StatelessWidget {
  const _ThemeSwatch({required this.palette});

  final AppPalette palette;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: palette.overlayBase.withValues(alpha: 0.14)),
      ),
      child: Center(
        child: Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: palette.primary,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
