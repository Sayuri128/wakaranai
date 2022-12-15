import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/services/configs_service/configs_service.dart';
import 'package:wakaranai/services/configs_service/github_configs_service.dart';
import 'package:wakaranai/services/configs_service/repo_configs_service.dart';
import 'package:wakascript/api_controller.dart';

part 'remote_configs_state.dart';

class RemoteConfigsCubit extends Cubit<RemoteConfigsState> {
  RemoteConfigsCubit() : super(RemoteConfigsLoading());

  final ConfigsService _configsService = RepoConfigsService();

  void getConfigs() async {
    emit(RemoteConfigsLoading());
    final mangaConfigs = await _configsService.getMangaConfigs();
    // TODO: other configs. booru, anime etc

    emit(RemoteConfigsLoaded(mangaApiClients: mangaConfigs));
  }
}
