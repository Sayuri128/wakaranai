import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_config_info.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/services/local_api_clients_service/local_api_clients_service.dart';
import 'package:wakaranai/ui/home/library/cubit/library_page_cubit.dart';

part 'local_configs_state.dart';

class LocalConfigsCubit extends Cubit<LocalConfigsState> {
  LocalConfigsCubit(
      {required this.localApiClientsService,
      required this.remoteConfigsCubit,
      required this.libraryPageCubit})
      : super(LocalConfigsInitial());

  final LocalApiClientsService localApiClientsService;
  final RemoteConfigsCubit remoteConfigsCubit;
  final LibraryPageCubit libraryPageCubit;

  void init() async {
    emit(LocalConfigsLoading());
    localApiClientsService.getAll().then((value) {
      emit(LocalConfigsLoaded(localApiClients: value));
    });
  }

  void update(LocalApiClient apiClient, RemoteConfig remoteConfig) async {
    final script = await remoteConfigsCubit.configService
        .getRemoteScript(remoteConfig.path);
    final newLocalConfig = LocalConfigInfo.fromConfigInfo(remoteConfig.config);
    newLocalConfig.id = apiClient.localConfigInfo.id;
    final newApiClient = apiClient.copyWith(
        code: script.script, localConfigInfo: newLocalConfig);
    await localApiClientsService.update(newApiClient);
    libraryPageCubit.reloadPage(fromLocalApiClientType(apiClient.type));
    if (state is LocalConfigsLoaded) {
      final state = this.state as LocalConfigsLoaded;
      final index = state.localApiClients.indexOf(state.localApiClients
          .singleWhere((element) =>
              element.localConfigInfo.uid == apiClient.localConfigInfo.uid));
      final copy = List.of(state.localApiClients)
        ..removeAt(index)
        ..insert(index, newApiClient);
      emit(LocalConfigsLoaded(localApiClients: copy));
    }
  }
}
