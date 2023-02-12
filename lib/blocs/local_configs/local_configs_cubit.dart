import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/services/local_api_clients_service/local_api_clients_service.dart';

part 'local_configs_state.dart';

class LocalConfigsCubit extends Cubit<LocalConfigsState> {
  LocalConfigsCubit({required this.localApiClientsService})
      : super(LocalConfigsInitial());

  final LocalApiClientsService localApiClientsService;

  void init() async {
    emit(LocalConfigsLoading());
    localApiClientsService.getAll().then((value) {
      emit(LocalConfigsLoaded(localApiClients: value));
    });
  }
}
