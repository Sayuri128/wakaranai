import 'dart:convert';

import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

part 'concrete_view_state.dart';

enum ConcreteViewOrder { def, defReverse }

class ConcreteViewCubit<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> extends Cubit<ConcreteViewState<T, C, G>> {
  ConcreteViewCubit(
    super.state, {
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
    required this.animeEpisodeActivityRepository,
  });

  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;

  Future<C> _getConcrete(String uid, Map<String, dynamic> data) async {
    return await (state.apiClient as dynamic) // TODO: avoid dynamic
        .getConcrete(uid: uid, data: data);
  }

  Future<void> getConcrete(String uid, Map<String, dynamic> galleryData,
      {bool forceRemote = false}) async {
    try {
      final ConcreteView<dynamic> concreteView =
          await _getConcrete(uid, galleryData);

      final domain = await concreteDataRepository
          .createUpdateBy<$ConcreteDataTableTable, String>(
        concreteView.toConcreteDataDomain(
          data: galleryData,
          extensionUid: state.configInfo.uid,
        ),
        by: (tbl) => tbl.uid,
        where: (tbl) => tbl.uid,
      );
      final Map<String, String> imageHeaders =
          await state.apiClient.getImageHeaders(uid: uid, data: galleryData);

      // Fetch chapter activities to show the user's progress
      final Map<String, ChapterActivityDomain> chapterActivities = {};

      if (state.configInfo.type == ConfigInfoType.MANGA) {
        chapterActivities
            .addAll(await _fetchMangaChapterActivities(concreteView));
      }

      final Map<String, AnimeEpisodeActivityDomain> animeEpisodeActivities = {};

      if (state.configInfo.type == ConfigInfoType.ANIME) {
        animeEpisodeActivities
            .addAll(await _fetchAnimeEpisodeActivities(concreteView));
      }

      final groupIndex = concreteView.groups.isNotEmpty ? 0 : -1;
      emit(
        ConcreteViewInitialized<T, C, G>(
          concreteView: concreteView as dynamic,
          apiClient: state.apiClient,
          configInfo: state.configInfo,
          domain: domain,
          groupIndex: groupIndex,
          imageHeaders: imageHeaders,
          chapterActivities: chapterActivities,
          animeEpisodeActivities: animeEpisodeActivities,
          order: ConcreteViewOrder.def,
          selection: [],
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

  Future<Map<String, AnimeEpisodeActivityDomain>> _fetchAnimeEpisodeActivities(
      ConcreteView<dynamic> concreteView) async {
    final Map<String, AnimeEpisodeActivityDomain> animeEpisodeActivities = {};

    if (state.configInfo.type == ConfigInfoType.ANIME) {
      final data = await animeEpisodeActivityRepository
          .getAllActivitiesByConcreteId(concreteView.uid);

      for (AnimeEpisodeActivityDomain activity in data ?? []) {
        animeEpisodeActivities[activity.uid] = activity;
      }
    }

    return animeEpisodeActivities;
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

  void updateActivities() {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;

      if (state.configInfo.type == ConfigInfoType.MANGA) {
        _fetchMangaChapterActivities(state.concreteView)
            .then((chapterActivities) {
          emit(state.copyWith(chapterActivities: chapterActivities));
        });
      } else if (state.configInfo.type == ConfigInfoType.ANIME) {
        _fetchAnimeEpisodeActivities(state.concreteView)
            .then((animeEpisodeActivities) {
          emit(state.copyWith(animeEpisodeActivities: animeEpisodeActivities));
        });
      }
    }
  }

  void changeGroup(int index) async {
    if (state is ConcreteViewInitialized<T, C, G>) {
      emit((state as ConcreteViewInitialized<T, C, G>).copyWith(
        groupIndex: index,
        selection: [],
      ));
    }
  }

  void changeSelection(String uid) {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;

      final List<String> selection = List.of(state.selection);

      if (selection.contains(uid)) {
        selection.remove(uid);
      } else {
        selection.add(uid);
      }

      emit(state.copyWith(selection: selection));
    }
  }

  void invertSelection() {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;

      final List<String> selection = List.of(state.selection);

      final List<String> newSelection = [];
      for (int i = 0;
          i < state.concreteView.groups[state.groupIndex].elements.length;
          i++) {
        final ElementOfElementsGroupOfConcrete element =
            state.concreteView.groups[state.groupIndex].elements[i];
        if (!selection.contains(element.uid)) {
          newSelection.add(element.uid);
        }
      }

      emit(state.copyWith(selection: newSelection));
    }
  }

  void selectAll() {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;
      emit(
        state.copyWith(
          selection: List.generate(
              state.concreteView.groups[state.groupIndex].elements.length,
              (index) => state
                  .concreteView.groups[state.groupIndex].elements[index].uid),
        ),
      );
    }
  }

  void clearSelection() {
    if (state is ConcreteViewInitialized<T, C, G>) {
      emit((state as ConcreteViewInitialized<T, C, G>).copyWith(
        selection: [],
      ));
    }
  }

  void markSelectedAsNotCompleted() async {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;
      if (state.domain == null) return;

      final List<String> selection = List.of(state.selection);

      for (String uid in selection) {
        if (state.configInfo.type == ConfigInfoType.MANGA) {
          await chapterActivityRepository.deleteBy<$ChapterActivityTableTable>(
            uid,
            where: (tbl) => tbl.uid,
          );
        } else if (state.configInfo.type == ConfigInfoType.ANIME) {
          await animeEpisodeActivityRepository
              .deleteBy<$AnimeEpisodeActivityTableTable>(
            uid,
            where: (tbl) => tbl.uid,
          );
        }
      }

      clearSelection();
      updateActivities();
    }
  }

  void markSelectedAsCompleted() async {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final ConcreteViewInitialized<T, C, G> state =
          this.state as ConcreteViewInitialized<T, C, G>;
      if (state.domain == null) return;

      final List<String> selection = List.of(state.selection);

      for (String uid in selection) {
        final groupItem = state.concreteView.groups[state.groupIndex].elements
            .firstWhere((element) => element.uid == uid);

        if (state.configInfo.type == ConfigInfoType.MANGA) {
          final chapter = groupItem as Chapter;

          final ChapterActivityDomain activity = ChapterActivityDomain(
            id: 0,
            uid: uid,
            concreteId: state.domain!.id,
            timestamp: chapter.timestamp,
            title: chapter.title,
            data: jsonEncode(chapter.data),
            createdAt: DateTime.now(),
            readPages: 0,
            totalPages: 0,
          );

          await chapterActivityRepository
              .createUpdateBy<$ChapterActivityTableTable, String>(
            activity,
            by: (tbl) => tbl.uid,
            where: (tbl) => tbl.uid,
          );
        } else if (state.configInfo.type == ConfigInfoType.ANIME) {
          final AnimeEpisodeActivityDomain activity =
              AnimeEpisodeActivityDomain(
            id: 0,
            uid: uid,
            concreteId: state.domain!.id,
            timestamp: groupItem.timestamp,
            title: groupItem.title,
            data: jsonEncode(groupItem.data),
            createdAt: DateTime.now(),
            watchedTime: null,
            totalTime: null,
          );

          await animeEpisodeActivityRepository
              .createUpdateBy<$AnimeEpisodeActivityTableTable, String>(
            activity,
            by: (tbl) => tbl.uid,
            where: (tbl) => tbl.uid,
          );
        }
      }

      clearSelection();
      updateActivities();
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
