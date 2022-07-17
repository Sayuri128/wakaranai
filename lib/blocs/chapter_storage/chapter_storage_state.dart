part of 'chapter_storage_cubit.dart';

@immutable
abstract class ChapterStorageState {
  const ChapterStorageState();
}

class ChapterStorageInitial extends ChapterStorageState {}

class ChapterStorageInitializing extends ChapterStorageState {}

class ChapterStorageInitialized extends ChapterStorageState {

  final Chapter chapter;
  final ChapterStorageItem? item;

  const ChapterStorageInitialized({
    required this.chapter,
    this.item,
  });

  ChapterStorageInitialized copyWith({
    Chapter? chapter,
    ChapterStorageItem? items,
  }) {
    return ChapterStorageInitialized(
      chapter: chapter ?? this.chapter,
      item: items ?? this.item,
    );
  }
}
