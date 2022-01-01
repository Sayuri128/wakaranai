import 'package:bloc/bloc.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/api/endpoint/endpoint.dart';
import 'package:wakaranai_json_runtime/api/endpoint/parameter/EndpointParameter.dart';
import 'package:wakaranai_json_runtime/models/config_info/config_info.dart';
import 'package:wakaranai_json_runtime/models/gallery_view/gallery_view.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({required ApiClient apiClient})
      : super(ApiClientControllerState(client: apiClient));

  void getConfigInfo() async {
    emit(state.copyWith(configInfo: await state.client.getConfigInfo()));
  }

  void getGallery(int page) async {
    emit(state.copyWith(
        galleryViews: await state.client.makeGetGalleryRequest(parameters: {
      state.client.getEndpoints
          .firstWhere((element) => element.type == GetEndpointType.GALLERY)
          .parameters
          .firstWhere((element) => element.type == EndpointParameterType.PAGINATION)
          .name: '$page'
    })));
  }
}
