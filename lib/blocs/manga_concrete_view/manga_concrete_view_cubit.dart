import 'package:bloc/bloc.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

part 'manga_concrete_view_state.dart';

enum MangaConcreteViewOrder { DEFAULT, DEFAULT_REVERSE }

class MangaConcreteViewCubit extends Cubit<MangaConcreteViewState> {
  MangaConcreteViewCubit(initialState) : super(initialState);

  void getConcrete(String uid, MangaGalleryView galleryView) async {
    final concrete =
        await state.apiClient.getConcrete(uid: uid, data: galleryView.data);
    emit(MangaConcreteViewInitialized(
        concreteView: concrete,
        galleryView: galleryView,
        apiClient: state.apiClient,
        currentGroupIndex: concrete.chapterGroups.isNotEmpty ? 0 : -1,
        order: MangaConcreteViewOrder.DEFAULT));
  }

  void changeGroup(int index) async {
    if (state is MangaConcreteViewInitialized) {
      emit((state as MangaConcreteViewInitialized)
          .copyWith(currentGroupIndex: index));
    }
  }

  void changeOrder(MangaConcreteViewOrder order) {
    if (state is MangaConcreteViewInitialized) {
      final state = this.state as MangaConcreteViewInitialized;

      emit(state.copyWith(
          order: order,
          concreteView: state.concreteView.copyWith(
              chapterGroups: state.concreteView.chapterGroups
                  .map(
                      (e) => e.copyWith(chapters: e.chapters.reversed.toList()))
                  .toList())));
    }
  }
}
