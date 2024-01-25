import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/data/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/data/models/configs_source_type/configs_source_type.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';

part 'remote_configs_state.dart';

class RemoteConfigsCubit extends Cubit<RemoteConfigsState> {
  RemoteConfigsCubit() : super(RemoteConfigsLoading());

  ConfigsService _configsService =
      GitHubConfigsService(Env.configsSourceOrg, Env.configsSourceRepo);

  // ConfigsService _configsService =
  //     RepoConfigsService(url: Env.LOCAL_REPOSITORY_URL);

  ConfigsService get configService => _configsService;

  void init() async {
    final SettingsService settingsService = SettingsService();

    final int? defaultId = await settingsService.getDefaultConfigsSourceId();

    if (defaultId == null) {
      getConfigs();
      return;
    }
  }

  void getConfigs() async {
    emit(RemoteConfigsLoading());

    Future.wait(<Future<List<RemoteConfig>>>[
      _configsService.getMangaConfigs(),
      _configsService.getAnimeConfigs()
    ]).then((List<List<RemoteConfig>> value) {
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
        case ConfigsSourceType.github:
          _configsService = GitHubConfigsService(
              source.baseUrl.split('/')[0], source.baseUrl.split('/')[1]);
          break;
        case ConfigsSourceType.rest:
          break;
      }
    } catch (_) {
      emit(RemoteConfigsError(
          message:
              S.current.home_configs_source_initializing_error(source.name)));
      return;
    }

    getConfigs();
  }
}
