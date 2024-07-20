import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/chapter_activity_domain/chapter_activity_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/data/domain/concrete_data_domain/concrete_data_domain.dart';

part 'concrete_view_state.dart';

enum ConcreteViewOrder { def, defReverse }

class A<G extends ElementsGroupOfConcrete<dynamic>> {}

class ConcreteViewCubit<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> extends Cubit<ConcreteViewState<T, C, G>> {
  ConcreteViewCubit(
    super.state, {
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
  });

  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;

  Future<C> _getConcrete(String uid, Map<String, dynamic> data) async {
    return await (state.apiClient as dynamic) // TODO: avoid dynamic
        .getConcrete(uid: uid, data: data);
  }

  Future<void> getConcrete(String uid, G galleryView,
      {bool forceRemote = false}) async {
    try {
      final ConcreteView<dynamic> concreteView =
          await _getConcrete(uid, galleryView.data);

      final all = await concreteDataRepository.getAll();

      await concreteDataRepository
          .createUpdateBy<$ConcreteDataTableTable, String>(
        concreteView.toConcreteDataDomain(
          data: galleryView.data,
          extensionUid: state.configInfo.uid,
        ),
        by: (tbl) => tbl.uid,
        where: (tbl) => tbl.uid,
      );
      final Map<String, String> imageHeaders = await state.apiClient
          .getImageHeaders(uid: uid, data: galleryView.data);

      // Fetch chapter activities to show the user's progress
      final Map<String, ChapterActivityDomain> chapterActivities = {};

      if (state.configInfo.type == ConfigInfoType.MANGA) {
        chapterActivities
            .addAll(await _fetchMangaChapterActivities(concreteView));
      }

      emit(
        ConcreteViewInitialized<T, C, G>(
          concreteView: concreteView as dynamic,
          galleryView: galleryView,
          apiClient: state.apiClient,
          configInfo: state.configInfo,
          groupIndex: concreteView.groups.isNotEmpty ? 0 : -1,
          imageHeaders: imageHeaders,
          chapterActivities: chapterActivities,
          order: ConcreteViewOrder.def,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.e(s);

      emit(
        ConcreteViewError<T, C, G>(
          message: e.toString(),
          apiClient: state.apiClient,
          configInfo: state.configInfo,
        ),
      );
    }
  }

  Future<Map<String, ChapterActivityDomain>> _fetchMangaChapterActivities(
      ConcreteView<dynamic> concreteView) async {
    final Map<String, ChapterActivityDomain> chapterActivities = {};

    if (state.configInfo.type == ConfigInfoType.MANGA) {
      final data = await chapterActivityRepository
          .getAllActivitiesByConcreteId(concreteView.uid);

      for (ChapterActivityDomain activity in data ?? []) {
        chapterActivities[activity.uid] = activity;
      }
    }

    return chapterActivities;
  }

  void updateMangaActivities() {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;

      if (state.configInfo.type == ConfigInfoType.MANGA) {
        _fetchMangaChapterActivities(state.concreteView)
            .then((chapterActivities) {
          emit(state.copyWith(chapterActivities: chapterActivities));
        });
      }
    }
  }

  void changeGroup(int index) async {
    if (state is ConcreteViewInitialized<T, C, G>) {
      emit((state as ConcreteViewInitialized<T, C, G>)
          .copyWith(groupIndex: index));
    }
  }

  void changeOrder(ConcreteViewOrder order) {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;

      final List groups = state.concreteView.groups;

      final List<ElementsGroupOfConcrete> copyGroups = List.from(groups);
      groups.clear();
      for (ElementsGroupOfConcrete element in copyGroups) {
        final List<ElementOfElementsGroupOfConcrete> reversed =
            List.of(element.elements.reversed);
        element.elements.clear();
        reversed.forEach(element.elements.add);
        groups.add(element);
      }

      emit(state.copyWith(order: order));
    }
  }
}
