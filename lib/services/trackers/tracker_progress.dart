import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';

final List<RegExp> _chapterPatterns = <RegExp>[
  RegExp(
    r'(?:chapter|chap|ch|глава|гл|розділ|розд)\.?\s*(\d+(?:[.,]\d+)?)',
    caseSensitive: false,
    unicode: true,
  ),
  RegExp(r'(?:#|№)\s*(\d+(?:[.,]\d+)?)', unicode: true),
  RegExp(r'^\s*(\d+(?:[.,]\d+)?)', unicode: true),
];

double? parseChapterNumber(String title) {
  for (final RegExp pattern in _chapterPatterns) {
    final RegExpMatch? match = pattern.firstMatch(title);
    if (match == null) {
      continue;
    }
    final double? number =
        double.tryParse(match.group(1)!.replaceAll(',', '.'));
    if (number != null) {
      return number;
    }
  }
  return null;
}

int? finishedChapterProgress({
  required List<ChaptersGroup> groups,
  required Map<String, ChapterActivityDomain> activities,
}) {
  double? best;
  for (final ChaptersGroup group in groups) {
    for (int index = 0; index < group.elements.length; index++) {
      final Chapter chapter = group.elements[index];
      final ChapterActivityDomain? activity = activities[chapter.uid];
      if (activity == null || !isChapterFinished(activity)) {
        continue;
      }
      final double number =
          chapter.number ?? parseChapterNumber(chapter.title) ?? index + 1.0;
      if (best == null || number > best) {
        best = number;
      }
    }
  }
  return best?.floor();
}

int? finishedEpisodeProgress({
  required List<AnimeVideoGroup> groups,
  required Map<String, AnimeEpisodeActivityDomain> activities,
}) {
  double? best;
  for (final AnimeVideoGroup group in groups) {
    final List<AnimeVideo> ascending = EpisodeGroupOrder(group.elements).ascending;
    for (int index = 0; index < ascending.length; index++) {
      final AnimeVideo episode = ascending[index];
      final AnimeEpisodeActivityDomain? activity = activities[episode.uid];
      if (activity == null || !isEpisodeFinished(activity)) {
        continue;
      }
      final double number = episodeNumberOf(episode) ?? index + 1.0;
      if (best == null || number > best) {
        best = number;
      }
    }
  }
  return best?.floor();
}

TrackerStatus statusAfterProgress({
  required TrackerStatus current,
  required int progress,
  int? totalCount,
}) {
  final int? total = totalCount;
  if (total != null && total > 0 && progress >= total) {
    return TrackerStatus.completed;
  }
  if (current == TrackerStatus.repeating) {
    return TrackerStatus.repeating;
  }
  return TrackerStatus.current;
}
