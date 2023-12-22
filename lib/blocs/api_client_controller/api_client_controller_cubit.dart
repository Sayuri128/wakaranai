import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/foundation.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/models/remote_config/remote_category.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/models/remote_script/remote_script.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit<T extends ApiClient, C>
    extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit(
      {required this.remoteConfig,
      required this.remoteConfigsCubit})
      : super(const ApiClientControllerState());

  final RemoteConfigsCubit remoteConfigsCubit;
  final RemoteConfig? remoteConfig;

  void buildApiClient() async {
    if (remoteConfig != null) {
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
    }
  }
}
