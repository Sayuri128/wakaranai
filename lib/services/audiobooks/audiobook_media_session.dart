abstract class AudiobookMediaControls {
  Future<void> play();

  Future<void> pause();

  Future<void> seek(Duration position);

  Future<void> skipForward();

  Future<void> skipBackward();

  Future<void> next();

  Future<void> previous();

  Future<void> setSpeed(double speed);

  Future<void> stop();
}

enum AudiobookMediaProcessing { idle, loading, buffering, ready, completed, error }

class AudiobookMediaSnapshot {
  const AudiobookMediaSnapshot({
    required this.id,
    required this.title,
    required this.album,
    required this.artist,
    required this.processing,
    required this.playing,
    required this.position,
    required this.buffered,
    required this.speed,
    required this.hasNext,
    required this.hasPrevious,
    this.duration,
    this.artUri,
    this.artHeaders = const <String, String>{},
  });

  final String id;
  final String title;
  final String album;
  final String artist;
  final AudiobookMediaProcessing processing;
  final bool playing;
  final Duration position;
  final Duration buffered;
  final double speed;
  final bool hasNext;
  final bool hasPrevious;
  final Duration? duration;
  final String? artUri;
  final Map<String, String> artHeaders;

  bool sameControlsAs(AudiobookMediaSnapshot other) {
    return id == other.id &&
        title == other.title &&
        processing == other.processing &&
        playing == other.playing &&
        speed == other.speed &&
        hasNext == other.hasNext &&
        hasPrevious == other.hasPrevious &&
        duration == other.duration &&
        artUri == other.artUri;
  }
}

abstract class AudiobookMediaSession {
  Future<void> attach(AudiobookMediaControls controls);

  void publish(AudiobookMediaSnapshot snapshot);

  Future<void> clear();
}

class SilentAudiobookMediaSession implements AudiobookMediaSession {
  const SilentAudiobookMediaSession();

  @override
  Future<void> attach(AudiobookMediaControls controls) async {}

  @override
  void publish(AudiobookMediaSnapshot snapshot) {}

  @override
  Future<void> clear() async {}
}
