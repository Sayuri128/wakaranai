import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/extension/extension_source_type.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/utils/github_url_parser.dart';

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
      await getConfigs(
          sourceName:
              S.current.extension_sources_page_wakaranai_github_repo_title);
      return;
    }
  }

  Future<void> getConfigs({required String sourceName}) async {
    emit(RemoteConfigsLoading());

    Future.wait(<Future<List<RemoteConfig>>>[
      _configsService.getMangaConfigs(),
      _configsService.getAnimeConfigs()
    ]).then((List<List<RemoteConfig>> value) {
      emit(
        RemoteConfigsLoaded(
          mangaRemoteConfigs: value[0].cast(),
          animeRemoteConfigs: value[1].cast(),
          sourceName: sourceName,
        ),
      );
    }).catchError((err, s) {
      logger.e(err);
      logger.e(s);
      emit(RemoteConfigsError(message: "Configs source error :c"));
    });
  }

  void changeSource(ExtensionSourcesPageResult source) async {
    try {
      switch (source.type) {
        case ExtensionSourceType.github:
          final githubParser = GithubUrlParser(url: source.url);
          final githubParserResult = githubParser.parse()!;
          _configsService = GitHubConfigsService(
              githubParserResult.org, githubParserResult.repo);
          break;
      }
    } catch (_) {
      emit(RemoteConfigsError(
          message:
              S.current.home_configs_source_initializing_error(source.name)));
      return;
    }

    await getConfigs(
      sourceName: source.name,
    );
  }
}
