import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';

part 'native_player_state.dart';

const List<double> kNativePlayerSpeeds = <double>[
  0.5,
  0.75,
  1.0,
  1.25,
  1.5,
  1.75,
  2.0,
];

const Duration kNativePlayerSeekStep = Duration(seconds: 10);

class NativePlayerCubit extends Cubit<NativePlayerState> {
  NativePlayerCubit({
    required this.video,
    required NativePlayerEngineFactory engineFactory,
    required EpisodeProgressStore progressStore,
    required SubtitleLoader subtitleLoader,
    Duration progressSaveInterval = const Duration(seconds: 10),
  })  : _engineFactory = engineFactory,
        _progressStore = progressStore,
        _subtitleLoader = subtitleLoader,
        _progressSaveInterval = progressSaveInterval,
        super(const NativePlayerState());

  final PlayableVideo video;
  final NativePlayerEngineFactory _engineFactory;
  final EpisodeProgressStore _progressStore;
  final SubtitleLoader _subtitleLoader;
  final Duration _progressSaveInterval;

  NativePlayerEngine? _engine;
  ClosedCaptionFile? _captionFile;
  Timer? _progressTimer;
  EpisodeProgress? _savedProgress;
  EpisodeProgress? _lastPersistedProgress;
  Duration _lastKnownPosition = Duration.zero;
  int _openGeneration = 0;
  int _subtitleGeneration = 0;
  Future<void> _pendingSave = Future<void>.value();

  Future<void> init() async {
    if (video.streams.isEmpty) {
      _emitError('No playable streams');
      return;
    }
    _savedProgress = await _loadSavedProgress();
    if (isClosed) {
      return;
    }
    _progressTimer = Timer.periodic(
      _progressSaveInterval,
      (Timer timer) => unawaited(saveProgress()),
    );
    await _openStream(0, savedProgress: _savedProgress, autoPlay: true);
  }

  Future<void> retry() async {
    if (video.streams.isEmpty) {
      return;
    }
    final Duration? startPosition =
        _lastKnownPosition > Duration.zero ? _lastKnownPosition : null;
    await _openStream(
      state.streamIndex,
      startPosition: startPosition,
      savedProgress: _savedProgress,
      autoPlay: true,
    );
  }

