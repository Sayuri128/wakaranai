import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';

class ParkedEpisode {
  ParkedEpisode({
    required this.playlist,
    required this.watchedEpisodeUids,
    required this.video,
    required this.progressStore,
    required this.engine,
    required this.wasPlaying,
    required this.position,
    required this.progress,
    required this.streamIndex,
    required this.renditions,
    required this.selectedRenditionId,
    required this.subtitleIndex,
    required this.captionFile,
    required this.savedProgress,
    required this.lastPersistedProgress,
  });

  final EpisodePlaylist playlist;
  final Set<String> watchedEpisodeUids;
  final PlayableVideo video;
  final EpisodeProgressStore progressStore;
  final NativePlayerEngine? engine;
  final bool wasPlaying;
  final Duration position;
  final EpisodeProgress? progress;
  final int streamIndex;
  final List<PlayerRendition> renditions;
  final String? selectedRenditionId;
  final int? subtitleIndex;
  final ClosedCaptionFile? captionFile;
  final EpisodeProgress? savedProgress;
  EpisodeProgress? lastPersistedProgress;
}
