import 'package:bloc/bloc.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/concrete_view.dart';
import 'package:wakaranai_json_runtime/models/config_info/config_info.dart';
import 'package:wakaranai_json_runtime/models/gallery_view/gallery_view.dart';

part 'api_client_controller_state.dart';

class ApiClientControllerCubit extends Cubit<ApiClientControllerState> {
  ApiClientControllerCubit({required ApiClient apiClient})
      : super(ApiClientControllerState(client: apiClient));

  void getConfigInfo() async {
    emit(ApiClientControllerConfigInfo(
        client: state.client, configInfo: await state.client.getConfigInfo()));
  }

  void getGallery() async {
    List<GalleryView> galleryViews = [];
    var currentPage = 0;

    if (state is ApiClientControllerGalleryView) {
      galleryViews = (state as ApiClientControllerGalleryView).galleryViews;
      currentPage = (state as ApiClientControllerGalleryView).currentPage;
    }

    galleryViews.addAll(
        await state.client.makeGetGalleryRequest(page: currentPage += 1));

    emit(ApiClientControllerGalleryView(
        client: state.client,
        galleryViews: galleryViews,
        currentPage: currentPage));
  }

  void getConcrete(String uid) async {
    emit(ApiClientControllerConcreteView(
        client: state.client,
        concreteView: await state.client.makeGetConcreteRequest(uid: uid)));
  }
}
