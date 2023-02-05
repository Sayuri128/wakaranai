import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/configs_sources/configs_sources_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
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
                    if (configsState is ConfigsSourcesInitialized) {
                      return SizedBox(
                        width: double.maxFinite,
                        child: DropdownButtonFormField<int?>(
                            value: configsState.sources
                                    .where((e) =>
                                        e.id == state.defaultConfigsSourceId)
                                    .isNotEmpty
                                ? state.defaultConfigsSourceId
                                : null,
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
                            items: [
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
                            ],
                            onChanged: (mode) {
                              if (mode != null) {
                                context
                                    .read<SettingsCubit>()
                                    .onChangedDefaultSourceId(mode);
                              }
                            }),
                      );
                    }
                    return const SizedBox();
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
                      okLabel: S.current
                          .clear_cookies_cache_dialog_confirmation_ok_label,
                      cancelLabel: S.current
                          .clear_cookies_cache_dialog_confirmation_cancel_label,
                      title: S.current
                          .clear_cookies_cache_dialog_confirmation_title,
                      message: S.current
                          .clear_cookies_cache_dialog_confirmation_message,
                    ).then((value) {
                      if (value.index == 0) {
                        ProtectorStorageService().clear().then((_) {
                          showOkAlertDialog(
                              context: context,
                              title: S.current.clear_cookies_dialog_success);
                        });
                      }
                    });
                  },
                  title: Text(S.current.clear_cookies_cache,
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
