import 'dart:convert';
import 'dart:math';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/repositories/shared_pref/default_manga_reader_mode_repository/default_manga_reader_repository.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/services/cubits/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/utils/page_image.dart';
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
    required this.downloadRepository,
  }) : super(ChapterViewInit());

  final ConcreteDataRepository concreteDataRepository;
  final ChapterActivityRepository chapterActivityRepository;
  final DownloadRepository downloadRepository;

  final SettingsCubit settingsCubit;
  final MangaApiClient apiClient;

  final PageController pageController;
  final ItemScrollController itemScrollController;
  final DefaultMangaReaderRepository defaultMangaReaderRepository =
      DefaultMangaReaderRepository();
  final int initialPage;

  ChapterViewInitialized get stateInitialized =>
      state as ChapterViewInitialized;

  bool isLocalPages(Pages pages) =>
      pages.value.isNotEmpty && isLocalPagePath(pages.value.first);

  Future<({Pages pages, Map<String, String> headers})> _loadPages(
      String uid, Map<String, dynamic>? data) async {
    final DownloadDomain? download = await downloadRepository.getByUid(uid);
    if (download != null &&
        download.status == DownloadStatus.done &&
        download.totalPages > 0) {
      return (
        pages: Pages(
          chapterUid: uid,
          value: DownloadManagerCubit.localPagePaths(download),
        ),
        headers: <String, String>{},
      );
    }

    final Pages pages = await apiClient.getPages(uid: uid, data: data);
    final Map<String, String> headers = await apiClient
        .getImageHeaders(uid: pages.chapterUid, data: <String, dynamic>{});
    return (pages: pages, headers: headers);
  }

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
        logger.w('Failed to load default manga reader mode: $e');
        logger.w(s);
      }

      final ({Pages pages, Map<String, String> headers}) loaded =
          await _loadPages(data.chapter.uid, data.chapter.data);

      final List<Pages> pagesS = <Pages>[loaded.pages];

      final int chapterIndex = data.group.elements.indexWhere(
          (Chapter element) => element.uid == pagesS.last.chapterUid);
      final Pages currentPages = pagesS.last;

      final bool canGetPreviousPages = (chapterIndex - 1) >= 0;
      final bool canGetNextPages =
          (chapterIndex + 1) < data.group.elements.length;

      final concreteData = await concreteDataRepository.getByUid(
        data.concreteView.uid,
      );

      if (concreteData != null) {
        await chapterActivityRepository
            .createUpdateBy<$ChapterActivityTableTable, String>(
          ChapterActivityDomain(
            uid: data.chapter.uid,
            concreteId: concreteData.id,
            title: data.chapter.title,
            data: jsonEncode(data.chapter.data),
            timestamp: data.chapter.timestamp,
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
          headers: loaded.headers,
          currentPages: currentPages,
          currentPage: max(1, initialPage),
          concreteData: concreteData,
          totalPages: currentPages.value.length,
          controlsVisible: true,
          controlsEnabled: false,
          mode: mode ??
              (settingsCubit.state is SettingsInitialized
                  ? (settingsCubit.state as SettingsInitialized).defaultMode
                  : ChapterViewMode.leftToRight),
          group: data.group,
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

      try {
        await _loadAdjacentChapter(state, next: next, onDone: onDone);
      } catch (e, s) {
        logger.e(e);
        logger.e(s);
        emit(state);
      }
    }
  }

  Future<void> _loadAdjacentChapter(ChapterViewInitialized state,
      {required bool next, VoidCallback? onDone}) async {
    final int chapterIndex = state.group.elements.indexWhere(
            (Chapter element) => element.uid == state.currentPages.chapterUid) +
        (next ? 1 : -1);

    final bool canGetPreviousPages = chapterIndex > 0;
    final bool canGetNextPages = chapterIndex < state.group.elements.length - 1;

    final chapter = state.group.elements[chapterIndex];

    Pages? optionalLoadedPages = state.pages
        .firstWhereOrNull((Pages element) => element.chapterUid == chapter.uid);

    final List<Pages> newPages = <Pages>[...state.pages];

    Map<String, String>? loadedHeaders;

    if (optionalLoadedPages == null) {
      final ({Pages pages, Map<String, String> headers}) loaded =
          await _loadPages(
        state.group.elements[chapterIndex].uid,
        state.group.elements[chapterIndex].data,
      );
      optionalLoadedPages = loaded.pages;
      loadedHeaders = loaded.headers;
      if (next) {
        newPages.add(optionalLoadedPages);
      } else {
        newPages.insert(0, optionalLoadedPages);
      }
    }

    final concreteData = state.concreteData;
    if (concreteData != null) {
      await chapterActivityRepository
          .createUpdateBy<$ChapterActivityTableTable, String>(
        ChapterActivityDomain(
          uid: chapter.uid,
          concreteId: concreteData.id,
          readPages: next ? 1 : optionalLoadedPages.value.length,
          id: 0,
          totalPages: optionalLoadedPages.value.length,
          title: chapter.title,
          timestamp: chapter.timestamp,
          data: jsonEncode(chapter.data),
          createdAt: concreteData.createdAt,
        ),
        by: (tbl) => tbl.uid,
        where: (tbl) => tbl.uid,
      );
    }
    emit(
      state.copyWith(
        canGetNextPages: canGetNextPages,
        canGetPreviousPages: canGetPreviousPages,
        pages: newPages,
        totalPages: optionalLoadedPages.value.length,
        currentPage: next ? 1 : optionalLoadedPages.value.length,
        currentPages: optionalLoadedPages,
        headers: loadedHeaders ??
            (isLocalPages(optionalLoadedPages)
                ? <String, String>{}
                : await apiClient.getImageHeaders(
                    uid: optionalLoadedPages.chapterUid, data: {})),
      ),
    );

    onDone?.call();
  }

  void onPageChanged(int index, Pages currentPages,
      {void Function(Pages)? onDone}) async {
    if (state is ChapterViewInitialized &&
        currentPages.chapterUid == stateInitialized.currentPages.chapterUid) {
      onDone?.call(stateInitialized.currentPages);
      final concreteData = stateInitialized.concreteData;
      if (concreteData != null && stateInitialized.currentPage < index) {
        final chapter = stateInitialized.group.elements.firstWhere(
            (Chapter element) => element.uid == currentPages.chapterUid);

        await chapterActivityRepository
            .createUpdateBy<$ChapterActivityTableTable, String>(
          ChapterActivityDomain(
            uid: chapter.uid,
            concreteId: concreteData.id,
            readPages: index,
            id: 0,
            timestamp: chapter.timestamp,
            data: jsonEncode(chapter.data),
            title: chapter.title,
            totalPages: currentPages.value.length,
            createdAt: concreteData.createdAt,
          ),
          by: (tbl) => tbl.uid,
          where: (tbl) => tbl.uid,
        );
      }
      // Re-check: an awaited DB write above may have yielded to another
      // handler (e.g. onPagesChanged) that changed the state.
      if (state is ChapterViewInitialized &&
          currentPages.chapterUid == stateInitialized.currentPages.chapterUid) {
        emit(stateInitialized.copyWith(currentPage: index));
      }
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
