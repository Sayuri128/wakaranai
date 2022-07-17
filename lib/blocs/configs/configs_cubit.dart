import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakascript/api_controller.dart';

part 'configs_state.dart';

class ConfigsCubit extends Cubit<ConfigsState> {
  ConfigsCubit() : super(ConfigsLoading());

  final ConfigsService _configsService = ConfigsService();

  void getConfigs() async {
    emit(ConfigsLoading());
    final mangaConfigs = await _configsService.getMangaConfigs();
    // TODO: other configs. booru, anime etc

    emit(ConfigsLoaded(mangaApiClients: mangaConfigs));
  }
}
