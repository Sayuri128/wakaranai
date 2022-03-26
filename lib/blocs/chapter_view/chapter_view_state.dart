
import 'package:wakaranai_json_runtime/models/concrete_view/chapter/chapter.dart';

abstract class ChapterViewState {

}

class ChapterViewInit extends ChapterViewState {}

class ChapterViewInitialized extends ChapterViewState {

  final Chapter chapter;
  final bool controlsVisible;
  final int currentPage;
  final int totalPages;

  ChapterViewInitialized({
    required this.chapter,
    required this.controlsVisible,
    required this.currentPage,
    required this.totalPages,
  });

  ChapterViewInitialized copyWith({
    Chapter? chapter,
    bool? controlsVisible,
    int? currentPage,
    int? totalPages,
  }) {
    return ChapterViewInitialized(
      chapter: chapter ?? this.chapter,
      controlsVisible: controlsVisible ?? this.controlsVisible,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
