import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/foundation.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/data/models/remote_config/remote_category.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/data/models/remote_script/remote_script.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit<T extends ApiClient, C>
    extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({
    required this.remoteConfig,
    required this.remoteConfigsCubit,
  }) : super(const ApiClientControllerState());

  final RemoteConfigsCubit remoteConfigsCubit;
  final RemoteConfig? remoteConfig;

  void buildApiClient() async {
    if (remoteConfig != null) {
      try {
        final RemoteScript remoteScript = await remoteConfigsCubit.configService
            .getRemoteScript(remoteConfig!.path);

        switch (remoteConfig!.category) {
          case RemoteCategory.anime:
            compute<String, ApiClient>(
                    (message) async => AnimeApiClient(code: message),
                    remoteScript.script)
                .then((value) {
              emit(ApiClientControllerInitialized<AnimeApiClient>(
                  apiClient: value as AnimeApiClient,
                  configInfo: remoteConfig!.config));
            });
            break;
          case RemoteCategory.manga:
            compute<String, ApiClient>(
                    (message) async => MangaApiClient(code: message),
                    remoteScript.script)
                .then((value) {
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