  Future<void> selectQuality(int index) async {
    if (index < 0 || index >= video.streams.length) {
      return;
    }
    if (index == state.streamIndex && state.status == NativePlayerStatus.ready) {
      return;
    }
    final NativePlayerEngine? currentEngine = _engine;
    final bool wasPlaying = currentEngine == null ||
        state.status != NativePlayerStatus.ready ||
        currentEngine.value.isPlaying;
    final Duration position = _currentPosition();
    await saveProgress();
    await _openStream(
      index,
      startPosition: position > Duration.zero ? position : null,
      savedProgress: _savedProgress,
      autoPlay: wasPlaying,
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
    _lastKnownPosition = target;
    await currentEngine.seekTo(target);
  }

  Future<void> setPlaybackSpeed(double speed) async {
    emit(state.copyWith(playbackSpeed: speed));
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    await currentEngine.setPlaybackSpeed(speed);
  }

  Future<void> selectSubtitle(int? index) async {
    final int generation = ++_subtitleGeneration;
    if (index == null || index < 0 || index >= video.subtitles.length) {
      await _clearSubtitle();
      return;
    }
    emit(state.copyWith(
      subtitleIndex: () => index,
      subtitleLoading: true,
      subtitleFailed: false,
    ));
    try {
      final ClosedCaptionFile captionFile =
          await _subtitleLoader.load(video.subtitles[index]);
      if (generation != _subtitleGeneration || isClosed) {
        return;
      }
      _captionFile = captionFile;
      await _engine?.setClosedCaptionFile(captionFile);
      emit(state.copyWith(subtitleLoading: false));
    } catch (error, stackTrace) {
      logger.e('Failed to load subtitle ${video.subtitles[index].url}: $error');
      logger.e(stackTrace);
      if (generation != _subtitleGeneration || isClosed) {
        return;
      }
      _captionFile = null;
      emit(state.copyWith(
        subtitleIndex: () => null,
        subtitleLoading: false,
        subtitleFailed: true,
      ));
    }
  }

  Future<void> saveProgress() {
    _pendingSave = _pendingSave.then((_) => _persistProgress());
    return _pendingSave;
  }

  @override
  Future<void> close() async {
    _progressTimer?.cancel();
    _progressTimer = null;
    _openGeneration++;
    _subtitleGeneration++;
    await saveProgress();
    await _releaseEngine();
    return super.close();
  }

  Future<EpisodeProgress?> _loadSavedProgress() async {
    try {
      return await _progressStore.start();
    } catch (error, stackTrace) {
      logger.e('Failed to load episode progress: $error');
      logger.e(stackTrace);
      return null;
    }
  }

  Future<void> _openStream(
    int index, {
    Duration? startPosition,
    EpisodeProgress? savedProgress,
    required bool autoPlay,
  }) async {
    final int generation = ++_openGeneration;
    await _releaseEngine();
    if (generation != _openGeneration || isClosed) {
      return;
    }
    emit(state.copyWith(
      status: NativePlayerStatus.loading,
      engine: () => null,
      streamIndex: index,
      isPlaying: false,
      errorMessage: () => null,
    ));
    final NativePlayerEngine? openedEngine = await _initializeEngine(
      index,
      generation,
    );
    if (openedEngine == null) {
      return;
    }
    await _prepareEngine(
      openedEngine,
      startPosition: startPosition,
      savedProgress: savedProgress,
      autoPlay: autoPlay,
    );
    if (generation != _openGeneration || isClosed) {
      return;
    }
    emit(state.copyWith(
      status: NativePlayerStatus.ready,
      engine: () => openedEngine,
      engineGeneration: state.engineGeneration + 1,
      isPlaying: openedEngine.value.isPlaying,
    ));
  }

  Future<NativePlayerEngine?> _initializeEngine(
    int index,
    int generation,
  ) async {
    final PlayableStream stream = video.streams[index];
    try {
      final NativePlayerEngine createdEngine = _engineFactory(stream);
      _engine = createdEngine;
      await createdEngine.initialize();
      if (generation != _openGeneration || isClosed) {
        return null;
      }
      createdEngine.addListener(_onEngineValueChanged);
      return createdEngine;
    } catch (error, stackTrace) {
      logger.e('Native player failed to open ${stream.url}: $error');
      logger.e(stackTrace);
      if (generation == _openGeneration && !isClosed) {
        await _releaseEngine();
        _emitError(error.toString());
      }
      return null;
    }
  }

  Future<void> _prepareEngine(
    NativePlayerEngine preparedEngine, {
    required Duration? startPosition,
    required EpisodeProgress? savedProgress,
    required bool autoPlay,
  }) async {
    if (state.playbackSpeed != 1.0) {
      await preparedEngine.setPlaybackSpeed(state.playbackSpeed);
    }
    final Duration? resumePosition = startPosition ??
        resolveResumePosition(
          saved: savedProgress,
          duration: preparedEngine.value.duration,
        );
    if (resumePosition != null && resumePosition > Duration.zero) {
      final Duration target =
          _clampToDuration(resumePosition, preparedEngine.value);
      _lastKnownPosition = target;
      await preparedEngine.seekTo(target);
    }
    if (_captionFile != null) {
      await preparedEngine.setClosedCaptionFile(_captionFile);
    }
    if (autoPlay) {
      await preparedEngine.play();
    }
  }

  void _onEngineValueChanged() {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || isClosed) {
      return;
    }
    final VideoPlayerValue value = currentEngine.value;
    if (value.isInitialized && value.position > Duration.zero) {
      _lastKnownPosition = value.position;
    }
    if (value.hasError && state.status == NativePlayerStatus.ready) {
      logger.e('Native player playback error: ${value.errorDescription}');
      unawaited(saveProgress());
      _emitError(value.errorDescription);
      return;
    }
    if (state.status != NativePlayerStatus.ready) {
      return;
    }
    if (value.isPlaying != state.isPlaying) {
      emit(state.copyWith(isPlaying: value.isPlaying));
      if (!value.isPlaying) {
        unawaited(saveProgress());
      }
    }
  }

  Future<void> _persistProgress() async {
    final EpisodeProgress? progress = _currentProgress();
    if (progress == null || progress == _lastPersistedProgress) {
      return;
    }
    try {
      await _progressStore.save(progress);
      _lastPersistedProgress = progress;
    } catch (error, stackTrace) {
      logger.e('Failed to save episode progress: $error');
      logger.e(stackTrace);
    }
  }

  EpisodeProgress? _currentProgress() {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null) {
      return null;
    }
    final VideoPlayerValue value = currentEngine.value;
    if (!value.isInitialized || value.duration <= Duration.zero) {
      return null;
    }
    final Duration watched = value.isCompleted ? value.duration : value.position;
    if (watched <= Duration.zero) {
      return null;
    }
    return EpisodeProgress(
      watchedSeconds: watched.inSeconds,
      totalSeconds: value.duration.inSeconds,
    );
  }

  Duration _currentPosition() {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine != null && currentEngine.value.isInitialized) {
      return currentEngine.value.position;
    }
    return _lastKnownPosition;
  }

  Duration _clampToDuration(Duration position, VideoPlayerValue value) {
    if (position < Duration.zero) {
      return Duration.zero;
    }
    if (value.duration > Duration.zero && position > value.duration) {
      return value.duration;
    }
    return position;
  }

  Future<void> _clearSubtitle() async {
    _captionFile = null;
    emit(state.copyWith(
      subtitleIndex: () => null,
      subtitleLoading: false,
      subtitleFailed: false,
    ));
    await _engine?.setClosedCaptionFile(null);
  }

  Future<void> _releaseEngine() async {
    final NativePlayerEngine? releasedEngine = _engine;
    if (releasedEngine == null) {
      return;
    }
    _engine = null;
    releasedEngine.removeListener(_onEngineValueChanged);
    try {
      await releasedEngine.dispose();
    } catch (error) {
      logger.w('Failed to dispose native player engine: $error');
    }
  }

  void _emitError(String? message) {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(
      status: NativePlayerStatus.error,
      engine: () => null,
      isPlaying: false,
      errorMessage: () => message,
    ));
  }
}
