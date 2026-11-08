import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';

class DeveloperSettingsSection extends StatelessWidget {
  const DeveloperSettingsSection({super.key, required this.state});

  final SettingsInitialized state;

  @override
  Widget build(BuildContext context) {
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
}
