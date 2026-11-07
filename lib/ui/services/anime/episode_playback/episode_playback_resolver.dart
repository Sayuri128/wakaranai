import 'dart:async';

import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video_source.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/episode/downloaded_episode_lookup.dart';
import 'package:wakaranai/services/downloads/storage/local_playback_fallback.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/video_sources_mapper.dart';
import 'package:wakaranai/utils/source_error_description.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

const Duration kVideoSourcesTimeout = Duration(seconds: 20);

enum WebPlaybackReason { webOnlyPreference, unsupported, noSources, failed, timedOut }

sealed class EpisodePlaybackPlan {
  const EpisodePlaybackPlan();
}

class NativePlaybackPlan extends EpisodePlaybackPlan {
  const NativePlaybackPlan(this.video);

  final PlayableVideo video;
}

class WebPlaybackPlan extends EpisodePlaybackPlan {
  const WebPlaybackPlan(this.reason, {this.sourceError});

  final WebPlaybackReason reason;
  final SourceError? sourceError;

  bool get shouldNotifyUser =>
      sourceError != null ||
      reason == WebPlaybackReason.failed ||
      reason == WebPlaybackReason.timedOut;
}

class SourceErrorPlaybackPlan extends EpisodePlaybackPlan {
  const SourceErrorPlaybackPlan(this.error);

  final SourceError error;
}

EpisodePlaybackPlan playbackPlanForSourceError(
  AnimeVideo episode,
  SourceError error,
) {
  if (error.kind == SourceErrorKind.unsupported) {
    return _directOrWeb(
      episode,
      WebPlaybackReason.failed,
      sourceError: error,
    );
  }
  return SourceErrorPlaybackPlan(error);
}

abstract class VideoSourceProvider {
  Future<bool> supportsVideoSources();

  Future<List<AnimeVideoSource>> getVideoSources(AnimeVideo video);
}

class AnimeApiClientVideoSourceProvider implements VideoSourceProvider {
  const AnimeApiClientVideoSourceProvider(this.client);

  final AnimeApiClient client;

  @override
  Future<bool> supportsVideoSources() {
    return runSerializedOn(client, client.supportsVideoSources);
  }

  @override
  Future<List<AnimeVideoSource>> getVideoSources(AnimeVideo video) {
    return runSerializedOn(client, () => client.getVideoSources(video));
  }
}

Future<EpisodePlaybackPlan> resolveEpisodePlayback({
  required AnimeVideo episode,
  required VideoSourceProvider? provider,
  required VideoPlayerPreference preference,
  DownloadedEpisodeLookup? downloadedEpisodes,
  LocalPlaybackFailures? localPlaybackFailures,
  Duration timeout = kVideoSourcesTimeout,
  void Function()? onFetchingSources,
}) async {
  final bool streamInsteadOfDownload = _takeStreamingFallback(
    localPlaybackFailures ?? LocalPlaybackFailures.shared,
    episode: episode,
    provider: provider,
  );
  final PlayableVideo? downloaded = streamInsteadOfDownload
      ? null
      : await _downloadedPlayable(downloadedEpisodes, episode);
  if (downloaded != null) {
    logger.i('Playing ${episode.uid} from its download');
    return NativePlaybackPlan(downloaded);
  }
  if (preference == VideoPlayerPreference.webOnly) {
    return const WebPlaybackPlan(WebPlaybackReason.webOnlyPreference);
  }
  if (provider == null) {
    return _directOrWeb(episode, WebPlaybackReason.failed);
  }
  final bool supported = await _supportsVideoSources(provider);
  if (!supported) {
    return _directOrWeb(episode, WebPlaybackReason.unsupported);
  }
  onFetchingSources?.call();
  try {
    final List<AnimeVideoSource> sources =
        await provider.getVideoSources(episode).timeout(timeout);
    final PlayableVideo video = playableVideoFromSources(sources);
    if (video.streams.isEmpty) {
      logger.i('getVideoSources returned no streams for ${episode.uid}');
      return _directOrWeb(episode, WebPlaybackReason.noSources);
    }
    return NativePlaybackPlan(video);
  } on TimeoutException {
    logger.w('getVideoSources timed out for ${episode.uid}');
    return _directOrWeb(episode, WebPlaybackReason.timedOut);
  } catch (error, stackTrace) {
    logger.e('getVideoSources failed for ${episode.uid}: $error');
    logger.e(stackTrace);
    final SourceError? sourceError = findSourceError(error);
    if (sourceError != null) {
      return playbackPlanForSourceError(episode, sourceError);
    }
    return _directOrWeb(episode, WebPlaybackReason.failed);
  }
}

bool _takeStreamingFallback(
  LocalPlaybackFailures failures, {
  required AnimeVideo episode,
  required VideoSourceProvider? provider,
}) {
  final bool canStream = provider != null || isDirectEpisode(episode);
  if (!canStream) {
    return false;
  }
  return failures.consumeFailure(episode.uid);
}

bool isDirectEpisode(AnimeVideo episode) {
  return episode.type == AnimeVideoType.DIRECT && episode.src.trim().isNotEmpty;
}

Future<PlayableVideo?> _downloadedPlayable(
  DownloadedEpisodeLookup? downloadedEpisodes,
  AnimeVideo episode,
) async {
  if (downloadedEpisodes == null) {
    return null;
  }
  try {
    return await downloadedEpisodes.playableFor(episode.uid);
  } catch (error, stackTrace) {
    logger.e('Downloaded episode lookup failed for ${episode.uid}: $error');
    logger.e(stackTrace);
    return null;
  }
}

Future<bool> _supportsVideoSources(VideoSourceProvider provider) async {
  try {
    return await provider.supportsVideoSources();
  } catch (error, stackTrace) {
    logger.e('supportsVideoSources failed: $error');
    logger.e(stackTrace);
    return false;
  }
}

EpisodePlaybackPlan _directOrWeb(
  AnimeVideo episode,
  WebPlaybackReason reason, {
  SourceError? sourceError,
}) {
  if (isDirectEpisode(episode)) {
    return NativePlaybackPlan(playableVideoFromDirectSource(episode.src));
  }
  logger.i('Playing ${episode.uid} in the web player: ${reason.name}');
  return WebPlaybackPlan(reason, sourceError: sourceError);
}
