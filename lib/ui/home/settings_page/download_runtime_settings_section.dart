import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';

class DownloadWifiOnlyTile extends StatelessWidget {
  const DownloadWifiOnlyTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SettingsCubit, SettingsState>(
      listenWhen: _wifiOnlyChanged,
      listener: (BuildContext context, SettingsState state) {
        context
            .read<DownloadManagerCubit>()
            .setWifiOnly((state as SettingsInitialized).downloadWifiOnly);
      },
      buildWhen: _wifiOnlyChanged,
      builder: (BuildContext context, SettingsState state) {
        final bool wifiOnly =
            state is SettingsInitialized && state.downloadWifiOnly;
        return SettingsTile(
          icon: Icons.wifi_rounded,
          title: S.of(context).downloads_runtime_wifi_only_title,
          subtitle: S.of(context).downloads_runtime_wifi_only_subtitle,
          trailing: Switch(
            value: wifiOnly,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: (bool value) => _change(context, value),
          ),
          onTap: () => _change(context, !wifiOnly),
        );
      },
    );
  }

  static bool _wifiOnlyChanged(SettingsState previous, SettingsState current) {
    if (current is! SettingsInitialized) {
      return false;
    }
    if (previous is! SettingsInitialized) {
      return true;
    }
    return previous.downloadWifiOnly != current.downloadWifiOnly;
  }

  static void _change(BuildContext context, bool value) {
    unawaited(context.read<SettingsCubit>().onChangedDownloadWifiOnly(value));
  }
}
