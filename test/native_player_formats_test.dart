import 'package:flutter_test/flutter_test.dart';
import 'package:video_player/video_player.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';
import 'package:wakaranai/ui/services/anime/native_player/local_media.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player_engine.dart';
import 'package:wakaranai/ui/services/anime/native_player/subtitle_loader.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_seek_bar.dart';

const String _subRipSample = '1\r\n'
    '00:00:01,000 --> 00:00:02,500\r\n'
    'First line\r\n'
    '\r\n'
    '2\r\n'
    '00:00:03,000 --> 00:00:04,000\r\n'
    'Second line\r\n';

const String _webVttSample = '﻿WEBVTT\n'
    '\n'
    '00:00:01.000 --> 00:00:02.500\n'
    'First line\n'
    '\n'
    '00:00:03.000 --> 00:00:04.000\n'
    'Second line\n';

void main() {
  group('stream format', () {
    test('keeps an explicit format', () {
      const PlayableStream stream = PlayableStream(
        url: 'https://cdn.test/video.mp4',
        format: PlayableStreamFormat.hls,
      );
      expect(resolveStreamFormat(stream), PlayableStreamFormat.hls);
    });

    test('detects formats from the url path, ignoring the query', () {
      expect(
        resolveStreamFormat(
          const PlayableStream(url: 'https://cdn.test/master.M3U8?token=1'),
        ),
        PlayableStreamFormat.hls,
      );
      expect(
        resolveStreamFormat(
          const PlayableStream(url: 'https://cdn.test/manifest.mpd'),
        ),
        PlayableStreamFormat.dash,
      );
      expect(
        resolveStreamFormat(
          const PlayableStream(url: 'https://cdn.test/ep1.mp4?exp=9'),
        ),
        PlayableStreamFormat.mp4,
      );
      expect(
        resolveStreamFormat(
          const PlayableStream(url: 'https://cdn.test/play?id=42'),
        ),
        PlayableStreamFormat.auto,
      );
    });

    test('maps to video_player format hints', () {
      expect(
        videoFormatHintFor(
          const PlayableStream(url: 'https://cdn.test/a.m3u8'),
        ),
        VideoFormat.hls,
      );
      expect(
        videoFormatHintFor(
          const PlayableStream(
            url: 'https://cdn.test/a',
            format: PlayableStreamFormat.dash,
          ),
        ),
        VideoFormat.dash,
      );
      expect(
        videoFormatHintFor(const PlayableStream(url: 'https://cdn.test/a.mp4')),
        VideoFormat.other,
      );
      expect(
        videoFormatHintFor(const PlayableStream(url: 'https://cdn.test/a')),
        isNull,
      );
    });
  });

  group('local media', () {
    test('recognises file urls', () {
      expect(isLocalFileUrl('file:///data/episode/index.m3u8'), isTrue);
      expect(isLocalFileUrl(' file:///data/episode/video.mp4 '), isTrue);
      expect(isLocalFileUrl('https://cdn.test/index.m3u8'), isFalse);
      expect(isLocalFileUrl('/data/episode/video.mp4'), isFalse);
    });

    test('drops request headers for a local stream', () {
      const Map<String, String> headers = <String, String>{
        'Referer': 'https://site.test/',
      };

      expect(
        playbackHeadersFor(
          const PlayableStream(
            url: 'file:///data/episode/index.m3u8',
            headers: headers,
          ),
        ),
        isEmpty,
      );
      expect(
        playbackHeadersFor(
          const PlayableStream(url: 'https://cdn.test/a.m3u8', headers: headers),
        ),
        headers,
      );
    });

    test('keeps the hls hint for a local playlist', () {
      expect(
        videoFormatHintFor(
          const PlayableStream(
            url: 'file:///data/episode/index.m3u8',
            format: PlayableStreamFormat.hls,
          ),
        ),
        VideoFormat.hls,
      );
    });
  });

  group('subtitle format', () {
    test('keeps an explicit format', () {
      const PlayableSubtitle subtitle = PlayableSubtitle(
        url: 'https://cdn.test/subs.vtt',
        format: PlayableSubtitleFormat.srt,
      );
      expect(resolveSubtitleFormat(subtitle), PlayableSubtitleFormat.srt);
    });

    test('detects formats from the url extension', () {
      expect(
        resolveSubtitleFormat(
          const PlayableSubtitle(url: 'https://cdn.test/en.vtt?sig=1'),
        ),
        PlayableSubtitleFormat.vtt,
      );
      expect(
        resolveSubtitleFormat(
          const PlayableSubtitle(url: 'https://cdn.test/en.SRT'),
        ),
        PlayableSubtitleFormat.srt,
      );
      expect(
        resolveSubtitleFormat(
          const PlayableSubtitle(url: 'https://cdn.test/subtitle?id=1'),
        ),
        PlayableSubtitleFormat.auto,
      );
    });

    test('sniffs the content when the url has no extension', () {
      const PlayableSubtitle subtitle =
          PlayableSubtitle(url: 'https://cdn.test/subtitle?id=1');
      expect(
        resolveSubtitleFormat(subtitle, content: _webVttSample),
        PlayableSubtitleFormat.vtt,
      );
      expect(
        resolveSubtitleFormat(subtitle, content: _subRipSample),
        PlayableSubtitleFormat.srt,
      );
      expect(
        resolveSubtitleFormat(subtitle, content: 'not a subtitle'),
        PlayableSubtitleFormat.auto,
      );
    });

    test('parses SubRip with windows line endings', () {
      final ClosedCaptionFile file = parseClosedCaptionFile(
        const PlayableSubtitle(url: 'https://cdn.test/subtitle'),
        _subRipSample,
      );
      expect(file, isA<SubRipCaptionFile>());
      expect(file.captions, hasLength(2));
      expect(file.captions.first.text, 'First line');
      expect(file.captions.first.end, const Duration(milliseconds: 2500));
    });

    test('parses WebVTT with a byte order mark', () {
      final ClosedCaptionFile file = parseClosedCaptionFile(
        const PlayableSubtitle(url: 'https://cdn.test/subtitle'),
        _webVttSample,
      );
      expect(file, isA<WebVTTCaptionFile>());
      expect(file.captions, hasLength(2));
      expect(file.captions.last.text, 'Second line');
    });
  });

  group('resume position', () {
    test('nothing saved starts from the beginning', () {
      expect(
        resolveResumePosition(saved: null, duration: const Duration(minutes: 24)),
        isNull,
      );
    });

    test('a few seconds in starts from the beginning', () {
      expect(
        resolveResumePosition(
          saved: const EpisodeProgress(watchedSeconds: 3, totalSeconds: 1440),
          duration: const Duration(minutes: 24),
        ),
        isNull,
      );
    });

    test('resumes a partly watched episode', () {
      expect(
        resolveResumePosition(
          saved: const EpisodeProgress(watchedSeconds: 600, totalSeconds: 1440),
          duration: const Duration(minutes: 24),
        ),
        const Duration(seconds: 600),
      );
    });

    test('a finished episode starts over', () {
      expect(
        resolveResumePosition(
          saved: const EpisodeProgress(watchedSeconds: 1380, totalSeconds: 1440),
          duration: const Duration(minutes: 24),
        ),
        isNull,
      );
      expect(
        resolveResumePosition(
          saved: const EpisodeProgress(watchedSeconds: 1500, totalSeconds: 1500),
          duration: const Duration(minutes: 24),
        ),
        isNull,
      );
    });

    test('falls back to the saved total when the duration is unknown', () {
      expect(
        resolveResumePosition(
          saved: const EpisodeProgress(watchedSeconds: 1400, totalSeconds: 1440),
          duration: Duration.zero,
        ),
        isNull,
      );
      expect(
        resolveResumePosition(
          saved: const EpisodeProgress(watchedSeconds: 600),
          duration: Duration.zero,
        ),
        const Duration(seconds: 600),
      );
    });
  });

  test('formats playback durations', () {
    expect(formatPlaybackDuration(Duration.zero), '00:00');
    expect(formatPlaybackDuration(const Duration(minutes: 3, seconds: 7)), '03:07');
    expect(
      formatPlaybackDuration(const Duration(hours: 1, minutes: 2, seconds: 3)),
      '1:02:03',
    );
  });
}
