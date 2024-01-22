import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
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

  ConfigsService _configsService = GitHubConfigsService(
      Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG,
      Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY);

  // ConfigsService _configsService =
  //     RepoConfigsService(url: Env.LOCAL_REPOSITORY_URL);

  ConfigsService get configService => _configsService;

  void init() async {
    final SettingsService settingsService = SettingsService();

    final defaultId = await settingsService.getDefaultConfigsSourceId();

    if (defaultId == null) {
      getConfigs();
      return;
    }
  }

  void getConfigs() async {
    emit(RemoteConfigsLoading());

    Future.wait([
      _configsService.getMangaConfigs(),
      _configsService.getAnimeConfigs()
    ]).then((value) {
      emit(
        RemoteConfigsLoaded(
          mangaRemoteConfigs: value[0].cast(),
          animeRemoteConfigs: value[1].cast(),
        ),
      );
    }).catchError((err, s) {
      logger.e(err);
      logger.e(s);
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
