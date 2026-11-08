part of 'native_player_cubit.dart';

abstract class _NativePlayerCore extends Cubit<NativePlayerState> {
  _NativePlayerCore({
    required PlayableVideo video,
    required EpisodePlaylist playlist,
    required NativePlayerEngineFactory engineFactory,
    required EpisodeProgressStoreFactory progressStoreFor,
    required SubtitleLoader subtitleLoader,
    EpisodeResolver? resolveEpisode,
    Set<String> watchedEpisodeUids = const <String>{},
    PlayerPreferences? preferences,
    Duration progressSaveInterval = const Duration(seconds: 10),
    Duration autoNextTick = const Duration(seconds: 1),
  })  : _video = video,
        _engineFactory = engineFactory,
        _progressStoreFor = progressStoreFor,
        _progress = EpisodeProgressKeeper(progressStoreFor(playlist.current)),
        _resolveEpisode = resolveEpisode,
        _subtitleLoader = subtitleLoader,
        _preferences = preferences ?? PlayerPreferences(),
        _progressSaveInterval = progressSaveInterval,
        _autoNextTick = autoNextTick,
        super(NativePlayerState(
          playlist: playlist,
          watchedEpisodeUids: <String>{
            ...watchedEpisodeUids,
            playlist.current.uid,
          },
        ));

  final NativePlayerEngineFactory _engineFactory;
  final EpisodeProgressStoreFactory _progressStoreFor;
  final EpisodeResolver? _resolveEpisode;
  final SubtitleLoader _subtitleLoader;
  final PlayerPreferences _preferences;
  final Duration _progressSaveInterval;
  final Duration _autoNextTick;

  PlayableVideo _video;
  final EpisodeProgressKeeper _progress;
  NativePlayerEngine? _engine;
  ParkedEpisode? _parkedEpisode;
  ClosedCaptionFile? _captionFile;
  Timer? _progressTimer;
  Timer? _autoNextTimer;
  Duration _lastKnownPosition = Duration.zero;
  int _openGeneration = 0;
  int _subtitleGeneration = 0;
  int _episodeGeneration = 0;
  bool _autoPlayNext = kDefaultAutoPlayNext;
  bool _autoSkipMarkers = kDefaultAutoSkipMarkers;
  final SkipMarkerTracker _skipTracker = SkipMarkerTracker();
  bool _completionHandled = false;
  SubtitlePreference? _subtitlePreference;
  QualityPreference _qualityPreference = const QualityPreference();

  PlayableVideo get video => _video;

  List<PlayableSkipMarker> get skipMarkers {
    final int index = state.streamIndex;
    if (index < 0 || index >= _video.streams.length) {
      return const <PlayableSkipMarker>[];
    }
    return _video.streams[index].skipMarkers;
  }

  bool get canSwitchEpisodes => _resolveEpisode != null;

  bool get hasNextEpisode => canSwitchEpisodes && state.playlist.next != null;

  bool get hasPreviousEpisode =>
      canSwitchEpisodes && state.playlist.previous != null;

  Future<void> saveProgress() {
    return _progress.save(() => _progressOf(_engine));
  }

  Future<void> playNext();

  void _finishSwitch();

  Future<bool> _trySetSpeed(NativePlayerEngine engine, double speed);

  Future<void> _applyInitialSpeed(NativePlayerEngine preparedEngine);

  Future<void> _loadRenditions(NativePlayerEngine openedEngine, int generation);

  Future<void> _restorePreferredSubtitle();

  Future<void> _applySubtitle(int? index);

  void _resetCompletion();

  void _trackCompletion(VideoPlayerValue value);

  Future<void> _seekEngine(
    NativePlayerEngine currentEngine,
    Duration target,
  ) async {
    _lastKnownPosition = target;
    await currentEngine.seekTo(target);
  }

