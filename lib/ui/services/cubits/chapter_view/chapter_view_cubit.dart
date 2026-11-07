import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';
import 'package:wakaranai/services/downloads/storage/download_files.dart';
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
import 'package:wakaranai/ui/services/cubits/chapter_view/reader_strip.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
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

  static const Duration _activityWriteDelay = Duration(seconds: 1);

  Timer? _activityDebounce;
  ChapterActivityDomain? _pendingActivity;

  ChapterViewInitialized get stateInitialized =>
      state as ChapterViewInitialized;

  void _scheduleActivityWrite(ChapterActivityDomain activity) {
    _pendingActivity = activity;
    _activityDebounce?.cancel();
    _activityDebounce = Timer(_activityWriteDelay, () {
      unawaited(_flushActivity());
    });
  }

  Future<void> _flushActivity() async {
    _activityDebounce?.cancel();
    _activityDebounce = null;

    final ChapterActivityDomain? activity = _pendingActivity;
    _pendingActivity = null;
    if (activity == null || IncognitoMode.active) {
      return;
    }

    await chapterActivityRepository
        .createUpdateBy<$ChapterActivityTableTable, String>(
          activity,
          by: (tbl) => tbl.uid,
          where: (tbl) => tbl.uid,
        );
  }

  bool isLocalPages(Pages pages) =>
      pages.value.isNotEmpty && isLocalPagePath(pages.value.first);

  Future<LoadedChapter> _loadChapter(Chapter chapter) async {
    final DownloadDomain? download = await downloadRepository.getByUid(
      chapter.uid,
    );
    if (download != null &&
        download.status == DownloadStatus.done &&
        download.totalPages > 0) {
      return LoadedChapter(
        chapter: chapter,
        pages: Pages(
          chapterUid: chapter.uid,
          value: DownloadFiles.localPagePaths(download),
        ),
        headers: <String, String>{},
      );
    }

    final Pages pages = await apiClient.getPages(
      uid: chapter.uid,
      data: chapter.data,
    );
    final Map<String, String> headers = await apiClient.getImageHeaders(
      uid: pages.chapterUid,
      data: <String, dynamic>{},
    );
    return LoadedChapter(chapter: chapter, pages: pages, headers: headers);
  }

  Future<void> _writeChapterActivity(
    ConcreteDataDomain? concreteData,
    Chapter chapter, {
    required int readPages,
    required int totalPages,
  }) async {
    if (concreteData == null || IncognitoMode.active) {
      return;
    }
    await chapterActivityRepository
        .createUpdateBy<$ChapterActivityTableTable, String>(
          ChapterActivityDomain(
            uid: chapter.uid,
            concreteId: concreteData.id,
            title: chapter.title,
            data: jsonEncode(chapter.data),
            timestamp: chapter.timestamp,
            readPages: readPages,
            id: 0,
            totalPages: totalPages,
            createdAt: DateTime.now(),
          ),
          by: (tbl) => tbl.uid,
          where: (tbl) => tbl.uid,
        );
  }

  ({bool previous, bool next}) _neighbours(ChaptersGroup group, String uid) {
    return (
      previous: chapterBefore(group.elements, uid) != null,
      next: chapterAfter(group.elements, uid) != null,
    );
  }

  Future<void>? _initInFlight;

  Future<void> init(
    ChapterViewerData data, {
    void Function(int page, int totalPage)? pagesLoaded,
  }) {
    final Future<void>? running = _initInFlight;
    if (running != null) {
      return running;
    }
    if (isClosed) {
      return Future<void>.value();
    }
    if (state is ChapterViewError) {
      emit(ChapterViewInit());
    }
    final Future<void> opening = _open(data, pagesLoaded: pagesLoaded);
    _initInFlight = opening;
    return opening.whenComplete(() {
      _initInFlight = null;
    });
  }

  Future<void> _open(
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

      final LoadedChapter loaded = await _loadChapter(data.chapter);
      final ({bool previous, bool next}) neighbours = _neighbours(
        data.group,
        loaded.uid,
      );

      final ConcreteDataDomain? concreteData = await concreteDataRepository
          .getByUid(data.concreteView.uid);

      await _writeChapterActivity(
        concreteData,
        data.chapter,
        readPages: initialPage,
        totalPages: loaded.pageCount,
      );

      if (isClosed) {
        return;
      }
      emit(
        ChapterViewInitialized(
          data: data,
          chapters: <LoadedChapter>[loaded],
          headers: loaded.headers,
          currentPages: loaded.pages,
          currentPage: max(1, initialPage),
          concreteData: concreteData,
          totalPages: loaded.pageCount,
          controlsVisible: true,
          controlsEnabled: false,
          mode:
              mode ??
              (settingsCubit.state is SettingsInitialized
                  ? (settingsCubit.state as SettingsInitialized).defaultMode
                  : ChapterViewMode.leftToRight),
          group: data.group,
          canGetPreviousPages: neighbours.previous,
          canGetNextPages: neighbours.next,
        ),
      );
      pagesLoaded?.call(initialPage, loaded.pageCount);
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      if (isClosed) {
        return;
      }
      emit(ChapterViewError(message: e.toString(), error: e));
    }
  }

  Future<void> loadNextInStrip() async {
    final ChapterViewState current = state;
    if (current is! ChapterViewInitialized ||
        current.nextLoad == ChapterLoad.loading) {
      return;
    }
    final Chapter? target = chapterAfter(
      current.group.elements,
      current.chapters.last.uid,
    );
    if (target == null) {
      return;
    }
    emit(current.copyWith(nextLoad: ChapterLoad.loading));
    try {
      final LoadedChapter loaded = await _loadChapter(target);
      final ChapterViewState latest = state;
      if (latest is! ChapterViewInitialized) {
        return;
      }
      emit(
        latest.copyWith(
          chapters: <LoadedChapter>[...latest.chapters, loaded],
          nextLoad: ChapterLoad.idle,
        ),
      );
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      final ChapterViewState latest = state;
      if (latest is ChapterViewInitialized) {
        emit(latest.copyWith(nextLoad: ChapterLoad.failed));
      }
    }
  }

  Future<bool> loadPreviousInStrip() async {
    final ChapterViewState current = state;
    if (current is! ChapterViewInitialized ||
        current.previousLoad == ChapterLoad.loading) {
      return false;
    }
    final Chapter? target = chapterBefore(
      current.group.elements,
      current.chapters.first.uid,
    );
    if (target == null) {
      return false;
    }
    emit(current.copyWith(previousLoad: ChapterLoad.loading));
    try {
      final LoadedChapter loaded = await _loadChapter(target);
      final ChapterViewState latest = state;
      if (latest is! ChapterViewInitialized) {
        return false;
      }
      emit(
        latest.copyWith(
          chapters: <LoadedChapter>[loaded, ...latest.chapters],
          previousLoad: ChapterLoad.idle,
        ),
      );
      return true;
    } catch (e, s) {
      logger.e(e);
      logger.e(s);
      final ChapterViewState latest = state;
      if (latest is ChapterViewInitialized) {
        emit(latest.copyWith(previousLoad: ChapterLoad.failed));
      }
      return false;
    }
  }

  void onStripPosition(String chapterUid, int page) {
    final ChapterViewState current = state;
    if (current is! ChapterViewInitialized) {
      return;
    }
    if (chapterUid == current.currentPages.chapterUid) {
      onPageChanged(page, current.currentPages);
      return;
    }
    final LoadedChapter? loaded = current.loadedChapter(chapterUid);
    if (loaded == null) {
      return;
    }
    unawaited(_flushActivity());
    final ({bool previous, bool next}) neighbours = _neighbours(
      current.group,
      chapterUid,
    );
    emit(
      current.copyWith(
        currentPages: loaded.pages,
        headers: loaded.headers,
        currentPage: page,
        totalPages: loaded.pageCount,
        canGetNextPages: neighbours.next,
        canGetPreviousPages: neighbours.previous,
      ),
    );
    unawaited(
      _writeChapterActivity(
        current.concreteData,
        loaded.chapter,
        readPages: page,
        totalPages: loaded.pageCount,
      ),
    );
  }

  void onPageChanged(
    int index,
    Pages currentPages, {
    void Function(Pages)? onDone,
  }) {
    if (state is! ChapterViewInitialized) return;
    if (currentPages.chapterUid != stateInitialized.currentPages.chapterUid) {
      return;
    }

    onDone?.call(stateInitialized.currentPages);

    if (stateInitialized.currentPage == index) {
      return;
    }

    final concreteData = stateInitialized.concreteData;
    if (concreteData != null && stateInitialized.currentPage < index) {
      final chapter = stateInitialized.group.elements.firstWhere(
        (Chapter element) => element.uid == currentPages.chapterUid,
      );

      _scheduleActivityWrite(
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
      );
    }

    emit(stateInitialized.copyWith(currentPage: index));
  }

  void onSetControls(bool value) {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(controlsEnabled: value));
    }
  }

  void onChangeVisibility() {
    if (state is ChapterViewInitialized) {
      emit(
        (state as ChapterViewInitialized).copyWith(
          controlsVisible: !(state as ChapterViewInitialized).controlsVisible,
        ),
      );
    }
  }

  @override
  Future<void> close() {
    _activityDebounce?.cancel();
    unawaited(_flushActivity());
    return super.close();
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
