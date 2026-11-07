import 'dart:convert';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';

const double kResumeFinishedFraction = 0.95;
const Duration kResumeMinimumPosition = Duration(seconds: 5);

class EpisodeProgress {
  const EpisodeProgress({required this.watchedSeconds, this.totalSeconds});

  final int watchedSeconds;
  final int? totalSeconds;

  @override
  bool operator ==(Object other) {
    return other is EpisodeProgress &&
        other.watchedSeconds == watchedSeconds &&
        other.totalSeconds == totalSeconds;
  }

  @override
  int get hashCode => Object.hash(watchedSeconds, totalSeconds);
}

Duration? resolveResumePosition({
  required EpisodeProgress? saved,
  required Duration duration,
}) {
  if (saved == null) {
    return null;
  }
  final Duration savedPosition = Duration(seconds: saved.watchedSeconds);
  if (savedPosition < kResumeMinimumPosition) {
    return null;
  }
  final Duration total = duration > Duration.zero
      ? duration
      : Duration(seconds: saved.totalSeconds ?? 0);
  if (total <= Duration.zero) {
    return savedPosition;
  }
  if (_reachedFinishedFraction(
    watched: savedPosition.inMilliseconds,
    total: total.inMilliseconds,
  )) {
    return null;
  }
  return savedPosition;
}

bool isEpisodeActivityFinished(AnimeEpisodeActivityDomain activity) {
  final int? watchedSeconds = activity.watchedTime;
  final int? totalSeconds = activity.totalTime;
  if (watchedSeconds == null || totalSeconds == null || totalSeconds <= 0) {
    return true;
  }
  return _reachedFinishedFraction(watched: watchedSeconds, total: totalSeconds);
}

bool _reachedFinishedFraction({required int watched, required int total}) {
  return watched / total >= kResumeFinishedFraction;
}

abstract class EpisodeProgressStore {
  Future<EpisodeProgress?> start();

  Future<void> save(EpisodeProgress progress);
}

class ActivityEpisodeProgressStore implements EpisodeProgressStore {
  ActivityEpisodeProgressStore({
    required this.concreteDataRepository,
    required this.animeEpisodeActivityRepository,
    required this.anime,
    required this.episode,
  });

  final ConcreteDataRepository concreteDataRepository;
  final AnimeEpisodeActivityRepository animeEpisodeActivityRepository;
  final AnimeConcreteView anime;
  final AnimeVideo episode;

  int? _concreteId;
  DateTime _openedAt = DateTime.now();

  @override
  Future<EpisodeProgress?> start() async {
    final ConcreteDataDomain? concreteData =
        await concreteDataRepository.getByUid(anime.uid);
    if (concreteData == null) {
      return null;
    }
    _concreteId = concreteData.id;
    _openedAt = DateTime.now();
    final AnimeEpisodeActivityDomain? existing =
        await animeEpisodeActivityRepository
            .getBy<$AnimeEpisodeActivityTableTable>(
      episode.uid,
      where: (tbl) => tbl.uid,
    );
    await _write(
      watchedTime: existing?.watchedTime,
      totalTime: existing?.totalTime,
    );
    final int? watchedTime = existing?.watchedTime;
    if (watchedTime == null) {
      return null;
    }
    return EpisodeProgress(
      watchedSeconds: watchedTime,
      totalSeconds: existing?.totalTime,
    );
  }

  @override
  Future<void> save(EpisodeProgress progress) async {
    if (_concreteId == null) {
      return;
    }
    await _write(
      watchedTime: progress.watchedSeconds,
      totalTime: progress.totalSeconds,
    );
  }

  Future<void> _write({
    required int? watchedTime,
    required int? totalTime,
  }) async {
    final int? concreteId = _concreteId;
    if (concreteId == null) {
      return;
    }
    await animeEpisodeActivityRepository
        .createUpdateBy<$AnimeEpisodeActivityTableTable, String>(
      AnimeEpisodeActivityDomain(
        id: 0,
        title: episode.title,
        uid: episode.uid,
        concreteId: concreteId,
        data: jsonEncode(episode.data),
        watchedTime: watchedTime,
        totalTime: totalTime,
        timestamp: episode.timestamp,
        createdAt: _openedAt,
      ),
      by: (AnimeEpisodeActivityDomain domain) => domain.uid,
      where: (tbl) => tbl.uid,
    );
  }
}
