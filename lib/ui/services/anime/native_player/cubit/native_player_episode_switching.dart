part of 'native_player_cubit.dart';

mixin _EpisodeSwitching on _NativePlayerCore {
  @override
  Future<void> playNext() async {
    final AnimeVideo? next = state.playlist.next;
    if (next == null) {
      return;
    }
    await switchTo(state.playlist.moveTo(next));
  }

  Future<void> playPrevious() async {
    final AnimeVideo? previous = state.playlist.previous;
    if (previous == null) {
      return;
    }
    await switchTo(state.playlist.moveTo(previous));
  }

  Future<void> selectEpisode(AnimeVideo episode) {
    return switchTo(state.playlist.moveTo(episode));
  }

  Future<void> selectGroup(int groupIndex) async {
    final EpisodePlaylist? target = state.playlist.switchGroup(groupIndex);
    if (target == null) {
      return;
    }
    await switchTo(target);
  }

  Future<void> switchTo(EpisodePlaylist target) async {
    final EpisodeResolver? resolve = _resolveEpisode;
    if (resolve == null || isClosed || target.isAt(state.playlist)) {
      return;
    }
    final int generation = await _leaveCurrentEpisode(target);
    if (_isStaleEpisode(generation)) {
      return;
    }
    final EpisodePlaybackPlan plan = await _resolveSafely(resolve, target);
    if (_isStaleEpisode(generation)) {
      return;
    }
    await _applyPlan(target, plan, generation);
  }

  Future<void> _applyPlan(
    EpisodePlaylist target,
    EpisodePlaybackPlan plan,
    int generation,
  ) async {
    switch (plan) {
      case WebPlaybackPlan():
        _finishSwitch();
        emit(state.copyWith(
          switchingEpisode: false,
          webPlayerRequest: () => OpenInWebPlayer(
            target,
            showFallbackNotice: plan.shouldNotifyUser,
            sourceError: plan.sourceError,
          ),
        ));
      case SourceErrorPlaybackPlan():
        _emitSourceError(plan.error);
      case NativePlaybackPlan():
        await _startEpisode(target, plan.video, generation);
    }
  }

  void _emitSourceError(SourceError error) {
    if (isClosed) {
      return;
    }
    _finishSwitch();
    emit(state.copyWith(
      status: NativePlayerStatus.error,
      engine: () => null,
      isPlaying: false,
      errorMessage: () => null,
      sourceError: () => error,
      switchingEpisode: false,
    ));
  }

  Future<void> _resolveCurrentEpisodeAgain() async {
    final EpisodeResolver? resolve = _resolveEpisode;
    if (resolve == null || isClosed) {
      return;
    }
    final EpisodePlaylist target = state.playlist;
    final int generation = ++_episodeGeneration;
    _openGeneration++;
    _subtitleGeneration++;
    emit(state.copyWith(
      status: NativePlayerStatus.loading,
      sourceError: () => null,
      errorMessage: () => null,
    ));
    final EpisodePlaybackPlan plan = await _resolveSafely(resolve, target);
    if (_isStaleEpisode(generation)) {
      return;
    }
    await _applyPlan(target, plan, generation);
  }

  Future<bool> cancelSwitch() async {
    final ParkedEpisode? parked = _parkedEpisode;
    if (parked == null || isClosed) {
      return false;
    }
    _parkedEpisode = null;
    _episodeGeneration++;
    _openGeneration++;
    _subtitleGeneration++;
    _resetCompletion();
    final NativePlayerEngine? abandonedEngine = _detachEngine();
    _restoreParkedFields(parked);
    final NativePlayerEngine? parkedEngine = parked.engine;
    if (parkedEngine == null) {
      await _reopenParkedEpisode(parked, abandonedEngine);
      return true;
    }
    _resumeParkedEngine(parked, parkedEngine);
    await _disposeEngine(abandonedEngine);
    await _restoreParkedPlayback(parked, parkedEngine);
    return true;
  }

  Future<int> _leaveCurrentEpisode(EpisodePlaylist target) async {
    final int generation = ++_episodeGeneration;
    _openGeneration++;
    _subtitleGeneration++;
    _resetCompletion();
    final ParkedEpisode? newlyParked =
        _parkedEpisode == null ? _parkCurrentEpisode() : null;
    final NativePlayerEngine? abandonedEngine = _detachEngine();
    _emitSwitchingTo(target);
    if (newlyParked != null) {
      await _settleParkedEpisode(newlyParked);
    }
    await _disposeEngine(abandonedEngine);
    return generation;
  }

  void _emitSwitchingTo(EpisodePlaylist target) {
    emit(state.copyWith(
      playlist: target,
      status: NativePlayerStatus.loading,
      engine: () => null,
      isPlaying: false,
      holdActive: false,
      activeHoldSpeed: () => null,
      streamIndex: 0,
      renditions: const <PlayerRendition>[],
      selectedRenditionId: () => null,
      subtitleIndex: () => null,
      subtitleLoading: false,
      subtitleFailed: false,
      errorMessage: () => null,
      sourceError: () => null,
      switchingEpisode: true,
      webPlayerRequest: () => null,
    ));
  }

  ParkedEpisode _parkCurrentEpisode() {
    final NativePlayerEngine? currentEngine = _engine;
    final bool parkable =
        currentEngine != null && state.status == NativePlayerStatus.ready;
    final NativePlayerEngine? parkedEngine = parkable ? currentEngine : null;
    final ParkedEpisode parked = ParkedEpisode(
      playlist: state.playlist,
      watchedEpisodeUids: state.watchedEpisodeUids,
      video: _video,
      progressStore: _progress.store,
      engine: parkedEngine,
      wasPlaying: parkedEngine?.value.isPlaying ?? false,
      position: _currentPosition(),
      progress: _progressOf(currentEngine),
      streamIndex: state.streamIndex,
      renditions: state.renditions,
      selectedRenditionId: state.selectedRenditionId,
      subtitleIndex: state.subtitleIndex,
      captionFile: _captionFile,
      savedProgress: _progress.saved,
      lastPersistedProgress: _progress.lastPersisted,
    );
    if (parkedEngine != null) {
      _detachEngine();
    }
    _parkedEpisode = parked;
    return parked;
  }

  Future<void> _settleParkedEpisode(ParkedEpisode parked) async {
    final NativePlayerEngine? parkedEngine = parked.engine;
    if (parkedEngine != null) {
      await _pauseQuietly(parkedEngine);
    }
    await _progress.saveParked(parked);
  }

  Future<void> _pauseQuietly(NativePlayerEngine parkedEngine) async {
    try {
      await parkedEngine.pause();
    } catch (error) {
      logger.w('Failed to pause the previous episode: $error');
    }
  }

  @override
  void _finishSwitch() {
    final ParkedEpisode? parked = _parkedEpisode;
    if (parked == null) {
      return;
    }
    _parkedEpisode = null;
    unawaited(_disposeEngine(parked.engine));
  }

  void _restoreParkedFields(ParkedEpisode parked) {
    _video = parked.video;
    _progress.restore(parked);
    _lastKnownPosition = parked.position;
    _captionFile = parked.captionFile;
  }

  void _resumeParkedEngine(
    ParkedEpisode parked,
    NativePlayerEngine parkedEngine,
  ) {
    _engine = parkedEngine;
    parkedEngine.addListener(_onEngineValueChanged);
    _completionHandled = parkedEngine.value.isCompleted;
    emit(state.copyWith(
      playlist: parked.playlist,
      watchedEpisodeUids: parked.watchedEpisodeUids,
      status: NativePlayerStatus.ready,
      engine: () => parkedEngine,
      engineGeneration: state.engineGeneration + 1,
      streamIndex: parked.streamIndex,
      renditions: parked.renditions,
      selectedRenditionId: () => parked.selectedRenditionId,
      subtitleIndex: () => parked.subtitleIndex,
      subtitleLoading: false,
      subtitleFailed: false,
      isPlaying: parkedEngine.value.isPlaying,
      errorMessage: () => null,
      switchingEpisode: false,
    ));
  }

  Future<void> _restoreParkedPlayback(
    ParkedEpisode parked,
    NativePlayerEngine parkedEngine,
  ) async {
    if (parkedEngine.value.playbackSpeed != state.playbackSpeed) {
      await _trySetSpeed(parkedEngine, state.playbackSpeed);
    }
    if (_engine != parkedEngine) {
      return;
    }
    if (parked.wasPlaying && !parkedEngine.value.isCompleted) {
      await parkedEngine.play();
    }
    final int? subtitleIndex = parked.subtitleIndex;
    if (subtitleIndex != null && parked.captionFile == null) {
      await _applySubtitle(subtitleIndex);
    }
  }

  Future<void> _reopenParkedEpisode(
    ParkedEpisode parked,
    NativePlayerEngine? abandonedEngine,
  ) async {
    emit(state.copyWith(
      playlist: parked.playlist,
      watchedEpisodeUids: parked.watchedEpisodeUids,
      switchingEpisode: false,
    ));
    await _disposeEngine(abandonedEngine);
    final int generation = _episodeGeneration;
    await _openStream(
      parked.streamIndex,
      startPosition: parked.position > Duration.zero ? parked.position : null,
      savedProgress: parked.savedProgress,
      autoPlay: true,
    );
    if (_isStaleEpisode(generation)) {
      return;
    }
    final int? subtitleIndex = parked.subtitleIndex;
    if (subtitleIndex != null && state.status == NativePlayerStatus.ready) {
      await _applySubtitle(subtitleIndex);
    }
  }

  Future<EpisodePlaybackPlan> _resolveSafely(
    EpisodeResolver resolve,
    EpisodePlaylist target,
  ) async {
    try {
      return await resolve(target);
    } catch (error, stackTrace) {
      logger.e('Failed to resolve ${target.current.uid}: $error');
      logger.e(stackTrace);
      final SourceError? sourceError = findSourceError(error);
      if (sourceError != null) {
        return playbackPlanForSourceError(target.current, sourceError);
      }
      return const WebPlaybackPlan(WebPlaybackReason.failed);
    }
  }

  Future<void> _startEpisode(
    EpisodePlaylist target,
    PlayableVideo playableVideo,
    int generation,
  ) async {
    _video = playableVideo;
    _progress.startEpisode(_progressStoreFor(target.current));
    _lastKnownPosition = Duration.zero;
    _captionFile = null;
    emit(state.copyWith(
      watchedEpisodeUids: <String>{
        ...state.watchedEpisodeUids,
        target.current.uid,
      },
    ));
    if (_video.streams.isEmpty) {
      _emitError('No playable streams');
      return;
    }
    await _playCurrentVideo(generation);
  }
}
