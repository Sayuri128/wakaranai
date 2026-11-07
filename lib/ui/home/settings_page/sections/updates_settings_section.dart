
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class UpdatesSettingsSection extends StatelessWidget {
  const UpdatesSettingsSection({super.key, required this.state});

  final SettingsInitialized state;

  @override
  Widget build(BuildContext context) {
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
            trailing: SettingsValueTrailing(
              value: S.current
                  .settings_update_frequency_value(state.updateFrequencyHours),
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
}
