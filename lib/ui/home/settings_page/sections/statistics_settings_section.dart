
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';

class StatisticsSettingsSection extends StatelessWidget {
  const StatisticsSettingsSection({super.key, required this.state});

  final SettingsInitialized state;

  @override
  Widget build(BuildContext context) {
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
}
