import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/import_export_progress_overlay.dart';
import 'package:wakaranai/ui/home/settings_page/sections/about_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/activity_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/appearance_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/content_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/developer_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/player_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/reader_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/settings_header.dart';
import 'package:wakaranai/ui/home/settings_page/sections/statistics_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/sections/updates_settings_section.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';

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
                      child: SettingsHeader(),
                    ),
                    SettingsUpdateBanner(),
                    AppearanceSettingsSection(
                      currentTheme: context.watch<ThemeCubit>().state.id,
                    ),
                    ReaderSettingsSection(state: state),
                    PlayerSettingsSection(state: state),
                    ContentSettingsSection(state: state),
                    if (kDebugMode) DeveloperSettingsSection(state: state),
                    UpdatesSettingsSection(state: state),
                    StatisticsSettingsSection(state: state),
                    ActivitySettingsSection(),
                    AboutSettingsSection(),
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
}
