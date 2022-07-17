import 'package:wakascript/models/concrete_view/chapter/pages/pages.dart';

abstract class ChapterViewState {

}

class ChapterViewInit extends ChapterViewState {}

class ChapterViewInitialized extends ChapterViewState {

  final Pages pages;
  final bool controlsVisible;
  final int currentPage;
  final int totalPages;

  ChapterViewInitialized({
    required this.pages,
    required this.controlsVisible,
    required this.currentPage,
    required this.totalPages,
  });

  ChapterViewInitialized copyWith({
    Pages? pages,
    bool? controlsVisible,
    int? currentPage,
    int? totalPages,
  }) {
    return ChapterViewInitialized(
      pages: pages ?? this.pages,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
