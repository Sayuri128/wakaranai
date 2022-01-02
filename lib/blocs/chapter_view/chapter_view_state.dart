class ChapterViewState {

  final bool controlsVisible;
  final int currentPage;
  final int totalPages;

  const ChapterViewState({
    required this.controlsVisible,
    required this.currentPage,
    required this.totalPages,
  });

  ChapterViewState copyWith({
    bool? controlsVisible,
    int? currentPage,
    int? totalPages,
  }) {
    return ChapterViewState(
      controlsVisible: controlsVisible ?? this.controlsVisible,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
