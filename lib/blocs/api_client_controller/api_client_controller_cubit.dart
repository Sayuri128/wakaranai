import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';

part 'api_client_controller_state.dart';

Future<ApiClient> _buildAnimeApiClient(String code) async =>
    AnimeApiClient(code: code);

Future<ApiClient> _buildMangaApiClient(String code) async =>
    MangaApiClient(code: code);

class ApiClientControllerCubit<T extends ApiClient, C>
    extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({
    required this.extensionRepository,
    required this.remoteConfig,
    required this.remoteConfigsCubit,
  }) : super(const ApiClientControllerState());

  final RemoteConfigsCubit remoteConfigsCubit;
  final ExtensionRepository extensionRepository;
  final BaseExtension? remoteConfig;

  Future<void> buildApiClient() async {
    final BaseExtension? extension = remoteConfig;

    if (extension == null) {
      emit(ApiClientControllerError(message: 'No extension was selected'));
      return;
    }

    if (state is ApiClientControllerError) {
      emit(const ApiClientControllerState());
    }

    try {
      final String script = await _resolveScript(extension);
      final ConfigInfo config = extension.config;

      final ApiClient client = await compute<String, ApiClient>(
        config.type == ConfigInfoType.ANIME
            ? _buildAnimeApiClient
            : _buildMangaApiClient,
        script,
      );

      if (isClosed) return;

      switch (config.type) {
        case ConfigInfoType.ANIME:
          emit(ApiClientControllerInitialized<AnimeApiClient>(
              apiClient: client as AnimeApiClient, configInfo: config));
          break;
        case ConfigInfoType.MANGA:
          emit(ApiClientControllerInitialized<MangaApiClient>(
              apiClient: client as MangaApiClient, configInfo: config));
          break;
      }
    } catch (e, s) {
      logger.e('Failed to build api client for ${remoteConfig?.config.uid}: $e');
      logger.e(s);
      if (isClosed) return;
      emit(ApiClientControllerError(message: e.toString()));
    }
  }

  Future<String> _resolveScript(BaseExtension extension) async {
    if (extension is ExtensionDomain) {
      return extension.sourceCode;
    }

    if (extension is RemoteConfig) {
      final String script = (await remoteConfigsCubit.configService
              .getRemoteScript(extension.path))
          .script;

      await extensionRepository.createUpdateByUid(
        ExtensionDomain(
          id: 0,
          config: extension.config,
          sourceCode: script,
          createdAt: DateTime.now(),
        ),
      );

      return script;
    }

    throw Exception('Invalid remote config type ${extension.runtimeType}');
  }
}
