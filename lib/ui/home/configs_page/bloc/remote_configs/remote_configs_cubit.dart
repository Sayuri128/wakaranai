import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/extension/base_extension.dart';
import 'package:wakaranai/data/domain/extension/extension_source_type.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/utils/github_url_parser.dart';

import '../../../../../repositories/shared_pref/default_extension_source_repository/default_extension_source_repository.dart';

part 'remote_configs_state.dart';

class RemoteConfigsCubit extends Cubit<RemoteConfigsState> {
  RemoteConfigsCubit({
    required this.extensionSourceRepository,
  }) : super(RemoteConfigsLoading());

  ConfigsService _configsService =
      GitHubConfigsService(Env.configsSourceOrg, Env.configsSourceRepo);

  // ConfigsService _configsService =
  //     RepoConfigsService(url: Env.LOCAL_REPOSITORY_URL);

  final DefaultExtensionRepository defaultExtensionRepository =
      DefaultExtensionRepository();
  final ExtensionSourceRepository extensionSourceRepository;

  ConfigsService get configService => _configsService;

  void init() async {
    await defaultExtensionRepository.init();

    final int? defaultId =
        await defaultExtensionRepository.getDefaultExtensionId();

    Future<void> getDefaultConfig() async {
      await getConfigs(
          sourceName:
              S.current.extension_sources_page_wakaranai_github_repo_title);
    }

    if (defaultId == null) {
      await getDefaultConfig();
      return;
    }

    final source = await extensionSourceRepository.get(defaultId);

    if (source == null) {
      await getDefaultConfig();
      return;
    }

    await changeSource(ExtensionSourcesPageResult(
      name: source.name,
      id: source.id,
      type: ExtensionSourceType.github,
      url: source.url,
    ));
  }

  Future<void> getConfigs({required String sourceName}) async {
    emit(RemoteConfigsLoading());

    Future.wait(<Future<List<BaseExtension>>>[
      _configsService.getMangaConfigs(),
      _configsService.getAnimeConfigs()
    ]).then((List<List<BaseExtension>> value) {
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

  Future<void> changeSource(ExtensionSourcesPageResult source) async {
    try {
      switch (source.type) {
        case ExtensionSourceType.github:
          final githubParser = GithubUrlParser(url: source.url);
          final githubParserResult = githubParser.parse()!;
          _configsService = GitHubConfigsService(
              githubParserResult.org, githubParserResult.repo);
          break;
      }
      await defaultExtensionRepository.setDefaultExtensionId(source.id);
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
