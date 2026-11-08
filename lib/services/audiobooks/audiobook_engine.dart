import 'dart:async';

class AudiobookEngineSnapshot {
  const AudiobookEngineSnapshot({
    this.position = Duration.zero,
    this.duration,
    this.buffered = Duration.zero,
    this.playing = false,
    this.buffering = false,
    this.completed = false,
  });

  final Duration position;
  final Duration? duration;
  final Duration buffered;
  final bool playing;
  final bool buffering;
  final bool completed;
}

class AudiobookStream {
  const AudiobookStream({
    required this.url,
    this.headers = const <String, String>{},
    this.format,
  });

  final String url;
  final Map<String, String> headers;
  final String? format;

  bool get isHls {
    return format == 'hls' || Uri.tryParse(url)?.path.endsWith('.m3u8') == true;
  }
}

abstract class AudiobookEngine {
  Stream<AudiobookEngineSnapshot> get snapshots;

  Stream<Object> get errors;

  AudiobookEngineSnapshot get current;

  Future<Duration?> load(AudiobookStream stream, {Duration initialPosition});

  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> setSpeed(double speed);

  Future<void> stop();

  Future<void> dispose();
}
