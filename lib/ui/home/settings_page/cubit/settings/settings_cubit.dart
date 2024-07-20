import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.remoteConfigsCubit}) : super(SettingsInitial());

  // static final DefaultConfigsServiceItem = ConfigsSourceItem(
  //     baseUrl:
  //         '${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG}/${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY}',
  //     name: S.current.github_configs_source_type,
  //     type: ConfigsSourceType.GIT_HUB);

  final RemoteConfigsCubit remoteConfigsCubit;

  final SettingsService _settingsService = SettingsService();

  void init() async {
    emit(
      SettingsInitialized(
        defaultMode: await _settingsService.getDefaultReaderMode(),
      ),
    );
  }

  void onChangedDefaultReadMode(ChapterViewMode mode) async {
    await _settingsService.setDefaultReaderMode(mode);
    emit((state as SettingsInitialized).copyWith(defaultMode: mode));
  }
}
