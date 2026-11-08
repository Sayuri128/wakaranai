import 'dart:async';

import 'package:capyscript/api_clients/audio_api_client.dart';
import 'package:capyscript/modules/waka_models/models/audio/audio_marker.dart';
import 'package:capyscript/modules/waka_models/models/audio/audio_track_source.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/audiobook_player_preferences.dart';
import 'package:wakaranai/services/audiobooks/audio_progress.dart';
import 'package:wakaranai/services/audiobooks/audiobook_engine.dart';
import 'package:wakaranai/services/audiobooks/audiobook_media_session.dart';
import 'package:wakaranai/services/audiobooks/audiobook_progress_store.dart';
import 'package:wakaranai/utils/serial_call_queue.dart';

part 'audiobook_player_state.dart';

typedef AudiobookEngineFactory = AudiobookEngine Function();

typedef AudiobookSourcesLoader = Future<List<AudioTrackSource>> Function(
  AudiobookSession session,
  Chapter track,
);

class AudiobookNoSourceException implements Exception {
  const AudiobookNoSourceException();
}

class AudiobookPlayerCubit extends Cubit<AudiobookPlayerState>
    implements AudiobookMediaControls {
  AudiobookPlayerCubit({
    required this.progressStore,
    required this.engineFactory,
    this.mediaSession = const SilentAudiobookMediaSession(),
    AudiobookPlayerPreferences? preferences,
    AudiobookSourcesLoader? loadSources,
    this.skipForwardInterval = const Duration(seconds: 30),
    this.skipBackwardInterval = const Duration(seconds: 15),
    this.progressSaveInterval = const Duration(seconds: 10),
    this.restartThreshold = const Duration(seconds: 5),
    DateTime Function()? clock,
  })  : preferences = preferences ?? AudiobookPlayerPreferences(),
        loadSources = loadSources ?? _loadFromClient,
        _clock = clock ?? DateTime.now,
        super(const AudiobookPlayerState());

  final AudiobookProgressStore progressStore;
  final AudiobookEngineFactory engineFactory;
  final AudiobookMediaSession mediaSession;
  final AudiobookPlayerPreferences preferences;
  final AudiobookSourcesLoader loadSources;
  final Duration skipForwardInterval;
  final Duration skipBackwardInterval;
  final Duration progressSaveInterval;
  final Duration restartThreshold;
  final DateTime Function() _clock;

  AudiobookEngine? _engine;
  StreamSubscription<AudiobookEngineSnapshot>? _snapshotSubscription;
  StreamSubscription<Object>? _errorSubscription;
  Timer? _sleepTimer;
  int _loadGeneration = 0;
  Duration? _lastSavedPosition;
  bool _completionHandled = false;
  bool _speedLoaded = false;

  static Future<List<AudioTrackSource>> _loadFromClient(
    AudiobookSession session,
    Chapter track,
  ) {
    return runSerializedOn(
      session.client,
      () => session.client.getAudioSources(uid: track.uid, data: track.data),
    );
  }

  AudiobookEngine _ensureEngine() {
    final AudiobookEngine? existing = _engine;
    if (existing != null) {
      return existing;
    }
    final AudiobookEngine engine = engineFactory();
    _engine = engine;
    _snapshotSubscription = engine.snapshots.listen(_onSnapshot);
    _errorSubscription = engine.errors.listen(_onEngineError);
    return engine;
  }

  Future<void> _loadSpeed() async {
    if (_speedLoaded) {
      return;
    }
    _speedLoaded = true;
    try {
      final double speed = await preferences.getSpeed();
      if (!isClosed) {
        emit(state.copyWith(speed: speed));
      }
    } catch (error) {
      logger.w('Could not read the audiobook speed: $error');
    }
  }

  Future<void> open(
    AudiobookSession session, {
    required int trackIndex,
    Duration? startAt,
  }) async {
    if (trackIndex < 0 || trackIndex >= session.tracks.length) {
      return;
    }
    await _loadSpeed();
    final AudiobookSession? current = state.session;
    final bool sameTrack = current != null &&
        current.sameTitleAs(session) &&
        state.trackIndex == trackIndex &&
        state.status != AudiobookStatus.error;
    if (sameTrack && startAt == null) {
      if (!state.playing && state.status == AudiobookStatus.ready) {
        await play();
      }
      return;
    }
    await _saveProgress();
    if (isClosed) {
      return;
    }
    emit(state.withSession(session));
    await mediaSession.attach(this);
    await _loadTrack(trackIndex, startAt: startAt, autoplay: true);
  }

  Future<void> _loadTrack(
    int trackIndex, {
    Duration? startAt,
    bool autoplay = true,
    List<AudioTrackSource>? knownSources,
    int sourceIndex = 0,
  }) async {
    final AudiobookSession? session = state.session;
    if (session == null || trackIndex < 0 || trackIndex >= session.tracks.length) {
      return;
    }
    final int generation = ++_loadGeneration;
    final Chapter track = session.tracks[trackIndex];
    final AudiobookEngine engine = _ensureEngine();
    _completionHandled = false;
    _lastSavedPosition = null;
    await engine.pause();
    if (isClosed) {
      return;
    }
    emit(AudiobookPlayerState(
      session: session,
      trackIndex: trackIndex,
      status: AudiobookStatus.loading,
      speed: state.speed,
      sleepTimer: state.sleepTimer,
    ));
    _publishMedia();
    try {
      final List<AudioTrackSource> sources =
          knownSources ?? await loadSources(session, track);
      if (sources.isEmpty) {
        throw const AudiobookNoSourceException();
      }
      final int chosenSource = sourceIndex.clamp(0, sources.length - 1);
      final AudioTrackSource source = sources[chosenSource];
      final ChapterActivityDomain? stored =
          await progressStore.activityOf(track.uid);
      if (_isStale(generation)) {
        return;
      }
      final Duration start = startAt ?? AudioProgress.resumePositionOf(stored);
      await engine.setSpeed(state.speed);
      final Duration? loaded = await engine.load(
        AudiobookStream(
          url: source.url,
          headers: source.headers,
          format: source.format,
        ),
        initialPosition: start,
      );
      if (_isStale(generation)) {
        return;
      }
      emit(state.copyWith(
        status: AudiobookStatus.ready,
        sources: sources,
        sourceIndex: chosenSource,
        position: start,
        duration: _durationOf(loaded, source, stored),
      ));
      _lastSavedPosition = start;
      _publishMedia();
      if (autoplay) {
        await engine.play();
      }
    } catch (error, stack) {
      logger.e('Failed to load audiobook track ${track.uid}: $error');
      logger.e(stack);
      if (_isStale(generation)) {
        return;
      }
      emit(state.copyWith(
        status: AudiobookStatus.error,
        playing: false,
        error: error,
      ));
      _publishMedia();
    }
  }

  bool _isStale(int generation) {
    return isClosed || generation != _loadGeneration;
  }

  static Duration _durationOf(
    Duration? loaded,
    AudioTrackSource source,
    ChapterActivityDomain? stored,
  ) {
    if (loaded != null && loaded > Duration.zero) {
      return loaded;
    }
    final double? declared = source.duration;
    if (declared != null) {
      return Duration(milliseconds: (declared * 1000).round());
    }
    return AudioProgress.durationOf(stored);
  }

  void _onSnapshot(AudiobookEngineSnapshot snapshot) {
    if (isClosed || state.status != AudiobookStatus.ready) {
      return;
    }
    final Duration? reported = snapshot.duration;
    final AudiobookPlayerState previous = state;
    emit(state.copyWith(
      position: snapshot.position,
      duration: reported != null && reported > Duration.zero
          ? reported
          : state.duration,
      buffered: snapshot.buffered,
      playing: snapshot.playing && !snapshot.completed,
      buffering: snapshot.buffering,
      ended: _endedAfter(snapshot),
    ));
    if (_controlsChanged(previous, state)) {
      _publishMedia();
    }
    _saveIfDue(snapshot.position);
    if (snapshot.completed && !_completionHandled) {
      _completionHandled = true;
      unawaited(_onTrackCompleted());
    }
  }

  bool _endedAfter(AudiobookEngineSnapshot snapshot) {
    if (snapshot.completed) {
      return !state.hasNext;
    }
    return state.ended;
  }

  static bool _controlsChanged(
    AudiobookPlayerState previous,
    AudiobookPlayerState next,
  ) {
    return previous.playing != next.playing ||
        previous.buffering != next.buffering ||
        previous.duration != next.duration ||
        previous.ended != next.ended;
  }

  void _onEngineError(Object error) {
    if (isClosed || state.session == null) {
      return;
    }
    logger.e('Audiobook playback failed: $error');
    emit(state.copyWith(
      status: AudiobookStatus.error,
      playing: false,
      error: error,
    ));
    _publishMedia();
  }

  void _saveIfDue(Duration position) {
    final Duration? last = _lastSavedPosition;
    if (last != null && (position - last).abs() < progressSaveInterval) {
      return;
    }
    _lastSavedPosition = position;
    unawaited(_saveProgress());
  }

  Future<void> _saveProgress({bool finished = false}) async {
    final AudiobookSession? session = state.session;
    final Chapter? track = state.track;
    if (session == null || track == null) {
      return;
    }
    if (state.status != AudiobookStatus.ready) {
      return;
    }
    try {
      await progressStore.save(
        concreteUid: session.concreteUid,
        track: track,
        position: state.position,
        duration: state.duration,
        finished: finished,
      );
    } catch (error) {
      logger.w('Could not save audiobook progress: $error');
    }
  }

  Future<void> _onTrackCompleted() async {
    await _saveProgress(finished: true);
    if (isClosed) {
      return;
    }
    if (state.sleepTimer.mode == AudiobookSleepMode.endOfTrack) {
      cancelSleepTimer();
      await _engine?.pause();
      return;
    }
    if (state.hasNext) {
      await _loadTrack(state.trackIndex + 1, startAt: Duration.zero);
      return;
    }
    await _engine?.pause();
  }

  @override
  Future<void> play() async {
    if (state.session == null) {
      return;
    }
    if (state.status == AudiobookStatus.error) {
      await retry();
      return;
    }
    if (state.status != AudiobookStatus.ready) {
      return;
    }
    final AudiobookEngine engine = _ensureEngine();
    if (state.ended || _atEnd()) {
      _completionHandled = false;
      await engine.seek(Duration.zero);
      emit(state.copyWith(position: Duration.zero, ended: false));
    }
    await engine.play();
  }

  bool _atEnd() {
    return state.duration > Duration.zero && state.position >= state.duration;
  }

  @override
  Future<void> pause() async {
    final AudiobookEngine? engine = _engine;
    if (engine == null) {
      return;
    }
    await engine.pause();
    await _saveProgress();
  }

  Future<void> togglePlay() async {
    if (state.playing) {
      await pause();
      return;
    }
    await play();
  }

  @override
  Future<void> seek(Duration position) async {
    final AudiobookEngine? engine = _engine;
    if (engine == null || state.status != AudiobookStatus.ready) {
      return;
    }
    final Duration target = _clampPosition(position);
    _completionHandled = false;
    emit(state.copyWith(position: target, ended: false));
    await engine.seek(target);
    _lastSavedPosition = target;
    await _saveProgress();
    _publishMedia();
  }

  Duration _clampPosition(Duration position) {
    if (position.isNegative) {
      return Duration.zero;
    }
    if (state.duration > Duration.zero && position > state.duration) {
      return state.duration;
    }
    return position;
  }

  @override
  Future<void> skipForward() {
    return seek(state.position + skipForwardInterval);
  }

  @override
  Future<void> skipBackward() {
    return seek(state.position - skipBackwardInterval);
  }

  @override
  Future<void> next() async {
    if (!state.hasNext) {
      return;
    }
    await _saveProgress();
    await _loadTrack(state.trackIndex + 1);
  }

  @override
  Future<void> previous() async {
    if (state.position > restartThreshold || !state.hasPrevious) {
      await seek(Duration.zero);
      return;
    }
    await _saveProgress();
    await _loadTrack(state.trackIndex - 1);
  }

  Future<void> jumpToTrack(int index) async {
    if (index == state.trackIndex && state.status == AudiobookStatus.ready) {
      await play();
      return;
    }
    await _saveProgress();
    await _loadTrack(index);
  }

  Future<void> jumpToMarker(AudioMarker marker) {
    return seek(Duration(milliseconds: (marker.start * 1000).round()));
  }

  Future<void> selectSource(int index) async {
    if (index == state.sourceIndex || index < 0 || index >= state.sources.length) {
      return;
    }
    await _saveProgress();
    await _loadTrack(
      state.trackIndex,
      startAt: state.position,
      autoplay: state.playing,
      knownSources: state.sources,
      sourceIndex: index,
    );
  }

  Future<void> retry() async {
    if (state.session == null) {
      return;
    }
    await _loadTrack(state.trackIndex, startAt: _retryPosition());
  }

  Duration? _retryPosition() {
    if (state.position > Duration.zero) {
      return state.position;
    }
    return null;
  }

  @override
  Future<void> setSpeed(double speed) async {
    final double clamped = AudiobookPlayerPreferences.clampSpeed(speed);
    emit(state.copyWith(speed: clamped));
    await _engine?.setSpeed(clamped);
    _publishMedia();
    try {
      await preferences.setSpeed(clamped);
    } catch (error) {
      logger.w('Could not save the audiobook speed: $error');
    }
  }

  void setSleepTimer(Duration length) {
    _sleepTimer?.cancel();
    _sleepTimer = Timer(length, _onSleepTimerFired);
    emit(state.copyWith(sleepTimer: AudiobookSleepTimer.until(_clock().add(length))));
  }

  void sleepAtEndOfTrack() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    emit(state.copyWith(sleepTimer: const AudiobookSleepTimer.endOfTrack()));
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimer = null;
    if (isClosed) {
      return;
    }
    emit(state.copyWith(sleepTimer: const AudiobookSleepTimer.off()));
  }

  void _onSleepTimerFired() {
    _sleepTimer = null;
    if (isClosed) {
      return;
    }
    emit(state.copyWith(sleepTimer: const AudiobookSleepTimer.off()));
    unawaited(pause());
  }

  @override
  Future<void> stop() async {
    await _saveProgress();
    _loadGeneration++;
    _sleepTimer?.cancel();
    _sleepTimer = null;
    await _engine?.stop();
    if (isClosed) {
      return;
    }
    emit(AudiobookPlayerState(speed: state.speed));
    await mediaSession.clear();
  }

  void _publishMedia() {
    final AudiobookSession? session = state.session;
    final Chapter? track = state.track;
    if (session == null || track == null) {
      return;
    }
    mediaSession.publish(AudiobookMediaSnapshot(
      id: '${session.concreteUid}/${track.uid}',
      title: track.title,
      album: session.title,
      artist: session.configInfo.name,
      processing: _processingOf(state),
      playing: state.playing,
      position: state.position,
      buffered: state.buffered,
      speed: state.speed,
      hasNext: state.hasNext,
      hasPrevious: state.hasPrevious,
      duration: state.duration > Duration.zero ? state.duration : null,
      artUri: session.cover,
      artHeaders: session.coverHeaders,
    ));
  }

  static AudiobookMediaProcessing _processingOf(AudiobookPlayerState state) {
    switch (state.status) {
      case AudiobookStatus.idle:
        return AudiobookMediaProcessing.idle;
      case AudiobookStatus.loading:
        return AudiobookMediaProcessing.loading;
      case AudiobookStatus.error:
        return AudiobookMediaProcessing.error;
      case AudiobookStatus.ready:
        return _readyProcessingOf(state);
    }
  }

  static AudiobookMediaProcessing _readyProcessingOf(
    AudiobookPlayerState state,
  ) {
    if (state.ended) {
      return AudiobookMediaProcessing.completed;
    }
    if (state.buffering) {
      return AudiobookMediaProcessing.buffering;
    }
    return AudiobookMediaProcessing.ready;
  }

  @override
  Future<void> close() async {
    await _saveProgress();
    _sleepTimer?.cancel();
    await _snapshotSubscription?.cancel();
    await _errorSubscription?.cancel();
    await _engine?.dispose();
    return super.close();
  }
}
