import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/model/services/local_api_sources_service.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakaranai/models/data/local_protector_config.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/ui/home/library/cubit/library_page_cubit.dart';

part 'local_configs_state.dart';

class LocalConfigsCubit extends Cubit<LocalConfigsState> {
  LocalConfigsCubit(
      {required this.remoteConfigsCubit, required this.libraryPageCubit})
      : super(LocalConfigsInitial());

  final RemoteConfigsCubit remoteConfigsCubit;
  final LibraryPageCubit libraryPageCubit;

  void init() async {
    emit(LocalConfigsLoading());
    LocalApiSourcesService.instance.getAll().then((value) {
      emit(LocalConfigsLoaded(localApiClients: value));
    });
  }

  void update(LocalApiClient apiClient, RemoteConfig remoteConfig) async {
    final script = await remoteConfigsCubit.configService
        .getRemoteScript(remoteConfig.path);
    LocalApiSourcesService.instance.update(LocalApiClient(
        id: apiClient.id,
        code: script.script,
        type: apiClient.type,
        localConfigInfo: LocalConfigInfo(
            id: apiClient.localConfigInfo.id,
            name: remoteConfig.config.name,
            uid: remoteConfig.config.uid,
            logoUrl: remoteConfig.config.logoUrl,
            nsfw: remoteConfig.config.nsfw,
            language: remoteConfig.config.language,
            version: remoteConfig.config.version,
            searchAvailable: remoteConfig.config.searchAvailable,
            localProtectorConfig: remoteConfig.config.protectorConfig != null
                ? LocalProtectorConfig(
                    id: apiClient.localConfigInfo.localProtectorConfig?.id,
                    pingUrl: remoteConfig.config.protectorConfig!.pingUrl,
                    inAppBrowserInterceptor: remoteConfig
                        .config.protectorConfig!.inAppBrowserInterceptor,
                    needToLogin:
                        remoteConfig.config.protectorConfig!.needToLogin,
                  )
                : null)));
    init();
  }
}
