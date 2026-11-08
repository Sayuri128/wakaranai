import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/audiobooks/audiobook_media_session.dart';

class AudiobookAudioHandler extends BaseAudioHandler {
  AudiobookMediaControls? controls;

  @override
  Future<void> play() async {
    await controls?.play();
  }

  @override
  Future<void> pause() async {
    await controls?.pause();
  }

  @override
  Future<void> seek(Duration position) async {
    await controls?.seek(position);
  }

  @override
  Future<void> fastForward() async {
    await controls?.skipForward();
  }

  @override
  Future<void> rewind() async {
    await controls?.skipBackward();
  }

  @override
  Future<void> skipToNext() async {
    await controls?.next();
  }

  @override
  Future<void> skipToPrevious() async {
    await controls?.previous();
  }

  @override
  Future<void> setSpeed(double speed) async {
    await controls?.setSpeed(speed);
  }

  @override
  Future<void> stop() async {
    await controls?.stop();
  }

  @override
  Future<void> click([MediaButton button = MediaButton.media]) async {
    if (button == MediaButton.next) {
      await controls?.skipForward();
      return;
    }
    if (button == MediaButton.previous) {
      await controls?.skipBackward();
      return;
    }
    if (playbackState.value.playing) {
      await pause();
      return;
    }
    await play();
  }
}

class AudioServiceMediaSession implements AudiobookMediaSession {
  AudioServiceMediaSession({
    this.skipForward = const Duration(seconds: 30),
    this.skipBackward = const Duration(seconds: 15),
  });

  static const String channelId = 'io.github.sayuri128.wakaranai.audiobooks';
  static const String notificationIcon = 'drawable/ic_stat_audiobook';

  static Future<AudiobookAudioHandler>? _handler;

  final Duration skipForward;
  final Duration skipBackward;
  AudiobookMediaSnapshot? _lastPublished;

  Future<AudiobookAudioHandler> _ensureHandler() {
    return _handler ??= AudioService.init<AudiobookAudioHandler>(
      builder: AudiobookAudioHandler.new,
      config: AudioServiceConfig(
        androidNotificationChannelId: channelId,
        androidNotificationChannelName:
            S.current.audio_notification_channel_name,
        androidNotificationIcon: notificationIcon,
        androidStopForegroundOnPause: true,
        fastForwardInterval: skipForward,
        rewindInterval: skipBackward,
      ),
    );
  }

  @override
  Future<void> attach(AudiobookMediaControls controls) async {
    try {
      final AudiobookAudioHandler handler = await _ensureHandler();
      handler.controls = controls;
    } catch (error, stack) {
      _handler = null;
      logger.w('Audio service unavailable: $error');
      logger.w(stack);
    }
  }

  @override
  void publish(AudiobookMediaSnapshot snapshot) {
    final Future<AudiobookAudioHandler>? pending = _handler;
    if (pending == null) {
      return;
    }
    final AudiobookMediaSnapshot? previous = _lastPublished;
    _lastPublished = snapshot;
    unawaited(pending.then((AudiobookAudioHandler handler) {
      if (_mediaItemChanged(previous, snapshot)) {
        handler.mediaItem.add(_mediaItemOf(snapshot));
      }
      handler.playbackState.add(_playbackStateOf(snapshot));
    }).catchError((Object error) {
      logger.w('Could not publish audiobook state: $error');
    }));
  }

  @override
  Future<void> clear() async {
    final Future<AudiobookAudioHandler>? pending = _handler;
    _lastPublished = null;
    if (pending == null) {
      return;
    }
    try {
      final AudiobookAudioHandler handler = await pending;
      handler.playbackState.add(PlaybackState(
        processingState: AudioProcessingState.idle,
        playing: false,
      ));
      handler.mediaItem.add(null);
    } catch (error) {
      logger.w('Could not clear the audiobook session: $error');
    }
  }

  bool _mediaItemChanged(
    AudiobookMediaSnapshot? previous,
    AudiobookMediaSnapshot snapshot,
  ) {
    if (previous == null) {
      return true;
    }
    return previous.id != snapshot.id ||
        previous.title != snapshot.title ||
        previous.duration != snapshot.duration ||
        previous.artUri != snapshot.artUri;
  }

  MediaItem _mediaItemOf(AudiobookMediaSnapshot snapshot) {
    final String? art = snapshot.artUri;
    return MediaItem(
      id: snapshot.id,
      title: snapshot.title,
      album: snapshot.album,
      artist: snapshot.artist,
      duration: snapshot.duration,
      artUri: art == null || art.isEmpty ? null : Uri.tryParse(art),
      artHeaders: snapshot.artHeaders.isEmpty ? null : snapshot.artHeaders,
    );
  }

  PlaybackState _playbackStateOf(AudiobookMediaSnapshot snapshot) {
    final List<MediaControl> controls = <MediaControl>[
      if (snapshot.hasPrevious) MediaControl.skipToPrevious,
      MediaControl.rewind,
      if (snapshot.playing) MediaControl.pause else MediaControl.play,
      MediaControl.fastForward,
      if (snapshot.hasNext) MediaControl.skipToNext,
    ];
    final int rewindIndex = controls.indexOf(MediaControl.rewind);
    return PlaybackState(
      controls: controls,
      systemActions: const <MediaAction>{
        MediaAction.seek,
        MediaAction.fastForward,
        MediaAction.rewind,
        MediaAction.stop,
      },
      androidCompactActionIndices: <int>[
        rewindIndex,
        rewindIndex + 1,
        rewindIndex + 2,
      ],
      processingState: _processingOf(snapshot.processing),
      playing: snapshot.playing,
      updatePosition: snapshot.position,
      bufferedPosition: snapshot.buffered,
      speed: snapshot.speed,
    );
  }

  AudioProcessingState _processingOf(AudiobookMediaProcessing processing) {
    switch (processing) {
      case AudiobookMediaProcessing.idle:
        return AudioProcessingState.idle;
      case AudiobookMediaProcessing.loading:
        return AudioProcessingState.loading;
      case AudiobookMediaProcessing.buffering:
        return AudioProcessingState.buffering;
      case AudiobookMediaProcessing.ready:
        return AudioProcessingState.ready;
      case AudiobookMediaProcessing.completed:
        return AudioProcessingState.completed;
      case AudiobookMediaProcessing.error:
        return AudioProcessingState.error;
    }
  }
}