  NativePlayerEngine? _detachEngine() {
    final NativePlayerEngine? detachedEngine = _engine;
    _engine = null;
    detachedEngine?.removeListener(_onEngineValueChanged);
    return detachedEngine;
  }

  Future<void> _playCurrentVideo(int generation) async {
    await _progress.loadSaved();
    if (_isStaleEpisode(generation)) {
      return;
    }
    _skipTracker.reset();
    final int initialStreamIndex = preferredStreamIndex(
      _video.streams,
      _qualityPreference.streamLabel,
      preferredAudio: _qualityPreference.audioLabel,
    );
    await _openStream(
      initialStreamIndex,
      savedProgress: _progress.saved,
      autoPlay: true,
    );
    if (_isStaleEpisode(generation)) {
      return;
    }
    await _restorePreferredSubtitle();
  }

  bool _isStaleEpisode(int generation) {
    return generation != _episodeGeneration || isClosed;
  }

  Future<void> _loadPreferences() async {
    try {
      final double speed = await _preferences.getPlaybackSpeed();
      final double holdSpeed = await _preferences.getHoldSpeed();
      final PlayerFitMode fitMode = await _preferences.getFitMode();
      final int skipOpeningSeconds =
          await _preferences.getSkipOpeningSeconds();
      _qualityPreference = await _preferences.getQualityPreference();
      _autoPlayNext = await _preferences.getAutoPlayNext();
      _autoSkipMarkers = await _preferences.getAutoSkipMarkers();
      _subtitlePreference = await _preferences.getSubtitle();
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
      renditions: const <PlayerRendition>[],
      selectedRenditionId: () => null,
      isPlaying: false,
      errorMessage: () => null,
      sourceError: () => null,
    ));
    final NativePlayerEngine? openedEngine = await _initializeEngine(
      index,
      generation,
    );
    if (openedEngine == null) {
      return;
    }
    await _loadRenditions(openedEngine, generation);
    if (generation != _openGeneration || isClosed) {
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
    _finishSwitch();
    emit(state.copyWith(
      status: NativePlayerStatus.ready,
      engine: () => openedEngine,
      engineGeneration: state.engineGeneration + 1,
      isPlaying: openedEngine.value.isPlaying,
      switchingEpisode: false,
    ));
  }

  Future<NativePlayerEngine?> _initializeEngine(
    int index,
    int generation,
  ) async {
    final PlayableStream stream = _video.streams[index];
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
    _autoSkipIfDue(currentEngine, value);
    _trackCompletion(value);
  }

  void _autoSkipIfDue(NativePlayerEngine currentEngine, VideoPlayerValue value) {
    if (!_autoSkipMarkers || !value.isPlaying || value.isCompleted) {
      return;
    }
    final PlayableSkipMarker? marker =
        _skipTracker.takeAutoSkip(skipMarkers, value.position);
    if (marker == null) {
      return;
    }
    emit(state.copyWith(
      lastAutoSkipType: () => marker.type,
      autoSkipCount: state.autoSkipCount + 1,
    ));
    unawaited(_seekEngine(
      currentEngine,
      _clampToDuration(marker.end, value),
    ));
  }

  EpisodeProgress? _progressOf(NativePlayerEngine? playbackEngine) {
    if (playbackEngine == null) {
      return null;
    }
    return episodeProgressOf(playbackEngine.value);
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

  Future<void> _releaseEngine() {
    return _disposeEngine(_detachEngine());
  }

  Future<void> _disposeEngine(NativePlayerEngine? disposedEngine) async {
    if (disposedEngine == null) {
      return;
    }
    try {
      await disposedEngine.dispose();
    } catch (error) {
      logger.w('Failed to dispose native player engine: $error');
    }
  }

  void _emitError(String? message) {
    if (isClosed) {
      return;
    }
    _finishSwitch();
    emit(state.copyWith(
      status: NativePlayerStatus.error,
      engine: () => null,
      isPlaying: false,
      errorMessage: () => message,
      switchingEpisode: false,
    ));
  }
}
