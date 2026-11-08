part of 'audiobook_player_cubit.dart';

class AudiobookSession {
  const AudiobookSession({
    required this.client,
    required this.configInfo,
    required this.concreteUid,
    required this.title,
    required this.tracks,
    this.cover,
    this.coverHeaders = const <String, String>{},
  });

  final AudioApiClient client;
  final ConfigInfo configInfo;
  final String concreteUid;
  final String title;
  final List<Chapter> tracks;
  final String? cover;
  final Map<String, String> coverHeaders;

  bool sameTitleAs(AudiobookSession other) {
    return concreteUid == other.concreteUid &&
        configInfo.uid == other.configInfo.uid;
  }

  int indexOfTrack(String uid) {
    return tracks.indexWhere((Chapter track) => track.uid == uid);
  }
}

enum AudiobookStatus { idle, loading, ready, error }

enum AudiobookSleepMode { off, timer, endOfTrack }

class AudiobookSleepTimer {
  const AudiobookSleepTimer.off()
      : mode = AudiobookSleepMode.off,
        endsAt = null;

  const AudiobookSleepTimer.endOfTrack()
      : mode = AudiobookSleepMode.endOfTrack,
        endsAt = null;

  const AudiobookSleepTimer.until(DateTime this.endsAt)
      : mode = AudiobookSleepMode.timer;

  final AudiobookSleepMode mode;
  final DateTime? endsAt;

  bool get isActive => mode != AudiobookSleepMode.off;

  Duration remaining(DateTime now) {
    final DateTime? end = endsAt;
    if (end == null) {
      return Duration.zero;
    }
    final Duration left = end.difference(now);
    if (left.isNegative) {
      return Duration.zero;
    }
    return left;
  }
}

class AudiobookPlayerState {
  const AudiobookPlayerState({
    this.session,
    this.trackIndex = 0,
    this.status = AudiobookStatus.idle,
    this.playing = false,
    this.buffering = false,
    this.ended = false,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.buffered = Duration.zero,
    this.speed = AudiobookPlayerPreferences.defaultSpeed,
    this.sources = const <AudioTrackSource>[],
    this.sourceIndex = 0,
    this.sleepTimer = const AudiobookSleepTimer.off(),
    this.error,
  });

  final AudiobookSession? session;
  final int trackIndex;
  final AudiobookStatus status;
  final bool playing;
  final bool buffering;
  final bool ended;
  final Duration position;
  final Duration duration;
  final Duration buffered;
  final double speed;
  final List<AudioTrackSource> sources;
  final int sourceIndex;
  final AudiobookSleepTimer sleepTimer;
  final Object? error;

  bool get hasSession => session != null;

  Chapter? get track {
    final AudiobookSession? current = session;
    if (current == null || trackIndex < 0 || trackIndex >= current.tracks.length) {
      return null;
    }
    return current.tracks[trackIndex];
  }

  bool get hasNext {
    final AudiobookSession? current = session;
    return current != null && trackIndex + 1 < current.tracks.length;
  }

  bool get hasPrevious => session != null && trackIndex > 0;

  AudioTrackSource? get source {
    if (sourceIndex < 0 || sourceIndex >= sources.length) {
      return null;
    }
    return sources[sourceIndex];
  }

  List<AudioMarker> get markers {
    return source?.markers ?? const <AudioMarker>[];
  }

  AudioMarker? get currentMarker {
    AudioMarker? current;
    final double seconds = position.inMilliseconds / 1000;
    for (final AudioMarker marker in markers) {
      if (marker.start > seconds) {
        break;
      }
      current = marker;
    }
    return current;
  }

  bool isPlayingTrack(String concreteUid, String trackUid) {
    final AudiobookSession? current = session;
    return current != null &&
        current.concreteUid == concreteUid &&
        track?.uid == trackUid;
  }

  AudiobookPlayerState copyWith({
    int? trackIndex,
    AudiobookStatus? status,
    bool? playing,
    bool? buffering,
    bool? ended,
    Duration? position,
    Duration? duration,
    Duration? buffered,
    double? speed,
    List<AudioTrackSource>? sources,
    int? sourceIndex,
    AudiobookSleepTimer? sleepTimer,
    Object? error,
    bool clearError = false,
  }) {
    return AudiobookPlayerState(
      session: session,
      trackIndex: trackIndex ?? this.trackIndex,
      status: status ?? this.status,
      playing: playing ?? this.playing,
      buffering: buffering ?? this.buffering,
      ended: ended ?? this.ended,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      buffered: buffered ?? this.buffered,
      speed: speed ?? this.speed,
      sources: sources ?? this.sources,
      sourceIndex: sourceIndex ?? this.sourceIndex,
      sleepTimer: sleepTimer ?? this.sleepTimer,
      error: clearError ? null : error ?? this.error,
    );
  }

  AudiobookPlayerState withSession(AudiobookSession? session) {
    return AudiobookPlayerState(
      session: session,
      speed: speed,
      sleepTimer: sleepTimer,
    );
  }
}
