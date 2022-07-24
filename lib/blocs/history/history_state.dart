part of 'history_cubit.dart';

@immutable
abstract class HistoryState {
  const HistoryState();
}

class HistoryInitial extends HistoryState {}

class HistoryInitialized extends HistoryState {
  final List<HistoryMangaItem> mangaHistory;
  final List<HistoryMangaGroup> groups;
  final Map<int, bool> expanded;

  @override
  int get hashCode => mangaHistory.hashCode;

  const HistoryInitialized({
    required this.mangaHistory,
    required this.groups,
    required this.expanded,
  });

  HistoryInitialized copyWith({
    List<HistoryMangaItem>? mangaHistory,
    List<HistoryMangaGroup>? groups,
    Map<int, bool>? expanded,
  }) {
    return HistoryInitialized(
      mangaHistory: mangaHistory ?? this.mangaHistory,
      groups: groups ?? this.groups,
      expanded: expanded ?? this.expanded,
    );
  }
}
