import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';

part 'configs_state.dart';

class ConfigsCubit extends Cubit<ConfigsState> {
  ConfigsCubit() : super(ConfigsLoading());

  final ConfigsService _configsService = ConfigsService();

  void getConfigs() async {
    emit(ConfigsLoading());
    final mangaConfigs = await _configsService.getMangaConfigs();
    // TODO: other configs. booru, anime etc

    emit(ConfigsLoaded(
        mangaApiClients:
            await Future.wait(mangaConfigs.map((e) async => await e.buildApiClient()))));
  }
}
