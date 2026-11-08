import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/services/trackers/tracker_progress.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

enum MigrationMediaKind { chapters, episodes }

const double _numberTolerance = 0.0001;

class MigrationOldProgress {
  const MigrationOldProgress({
    required this.uid,
    required this.title,
    required this.number,
    required this.finished,
    this.season,
    this.readPages = 0,
    this.totalPages = 0,
    this.watchedTime,
    this.totalTime,
    this.markedWatched = false,
  });

  factory MigrationOldProgress.fromChapter(
    ChapterActivityDomain activity, {
    double? number,
  }) {
    return MigrationOldProgress(
      uid: activity.uid,
      title: activity.title,
      number: number ?? parseChapterNumber(activity.title),
      finished: activity.isCompleted,
      readPages: activity.readPages,
      totalPages: activity.totalPages,
    );
  }

  factory MigrationOldProgress.fromEpisode(
    AnimeEpisodeActivityDomain activity, {
    double? number,
    int? season,
  }) {
    return MigrationOldProgress(
      uid: activity.uid,
      title: activity.title,
      number: number ?? parseEpisodeNumber(activity.title),
      season: season,
      finished: isEpisodeActivityFinished(activity),
      watchedTime: activity.watchedTime,
      totalTime: activity.totalTime,
      markedWatched: activity.markedWatched,
    );
  }

  final String uid;
  final String title;
  final double? number;
  final int? season;
  final bool finished;
  final int readPages;
  final int totalPages;
  final int? watchedTime;
  final int? totalTime;
  final bool markedWatched;

  double get fraction {
    if (finished) {
      return 1;
    }
    if (totalPages > 0) {
      return readPages / totalPages;
    }
    final int? watched = watchedTime;
    final int? total = totalTime;
    if (watched != null && total != null && total > 0) {
      return watched / total;
    }
    return 0;
  }

  bool isAheadOf(MigrationOldProgress other) {
    return fraction > other.fraction;
  }
}

class MigrationTargetElement {
  const MigrationTargetElement({
    required this.uid,
    required this.title,
    required this.number,
    required this.data,
    this.season,
    this.timestamp,
  });

  factory MigrationTargetElement.fromChapter(Chapter chapter) {
    return MigrationTargetElement(
      uid: chapter.uid,
      title: chapter.title,
      number: chapter.number ?? parseChapterNumber(chapter.title),
      timestamp: chapter.timestamp,
      data: chapter.data,
    );
  }

  factory MigrationTargetElement.fromEpisode(AnimeVideo episode) {
    return MigrationTargetElement(
      uid: episode.uid,
      title: episode.title,
      number: episodeNumberOf(episode),
      season: episode.season,
      timestamp: episode.timestamp,
      data: episode.data,
    );
  }

  final String uid;
  final String title;
  final double? number;
  final int? season;
  final String? timestamp;
  final Map<String, dynamic> data;
}

class MigrationProgressMatch {
  const MigrationProgressMatch({required this.from, required this.targets});

  final MigrationOldProgress from;
  final List<MigrationTargetElement> targets;
}

class MigrationProgressWrite {
  const MigrationProgressWrite({required this.target, required this.progress});

  final MigrationTargetElement target;
  final MigrationOldProgress progress;
}

class MigrationProgressPlan {
  const MigrationProgressPlan({
    required this.kind,
    required this.matches,
    required this.unmatched,
  });

  const MigrationProgressPlan.empty(this.kind)
      : matches = const <MigrationProgressMatch>[],
        unmatched = const <MigrationOldProgress>[];

  final MigrationMediaKind kind;
  final List<MigrationProgressMatch> matches;
  final List<MigrationOldProgress> unmatched;

  bool get isEmpty => matches.isEmpty && unmatched.isEmpty;

  List<MigrationProgressWrite> get writes {
    final Map<String, MigrationProgressWrite> byTarget =
        <String, MigrationProgressWrite>{};
    for (final MigrationProgressMatch match in matches) {
      for (final MigrationTargetElement target in match.targets) {
        final MigrationProgressWrite? current = byTarget[target.uid];
        if (current == null || match.from.isAheadOf(current.progress)) {
          byTarget[target.uid] =
              MigrationProgressWrite(target: target, progress: match.from);
        }
      }
    }
    return byTarget.values.toList(growable: false);
  }
}

