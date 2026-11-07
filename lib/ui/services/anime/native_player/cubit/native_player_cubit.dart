import 'dart:async';

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
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
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

typedef EpisodeProgressStoreFactory = EpisodeProgressStore Function(
  AnimeVideo episode,
);

class NativePlayerCubit extends Cubit<NativePlayerState> {
  NativePlayerCubit({
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
        _progressStore = progressStoreFor(playlist.current),
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
  EpisodeProgressStore _progressStore;
  NativePlayerEngine? _engine;
  ClosedCaptionFile? _captionFile;
  Timer? _progressTimer;
  Timer? _autoNextTimer;
  EpisodeProgress? _savedProgress;
  EpisodeProgress? _lastPersistedProgress;
  Duration _lastKnownPosition = Duration.zero;
  int _openGeneration = 0;
  int _subtitleGeneration = 0;
  int _episodeGeneration = 0;
  int _initialStreamIndex = 0;
  bool _autoPlayNext = kDefaultAutoPlayNext;
  bool _completionHandled = false;
  SubtitlePreference? _subtitlePreference;
  String? _preferredQuality;
  Future<void> _pendingSave = Future<void>.value();

  PlayableVideo get video => _video;

  bool get canSwitchEpisodes => _resolveEpisode != null;

  bool get hasNextEpisode => canSwitchEpisodes && state.playlist.next != null;

  bool get hasPreviousEpisode =>
      canSwitchEpisodes && state.playlist.previous != null;

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
    switch (plan) {
      case WebPlaybackPlan():
        emit(state.copyWith(
          webPlayerRequest: () => OpenInWebPlayer(
            target,
            showFallbackNotice: plan.shouldNotifyUser,
          ),
        ));
      case NativePlaybackPlan():
        await _startEpisode(target, plan.video, generation);
    }
  }

  Future<void> retry() async {
    if (_video.streams.isEmpty) {
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

  Future<void> selectQualityOption(QualityOption option) async {
    switch (option.kind) {
      case QualityOptionKind.stream:
        await selectQuality(option.streamIndex);
      case QualityOptionKind.auto:
        await selectRendition(null);
      case QualityOptionKind.rendition:
        await selectRendition(option.rendition);
    }
  }

  Future<void> selectRendition(PlayerRendition? rendition) async {
    final NativePlayerEngine? currentEngine = _engine;
    if (currentEngine == null || state.status != NativePlayerStatus.ready) {
      return;
    }
    _rememberQualityLabel(
      rendition?.preferenceLabel ?? _autoRenditionPreferenceLabel(),
    );
    if (rendition?.id == state.selectedRenditionId) {
      return;
    }
    await _selectRenditionOn(currentEngine, rendition, _openGeneration);
  }

  Future<void> selectQuality(int index) async {
    if (index < 0 || index >= _video.streams.length) {
      return;
    }
    _rememberQualityLabel(_video.streams[index].quality);
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
        index != null && index >= 0 && index < _video.subtitles.length;
    final SubtitlePreference? preference = valid
        ? subtitlePreferenceFor(_video.subtitles[index])
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

  Future<void> playNextNow() async {
    cancelAutoNext();
    if (isClosed || !hasNextEpisode) {
      return;
    }
    await playNext();
  }

  Future<void> tickAutoNext() async {
    final int? secondsLeft = state.autoNextSecondsLeft;
    if (isClosed || secondsLeft == null) {
      return;
    }
    final int remaining = secondsLeft - 1;
    if (remaining <= 0) {
      await playNextNow();
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
    _episodeGeneration++;
    await saveProgress();
    await _releaseEngine();
    return super.close();
  }

  Future<int> _leaveCurrentEpisode(EpisodePlaylist target) async {
    final int generation = ++_episodeGeneration;
    _openGeneration++;
    _subtitleGeneration++;
    _resetCompletion();
    await saveProgress();
    await _releaseEngine();
    if (_isStaleEpisode(generation)) {
      return generation;
    }
    emit(state.copyWith(
      playlist: target,
      status: NativePlayerStatus.loading,
      engine: () => null,
      isPlaying: false,
      holdActive: false,
      streamIndex: 0,
      renditions: const <PlayerRendition>[],
      selectedRenditionId: () => null,
      subtitleIndex: () => null,
      subtitleLoading: false,
      subtitleFailed: false,
      errorMessage: () => null,
    ));
    return generation;
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
      return const WebPlaybackPlan(WebPlaybackReason.failed);
    }
  }

  Future<void> _startEpisode(
    EpisodePlaylist target,
    PlayableVideo playableVideo,
    int generation,
  ) async {
    _video = playableVideo;
    _progressStore = _progressStoreFor(target.current);
    _savedProgress = null;
    _lastPersistedProgress = null;
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

  Future<void> _playCurrentVideo(int generation) async {
    _savedProgress = await _loadSavedProgress();
    if (_isStaleEpisode(generation)) {
      return;
    }
    _initialStreamIndex =
        preferredStreamIndex(_video.streams, _preferredQuality);
    await _openStream(
      _initialStreamIndex,
      savedProgress: _savedProgress,
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
      _preferredQuality = await _preferences.getQuality();
      _autoPlayNext = await _preferences.getAutoPlayNext();
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

  void _rememberQualityLabel(String? label) {
    final String? quality = label?.trim();
    if (quality == null || quality.isEmpty) {
      return;
    }
    _preferredQuality = quality;
    unawaited(_persistPreference(() => _preferences.setQuality(quality)));
  }

  String _autoRenditionPreferenceLabel() {
    if (_video.streams.length > 1) {
      final String? streamLabel =
          _video.streams[state.streamIndex].quality?.trim();
      if (streamLabel != null && streamLabel.isNotEmpty) {
        return streamLabel;
      }
    }
    return kAutoQualityLabel;
  }

  Future<void> _loadRenditions(
    NativePlayerEngine openedEngine,
    int generation,
  ) async {
    final List<PlayerRendition> renditions =
        await _readRenditions(openedEngine);
    if (generation != _openGeneration || isClosed) {
      return;
    }
    emit(state.copyWith(
      renditions: renditions,
      selectedRenditionId: () => null,
    ));
    final PlayerRendition? preferred = _preferredRendition();
    if (preferred == null) {
      return;
    }
    await _selectRenditionOn(openedEngine, preferred, generation);
  }

  Future<List<PlayerRendition>> _readRenditions(
    NativePlayerEngine openedEngine,
  ) async {
    if (!openedEngine.supportsVideoTracks) {
      return const <PlayerRendition>[];
    }
    try {
      return distinctRenditions(await openedEngine.getVideoTracks());
    } catch (error, stackTrace) {
      logger.w('Failed to read video tracks: $error');
      logger.w(stackTrace);
      return const <PlayerRendition>[];
    }
  }

  PlayerRendition? _preferredRendition() {
    final String? wanted = _preferredQuality;
    if (wanted == null || state.renditions.length < 2) {
      return null;
    }
    if (isAutoQualityLabel(wanted) || _isCurrentStreamLabel(wanted)) {
      return null;
    }
    return matchRendition(state.renditions, wanted);
  }

  bool _isCurrentStreamLabel(String label) {
    final String? streamLabel =
        _video.streams[state.streamIndex].quality?.trim().toLowerCase();
    return streamLabel != null && streamLabel == label.trim().toLowerCase();
  }

  Future<void> _selectRenditionOn(
    NativePlayerEngine targetEngine,
    PlayerRendition? rendition,
    int generation,
  ) async {
    try {
      await targetEngine.selectVideoTrack(rendition?.track);
    } catch (error, stackTrace) {
      logger.w('Failed to select video track ${rendition?.id}: $error');
      logger.w(stackTrace);
      return;
    }
    if (generation != _openGeneration || isClosed) {
      return;
    }
    emit(state.copyWith(selectedRenditionId: () => rendition?.id));
  }

  Future<void> _restorePreferredSubtitle() async {
    if (isClosed || state.status != NativePlayerStatus.ready) {
      return;
    }
    final int? index =
        preferredSubtitleIndex(_video.subtitles, _subtitlePreference);
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
      renditions: const <PlayerRendition>[],
      selectedRenditionId: () => null,
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
      (Timer timer) => unawaited(tickAutoNext()),
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
          await _subtitleLoader.load(_video.subtitles[index]);
      if (generation != _subtitleGeneration || isClosed) {
        return;
      }
      _captionFile = captionFile;
      await _engine?.setClosedCaptionFile(captionFile);
      emit(state.copyWith(subtitleLoading: false));
    } catch (error, stackTrace) {
      logger.e('Failed to load subtitle ${_video.subtitles[index].url}: $error');
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
