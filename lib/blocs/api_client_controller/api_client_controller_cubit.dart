import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/models/config_info/config_info.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({required ApiClient apiClient})
      : super(ApiClientControllerState(client: apiClient));

  void getConfigInfo() async {
    emit(state.copyWith(configInfo: await state.client.getConfigInfo()));
  }
}
