import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';
import 'package:wakaranai/services/audiobooks/audiobook_engine.dart';

class JustAudioEngine implements AudiobookEngine {
  JustAudioEngine() : _player = AudioPlayer(useProxyForRequestHeaders: false) {
    _subscriptions.add(_player.positionStream.listen((_) => _publish()));
    _subscriptions.add(_player.playerStateStream.listen((_) => _publish()));
    _subscriptions.add(_player.durationStream.listen((_) => _publish()));
    _subscriptions.add(_player.errorStream.listen(_errors.add));
  }

  final AudioPlayer _player;
  final StreamController<AudiobookEngineSnapshot> _snapshots =
      StreamController<AudiobookEngineSnapshot>.broadcast();
  final StreamController<Object> _errors = StreamController<Object>.broadcast();
  final List<StreamSubscription<Object?>> _subscriptions =
      <StreamSubscription<Object?>>[];
  bool _sessionConfigured = false;

  @override
  Stream<AudiobookEngineSnapshot> get snapshots => _snapshots.stream;

  @override
  Stream<Object> get errors => _errors.stream;

  @override
  AudiobookEngineSnapshot get current {
    final ProcessingState processing = _player.processingState;
    return AudiobookEngineSnapshot(
      position: _player.position,
      duration: _player.duration,
      buffered: _player.bufferedPosition,
      playing: _player.playing,
      buffering: processing == ProcessingState.loading ||
          processing == ProcessingState.buffering,
      completed: processing == ProcessingState.completed,
    );
  }

  void _publish() {
    if (_snapshots.isClosed) {
      return;
    }
    _snapshots.add(current);
  }

  Future<void> _configureSession() async {
    if (_sessionConfigured) {
      return;
    }
    _sessionConfigured = true;
    final AudioSession session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
  }

  @override
  Future<Duration?> load(
    AudiobookStream stream, {
    Duration initialPosition = Duration.zero,
  }) async {
    await _configureSession();
    final Uri uri = Uri.parse(stream.url);
    final AudioSource source = stream.isHls
        ? HlsAudioSource(uri, headers: stream.headers)
        : AudioSource.uri(uri, headers: stream.headers);
    return _player.setAudioSource(source, initialPosition: initialPosition);
  }

  @override
  Future<void> play() async {
    unawaited(_player.play());
  }

  @override
  Future<void> pause() {
    return _player.pause();
  }

  @override
  Future<void> seek(Duration position) {
    return _player.seek(position);
  }

  @override
  Future<void> setSpeed(double speed) {
    return _player.setSpeed(speed);
  }

  @override
  Future<void> stop() {
    return _player.stop();
  }

  @override
  Future<void> dispose() async {
    for (final StreamSubscription<Object?> subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _player.dispose();
    await _snapshots.close();
    await _errors.close();
  }
}
