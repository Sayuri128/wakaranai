import 'dart:io';

import 'package:flutter/services.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';

class ExternalPlaybackResult {
  const ExternalPlaybackResult({
    required this.launched,
    this.position,
    this.duration,
  });

  final bool launched;
  final Duration? position;
  final Duration? duration;
}

class ExternalPlayer {
  ExternalPlayer._();

  static const MethodChannel _channel =
      MethodChannel('wakaranai/external_player');

  static bool get isSupported => Platform.isAndroid;

  static Future<ExternalPlaybackResult> open({
    required PlayableStream stream,
    required String title,
    Duration? startAt,
  }) async {
    if (!isSupported) {
      return const ExternalPlaybackResult(launched: false);
    }
    try {
      final Map<Object?, Object?>? result =
          await _channel.invokeMapMethod<Object?, Object?>('open', <String, Object?>{
        'url': stream.url,
        'mimeType': externalMimeType(stream),
        'title': title,
        'headers': stream.headers,
        'positionMs': startAt?.inMilliseconds ?? 0,
      });
      return ExternalPlaybackResult(
        launched: result?['launched'] == true,
        position: _duration(result?['positionMs']),
        duration: _duration(result?['durationMs']),
      );
    } on PlatformException catch (error) {
      logger.w('External player failed to open: $error');
      return const ExternalPlaybackResult(launched: false);
    } on MissingPluginException catch (error) {
      logger.w('External player is unavailable: $error');
      return const ExternalPlaybackResult(launched: false);
    }
  }

  static Duration? _duration(Object? milliseconds) {
    if (milliseconds is! num || milliseconds <= 0) {
      return null;
    }
    return Duration(milliseconds: milliseconds.toInt());
  }
}

String externalMimeType(PlayableStream stream) {
  switch (stream.format) {
    case PlayableStreamFormat.hls:
      return 'application/x-mpegURL';
    case PlayableStreamFormat.mp4:
      return 'video/mp4';
    case PlayableStreamFormat.dash:
      return 'application/dash+xml';
    case PlayableStreamFormat.auto:
      return _mimeFromUrl(stream.url);
  }
}

String _mimeFromUrl(String url) {
  final String path = Uri.tryParse(url)?.path.toLowerCase() ?? '';
  if (path.endsWith('.m3u8')) {
    return 'application/x-mpegURL';
  }
  if (path.endsWith('.mpd')) {
    return 'application/dash+xml';
  }
  if (path.endsWith('.mp4')) {
    return 'video/mp4';
  }
  return 'video/*';
}

PlayableStream? pickExternalStream(List<PlayableStream> streams) {
  if (streams.isEmpty) {
    return null;
  }
  PlayableStream best = streams.first;
  int bestHeight = _qualityHeight(best);
  for (final PlayableStream stream in streams.skip(1)) {
    final int height = _qualityHeight(stream);
    if (height > bestHeight) {
      best = stream;
      bestHeight = height;
    }
  }
  return best;
}

int _qualityHeight(PlayableStream stream) {
  final RegExpMatch? match = RegExp(r'(\d{3,4})').firstMatch(stream.quality ?? '');
  if (match == null) {
    return 0;
  }
  return int.parse(match.group(1)!);
}
