import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:wakaranai/blocs/chapter_view/chapter_view_state.dart';
import 'package:wakaranai/blocs/history/history_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakascript/api_controller.dart';
import 'package:collection/collection.dart';

class ChapterViewCubit extends Cubit<ChapterViewState> {
  ChapterViewCubit(
      {required this.apiClient,
      required this.settingsCubit,
      required this.historyCubit,
      required this.pageController,
      required this.itemScrollController})
      : super(ChapterViewInit());

  final SettingsCubit settingsCubit;
  final HistoryCubit historyCubit;

  final ApiClient apiClient;

  final PageController pageController;
  final ItemScrollController itemScrollController;

  void init(ChapterViewerData data) async {
    final pagesS = [await apiClient.getPages(uid: data.chapter.uid)];

    var chapterIndex = data.concreteView.chapters
        .indexWhere((element) => element.uid == pagesS.last.chapterUid);

    final canGetPreviousPages = (chapterIndex - 1) >= 0;
    final canGetNextPages =
        (chapterIndex + 1) < data.concreteView.chapters.length;

    historyCubit.addMangaToHistory(
        serviceSourceCode: apiClient.parser.code,
        concreteView: data.concreteView,
        chapterUid: pagesS[0].chapterUid);

    emit(ChapterViewInitialized(
        pages: pagesS,
        currentPages: pagesS[0],
        currentPage: 1,
        totalPages: pagesS[0].value.length,
        controlsVisible: true,
        mode: settingsCubit.state is SettingsInitialized
            ? (settingsCubit.state as SettingsInitialized).defaultMode
            : ChapterViewMode.RIGHT_TO_LEFT,
        concreteView: data.concreteView,
        canGetPreviousPages: canGetPreviousPages,
        canGetNextPages: canGetNextPages));
  }

  void onPagesChanged({required bool next}) async {
    if (state is ChapterViewInitialized) {
      final state = this.state as ChapterViewInitialized;

      var chapterIndex = state.concreteView.chapters.indexWhere(
              (element) => element.uid == state.currentPages.chapterUid) +
          (next ? 1 : -1);

      final canGetPreviousPages = chapterIndex > 0;
      final canGetNextPages = chapterIndex < state.concreteView.chapters.length;

      var optionalLoadedPages = state.pages.firstWhereOrNull((element) =>
          element.chapterUid == state.concreteView.chapters[chapterIndex].uid);

      final newPages = [...state.pages];

      if (optionalLoadedPages == null) {
        optionalLoadedPages = await apiClient.getPages(
            uid: state.concreteView.chapters[chapterIndex].uid);
        if (next) {
          newPages.add(optionalLoadedPages);
        } else {
          newPages.insert(0, optionalLoadedPages);
        }
      }

      if (state.mode == ChapterViewMode.WEBTOON) {
        itemScrollController.jumpTo(
            index: next ? 0 : optionalLoadedPages.value.length - 1,
            alignment: 0);
      } else {
        pageController
            .jumpToPage(next ? 0 : optionalLoadedPages.value.length - 1);
      }

      historyCubit.addMangaToHistory(
          serviceSourceCode: apiClient.parser.code,
          concreteView: state.concreteView,
          chapterUid: optionalLoadedPages.chapterUid);

      emit(state.copyWith(
          canGetNextPages: canGetNextPages,
          canGetPreviousPages: canGetPreviousPages,
          pages: newPages,
          totalPages: optionalLoadedPages.value.length,
          currentPage: next ? 1 : optionalLoadedPages.value.length,
          currentPages: optionalLoadedPages));
    }
  }

  void onPageChanged(int index) {
    if (state is ChapterViewInitialized) {
      emit((state as ChapterViewInitialized).copyWith(currentPage: index));
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
