import 'package:capyscript/api_clients/source_error.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';

typedef EpisodeResolver = Future<EpisodePlaybackPlan> Function(
  EpisodePlaylist target,
);

sealed class EpisodePlayerResult {
  const EpisodePlayerResult(this.position);

  final EpisodePlaylist position;
}

class OpenInWebPlayer extends EpisodePlayerResult {
  const OpenInWebPlayer(
    super.position, {
    this.showFallbackNotice = false,
    this.sourceError,
  });

  final bool showFallbackNotice;
  final SourceError? sourceError;
}

class PlayEpisodeRequested extends EpisodePlayerResult {
  const PlayEpisodeRequested(super.position);
}
