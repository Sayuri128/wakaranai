import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/blocs/configs_sources/configs_sources_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.sourcesCubit, required this.remoteConfigsCubit})
      : super(SettingsInitial());

  final ConfigsSourcesCubit sourcesCubit;
  final RemoteConfigsCubit remoteConfigsCubit;

  final SettingsService _settingsService = SettingsService();

  void init() async {
    emit(SettingsInitialized(
        defaultMode: await _settingsService.getDefaultReaderMode(),
        defaultConfigsSourceId:
            await _settingsService.getDefaultConfigsSourceId()));
  }

  void onChangedDefaultReadMode(ChapterViewMode mode) async {
    await _settingsService.setDefaultReaderMode(mode);
    emit((state as SettingsInitialized).copyWith(defaultMode: mode));
  }

  void onChangedDefaultSourceId(int? id) async {
    await _settingsService.setDefaultConfigsSourceId(id);

    if (id != null && sourcesCubit.state is ConfigsSourcesInitialized) {
      remoteConfigsCubit.changeSource(
          (sourcesCubit.state as ConfigsSourcesInitialized)
              .sources
              .firstWhere((element) => element.id == id));
    } else {
      remoteConfigsCubit.changeSource(ConfigsSourceItem(
          baseUrl:
              '${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG}/${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY}',
          name: S.current.github_configs_source_type,
          type: ConfigsSourceType.GIT_HUB));
    }

    emit((state as SettingsInitialized).copyWith(defaultConfigsSourceId: id));
  }
}
