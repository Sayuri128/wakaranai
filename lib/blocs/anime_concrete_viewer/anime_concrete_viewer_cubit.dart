import 'package:bloc/bloc.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';

part 'anime_concrete_viewer_state.dart';

class AnimeConcreteViewCubit extends Cubit<AnimeConcreteViewState> {
  AnimeConcreteViewCubit(initalState) : super(initalState);

  void getConcrete(String uid, AnimeGalleryView galleryView) async {
    final concreteView =
        await state.apiClient.getConcrete(uid: uid, data: galleryView.data);
    emit(AnimeConcreteViewInitialized(
        concreteView: concreteView,
        galleryView: galleryView,
        apiClient: state.apiClient,
        videoGroupIndex: concreteView.videoGroups.isNotEmpty ? 0 : -1));
  }

  void changeGroup(int index) async {
    if (state is AnimeConcreteViewInitialized) {
      emit((state as AnimeConcreteViewInitialized)
          .copyWith(videoGroupIndex: index));
    }
  }
}
