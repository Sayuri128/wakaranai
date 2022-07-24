import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakascript/models/concrete_view/chapter/pages/pages.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';

abstract class ChapterViewState {
  const ChapterViewState();
}

class ChapterViewInit extends ChapterViewState {}

class ChapterViewInitialized extends ChapterViewState {

  final List<Pages> pages;
  final Pages currentPages;

  final ConcreteView concreteView;

  final int currentPage;
  final int totalPages;

  final ChapterViewMode mode;
  final bool controlsVisible;

  final bool canGetNextPages;
  final bool canGetPreviousPages;

  const ChapterViewInitialized({
    required this.pages,
    required this.currentPages,
    required this.concreteView,
    required this.currentPage,
    required this.totalPages,
    required this.mode,
    required this.controlsVisible,
    required this.canGetNextPages,
    required this.canGetPreviousPages,
  });

  ChapterViewInitialized copyWith({
    List<Pages>? pages,
    Pages? currentPages,
    ConcreteView? concreteView,
    int? currentPage,
    int? totalPages,
    ChapterViewMode? mode,
    bool? controlsVisible,
    bool? canGetNextPages,
    bool? canGetPreviousPages,
  }) {
    return ChapterViewInitialized(
      pages: pages ?? this.pages,
      currentPages: currentPages ?? this.currentPages,
      concreteView: concreteView ?? this.concreteView,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
      mode: mode ?? this.mode,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      canGetNextPages: canGetNextPages ?? this.canGetNextPages,
      canGetPreviousPages: canGetPreviousPages ?? this.canGetPreviousPages,
    );
  }
}
