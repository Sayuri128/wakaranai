import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_track_selection.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';

part 'native_player_state.dart';

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

class NativePlayerCubit extends Cubit<NativePlayerState> {
  NativePlayerCubit({
    required this.video,
    required NativePlayerEngineFactory engineFactory,
    required EpisodeProgressStore progressStore,
    required SubtitleLoader subtitleLoader,
    PlayerPreferences? preferences,
    this.hasNextEpisode = false,
    Duration progressSaveInterval = const Duration(seconds: 10),
    Duration autoNextTick = const Duration(seconds: 1),
  })  : _engineFactory = engineFactory,
        _progressStore = progressStore,
        _subtitleLoader = subtitleLoader,
        _preferences = preferences ?? PlayerPreferences(),
        _progressSaveInterval = progressSaveInterval,
        _autoNextTick = autoNextTick,
        super(const NativePlayerState());

  final PlayableVideo video;
  final bool hasNextEpisode;
  final NativePlayerEngineFactory _engineFactory;
  final EpisodeProgressStore _progressStore;
  final SubtitleLoader _subtitleLoader;
  final PlayerPreferences _preferences;
  final Duration _progressSaveInterval;
  final Duration _autoNextTick;

  NativePlayerEngine? _engine;
  ClosedCaptionFile? _captionFile;
  Timer? _progressTimer;
  Timer? _autoNextTimer;
  EpisodeProgress? _savedProgress;
  EpisodeProgress? _lastPersistedProgress;
  Duration _lastKnownPosition = Duration.zero;
  int _openGeneration = 0;
  int _subtitleGeneration = 0;
  int _initialStreamIndex = 0;
  bool _autoPlayNext = kDefaultAutoPlayNext;
  bool _completionHandled = false;
  SubtitlePreference? _subtitlePreference;
  Future<void> _pendingSave = Future<void>.value();

