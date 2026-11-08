import 'dart:async';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_source.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/video_sources_mapper.dart';

const Duration kEpisodeDownloadSourcesTimeout = Duration(seconds: 45);

typedef AnimeClientLoader = Future<AnimeApiClient> Function(
  String extensionUid,
);

class EpisodeSourcesUnavailable implements Exception {
  const EpisodeSourcesUnavailable(this.episodeUid);

  final String episodeUid;

  @override
  String toString() => 'EpisodeSourcesUnavailable($episodeUid)';
}

abstract class EpisodeSourceResolver {
  Future<PlayableVideo> resolve({
    required String extensionUid,
    required AnimeVideo episode,
  });
}

class PooledClientEpisodeSourceResolver implements EpisodeSourceResolver {
  PooledClientEpisodeSourceResolver({
    required this.loadClient,
    this.timeout = kEpisodeDownloadSourcesTimeout,
  });

  final AnimeClientLoader loadClient;
  final Duration timeout;

  @override
  Future<PlayableVideo> resolve({
    required String extensionUid,
    required AnimeVideo episode,
  }) async {
    final AnimeApiClient client = await loadClient(extensionUid);
    return resolveDownloadableEpisode(
      episode: episode,
      provider: AnimeApiClientVideoSourceProvider(client),
      timeout: timeout,
    );
  }
}

Future<PlayableVideo> resolveDownloadableEpisode({
  required AnimeVideo episode,
  required VideoSourceProvider provider,
  Duration timeout = kEpisodeDownloadSourcesTimeout,
}) async {
  if (await provider.supportsVideoSources()) {
    final List<AnimeVideoSource> sources =
        await provider.getVideoSources(episode).timeout(timeout);
    final PlayableVideo video = playableVideoFromSources(sources);
    if (video.streams.isNotEmpty) {
      return video;
    }
  }
  if (isDirectEpisode(episode)) {
    return playableVideoFromDirectSource(episode.src);
  }
  throw EpisodeSourcesUnavailable(episode.uid);
}
