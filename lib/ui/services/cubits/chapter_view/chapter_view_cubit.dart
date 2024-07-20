import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakaranai/data/domain/chapter_activity_domain/chapter_activity_domain.dart';
import 'package:wakaranai/data/entities/chapter_activity/chapter_activity_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/shared_pref/default_manga_reader_mode_repository/default_manga_reader_repository.dart';
import 'package:wakaranai/ui/home/settings/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit({
    required this.apiClient,
    required this.settingsCubit,
    required this.pageController,
    required this.itemScrollController,
    required this.initialPage,
    required this.concreteDataRepository,
    required this.chapterActivityRepository,
  }) : super(ChapterViewInit());

  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;

  final SettingsCubit settingsCubit;
  final MangaApiClient apiClient;

  final PageController pageController;
  final ItemScrollController itemScrollController;
  final DefaultMangaReaderRepository defaultMangaReaderRepository =
      DefaultMangaReaderRepository();
  final int initialPage;

  ChapterViewInitialized get stateInitialized =>
      state as ChapterViewInitialized;

  Future<void> init(
    ChapterViewerData data, {
    void Function(int page, int totalPage)? pagesLoaded,
  }) async {
    try {
      ChapterViewMode? mode;

      try {
        await defaultMangaReaderRepository.init();
        mode = await defaultMangaReaderRepository.getDefaultMangaReaderMode(
          data.configInfo.uid,
          data.concreteView.uid,
        );
      } catch (e, s) {
        // ignore:
      }

      final List<Pages> pagesS = <Pages>[
        await apiClient.getPages(
          uid: data.chapter.uid,
          data: data.chapter.data,
        )
      ];

      final int chapterIndex = data.group.elements.indexWhere(
          (Chapter element) => element.uid == pagesS.last.chapterUid);
      final Pages currentPages = pagesS.last;

      final bool canGetPreviousPages = (chapterIndex - 1) >= 0;
      final bool canGetNextPages =
          (chapterIndex + 1) < data.group.elements.length;

      final concreteData =
          await concreteDataRepository.getBy<$ConcreteDataTableTable>(
        data.concreteView.uid,
        where: (tbl) => tbl.uid,
      );

      if (concreteData != null) {
        chapterActivityRepository
            .createUpdateBy<$ChapterActivityTableTable, String>(
          ChapterActivityDomain(
            uid: currentPages.chapterUid,
            concreteId: concreteData.id,
            readPages: initialPage,
            id: 0,
            totalPages: currentPages.value.length,
            createdAt: DateTime.now(),
          ),
          by: (tbl) => tbl.uid,
          where: (tbl) => tbl.uid,
        );
      }

      emit(
        ChapterViewInitialized(
          data: data,
          pages: pagesS,
          headers: await apiClient
              .getImageHeaders(uid: currentPages.chapterUid, data: {}),
          currentPages: currentPages,
          currentPage: initialPage,
          concreteData: concreteData,
          totalPages: currentPages.value.length,
          controlsVisible: true,
          controlsEnabled: false,
          mode: mode ??
              (settingsCubit.state is SettingsInitialized
                  ? (settingsCubit.state as SettingsInitialized).defaultMode
                  : ChapterViewMode.leftToRight),
          group: data.group,
          galleryView: data.galleryView,
          canGetPreviousPages: canGetPreviousPages,
          canGetNextPages: canGetNextPages,
        ),
      );
      pagesLoaded?.call(initialPage, currentPages.value.length);
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      emit(
        ChapterViewError(
          message: e.toString(),
        ),
      );
    }
  }

  void onPagesChanged({required bool next, VoidCallback? onDone}) async {
    if (state is ChapterViewInitialized) {
      final ChapterViewInitialized state = this.state as ChapterViewInitialized;
      emit(ChapterViewInit());

      final int chapterIndex = state.group.elements.indexWhere(
              (Chapter element) =>
                  element.uid == state.currentPages.chapterUid) +
          (next ? 1 : -1);

      final bool canGetPreviousPages = chapterIndex > 0;
      final bool canGetNextPages =
          chapterIndex < state.group.elements.length - 1;

      Pages? optionalLoadedPages = state.pages.firstWhereOrNull(
          (Pages element) =>
              element.chapterUid == state.group.elements[chapterIndex].uid);

      final List<Pages> newPages = <Pages>[...state.pages];

      if (optionalLoadedPages == null) {
        optionalLoadedPages = await apiClient.getPages(
            uid: state.group.elements[chapterIndex].uid,
            data: state.group.elements[chapterIndex].data);
        if (next) {
          newPages.add(optionalLoadedPages);
        } else {
          newPages.insert(0, optionalLoadedPages);
        }
      }

      chapterActivityRepository
          .createUpdateBy<$ChapterActivityTableTable, String>(
        ChapterActivityDomain(
          uid: optionalLoadedPages.chapterUid,
          concreteId: state.concreteData!.id,
          readPages: next ? 1 : optionalLoadedPages.value.length,
          id: state.concreteData!.id,
          totalPages: optionalLoadedPages.value.length,
          createdAt: state.concreteData!.createdAt,
        ),
        by: (tbl) => tbl.uid,
        where: (tbl) => tbl.uid,
      );
      emit(
        state.copyWith(
          canGetNextPages: canGetNextPages,
          canGetPreviousPages: canGetPreviousPages,
          pages: newPages,
          totalPages: optionalLoadedPages.value.length,
          currentPage: next ? 1 : optionalLoadedPages.value.length,
          currentPages: optionalLoadedPages,
          headers: await apiClient
              .getImageHeaders(uid: optionalLoadedPages.chapterUid, data: {}),
        ),
      );

      onDone?.call();
    }
  }

  void onPageChanged(int index, Pages currentPages,
      {void Function(Pages)? onDone}) async {
    if (state is ChapterViewInitialized &&
        currentPages.chapterUid == stateInitialized.currentPages.chapterUid) {
      onDone?.call(stateInitialized.currentPages);
      if (stateInitialized.currentPage < index) {
        chapterActivityRepository
            .createUpdateBy<$ChapterActivityTableTable, String>(
          ChapterActivityDomain(
            uid: currentPages.chapterUid,
            concreteId: stateInitialized.concreteData!.id,
            readPages: index,
            id: stateInitialized.concreteData!.id,
            totalPages: currentPages.value.length,
            createdAt: stateInitialized.concreteData!.createdAt,
          ),
          by: (tbl) => tbl.uid,
          where: (tbl) => tbl.uid,
        );
      }
      emit(stateInitialized.copyWith(currentPage: index));
    }
  }

  void onSetControls(bool value) {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(controlsEnabled: value));
    }
  }

  void onChangeVisibility() {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(
          controlsVisible: !(state as ChapterViewInitialized).controlsVisible));
    }
  }

  void onModeChanged(ChapterViewMode mode) {
    if (state is ChapterViewInitialized) {
      defaultMangaReaderRepository
          .setDefaultMangaReaderMode(
        mode,
        (state as ChapterViewInitialized).data.configInfo.uid,
        (state as ChapterViewInitialized).data.concreteView.uid,
      )
          .catchError((e) {
        logger.e(e);
      });

      emit((state as ChapterViewInitialized).copyWith(mode: mode));
    }
  }
}
