import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_downloads.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';

enum ContinueKind { start, resume, next }

class ContinueTarget<E> {
  const ContinueTarget({
    required this.groupIndex,
    required this.element,
    required this.kind,
  });

  final int groupIndex;
  final E element;
  final ContinueKind kind;
}

ContinueTarget<E>? resolveContinueTarget<E>({
  required List<List<E>> groupsInReadingOrder,
  required int preferredGroup,
  required String Function(E element) uidOf,
  required BaseActivityDomain? Function(String uid) activityOf,
  required bool Function(BaseActivityDomain activity) isFinished,
}) {
  final _LastTouched<E>? last = _lastTouched(
    groupsInReadingOrder,
    uidOf,
    activityOf,
  );
  if (last == null) {
    return _start(groupsInReadingOrder, preferredGroup);
  }
  if (!isFinished(last.activity)) {
    return ContinueTarget<E>(
      groupIndex: last.groupIndex,
      element: last.group[last.index],
      kind: ContinueKind.resume,
    );
  }
  for (int index = last.index + 1; index < last.group.length; index++) {
    final E candidate = last.group[index];
    final BaseActivityDomain? activity = activityOf(uidOf(candidate));
    if (activity == null || !isFinished(activity)) {
      return ContinueTarget<E>(
        groupIndex: last.groupIndex,
        element: candidate,
        kind: ContinueKind.next,
      );
    }
  }
  return null;
}

ContinueTarget<E>? _start<E>(List<List<E>> groups, int preferredGroup) {
  if (preferredGroup >= 0 &&
      preferredGroup < groups.length &&
      groups[preferredGroup].isNotEmpty) {
    return ContinueTarget<E>(
      groupIndex: preferredGroup,
      element: groups[preferredGroup].first,
      kind: ContinueKind.start,
    );
  }
  for (int groupIndex = 0; groupIndex < groups.length; groupIndex++) {
    if (groups[groupIndex].isNotEmpty) {
      return ContinueTarget<E>(
        groupIndex: groupIndex,
        element: groups[groupIndex].first,
        kind: ContinueKind.start,
      );
    }
  }
  return null;
}

class _LastTouched<E> {
  const _LastTouched({
    required this.groupIndex,
    required this.group,
    required this.index,
    required this.activity,
  });

  final int groupIndex;
  final List<E> group;
  final int index;
  final BaseActivityDomain activity;
}

_LastTouched<E>? _lastTouched<E>(
  List<List<E>> groups,
  String Function(E element) uidOf,
  BaseActivityDomain? Function(String uid) activityOf,
) {
  _LastTouched<E>? best;
  for (int groupIndex = 0; groupIndex < groups.length; groupIndex++) {
    final List<E> group = groups[groupIndex];
    for (int index = 0; index < group.length; index++) {
      final BaseActivityDomain? activity = activityOf(uidOf(group[index]));
      if (activity == null) {
        continue;
      }
      if (best == null || _touchedAt(activity).isAfter(_touchedAt(best.activity))) {
        best = _LastTouched<E>(
          groupIndex: groupIndex,
          group: group,
          index: index,
          activity: activity,
        );
      }
    }
  }
  return best;
}

DateTime _touchedAt(BaseActivityDomain activity) {
  return activity.updatedAt ?? activity.createdAt;
}

ContinueTarget<Chapter>? resolveChapterContinue({
  required List<ChaptersGroup> groups,
  required int preferredGroup,
  required Map<String, ChapterActivityDomain> activities,
}) {
  return resolveContinueTarget<Chapter>(
    groupsInReadingOrder: groups
        .map((ChaptersGroup group) => group.elements)
        .toList(growable: false),
    preferredGroup: preferredGroup,
    uidOf: (Chapter chapter) => chapter.uid,
    activityOf: (String uid) => activities[uid],
    isFinished: (BaseActivityDomain activity) =>
        activity is ChapterActivityDomain && isChapterFinished(activity),
  );
}

bool isChapterFinished(ChapterActivityDomain activity) {
  if (activity.totalPages <= 0) {
    return false;
  }
  return activity.isCompleted;
}

ContinueTarget<AnimeVideo>? resolveEpisodeContinue({
  required List<AnimeVideoGroup> groups,
  required int preferredGroup,
  required Map<String, AnimeEpisodeActivityDomain> activities,
}) {
  return resolveContinueTarget<AnimeVideo>(
    groupsInReadingOrder: groups
        .map((AnimeVideoGroup group) => EpisodeGroupOrder(group.elements).ascending)
        .toList(growable: false),
    preferredGroup: preferredGroup,
    uidOf: (AnimeVideo episode) => episode.uid,
    activityOf: (String uid) => activities[uid],
    isFinished: (BaseActivityDomain activity) =>
        activity is AnimeEpisodeActivityDomain && isEpisodeFinished(activity),
  );
}

bool isEpisodeFinished(AnimeEpisodeActivityDomain activity) {
  if (activity.watchedTime == null) {
    return true;
  }
  return isEpisodeWatchedForCleanup(activity);
}