  Future<void> init() async {
    if (video.streams.isEmpty) {
      _emitError('No playable streams');
      return;
    }
    await _loadPreferences();
    if (isClosed) {
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
    await _openStream(
      _initialStreamIndex,
      savedProgress: _savedProgress,
      autoPlay: true,
    );
    await _restorePreferredSubtitle();
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
    _rememberQuality(video.streams[index]);
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

  Future<void> skipOpening() {
    return seekBy(Duration(seconds: state.skipOpeningSeconds));
  }

  Future<void> setPlaybackSpeed(double speed) async {
    final double previousSpeed = state.playbackSpeed;
    final double normalizedSpeed = normalizePlaybackSpeed(speed);
    emit(state.copyWith(playbackSpeed: normalizedSpeed));
    if (!state.holdActive) {
      final bool applied = await _applyEngineSpeed(normalizedSpeed);
      if (!applied) {
        await _rejectSpeed(fallbackSpeed: previousSpeed);
        return;
      }
    }
    await _persistPreference(
      () => _preferences.setPlaybackSpeed(normalizedSpeed),
    );
  }

  Future<void> startHoldSpeed() async {
    if (state.holdActive ||
        state.status != NativePlayerStatus.ready ||
        !state.isPlaying) {
      return;
    }
    emit(state.copyWith(holdActive: true));
    final bool applied = await _applyEngineSpeed(state.holdSpeed);
    if (!applied && !isClosed) {
      emit(state.copyWith(
        holdActive: false,
        speedRejections: state.speedRejections + 1,
      ));
      await _applyEngineSpeed(state.playbackSpeed);
    }
  }

  Future<void> endHoldSpeed() async {
    if (!state.holdActive || isClosed) {
      return;
    }
    emit(state.copyWith(holdActive: false));
    await _applyEngineSpeed(state.playbackSpeed);
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

  Future<void> selectSubtitle(int? index) async {
    final bool valid =
        index != null && index >= 0 && index < video.subtitles.length;
    final SubtitlePreference? preference = valid
        ? subtitlePreferenceFor(video.subtitles[index])
        : const SubtitlePreference.off();
    if (preference != null) {
      _subtitlePreference = preference;
      unawaited(_persistPreference(() => _preferences.setSubtitle(preference)));
    }
    await _applySubtitle(valid ? index : null);
  }

  void cancelAutoNext() {
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
    if (isClosed || state.autoNextSecondsLeft == null) {
      return;
    }
    emit(state.copyWith(autoNextSecondsLeft: () => null));
  }

  void playNextNow() {
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
    if (isClosed || !hasNextEpisode) {
      return;
    }
    emit(state.copyWith(
      autoNextSecondsLeft: () => null,
      nextEpisodeRequested: true,
    ));
  }

  void tickAutoNext() {
    final int? secondsLeft = state.autoNextSecondsLeft;
    if (isClosed || secondsLeft == null) {
      return;
    }
    final int remaining = secondsLeft - 1;
    if (remaining <= 0) {
      playNextNow();
      return;
    }
    emit(state.copyWith(autoNextSecondsLeft: () => remaining));
  }

  Future<void> saveProgress() {
    _pendingSave = _pendingSave.then((_) => _persistProgress());
    return _pendingSave;
  }

  @override
  Future<void> close() async {
    _progressTimer?.cancel();
    _progressTimer = null;
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
    _openGeneration++;
    _subtitleGeneration++;
    await saveProgress();
    await _releaseEngine();
    return super.close();
  }

  Future<void> _loadPreferences() async {
    try {
      final double speed = await _preferences.getPlaybackSpeed();
      final double holdSpeed = await _preferences.getHoldSpeed();
      final PlayerFitMode fitMode = await _preferences.getFitMode();
      final int skipOpeningSeconds =
          await _preferences.getSkipOpeningSeconds();
      final String? quality = await _preferences.getQuality();
      _autoPlayNext = await _preferences.getAutoPlayNext();
      _subtitlePreference = await _preferences.getSubtitle();
      _initialStreamIndex = preferredStreamIndex(video.streams, quality);
      if (isClosed) {
        return;
      }
      emit(state.copyWith(
        playbackSpeed: speed,
        holdSpeed: holdSpeed,
        fitMode: fitMode,
        skipOpeningSeconds: skipOpeningSeconds,
      ));
    } catch (error, stackTrace) {
      logger.e('Failed to load player preferences: $error');
      logger.e(stackTrace);
    }
  }

  Future<void> _persistPreference(Future<void> Function() write) async {
    try {
      await write();
    } catch (error, stackTrace) {
      logger.e('Failed to save player preference: $error');
      logger.e(stackTrace);
    }
  }

  void _rememberQuality(PlayableStream stream) {
    final String? quality = stream.quality?.trim();
    if (quality == null || quality.isEmpty) {
      return;
    }
    unawaited(_persistPreference(() => _preferences.setQuality(quality)));
  }

  Future<void> _restorePreferredSubtitle() async {
    if (isClosed || state.status != NativePlayerStatus.ready) {
      return;
    }
    final int? index =
        preferredSubtitleIndex(video.subtitles, _subtitlePreference);
    if (index == null) {
      return;
    }
    await _applySubtitle(index);
  }

  Future<bool> _applyEngineSpeed(double speed) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return true;
    }
    return _trySetSpeed(currentEngine, speed);
  }

  Future<bool> _trySetSpeed(NativePlayerEngine engine, double speed) async {
    try {
      await engine.setPlaybackSpeed(speed);
      return true;
    } catch (error, stackTrace) {
      logger.w('Playback speed $speed was rejected: $error');
      logger.w(stackTrace);
      return false;
    }
  }

  Future<void> _rejectSpeed({required double fallbackSpeed}) async {
    if (isClosed) {
      return;
    }
    emit(state.copyWith(
      playbackSpeed: fallbackSpeed,
      speedRejections: state.speedRejections + 1,
    ));
    await _applyEngineSpeed(fallbackSpeed);
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
    _resetCompletion();
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
    await _applyInitialSpeed(preparedEngine);
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

  Future<void> _applyInitialSpeed(NativePlayerEngine preparedEngine) async {
    final double speed = state.effectiveSpeed;
    if (speed == 1.0) {
      return;
    }
    final bool applied = await _trySetSpeed(preparedEngine, speed);
    if (applied || isClosed) {
      return;
    }
    emit(state.copyWith(
      playbackSpeed: 1.0,
      holdActive: false,
      speedRejections: state.speedRejections + 1,
    ));
    await _trySetSpeed(preparedEngine, 1.0);
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
    _trackCompletion(value);
  }

  void _trackCompletion(VideoPlayerValue value) {
    if (!value.isCompleted) {
      if (_completionHandled) {
        _resetCompletion();
      }
      return;
    }
    if (_completionHandled) {
      return;
    }
    _completionHandled = true;
    unawaited(saveProgress());
    if (hasNextEpisode && _autoPlayNext) {
      _startAutoNextCountdown();
    }
  }

  void _startAutoNextCountdown() {
    _autoNextTimer?.cancel();
    if (state.holdActive) {
      emit(state.copyWith(holdActive: false));
    }
    emit(state.copyWith(
      autoNextSecondsLeft: () => kAutoNextCountdownSeconds,
    ));
    _autoNextTimer = Timer.periodic(
      _autoNextTick,
      (Timer timer) => tickAutoNext(),
    );
  }

  void _resetCompletion() {
    _completionHandled = false;
    cancelAutoNext();
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

  Future<void> _applySubtitle(int? index) async {
    final int generation = ++_subtitleGeneration;
    if (index == null) {
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
