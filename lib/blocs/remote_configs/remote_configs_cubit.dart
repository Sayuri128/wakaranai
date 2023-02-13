import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/model/services/local_configs_sources_service.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/services/configs_service/repo_configs_service.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';

part 'remote_configs_state.dart';

class RemoteConfigsCubit extends Cubit<RemoteConfigsState> {
  RemoteConfigsCubit() : super(RemoteConfigsLoading());

  // ConfigsService _configsService = GitHubConfigsService(
  //     Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG,
  //     Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY);
  ConfigsService _configsService =
      RepoConfigsService(url: "http://192.168.31.208:3000");

  ConfigsService get configService => _configsService;
  final LocalConfigsSourcesService _localConfigsSourcesService =
      LocalConfigsSourcesService.instance;

  void init() async {
    final SettingsService settingsService = SettingsService();

    final defaultId = await settingsService.getDefaultConfigsSourceId();

    if (defaultId == null) {
      getConfigs();
      return;
    }

    changeSource((await _localConfigsSourcesService.getAll())
            .firstWhereOrNull((element) => element.id == defaultId) ??
        SettingsCubit.DefaultConfigsServiceItem);
  }

  void getConfigs() async {
    emit(RemoteConfigsLoading());

    Future.wait([
      _configsService.getMangaConfigs(),
      _configsService.getAnimeConfigs()
    ]).then((value) {
      emit(RemoteConfigsLoaded(
          mangaRemoteConfigs: value[0].cast(),
          animeRemoteConfigs: value[1].cast()));
    }).catchError((err) {
    emit(RemoteConfigsError(message: "Configs source error :c"));
    });
  }

  void changeSource(ConfigsSourceItem source) async {
    try {
      switch (source.type) {
        case ConfigsSourceType.GIT_HUB:
          _configsService = GitHubConfigsService(
              source.baseUrl.split('/')[0], source.baseUrl.split('/')[1]);
          break;
        case ConfigsSourceType.REST:
          _configsService = RepoConfigsService(url: source.baseUrl);
          break;
      }
    } catch (_) {
      emit(RemoteConfigsError(
          message: S.current.configs_source_initializing_error(source.name)));
      return;
    }

    getConfigs();
  }
}
