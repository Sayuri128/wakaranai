import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/reader_preferences/reader_preferences_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/reader_preference_labels.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ReaderDisplayTiles extends StatelessWidget {
  const ReaderDisplayTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderPreferencesCubit, ReaderPreferences>(
      builder: (BuildContext context, ReaderPreferences preferences) {
        final ReaderPreferencesCubit cubit =
            context.read<ReaderPreferencesCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingsTile(
              icon: Icons.fit_screen_rounded,
              title: S.current.reader_page_fit_title,
              trailing: SettingsValueTrailing(
                value: readerPageFitLabel(preferences.pageFit),
              ),
              onTap: () => _pickPageFit(context, cubit, preferences.pageFit),
            ),
            _divider(),
            SettingsTile(
              icon: Icons.format_color_fill_rounded,
              title: S.current.reader_background_title,
              trailing: SettingsValueTrailing(
                value: readerBackgroundLabel(preferences.background),
              ),
              onTap: () =>
                  _pickBackground(context, cubit, preferences.background),
            ),
            _divider(),
            _switchTile(
              icon: Icons.crop_rounded,
              title: S.current.reader_crop_borders_title,
              subtitle: S.current.reader_crop_borders_subtitle,
              value: preferences.cropBorders,
              onChanged: cubit.setCropBorders,
            ),
            _divider(),
            _switchTile(
              icon: Icons.menu_book_rounded,
              title: S.current.reader_double_page_title,
              subtitle: S.current.reader_double_page_subtitle,
              value: preferences.doublePageSpread,
              onChanged: cubit.setDoublePageSpread,
            ),
            _divider(),
            _switchTile(
              icon: Icons.volume_up_rounded,
              title: S.current.reader_volume_keys_title,
              value: preferences.volumeKeys,
              onChanged: cubit.setVolumeKeys,
            ),
            if (preferences.volumeKeys) ...<Widget>[
              _divider(),
              _switchTile(
                icon: Icons.swap_vert_rounded,
                title: S.current.reader_volume_keys_invert_title,
                value: preferences.invertVolumeKeys,
                onChanged: cubit.setInvertVolumeKeys,
              ),
            ],
          ],
        );
      },
    );
  }

  Widget _divider() {
    return Divider(height: 1, indent: 64, color: AppColors.overlay(0.06));
  }

  Widget _switchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required Future<void> Function(bool value) onChanged,
  }) {
    return SettingsTile(
      icon: icon,
      title: title,
      subtitle: subtitle,
      trailing: Switch(
        value: value,
        activeThumbColor: AppColors.mainBlack,
        activeTrackColor: AppColors.primary,
        onChanged: (bool updated) => unawaited(onChanged(updated)),
      ),
      onTap: () => unawaited(onChanged(!value)),
    );
  }

  void _pickPageFit(
    BuildContext context,
    ReaderPreferencesCubit cubit,
    ReaderPageFit current,
  ) {
    unawaited(showActionSheet(
      context,
      title: S.current.reader_page_fit_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ReaderPageFit fit in ReaderPageFit.values)
            ActionSheetRow(
              label: readerPageFitLabel(fit),
              selected: fit == current,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(cubit.setPageFit(fit));
              },
            ),
        ],
      ),
    ));
  }

  void _pickBackground(
    BuildContext context,
    ReaderPreferencesCubit cubit,
    ReaderBackground current,
  ) {
    unawaited(showActionSheet(
      context,
      title: S.current.reader_background_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final ReaderBackground background in ReaderBackground.values)
            ActionSheetRow(
              label: readerBackgroundLabel(background),
              selected: background == current,
              onTap: () {
                Navigator.of(context).pop();
                unawaited(cubit.setBackground(background));
              },
            ),
        ],
      ),
    ));
  }
}

class IncognitoTile extends StatelessWidget {
  const IncognitoTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReaderPreferencesCubit, ReaderPreferences>(
      buildWhen: (ReaderPreferences previous, ReaderPreferences current) =>
          previous.incognito != current.incognito,
      builder: (BuildContext context, ReaderPreferences preferences) {
        final ReaderPreferencesCubit cubit =
            context.read<ReaderPreferencesCubit>();
        return SettingsTile(
          icon: Icons.visibility_off_rounded,
          title: S.current.settings_incognito_title,
          subtitle: S.current.settings_incognito_subtitle,
          trailing: Switch(
            value: preferences.incognito,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) => unawaited(cubit.setIncognito(value)),
          ),
          onTap: () => unawaited(cubit.setIncognito(!preferences.incognito)),
        );
      },
    );
  }
}
