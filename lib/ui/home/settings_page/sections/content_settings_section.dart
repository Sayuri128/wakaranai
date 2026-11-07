
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ContentSettingsSection extends StatelessWidget {
  const ContentSettingsSection({super.key, required this.state});

  final SettingsInitialized state;

  @override
  Widget build(BuildContext context) {
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
}
