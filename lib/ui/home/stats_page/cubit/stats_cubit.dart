import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/data/domain/ui/reading_stats.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';

part 'stats_state.dart';

class StatsCubit extends Cubit<StatsState> {
  StatsCubit({
    required this.chapterActivityRepository,
    required this.animeEpisodeActivityRepository,
    required this.concreteDataRepository,
    required this.extensionResolver,
  }) : super(StatsInitial());

  final ChapterActivityRepository chapterActivityRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;
  final ConcreteDataRepository concreteDataRepository;
  final ExtensionResolver extensionResolver;

  final SettingsService _settingsService = SettingsService();

  static const int _topSourcesLimit = 6;

  void init() async {
    emit(StatsLoading());

    try {
      final bool enabled = await _settingsService.getCollectStatistics();
      if (!enabled) {
        emit(StatsDisabled());
        return;
      }

      final List<ChapterActivityDomain> chapters =
          await chapterActivityRepository.getAll();
      final List<AnimeEpisodeActivityDomain> episodes =
          await animeEpisodeActivityRepository.getAll();

      emit(StatsLoaded(await _compute(chapters, episodes)));
    } catch (_) {
      emit(StatsError());
    }
  }

  void enable() async {
    await _settingsService.setCollectStatistics(true);
    init();
  }

  Future<ReadingStats> _compute(
    List<ChapterActivityDomain> chapters,
    List<AnimeEpisodeActivityDomain> episodes,
  ) async {
    final Map<int, String> concreteToExtensionUid =
        await _concreteExtensionUids(chapters, episodes);
    final Map<String, ExtensionDomain?> extensions =
        await _resolveExtensions(concreteToExtensionUid.values.toSet());

    int chaptersRead = 0;
    int pagesRead = 0;
    for (final ChapterActivityDomain c in chapters) {
      if (c.isCompleted) chaptersRead++;
      final ExtensionDomain? extension =
          extensions[concreteToExtensionUid[c.concreteId]];
      if (_countsPages(extension?.config.type)) {
        pagesRead += c.readPages;
      }
    }

    int watchSeconds = 0;
    for (final AnimeEpisodeActivityDomain e in episodes) {
      watchSeconds += e.watchedTime ?? 0;
    }

    final Map<DateTime, int> dailyCounts = <DateTime, int>{};
    DateTime? first;
    DateTime? last;
    void addDay(DateTime raw) {
      final DateTime day = DateTime(raw.year, raw.month, raw.day);
      dailyCounts[day] = (dailyCounts[day] ?? 0) + 1;
      if (first == null || day.isBefore(first!)) first = day;
      if (last == null || day.isAfter(last!)) last = day;
    }

    for (final ChapterActivityDomain c in chapters) {
      addDay(c.updatedAt ?? c.createdAt);
    }
    for (final AnimeEpisodeActivityDomain e in episodes) {
      addDay(e.updatedAt ?? e.createdAt);
    }

    final Map<String, SourceStat> sources = _computeSources(
      chapters,
      episodes,
      concreteToExtensionUid,
      extensions,
    );

    final List<SourceStat> topSources = sources.values.toList()
      ..sort((SourceStat a, SourceStat b) => b.total.compareTo(a.total));

    return ReadingStats(
      chaptersRead: chaptersRead,
      chaptersStarted: chapters.length,
      pagesRead: pagesRead,
      episodesWatched: episodes.length,
      watchSeconds: watchSeconds,
      currentStreak: _currentStreak(dailyCounts.keys.toSet()),
      longestStreak: _longestStreak(dailyCounts.keys.toSet()),
      activeDays: dailyCounts.length,
      topSources: topSources.take(_topSourcesLimit).toList(),
      dailyCounts: dailyCounts,
      firstActivity: first,
      lastActivity: last,
    );
  }

  static bool _countsPages(ConfigInfoType? type) {
    return type != ConfigInfoType.NOVEL && type != ConfigInfoType.AUDIO;
  }

  Future<Map<int, String>> _concreteExtensionUids(
    List<ChapterActivityDomain> chapters,
    List<AnimeEpisodeActivityDomain> episodes,
  ) async {
    final Set<int> concreteIds = <int>{
      ...chapters.map((ChapterActivityDomain c) => c.concreteId),
      ...episodes.map((AnimeEpisodeActivityDomain e) => e.concreteId),
    };

    final Map<int, String> concreteToExtensionUid = <int, String>{};
    for (final int id in concreteIds) {
      final concrete = await concreteDataRepository.get(id);
      if (concrete != null) {
        concreteToExtensionUid[id] = concrete.extensionUid;
      }
    }
    return concreteToExtensionUid;
  }

  Future<Map<String, ExtensionDomain?>> _resolveExtensions(
    Set<String> extensionUids,
  ) async {
    final Map<String, ExtensionDomain?> extensions =
        <String, ExtensionDomain?>{};
    for (final String uid in extensionUids) {
      extensions[uid] = await extensionResolver.resolve(uid);
    }
    return extensions;
  }

  Map<String, SourceStat> _computeSources(
    List<ChapterActivityDomain> chapters,
    List<AnimeEpisodeActivityDomain> episodes,
    Map<int, String> concreteToExtensionUid,
    Map<String, ExtensionDomain?> extensions,
  ) {
    String nameFor(String extensionUid) {
      return extensions[extensionUid]?.config.name ?? extensionUid;
    }

    final Map<String, int> mangaCounts = <String, int>{};
    final Map<String, int> animeCounts = <String, int>{};

    for (final ChapterActivityDomain c in chapters) {
      final String? uid = concreteToExtensionUid[c.concreteId];
      if (uid == null) continue;
      final String name = nameFor(uid);
      mangaCounts[name] = (mangaCounts[name] ?? 0) + 1;
    }
    for (final AnimeEpisodeActivityDomain e in episodes) {
      final String? uid = concreteToExtensionUid[e.concreteId];
      if (uid == null) continue;
      final String name = nameFor(uid);
      animeCounts[name] = (animeCounts[name] ?? 0) + 1;
    }

    final Map<String, SourceStat> sources = <String, SourceStat>{};
    for (final String name in <String>{...mangaCounts.keys, ...animeCounts.keys}) {
      sources[name] = SourceStat(
        name: name,
        mangaCount: mangaCounts[name] ?? 0,
        animeCount: animeCounts[name] ?? 0,
      );
    }
    return sources;
  }

  int _currentStreak(Set<DateTime> days) {
    if (days.isEmpty) return 0;
    final DateTime now = DateTime.now();
    DateTime cursor = DateTime(now.year, now.month, now.day);
    if (!days.contains(cursor)) {
      cursor = cursor.subtract(const Duration(days: 1));
      if (!days.contains(cursor)) return 0;
    }
    int streak = 0;
    while (days.contains(cursor)) {
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _longestStreak(Set<DateTime> days) {
    if (days.isEmpty) return 0;
    final List<DateTime> sorted = days.toList()
      ..sort((DateTime a, DateTime b) => a.compareTo(b));
    int longest = 1;
    int current = 1;
    for (int i = 1; i < sorted.length; i++) {
      final Duration gap = sorted[i].difference(sorted[i - 1]);
      if (gap.inDays == 1) {
        current++;
        if (current > longest) longest = current;
      } else {
        current = 1;
      }
    }
    return longest;
  }
}
