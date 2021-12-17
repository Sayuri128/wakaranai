part of 'source_view_cubit.dart';

class SourceViewState {

  final bool controlsVisible;
  final int currentPage;
  final int totalPages;

  const SourceViewState({
    required this.currentPage,
    required this.totalPages,
    required this.controlsVisible
  });

  SourceViewState copyWith({
    bool? controlsVisible,
    int? currentPage,
    int? totalPages,
  }) {
    return SourceViewState(
      controlsVisible: controlsVisible ?? this.controlsVisible,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}
