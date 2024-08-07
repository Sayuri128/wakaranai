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

  void buildApiClient() async {
    if (remoteConfig != null) {
      try {
        late String script;

        if (remoteConfig is RemoteConfig) {
          script = (await remoteConfigsCubit.configService
                  .getRemoteScript((remoteConfig as RemoteConfig).path))
              .script;
          await extensionRepository.createUpdateByUid(
            ExtensionDomain(
              id: 0,
              config: remoteConfig!.config,
              sourceCode: script,
              createdAt: DateTime.now(),
            ),
          );
        } else if (remoteConfig is ExtensionDomain) {
          script = (remoteConfig as ExtensionDomain).sourceCode;
        } else {
          throw Exception("Invalid remote config type");
        }

        switch (remoteConfig!.config.type) {
          case ConfigInfoType.ANIME:
            compute<String, ApiClient>(
                    (String message) async => AnimeApiClient(code: message),
                    script)
                .then((ApiClient value) {
              emit(ApiClientControllerInitialized<AnimeApiClient>(
                  apiClient: value as AnimeApiClient,
                  configInfo: remoteConfig!.config));
            });
            break;
          case ConfigInfoType.MANGA:
            compute<String, ApiClient>(
                    (String message) async => MangaApiClient(code: message),
                    script)
                .then((ApiClient value) {
              emit(ApiClientControllerInitialized<MangaApiClient>(
                  apiClient: value as MangaApiClient,
                  configInfo: remoteConfig!.config));
            });
            break;
        }
      } catch (e, s) {
        logger.e(e);
        logger.e(s);
        emit(ApiClientControllerError(message: "Error getting remote script"));
        return;
      }
    }
  }
}
