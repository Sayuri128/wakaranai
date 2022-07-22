import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accentGreen),
            );
          }
          if (state is SettingsInitialized) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(S.current.settings_default_reader_mode_title,
                      style: semibold(size: 18)),
                ),
                SizedBox(
                  width: double.maxFinite,
                  child: DropdownButtonFormField<ChapterViewMode>(
                      value: state.defaultMode,
                      borderRadius: BorderRadius.circular(16.0),
                      style: medium(),
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: const BorderSide(
                                  color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: const BorderSide(
                                  color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide: const BorderSide(
                                  color: Colors.transparent))),
                      items: ChapterViewMode.values
                          .map((e) => DropdownMenuItem(
                                value: e,
                                alignment: Alignment.center,
                                child: Text(chapterViewModelToString(e),
                                    textAlign: TextAlign.center,
                                    style: medium()),
                              ))
                          .toList(),
                      onChanged: (mode) {
                        if (mode != null) {
                          context
                              .read<SettingsCubit>()
                              .onChangedDefaultReadMode(mode);
                        }
                      }),
                )
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