bool _sameNumber(double first, double second) {
  return (first - second).abs() < _numberTolerance;
}

bool _compatibleSeason(int? first, int? second) {
  if (first == null || second == null) {
    return true;
  }
  return first == second;
}

bool _sameKey(MigrationOldProgress first, MigrationOldProgress second) {
  final double? firstNumber = first.number;
  final double? secondNumber = second.number;
  if (firstNumber == null || secondNumber == null) {
    return false;
  }
  return _sameNumber(firstNumber, secondNumber) && first.season == second.season;
}

List<MigrationOldProgress> _mostAdvancedPerKey(
  List<MigrationOldProgress> progress,
) {
  final List<MigrationOldProgress> kept = <MigrationOldProgress>[];
  for (final MigrationOldProgress item in progress) {
    final int existing = kept.indexWhere(
      (MigrationOldProgress candidate) => _sameKey(candidate, item),
    );
    if (existing < 0) {
      kept.add(item);
      continue;
    }
    if (item.isAheadOf(kept[existing])) {
      kept[existing] = item;
    }
  }
  return kept;
}

int _compareByNumber(MigrationOldProgress first, MigrationOldProgress second) {
  final int bySeason = (first.season ?? 0).compareTo(second.season ?? 0);
  if (bySeason != 0) {
    return bySeason;
  }
  final double firstNumber = first.number ?? double.infinity;
  final double secondNumber = second.number ?? double.infinity;
  return firstNumber.compareTo(secondNumber);
}

MigrationProgressPlan mapMigrationProgress({
  required MigrationMediaKind kind,
  required List<MigrationOldProgress> progress,
  required List<List<MigrationTargetElement>> targetGroups,
}) {
  final List<MigrationTargetElement> targets = <MigrationTargetElement>[
    for (final List<MigrationTargetElement> group in targetGroups) ...group,
  ];
  final List<MigrationProgressMatch> matches = <MigrationProgressMatch>[];
  final List<MigrationOldProgress> unmatched = <MigrationOldProgress>[];
  final List<MigrationOldProgress> numbered = <MigrationOldProgress>[];
  for (final MigrationOldProgress item in progress) {
    if (item.number == null) {
      unmatched.add(item);
    } else {
      numbered.add(item);
    }
  }
  for (final MigrationOldProgress item in _mostAdvancedPerKey(numbered)) {
    final double number = item.number!;
    final List<MigrationTargetElement> found = targets
        .where((MigrationTargetElement target) {
          final double? targetNumber = target.number;
          return targetNumber != null &&
              _sameNumber(targetNumber, number) &&
              _compatibleSeason(target.season, item.season);
        })
        .toList(growable: false);
    if (found.isEmpty) {
      unmatched.add(item);
    } else {
      matches.add(MigrationProgressMatch(from: item, targets: found));
    }
  }
  matches.sort((MigrationProgressMatch a, MigrationProgressMatch b) =>
      _compareByNumber(a.from, b.from));
  unmatched.sort(_compareByNumber);
  return MigrationProgressPlan(
    kind: kind,
    matches: List<MigrationProgressMatch>.unmodifiable(matches),
    unmatched: List<MigrationOldProgress>.unmodifiable(unmatched),
  );
}

List<List<MigrationTargetElement>> migrationTargetGroupsOf(
  ConcreteView concrete,
  MigrationMediaKind kind,
) {
  final List<List<MigrationTargetElement>> groups =
      <List<MigrationTargetElement>>[];
  for (final Object group in concrete.groups) {
    if (kind == MigrationMediaKind.chapters && group is ChaptersGroup) {
      groups.add(group.elements
          .map(MigrationTargetElement.fromChapter)
          .toList(growable: false));
    }
    if (kind == MigrationMediaKind.episodes && group is AnimeVideoGroup) {
      groups.add(group.elements
          .map(MigrationTargetElement.fromEpisode)
          .toList(growable: false));
    }
  }
  return groups;
}
