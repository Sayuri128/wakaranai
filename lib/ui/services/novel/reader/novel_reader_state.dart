part of 'novel_reader_cubit.dart';

sealed class NovelReaderState {
  const NovelReaderState();

  Chapter? get chapter;
}

class NovelReaderLoading extends NovelReaderState {
  const NovelReaderLoading({this.chapter});

  @override
  final Chapter? chapter;
}

class NovelReaderLoaded extends NovelReaderState {
  const NovelReaderLoaded({
    required this.chapter,
    required this.html,
    required this.concrete,
    required this.initialFraction,
    required this.fraction,
    required this.wasFinished,
    required this.previous,
    required this.next,
  });

  @override
  final Chapter chapter;
  final String html;
  final ConcreteDataDomain? concrete;
  final double initialFraction;
  final double fraction;
  final bool wasFinished;
  final Chapter? previous;
  final Chapter? next;

  bool get isEmpty => html.trim().isEmpty;

  NovelReaderLoaded copyWith({double? fraction}) {
    return NovelReaderLoaded(
      chapter: chapter,
      html: html,
      concrete: concrete,
      initialFraction: initialFraction,
      fraction: fraction ?? this.fraction,
      wasFinished: wasFinished,
      previous: previous,
      next: next,
    );
  }
}

class NovelReaderError extends NovelReaderState {
  const NovelReaderError({required this.chapter, required this.error});

  @override
  final Chapter chapter;
  final Object error;
}
