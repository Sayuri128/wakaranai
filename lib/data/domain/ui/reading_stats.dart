import 'package:flutter/foundation.dart';

@immutable
class SourceStat {
  final String name;
  final int mangaCount;
  final int animeCount;

  const SourceStat({
    required this.name,
    required this.mangaCount,
    required this.animeCount,
  });

  int get total => mangaCount + animeCount;
}

@immutable
class ReadingStats {
  final int chaptersRead;
  final int chaptersStarted;
  final int pagesRead;
  final int episodesWatched;
  final int watchSeconds;
  final int currentStreak;
  final int longestStreak;
  final int activeDays;
  final List<SourceStat> topSources;
  final Map<DateTime, int> dailyCounts;
  final DateTime? firstActivity;
  final DateTime? lastActivity;

  const ReadingStats({
    required this.chaptersRead,
    required this.chaptersStarted,
    required this.pagesRead,
    required this.episodesWatched,
    required this.watchSeconds,
    required this.currentStreak,
    required this.longestStreak,
    required this.activeDays,
    required this.topSources,
    required this.dailyCounts,
    required this.firstActivity,
    required this.lastActivity,
  });

  bool get isEmpty => chaptersStarted == 0 && episodesWatched == 0;

  static const ReadingStats empty = ReadingStats(
    chaptersRead: 0,
    chaptersStarted: 0,
    pagesRead: 0,
    episodesWatched: 0,
    watchSeconds: 0,
    currentStreak: 0,
    longestStreak: 0,
    activeDays: 0,
    topSources: <SourceStat>[],
    dailyCounts: <DateTime, int>{},
    firstActivity: null,
    lastActivity: null,
  );
}
