import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/home/settings/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
                      decoration: _dropdownDecoration(),
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
                // Padding(
                //   padding: const EdgeInsets.symmetric(
                //       horizontal: 16.0, vertical: 8.0),
                //   child: Text(
                //     S.current.settings_default_configs_source_title,
                //     style: semibold(size: 18),
                //   ),
                // ),
                // const Divider(
                //   height: 2,
                //   color: AppColors.primary,
                // ),
                ListTile(
                  onTap: () {
                    showOkCancelAlertDialog(
                      context: context,
                      okLabel: S.current
                          .settings_clear_cookies_cache_dialog_confirmation_ok_label,
                      cancelLabel: S.current
                          .settings_clear_cookies_cache_dialog_confirmation_cancel_label,
                      title: S.current
                          .settings_clear_cookies_cache_dialog_confirmation_title,
                      message: S.current
                          .settings_clear_cookies_cache_dialog_confirmation_message,
                    ).then((value) {
                      if (value.index == 0) {
                        ProtectorStorageService().clear().then((_) {
                          showOkAlertDialog(
                              context: context,
                              title: S.current
                                  .settings_clear_cookies_dialog_success);
                        });
                      }
                    });
                  },
                  title: Text(S.current.settings_clear_cookies_cache,
                      style: medium(size: 16)),
                ),
                ListTile(
                  onTap: () {
                    launchUrl(
                      Uri.parse(
                          "https://github.com/Sayuri128/wakaranai/issues/new/choose"),
                    );
                  },
                  title: Text(
                    S.current.settings_submit_issue,
                    style: medium(size: 16),
                  ),
                ),

                BlocBuilder<LatestReleaseCubit, LatestReleaseState>(
                    builder: (context, state) {
                  if (state is LatestReleaseLoaded &&
                      state.releaseData.needsUpdate) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.0),
                          ),
                        ),
                        onPressed: () {
                          launchUrl(Uri.parse(
                            state.releaseData.url,
                          ));
                        },
                        child: Text(
                          S.current.settings_download_latest_release(
                              state.releaseData.latestVersion),
                          style: medium(size: 16),
                        ),
                      ),
                    );
                  }

                  return const SizedBox();
                }),
                // ListTile(
                //   onTap: () {
                //     showOkCancelAlertDialog(
                //             context: context,
                //             title:
                //                 "Are you sure you want to delete all your data?")
                //         .then((value) {
                //       // if (value == OkCancelResult.ok) {
                //       //   waka.hardReset().then((value) {
                //       //     context.read<LocalConfigsCubit>().init();
                //       //     context.read<LibraryPageCubit>().init();
                //       //   });
                //       // }
                //     });
                //   },
                //   title: Text(
                //     "Hard reset",
                //     style: medium(size: 16),
                //   ),
                // )
              ],
            );
          }

          return const SizedBox();
        },
      ),
    );
  }

  InputDecoration _dropdownDecoration() {
    return InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 16.0),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Colors.transparent)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Colors.transparent)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16.0),
            borderSide: const BorderSide(color: Colors.transparent)));
  }
}
