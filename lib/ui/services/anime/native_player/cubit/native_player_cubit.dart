import 'dart:async';

import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/episode_progress_keeper.dart';
import 'package:wakaranai/ui/services/anime/native_player/cubit/parked_episode.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_track_selection.dart';
import 'package:wakaranai/ui/services/anime/native_player/skip_markers.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';
import 'package:wakaranai/utils/source_error_description.dart';

part 'native_player_auto_next.dart';
part 'native_player_core.dart';
part 'native_player_episode_switching.dart';
part 'native_player_quality_selection.dart';
part 'native_player_speed.dart';
part 'native_player_state.dart';
part 'native_player_subtitles.dart';

const List<double> kNativePlayerSpeeds = <double>[
  0.25,
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2.0,
  2.5,
  3.0,
  3.5,
  4.0,
];

const Duration kNativePlayerSeekStep = Duration(seconds: 10);
const int kAutoNextCountdownSeconds = 5;

typedef EpisodeProgressStoreFactory = EpisodeProgressStore Function(
  AnimeVideo episode,
);

class NativePlayerCubit extends _NativePlayerCore
    with
        _EpisodeSwitching,
        _PlaybackSpeedControl,
        _QualitySelection,
        _SubtitleSelection,
        _AutoNextCountdown {
  NativePlayerCubit({
    required super.video,
    required super.playlist,
    required super.engineFactory,
    required super.progressStoreFor,
    required super.subtitleLoader,
    super.resolveEpisode,
    super.watchedEpisodeUids,
    super.preferences,
    super.progressSaveInterval,
    super.autoNextTick,
  });

  Future<void> init() async {
    if (_video.streams.isEmpty) {
      _emitError('No playable streams');
      return;
    }
    await _loadPreferences();
    if (isClosed) {
      return;
    }
    _progressTimer = Timer.periodic(
      _progressSaveInterval,
      (Timer timer) => unawaited(saveProgress()),
    );
    await _playCurrentVideo(_episodeGeneration);
  }

  Future<void> retry() async {
    if (state.sourceError != null) {
      await _resolveCurrentEpisodeAgain();
      return;
    }
    if (_video.streams.isEmpty) {
      return;
    }
    final Duration? startPosition =
        _lastKnownPosition > Duration.zero ? _lastKnownPosition : null;
    await _openStream(
      state.streamIndex,
      startPosition: startPosition,
      savedProgress: _progress.saved,
      autoPlay: true,
    );
  }

  Future<void> togglePlayPause() async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    final VideoPlayerValue value = currentEngine.value;
    if (value.isPlaying) {
      await currentEngine.pause();
      return;
    }
    if (value.isCompleted) {
      await currentEngine.seekTo(Duration.zero);
    }
    await currentEngine.play();
  }

  Future<void> seekBy(Duration offset) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    await seekTo(currentEngine.value.position + offset);
  }

  Future<void> seekTo(Duration position) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    final Duration target = _clampToDuration(position, currentEngine.value);
    _skipTracker.noteUserSeek(skipMarkers, target);
    await _seekEngine(currentEngine, target);
  }

  Future<void> skipOpening() {
    return seekBy(Duration(seconds: state.skipOpeningSeconds));
  }

  Future<void> skipMarker(PlayableSkipMarker marker) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    _skipTracker.markHandled(marker);
    await _seekEngine(
      currentEngine,
      _clampToDuration(marker.end, currentEngine.value),
    );
  }

  Future<void> setFitMode(PlayerFitMode mode) async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(fitMode: mode));
    await _persistPreference(() => _preferences.setFitMode(mode));
  }

  Future<void> cycleFitMode() {
    return setFitMode(nextFitMode(state.fitMode));
  }

  @override
  Future<void> close() async {
    _progressTimer?.cancel();
    _progressTimer = null;
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
    _openGeneration++;
    _subtitleGeneration++;
    _episodeGeneration++;
    await saveProgress();
    _finishSwitch();
    await _releaseEngine();
    return super.close();
  }
}
