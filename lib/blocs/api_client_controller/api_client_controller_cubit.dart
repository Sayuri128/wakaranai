import 'package:bloc/bloc.dart';
import 'package:wakaranai/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit<T extends ApiClient> extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({required T apiClient})
      : super(ApiClientControllerState(client: apiClient));

  final ProtectorStorageService _protectorStorageService =
      ProtectorStorageService();

  void getConfigInfo() async {
    final configInfo = await state.client.getConfigInfo();
    emit(ApiClientControllerConfigInfo(
        client: state.client,
        configInfo: configInfo,
        cachedProtector: await _protectorStorageService.getItem(
            uid: '${configInfo.name}_${configInfo.version}')));
  }
}
