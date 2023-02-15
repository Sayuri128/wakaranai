import 'package:bloc/bloc.dart';
import 'package:wakaranai/model/services/concrete/local_anime_concrete_view_service.dart';
import 'package:wakaranai/model/services/concrete/local_manga_concrete_view_service.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/concrete_view.dart';
import 'package:wakascript/models/elements_group_of_concrete.dart';
import 'package:wakascript/models/gallery_view.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

part 'concrete_view_state.dart';

enum ConcreteViewOrder { DEFAULT, DEFAULT_REVERSE }

class A<G extends ElementsGroupOfConcrete<dynamic>> {}

class ConcreteViewCubit<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> extends Cubit<ConcreteViewState<T, C, G>> {
  ConcreteViewCubit(initialState, {required this.tryLoadFromDb})
      : super(initialState);

  final bool tryLoadFromDb;

  Future<C> _getConcrete(String uid, Map<String, dynamic> data) async {
    return await (state.apiClient as dynamic) // TODO: avoid dynamic
        .getConcrete(uid: uid, data: data);
  }

  Future<void> getConcrete(String uid, G galleryView,
      {bool forceRemote = false}) async {
    late final ConcreteView<dynamic> concreteView;

    Future<void> saveLocalManga() async {
      await LocalMangaConcreteViewService.instance.add(
          concreteView as MangaConcreteView, galleryView as MangaGalleryView);
    }

    Future<void> saveLocalAnime() async {
      await LocalAnimeConcreteViewService.instance.add(
          concreteView as AnimeConcreteView, galleryView as AnimeGalleryView);
    }

    Future<void> getRemoteConcrete() async {
      concreteView = await _getConcrete(uid, galleryView.data);
    }

    if (!tryLoadFromDb || forceRemote) {
      await getRemoteConcrete();
      if (C == MangaConcreteView) {
        await saveLocalManga();
      } else if (C == AnimeConcreteView) {
        await saveLocalAnime();
      }
    } else {
      if (C == MangaConcreteView) {
        try {
          concreteView =
              (await LocalMangaConcreteViewService.instance.getByUid(uid))
                  .toRemote();
        } on Exception {
          await getRemoteConcrete();
          await saveLocalManga();
        }
      } else if (C == AnimeConcreteView) {
        try {
          concreteView =
              (await LocalAnimeConcreteViewService.instance.getByUid(uid))
                  .toRemote();
        } on Exception {
          await getRemoteConcrete();
          await saveLocalAnime();
        }
      } else {
        await getRemoteConcrete();
      }
    }

    emit(ConcreteViewInitialized<T, C, G>(
        concreteView: concreteView as dynamic,
        galleryView: galleryView,
        apiClient: state.apiClient,
        groupIndex: concreteView.groups.isNotEmpty ? 0 : -1,
        order: ConcreteViewOrder.DEFAULT));
  }

  void changeGroup(int index) async {
    if (state is ConcreteViewInitialized<T, C, G>) {
      emit((state as ConcreteViewInitialized<T, C, G>)
          .copyWith(groupIndex: index));
    }
  }

  void changeOrder(ConcreteViewOrder order) {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final state = this.state as ConcreteViewInitialized<T, C, G>;

      final groups = state.concreteView.groups;

      final List<ElementsGroupOfConcrete> copyGroups = List.from(groups);
      groups.clear();
      for (ElementsGroupOfConcrete element in copyGroups) {
        final reversed = List.of(element.elements.reversed);
        element.elements.clear();
        reversed.forEach(element.elements.add);
        groups.add(element);
      }

      emit(state.copyWith(order: order));
    }
  }
}
