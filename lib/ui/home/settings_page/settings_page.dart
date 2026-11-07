import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/auto_backup/auto_backup_cubit.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_palette.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_progress_overlay.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_sheet.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
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
                    _UpdateBanner(),
                    _buildAppearanceSection(context),
                    _buildReaderSection(context, state),
                    _buildPlayerSection(context, state),
                    _buildContentSection(context, state),
                    if (kDebugMode) _buildDeveloperSection(context, state),
                    _buildUpdatesSection(context, state),
                    _buildStatisticsSection(context, state),
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
    return SettingsSection(
      title: S.current.settings_appearance_section_title,
      tiles: <Widget>[
        SettingsTile(
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
    return SettingsSection(
      title: S.current.settings_content_section_title,
      tiles: <Widget>[
        SettingsTile(
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

  Widget _buildDeveloperSection(
      BuildContext context, SettingsInitialized state) {
    final String url = Env.localRepoUrl;
    final bool available = url.isNotEmpty;

    Future<void> toggle(bool value) async {
      await context.read<SettingsCubit>().onChangedUseLocalExtensionServer(value);
      await context.read<RemoteConfigsCubit>().refresh();
    }

    return SettingsSection(
      title: S.current.settings_developer_section,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.developer_mode_rounded,
          title: S.current.settings_local_extension_server_title,
          subtitle: available
              ? S.current.settings_local_extension_server_subtitle(url)
              : S.current.settings_local_extension_server_missing,
          trailing: Switch(
            value: available && state.useLocalExtensionServer,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: available ? toggle : null,
          ),
          onTap: available
              ? () => toggle(!state.useLocalExtensionServer)
              : null,
        ),
      ],
    );
  }

  Widget _buildUpdatesSection(BuildContext context, SettingsInitialized state) {
    final SettingsCubit cubit = context.read<SettingsCubit>();

    return SettingsSection(
      title: S.current.settings_updates_section,
      tiles: <Widget>[
        if (cubit.backgroundUpdatesSupported)
          SettingsTile(
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
          SettingsTile(
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
        SettingsTile(
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
    return SettingsSection(
      title: S.current.settings_statistics_section_title,
      tiles: <Widget>[
        SettingsTile(
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
        SettingsTile(
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
    return SettingsSection(
      title: S.current.settings_reader_section_title,
      tiles: <Widget>[
        SettingsTile(
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
        SettingsTile(
          icon: Icons.translate_rounded,
          title: S.current.settings_page_translation_title,
          subtitle: S.current.settings_page_translation_subtitle,
          trailing: Icon(
            Icons.chevron_right_rounded,
            color: AppColors.mainGrey,
          ),
          onTap: () =>
              Navigator.of(context).pushNamed(Routes.pageTranslationSettings),
        ),
      ],
    );
  }

  Widget _buildPlayerSection(BuildContext context, SettingsInitialized state) {
    return SettingsSection(
      title: S.current.settings_player_section_title,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.smart_display_rounded,
          title: S.current.settings_video_player_title,
          subtitle: S.current.settings_video_player_subtitle,
          trailing: _buildValueTrailing(
            videoPlayerPreferenceLabel(state.videoPlayerPreference),
          ),
          onTap: () =>
              _showVideoPlayerPicker(context, state.videoPlayerPreference),
        ),
        SettingsTile(
          icon: Icons.fast_forward_rounded,
          title: S.current.settings_player_hold_speed_title,
          subtitle: S.current.settings_player_hold_speed_subtitle,
          trailing: _buildValueTrailing(
            speedMultiplierLabel(state.playerHoldSpeed),
          ),
          onTap: () => _showHoldSpeedPicker(context, state.playerHoldSpeed),
        ),
        SettingsTile(
          icon: Icons.redo_rounded,
          title: S.current.settings_player_skip_opening_title,
          subtitle: S.current.settings_player_skip_opening_subtitle,
          trailing: _buildValueTrailing(
            S.current.settings_player_skip_opening_value(
              state.playerSkipOpeningSeconds,
            ),
          ),
          onTap: () => _showSkipOpeningPicker(
            context,
            state.playerSkipOpeningSeconds,
          ),
        ),
        SettingsTile(
          icon: Icons.playlist_play_rounded,
          title: S.current.settings_player_auto_next_title,
          subtitle: S.current.settings_player_auto_next_subtitle,
          trailing: Switch(
            value: state.playerAutoPlayNext,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) => unawaited(
              context.read<SettingsCubit>().onChangedPlayerAutoPlayNext(value),
            ),
          ),
          onTap: () => unawaited(
            context
                .read<SettingsCubit>()
                .onChangedPlayerAutoPlayNext(!state.playerAutoPlayNext),
          ),
        ),
      ],
    );
  }

  Widget _buildValueTrailing(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(value, style: medium(size: 13, color: AppColors.mainGrey)),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
      ],
    );
  }

  void _showHoldSpeedPicker(BuildContext context, double current) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    unawaited(showActionSheet(
      context,
      title: S.current.settings_player_hold_speed_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final double speed in kHoldSpeedOptions)
            ActionSheetRow(
              label: speedMultiplierLabel(speed),
              selected: speed == current,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(cubit.onChangedPlayerHoldSpeed(speed));
              },
            ),
        ],
      ),
    ));
  }

  void _showSkipOpeningPicker(BuildContext context, int current) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    unawaited(showActionSheet(
      context,
      title: S.current.settings_player_skip_opening_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final int seconds in kSkipOpeningOptions)
            ActionSheetRow(
              label: S.current.settings_player_skip_opening_value(seconds),
              selected: seconds == current,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(cubit.onChangedPlayerSkipOpeningSeconds(seconds));
              },
            ),
        ],
      ),
    ));
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

    await cubit.importBundle(context, bundle, sections);
  }

  Widget _buildActivitySection(BuildContext context) {
    return SettingsSection(
      title: S.current.home_navigation_bar_activity_history_title,
      action: _InfoButton(onTap: () => _showImportExportInfo(context)),
      tiles: <Widget>[
        const _AutoBackupTiles(),
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

  Widget _buildAboutSection(BuildContext context) {
    return SettingsSection(
      title: S.current.settings_about_section_title,
      tiles: <Widget>[
        SettingsTile(
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

  void _showVideoPlayerPicker(
    BuildContext context,
    VideoPlayerPreference current,
  ) {
    final SettingsCubit cubit = context.read<SettingsCubit>();
    unawaited(showActionSheet(
      context,
      title: S.current.settings_video_player_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final VideoPlayerPreference preference
              in VideoPlayerPreference.values)
            ActionSheetRow(
              label: videoPlayerPreferenceLabel(preference),
              selected: preference == current,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(cubit.onChangedVideoPlayerPreference(preference));
              },
            ),
        ],
      ),
    ));
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

String videoPlayerPreferenceLabel(VideoPlayerPreference preference) {
  switch (preference) {
    case VideoPlayerPreference.auto:
      return S.current.settings_video_player_auto;
    case VideoPlayerPreference.webOnly:
      return S.current.settings_video_player_web_only;
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

class _AutoBackupTiles extends StatelessWidget {
  const _AutoBackupTiles();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoBackupCubit, AutoBackupState>(
      builder: (BuildContext context, AutoBackupState backup) {
        final AutoBackupCubit cubit = context.read<AutoBackupCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingsTile(
              icon: Icons.backup_outlined,
              title: S.current.settings_auto_backup_title,
              subtitle: _subtitle(backup),
              trailing: Switch(
                value: backup.enabled,
                activeThumbColor: AppColors.mainBlack,
                activeTrackColor: AppColors.primary,
                onChanged: cubit.setEnabled,
              ),
              onTap: () => cubit.setEnabled(!backup.enabled),
            ),
            if (backup.enabled)
              SettingsTile(
                icon: Icons.save_alt_rounded,
                title: S.current.settings_auto_backup_now,
                trailing: backup.running
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
                onTap: backup.running ? null : () => _backUpNow(context, cubit),
              ),
          ],
        );
      },
    );
  }

  Future<void> _backUpNow(BuildContext context, AutoBackupCubit cubit) async {
    final bool saved = await cubit.backUpNow();
    if (!context.mounted) {
      return;
    }
    if (saved) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.settings_auto_backup_saved,
      );
    } else {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.settings_auto_backup_failed,
      );
    }
  }

  String _subtitle(AutoBackupState backup) {
    if (!backup.enabled) {
      return S.current.settings_auto_backup_off;
    }
    if (backup.failed) {
      return S.current.settings_auto_backup_failed;
    }
    final DateTime? last = backup.lastBackupAt;
    if (last == null) {
      return S.current.settings_auto_backup_never;
    }
    return S.current.settings_auto_backup_last(
      DateFormat.yMMMd().add_Hm().format(last),
    );
  }
}
