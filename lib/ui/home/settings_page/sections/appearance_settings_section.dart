
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/theme/theme_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_palette.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AppearanceSettingsSection extends StatelessWidget {
  const AppearanceSettingsSection({super.key, required this.currentTheme});

  final AppThemeId currentTheme;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: S.current.settings_appearance_section_title,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.palette_outlined,
          title: S.current.settings_theme_title,
          trailing: SettingsValueTrailing(
            value: _themeName(currentTheme),
          ),
          onTap: () => _showThemePicker(context, currentTheme),
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
