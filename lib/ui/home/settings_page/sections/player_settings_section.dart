import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';

class PlayerSettingsSection extends StatelessWidget {
  const PlayerSettingsSection({super.key, required this.state});

  final SettingsInitialized state;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: S.current.settings_player_section_title,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.smart_display_rounded,
          title: S.current.settings_video_player_title,
          subtitle: S.current.settings_video_player_subtitle,
          trailing: SettingsValueTrailing(
            value: videoPlayerPreferenceLabel(state.videoPlayerPreference),
          ),
          onTap: () =>
              _showVideoPlayerPicker(context, state.videoPlayerPreference),
        ),
        SettingsTile(
          icon: Icons.fast_forward_rounded,
          title: S.current.settings_player_hold_speed_title,
          subtitle: S.current.settings_player_hold_speed_subtitle,
          trailing: SettingsValueTrailing(
            value: speedMultiplierLabel(state.playerHoldSpeed),
          ),
          onTap: () => _showHoldSpeedPicker(context, state.playerHoldSpeed),
        ),
        SettingsTile(
          icon: Icons.redo_rounded,
          title: S.current.settings_player_skip_opening_title,
          subtitle: S.current.settings_player_skip_opening_subtitle,
          trailing: SettingsValueTrailing(
            value: S.current.settings_player_skip_opening_value(
              state.playerSkipOpeningSeconds,
            ),
          ),
          onTap: () => _showSkipOpeningPicker(
            context,
            state.playerSkipOpeningSeconds,
          ),
        ),
        SettingsTile(
          icon: Icons.skip_next_rounded,
          title: S.current.player_skip_auto_title,
          subtitle: S.current.player_skip_auto_subtitle,
          trailing: Switch(
            value: state.playerAutoSkipMarkers,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) => unawaited(
              context
                  .read<SettingsCubit>()
                  .onChangedPlayerAutoSkipMarkers(value),
            ),
          ),
          onTap: () => unawaited(
            context
                .read<SettingsCubit>()
                .onChangedPlayerAutoSkipMarkers(!state.playerAutoSkipMarkers),
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
}

String videoPlayerPreferenceLabel(VideoPlayerPreference preference) {
  switch (preference) {
    case VideoPlayerPreference.auto:
      return S.current.settings_video_player_auto;
    case VideoPlayerPreference.webOnly:
      return S.current.settings_video_player_web_only;
    case VideoPlayerPreference.external:
      return S.current.settings_video_player_external;
  }
}
