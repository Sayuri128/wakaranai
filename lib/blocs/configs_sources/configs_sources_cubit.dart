import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/model/services/local_configs_sources_service.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';

part 'configs_sources_state.dart';

class ConfigsSourcesCubit extends Cubit<ConfigsSourcesState> {
  ConfigsSourcesCubit() : super(ConfigsSourcesInitial());

  final LocalConfigsSourcesService _localConfigsSourcesService =
      LocalConfigsSourcesService.instance;

  void getSources() async {
    emit(ConfigsSourcesLoading());
    emit(ConfigsSourcesInitialized(
        sources: await _localConfigsSourcesService.getAll()));
  }

  void create(ConfigsSourceItem item) async {
    await _localConfigsSourcesService.add(item);
    getSources();
  }

  void delete(ConfigsSourceItem item) async {
    if (item.id != null) {
      await _localConfigsSourcesService.delete(item);
    }
    getSources();
  }
}
