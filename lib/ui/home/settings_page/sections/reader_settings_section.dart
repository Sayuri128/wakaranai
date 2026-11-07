
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ReaderSettingsSection extends StatelessWidget {
  const ReaderSettingsSection({super.key, required this.state});

  final SettingsInitialized state;

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: S.current.settings_reader_section_title,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.menu_book_rounded,
          title: S.current.settings_default_reader_mode_title,
          trailing: SettingsValueTrailing(
            value: chapterViewModelToString(state.defaultMode),
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
}
