import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';

typedef NativePlayerEngineFactory = NativePlayerEngine Function(
  PlayableStream stream,
);

abstract class NativePlayerEngine implements ValueListenable<VideoPlayerValue> {
  Future<void> initialize();

  Future<void> play();

  Future<void> pause();

  Future<void> seekTo(Duration position);

  Future<void> setPlaybackSpeed(double speed);

  Future<void> setClosedCaptionFile(ClosedCaptionFile? captionFile);

  bool get supportsVideoTracks;

  Future<List<VideoTrack>> getVideoTracks();

  Future<void> selectVideoTrack(VideoTrack? track);

  Future<void> dispose();

  Widget buildView();
}

VideoFormat? videoFormatHintFor(PlayableStream stream) {
  switch (resolveStreamFormat(stream)) {
    case PlayableStreamFormat.hls:
      return VideoFormat.hls;
    case PlayableStreamFormat.dash:
      return VideoFormat.dash;
    case PlayableStreamFormat.mp4:
      return VideoFormat.other;
    case PlayableStreamFormat.auto:
      return null;
  }
}

class VideoPlayerEngine implements NativePlayerEngine {
  VideoPlayerEngine(PlayableStream stream)
      : _controller = VideoPlayerController.networkUrl(
          Uri.parse(stream.url.trim()),
          httpHeaders: stream.headers,
          formatHint: videoFormatHintFor(stream),
        );

  final VideoPlayerController _controller;

  @override
  VideoPlayerValue get value => _controller.value;

  @override
  void addListener(VoidCallback listener) {
    _controller.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    _controller.removeListener(listener);
  }

  @override
  Future<void> initialize() {
    return _controller.initialize();
  }

  @override
  Future<void> play() {
    return _controller.play();
  }

  @override
  Future<void> pause() {
    return _controller.pause();
  }

  @override
  Future<void> seekTo(Duration position) {
    return _controller.seekTo(position);
  }

  @override
  Future<void> setPlaybackSpeed(double speed) {
    return _controller.setPlaybackSpeed(speed);
  }

  @override
  Future<void> setClosedCaptionFile(ClosedCaptionFile? captionFile) {
    if (captionFile == null) {
      return _controller.setClosedCaptionFile(null);
    }
    return _controller.setClosedCaptionFile(
      Future<ClosedCaptionFile>.value(captionFile),
    );
  }

  @override
  bool get supportsVideoTracks {
    try {
      return _controller.isVideoTrackSupportAvailable();
    } catch (error) {
      return false;
    }
  }

  @override
  Future<List<VideoTrack>> getVideoTracks() {
    return _controller.getVideoTracks();
  }

  @override
  Future<void> selectVideoTrack(VideoTrack? track) {
    return _controller.selectVideoTrack(track);
  }

  @override
  Future<void> dispose() {
    return _controller.dispose();
  }

  @override
  Widget buildView() {
    return VideoPlayer(_controller);
  }
}
