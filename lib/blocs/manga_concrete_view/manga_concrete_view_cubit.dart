import 'package:bloc/bloc.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

part 'manga_concrete_view_state.dart';

class MangaConcreteViewCubit extends Cubit<MangaConcreteViewState> {
  MangaConcreteViewCubit(initialState) : super(initialState);

  void getConcrete(String uid, MangaGalleryView galleryView) async {
    emit(MangaConcreteViewInitialized(
        concreteView:
            await state.apiClient.getConcrete(uid: uid, data: galleryView.data),
        galleryView: galleryView,
        apiClient: state.apiClient));
  }
}
