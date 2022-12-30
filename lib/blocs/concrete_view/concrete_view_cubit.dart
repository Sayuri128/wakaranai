import 'package:bloc/bloc.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';
import 'package:wakascript/models/gallery_view/gallery_view.dart';

part 'concrete_view_state.dart';

class ConcreteViewCubit extends Cubit<ConcreteViewState> {
  ConcreteViewCubit(initialState) : super(initialState);

  void getConcrete(String uid, GalleryView galleryView) async {
    emit(ConcreteViewInitialized(
        concreteView:
            await state.apiClient.getConcrete(uid: uid, data: galleryView.data),
        galleryView: galleryView,
        apiClient: state.apiClient));
  }
}
