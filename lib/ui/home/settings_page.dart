import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/configs_sources/configs_sources_cubit.dart';
import 'package:wakaranai/blocs/history/history_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

// TODO: improve settings UI
class SettingsPage extends StatelessWidget {
  SettingsPage({Key? key}) : super(key: key);

  final DropdownMenuItem<int?> _defaultConfigsSourceDropdownMenuItem =
      DropdownMenuItem<int?>(
          value: null,
          child: Center(
              child:
                  Text(S.current.official_github_configs_source_repository)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          if (state is SettingsInitial) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }
          if (state is SettingsInitialized) {
            return ListView(
              physics: const BouncingScrollPhysics(),
              children: [
                const SizedBox(
                  height: 12,
                ),
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
                      // borderRadius: BorderRadius.circular(16.0),
                      style: medium(),
                      icon: const Icon(Icons.arrow_drop_down_rounded),
                      decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.transparent)),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16.0),
                              borderSide:
                                  const BorderSide(color: Colors.transparent))),
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
                ),
                const Divider(
                  height: 2,
                  color: AppColors.primary,
                ),
                const SizedBox(
                  height: 12,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    "Default configs source",
                    style: semibold(size: 18),
                  ),
                ),
                BlocBuilder<ConfigsSourcesCubit, ConfigsSourcesState>(
                  builder: (context, configsState) {
                    return SizedBox(
                      width: double.maxFinite,
                      child: DropdownButtonFormField<int?>(
                          value: state.defaultConfigsSourceId,
                          // borderRadius: BorderRadius.circular(16.0),
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
                          items: configsState is ConfigsSourcesInitialized
                              ? [
                                  _defaultConfigsSourceDropdownMenuItem,
                                  ...configsState.sources
                                      .map((e) => DropdownMenuItem(
                                            value: e.id,
                                            alignment: Alignment.center,
                                            child: Text(e.name,
                                                textAlign: TextAlign.center,
                                                style: medium()),
                                          ))
                                      .toList()
                                ]
                              : [_defaultConfigsSourceDropdownMenuItem],
                          onChanged: (mode) {
                            if (mode != null) {
                              context
                                  .read<SettingsCubit>()
                                  .onChangedDefaultSourceId(mode);
                            }
                          }),
                    );
                  },
                ),
                const Divider(
                  height: 2,
                  color: AppColors.primary,
                ),
                ListTile(
                  onTap: () {
                    showOkCancelAlertDialog(
                      context: context,
                      okLabel: "Delete",
                      cancelLabel: "Cancel",
                      title: "Are you sure you want to clear your history?",
                      message: "This action cannot be canceled later",
                    ).then((value) {
                      if (value.index == 0) {
                        context.read<HistoryCubit>().clear().then((_) {
                          showOkAlertDialog(
                              context: context,
                              title: "History has been cleared");
                        });
                      }
                    });
                  },
                  title: Text(S.current.settings_clear_history_title,
                      style: medium(size: 16)),
                ),
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }
}
