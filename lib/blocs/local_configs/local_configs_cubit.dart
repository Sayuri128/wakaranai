import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/model/services/configs/local_api_sources_service.dart';
import 'package:wakaranai/model/services/configs/local_configs_info_service.dart';
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
    LocalConfigsInfoService.instance.getAll().then((value) {
      emit(LocalConfigsLoaded(localConfigsInfo: value));
    });
  }

  void update(
      LocalConfigInfo localConfigInfo, RemoteConfig remoteConfig) async {
    final script = await remoteConfigsCubit.configService
        .getRemoteScript(remoteConfig.path);

    final localApiClient = await LocalApiSourcesService.instance
        .getByConfigUid(localConfigInfo.id!);

    LocalApiSourcesService.instance.update(LocalApiClient(
        id: localConfigInfo.id,
        code: script.script,
        type: remoteCategoryToConfigInfoType(remoteConfig.category),
        localConfigInfo: LocalConfigInfo(
          id: localApiClient.localConfigInfo.id!,
          name: remoteConfig.config.name,
          uid: remoteConfig.config.uid,
          logoUrl: remoteConfig.config.logoUrl,
          nsfw: remoteConfig.config.nsfw,
          language: remoteConfig.config.language,
          version: remoteConfig.config.version,
          type: remoteConfig.config.type,
          searchAvailable: remoteConfig.config.searchAvailable,
          localProtectorConfig: remoteConfig.config.protectorConfig != null
              ? LocalProtectorConfig(
                  id: localApiClient.localConfigInfo.localProtectorConfig?.id,
                  pingUrl: remoteConfig.config.protectorConfig!.pingUrl,
                  inAppBrowserInterceptor: remoteConfig
                      .config.protectorConfig!.inAppBrowserInterceptor,
                  needToLogin: remoteConfig.config.protectorConfig!.needToLogin,
                )
              : null,
        )));
    init();
  }
}
