import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';

typedef SessionPlanResolver = Future<EpisodePlaybackPlan?> Function(
  EpisodePlaylist position,
);

typedef SessionNativePlayerOpener = Future<EpisodePlayerResult?> Function(
  EpisodePlaylist position,
  PlayableVideo video,
);

typedef SessionWebPlayerOpener = Future<EpisodePlayerResult?> Function(
  EpisodePlaylist position, {
  required bool showFallbackNotice,
  SourceError? sourceError,
});

typedef SessionSourceErrorHandler = Future<bool> Function(
  EpisodePlaylist position,
  SourceError error,
);

sealed class _SessionStep {
  const _SessionStep(this.position);

  final EpisodePlaylist position;
}

class _DecideStep extends _SessionStep {
  const _DecideStep(super.position);
}

class _WebStep extends _SessionStep {
  const _WebStep(
    super.position, {
    required this.showFallbackNotice,
    this.sourceError,
  });

  final bool showFallbackNotice;
  final SourceError? sourceError;
}

class EpisodePlaybackSession {
  EpisodePlaybackSession({
    required this.resolvePlan,
    required this.openNativePlayer,
    required this.openWebPlayer,
    required this.isActive,
    this.onEpisodeOpened,
    this.onSourceError,
  });

  final SessionPlanResolver resolvePlan;
  final SessionNativePlayerOpener openNativePlayer;
  final SessionWebPlayerOpener openWebPlayer;
  final bool Function() isActive;
  final void Function(AnimeVideo episode)? onEpisodeOpened;
  final SessionSourceErrorHandler? onSourceError;

  EpisodePlaylist? _lastPosition;

  EpisodePlaylist? get lastPosition => _lastPosition;

  void enterEpisode(EpisodePlaylist position) {
    _lastPosition = position;
    onEpisodeOpened?.call(position.current);
  }

  Future<EpisodePlaylist> run(EpisodePlaylist start) async {
    _lastPosition = start;
    _SessionStep? step = _DecideStep(start);
    while (step != null && isActive()) {
      step = await _runStep(step);
    }
    return _lastPosition ?? start;
  }

  Future<_SessionStep?> _runStep(_SessionStep step) async {
    enterEpisode(step.position);
    switch (step) {
      case _DecideStep():
        return _decide(step.position);
      case _WebStep():
        return _openWeb(
          step.position,
          showFallbackNotice: step.showFallbackNotice,
          sourceError: step.sourceError,
        );
    }
  }

  Future<_SessionStep?> _decide(EpisodePlaylist position) async {
    final EpisodePlaybackPlan? plan = await resolvePlan(position);
    if (plan == null || !isActive()) {
      return null;
    }
    switch (plan) {
      case WebPlaybackPlan():
        return _openWeb(
          position,
          showFallbackNotice: plan.shouldNotifyUser,
          sourceError: plan.sourceError,
        );
      case SourceErrorPlaybackPlan():
        return _reportSourceError(position, plan.error);
      case NativePlaybackPlan():
        return _nextStepFor(await openNativePlayer(position, plan.video));
    }
  }

  Future<_SessionStep?> _reportSourceError(
    EpisodePlaylist position,
    SourceError error,
  ) async {
    final SessionSourceErrorHandler? handler = onSourceError;
    if (handler == null) {
      return null;
    }
    final bool retry = await handler(position, error);
    if (!retry || !isActive()) {
      return null;
    }
    return _DecideStep(position);
  }

  Future<_SessionStep?> _openWeb(
    EpisodePlaylist position, {
    required bool showFallbackNotice,
    SourceError? sourceError,
  }) async {
    final EpisodePlayerResult? result = await openWebPlayer(
      position,
      showFallbackNotice: showFallbackNotice,
      sourceError: sourceError,
    );
    return _nextStepFor(result);
  }

  _SessionStep? _nextStepFor(EpisodePlayerResult? result) {
    switch (result) {
      case null:
        return null;
      case OpenInWebPlayer():
        return _WebStep(
          result.position,
          showFallbackNotice: result.showFallbackNotice,
          sourceError: result.sourceError,
        );
      case PlayEpisodeRequested():
        return _DecideStep(result.position);
    }
  }
}
