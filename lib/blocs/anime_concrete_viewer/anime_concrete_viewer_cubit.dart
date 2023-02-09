import 'package:bloc/bloc.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';

part 'anime_concrete_viewer_state.dart';

enum AnimeConcreteViewOrder { DEFAULT, DEFAULT_REVERSE }

class AnimeConcreteViewCubit extends Cubit<AnimeConcreteViewState> {
  AnimeConcreteViewCubit(initialState) : super(initialState);

  void getConcrete(String uid, AnimeGalleryView galleryView) async {
    final concreteView =
        await state.apiClient.getConcrete(uid: uid, data: galleryView.data);
    emit(AnimeConcreteViewInitialized(
        concreteView: concreteView,
        galleryView: galleryView,
        apiClient: state.apiClient,
        videoGroupIndex: concreteView.videoGroups.isNotEmpty ? 0 : -1,
        order: AnimeConcreteViewOrder.DEFAULT));
  }

  void changeGroup(int index) async {
    if (state is AnimeConcreteViewInitialized) {
      emit((state as AnimeConcreteViewInitialized)
          .copyWith(videoGroupIndex: index));
    }
  }

  void changeOrder(AnimeConcreteViewOrder order) {
    if (state is AnimeConcreteViewInitialized) {
      final state = this.state as AnimeConcreteViewInitialized;

      emit(state.copyWith(
          order: order,
          concreteView: state.concreteView.copyWith(
              videoGroups: state.concreteView.videoGroups
                  .map((e) => e.copyWith(videos: e.videos.reversed.toList()))
                  .toList())));
    }
  }
}
