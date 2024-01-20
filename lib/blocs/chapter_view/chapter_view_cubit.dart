import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/pages/pages.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit(
      {required this.apiClient,
      required this.settingsCubit,
      required this.pageController,
      required this.itemScrollController,
      required this.initialPage})
      : super(ChapterViewInit());

  final SettingsCubit settingsCubit;

  final MangaApiClient apiClient;

  final PageController pageController;
  final ItemScrollController itemScrollController;
  final int initialPage;

  ChapterViewInitialized get stateInitialized =>
      state as ChapterViewInitialized;

  void init(ChapterViewerData data,
      {void Function(int page, int totalPage)? pagesLoaded}) async {
    final pagesS = [
      await apiClient.getPages(uid: data.chapter.uid, data: data.chapter.data)
    ];

    final int chapterIndex = data.group.elements
        .indexWhere((element) => element.uid == pagesS.last.chapterUid);
    final Pages currentPages = pagesS.last;

    final canGetPreviousPages = (chapterIndex - 1) >= 0;
    final canGetNextPages = (chapterIndex + 1) < data.group.elements.length;

    emit(ChapterViewInitialized(
        pages: pagesS,
        currentPages: currentPages,
        currentPage: initialPage,
        totalPages: currentPages.value.length,
        controlsVisible: true,
        controlsEnabled: false,
        mode: settingsCubit.state is SettingsInitialized
            ? (settingsCubit.state as SettingsInitialized).defaultMode
            : ChapterViewMode.RIGHT_TO_LEFT,
        group: data.group,
        galleryView: data.galleryView,
        canGetPreviousPages: canGetPreviousPages,
        canGetNextPages: canGetNextPages));
  }

  void onPagesChanged({required bool next, VoidCallback? onDone}) async {
    if (state is ChapterViewInitialized) {
      final state = this.state as ChapterViewInitialized;
      emit(ChapterViewInit());

      final int chapterIndex = state.group.elements.indexWhere(
              (element) => element.uid == state.currentPages.chapterUid) +
          (next ? 1 : -1);

      final bool canGetPreviousPages = chapterIndex > 0;
      final bool canGetNextPages =
          chapterIndex < state.group.elements.length - 1;

      Pages? optionalLoadedPages = state.pages.firstWhereOrNull((element) =>
          element.chapterUid == state.group.elements[chapterIndex].uid);

      final List<Pages> newPages = [...state.pages];

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

      emit(state.copyWith(
          canGetNextPages: canGetNextPages,
          canGetPreviousPages: canGetPreviousPages,
          pages: newPages,
          totalPages: optionalLoadedPages.value.length,
          currentPage: next ? 1 : optionalLoadedPages.value.length,
          currentPages: optionalLoadedPages));

      onDone?.call();
    }
  }

  void onPageChanged(int index, Pages currentPages,
      {void Function(Pages)? onDone}) async {
    if (state is ChapterViewInitialized &&
        currentPages.chapterUid == stateInitialized.currentPages.chapterUid) {
      onDone?.call(stateInitialized.currentPages);
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
      emit((state as ChapterViewInitialized).copyWith(mode: mode));
    }
  }
}
