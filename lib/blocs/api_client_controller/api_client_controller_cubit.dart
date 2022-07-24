import 'package:bloc/bloc.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({required ApiClient apiClient})
      : super(ApiClientControllerState(client: apiClient));

  void getConfigInfo() async {
    emit(ApiClientControllerConfigInfo(
        client: state.client, configInfo: await state.client.getConfigInfo()));
  }

}
