import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/services/configs_source_service/configs_source_service.dart';

part 'configs_sources_state.dart';

class ConfigsSourcesCubit extends Cubit<ConfigsSourcesState> {
  ConfigsSourcesCubit() : super(ConfigsSourcesInitial());

  final ConfigsSourceService _configsSourceService = ConfigsSourceService();

  void getSources() async {
    emit(ConfigsSourcesLoading());
    emit(ConfigsSourcesInitialized(
        sources: await _configsSourceService.getAll()));
  }

  void create(ConfigsSourceItem item) async {
    item.id = await _configsSourceService.insert(item);
    getSources();
  }

  void delete(ConfigsSourceItem item) async {
    if (item.id != null) {
      await _configsSourceService.delete(item.id!);
    }
    getSources();
  }
}
