import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_downloader.dart';

class FakeRequest {
  const FakeRequest(this.url, this.headers);

  final String url;
  final Map<String, String> headers;

  String? header(String name) {
    for (final MapEntry<String, String> entry in headers.entries) {
      if (entry.key.toLowerCase() == name.toLowerCase()) {
        return entry.value;
      }
    }
    return null;
  }
}

class FakeReply {
  const FakeReply(
    this.status, {
    this.body = const <int>[],
    this.headers = const <String, String>{},
  });

  factory FakeReply.text(String text) =>
      FakeReply(200, body: utf8.encode(text));

  final int status;
  final List<int> body;
  final Map<String, String> headers;
}

typedef FakeResponder = FakeReply Function(FakeRequest request);

class FakeEpisodeHttp implements EpisodeHttp {
  final Map<String, FakeResponder> routes = <String, FakeResponder>{};
  final List<FakeRequest> requests = <FakeRequest>[];

  void serve(String url, FakeResponder responder) {
    routes[url] = responder;
  }

  void serveText(String url, String text) {
    serve(url, (_) => FakeReply.text(text));
  }

  void serveBytes(String url, List<int> bytes) {
    serve(url, (FakeRequest request) => rangeAware(request, bytes));
  }

  List<String> get urls =>
      requests.map((FakeRequest request) => request.url).toList();

  @override
  Future<EpisodeHttpResponse> get(
    String url, {
    required Map<String, String> headers,
    required CancelToken cancelToken,
  }) async {
    final FakeRequest request = FakeRequest(
      url,
      Map<String, String>.of(headers),
    );
    requests.add(request);
    await Future<void>.delayed(Duration.zero);
    final FakeResponder? responder = routes[url];
    final FakeReply reply = responder == null
        ? const FakeReply(404)
        : responder(request);
    return EpisodeHttpResponse(
      statusCode: reply.status,
      headers: <String, List<String>>{
        for (final MapEntry<String, String> entry in reply.headers.entries)
          entry.key: <String>[entry.value],
        'content-length': <String>['${reply.body.length}'],
      },
      body: Stream<List<int>>.fromIterable(chunked(reply.body, 5)),
    );
  }
}

Iterable<List<int>> chunked(List<int> bytes, int size) sync* {
  for (int start = 0; start < bytes.length; start += size) {
    final int end = start + size > bytes.length ? bytes.length : start + size;
    yield bytes.sublist(start, end);
  }
}

FakeReply rangeAware(FakeRequest request, List<int> bytes) {
  final String? range = request.header('range');
  if (range == null) {
    return FakeReply(200, body: bytes);
  }
  final RegExpMatch match = RegExp(r'bytes=(\d+)-(\d*)').firstMatch(range)!;
  final int start = int.parse(match.group(1)!);
  final String endText = match.group(2)!;
  final int end = endText.isEmpty ? bytes.length - 1 : int.parse(endText);
  if (start >= bytes.length) {
    return FakeReply(
      416,
      headers: <String, String>{'Content-Range': 'bytes */${bytes.length}'},
    );
  }
  return FakeReply(
    206,
    body: bytes.sublist(start, end + 1),
    headers: <String, String>{
      'Content-Range': 'bytes $start-$end/${bytes.length}',
    },
  );
}

class InstantThrottle extends DownloadThrottle {
  final List<String?> retryAfterHeaders = <String?>[];
  int rateLimitedCount = 0;

  @override
  Duration pageDelay(String extensionUid) => Duration.zero;

  @override
  void rateLimited(String extensionUid) {
    rateLimitedCount++;
    super.rateLimited(extensionUid);
  }

  @override
  Duration retryWait(int rateLimitedAttempt, {String? retryAfterHeader}) {
    retryAfterHeaders.add(retryAfterHeader);
    return Duration.zero;
  }
}

List<int> bytesOf(String label, int length) {
  return List<int>.generate(length, (int i) => (label.hashCode + i) & 0xff);
}

const String masterUrl = 'https://origin.example/hls/master.m3u8?sig=1';
const String cdn = 'https://cdn.example/v720';
const String keyUrl = 'https://cdn.example/keys/k1?sig=1';
const String subtitleUrl = 'https://subs.example/ep1.vtt';
const String subtitleBody = 'WEBVTT\n\n00:00.000 --> 00:01.000\nhello\n';

const String masterPlaylist = '''
#EXTM3U
#EXT-X-STREAM-INF:BANDWIDTH=800000,RESOLUTION=640x360
https://cdn.example/v360/index.m3u8
#EXT-X-STREAM-INF:BANDWIDTH=2500000,RESOLUTION=1280x720,CODECS="avc1.4d401f,mp4a.40.2"
https://cdn.example/v720/index.m3u8?token=t1
''';

String mediaPlaylist({
  String token = 't1',
  List<String> durations = const <String>['4.0', '4.0', '2.5'],
}) {
  final StringBuffer buffer = StringBuffer()
    ..writeln('#EXTM3U')
    ..writeln('#EXT-X-TARGETDURATION:4')
    ..writeln('#EXT-X-MEDIA-SEQUENCE:0')
    ..writeln(
      '#EXT-X-KEY:METHOD=AES-128,URI="/keys/k1?sig=1",IV=0x00000000000000000000000000000001',
    );
  for (int index = 0; index < durations.length; index++) {
    buffer
      ..writeln('#EXTINF:${durations[index]},')
      ..writeln('seg$index.ts?token=$token');
  }
  buffer.writeln('#EXT-X-ENDLIST');
  return buffer.toString();
}

String segmentUrl(int index, {String token = 't1'}) {
  return '$cdn/seg$index.ts?token=$token';
}

FakeEpisodeHttp hlsSite({String token = 't1'}) {
  final FakeEpisodeHttp http = FakeEpisodeHttp();
  http.serveText(masterUrl, masterPlaylist.replaceAll('t1', token));
  http.serveText('$cdn/index.m3u8?token=$token', mediaPlaylist(token: token));
  http.serveBytes(keyUrl, bytesOf('key', 16));
  for (int index = 0; index < 3; index++) {
    http.serveBytes(segmentUrl(index, token: token), bytesOf('seg$index', 40));
  }
  http.serveText(subtitleUrl, subtitleBody);
  return http;
}

const Map<String, String> sourceHeaders = <String, String>{
  'Referer': 'https://anime.example/',
  'accept-language': 'uk-UA',
};

PlayableVideo hlsVideo({List<PlayableSubtitle>? subtitles}) {
  return PlayableVideo(
    streams: const <PlayableStream>[
      PlayableStream(
        url: masterUrl,
        quality: 'HLS',
        format: PlayableStreamFormat.hls,
        headers: sourceHeaders,
      ),
    ],
    subtitles:
        subtitles ??
        const <PlayableSubtitle>[
          PlayableSubtitle(url: subtitleUrl, label: 'English', language: 'en'),
        ],
  );
}

const QualityPreference prefer720 = QualityPreference(
  streamLabel: 'HLS',
  renditionLabel: '720p',
);

void main() {
  late Directory dir;
  late InstantThrottle throttle;

  setUp(() async {
    dir = await Directory.systemTemp.createTemp('episode_download_test');
    throttle = InstantThrottle();
  });

  tearDown(() async {
    if (await dir.exists()) {
      await dir.delete(recursive: true);
    }
  });

  EpisodeDownloader downloaderFor(FakeEpisodeHttp http) {
    return EpisodeDownloader(
      http: http,
      throttle: throttle,
      failureBackoff: Duration.zero,
    );
  }

  Future<EpisodeDownloadManifest> run(
    FakeEpisodeHttp http, {
    PlayableVideo? video,
    QualityPreference quality = prefer720,
    CancelToken? cancelToken,
    void Function(EpisodeDownloadProgress progress)? onProgress,
  }) {
    return downloaderFor(http).download(
      video: video ?? hlsVideo(),
      quality: quality,
      dir: dir,
      throttleKey: 'ext',
      cancelToken: cancelToken ?? CancelToken(),
      onProgress: onProgress,
    );
  }

  File fileIn(String relative) => File(p.join(dir.path, relative));

  List<String> leftoverPartials() {
    return dir
        .listSync(recursive: true)
        .whereType<File>()
        .map((File file) => file.path)
        .where((String path) => path.endsWith('.part') || path.endsWith('.tmp'))
        .toList();
  }

  test(
    'downloads an encrypted hls episode into a playable local layout',
    () async {
      final FakeEpisodeHttp http = hlsSite();
      final List<EpisodeDownloadProgress> progress =
          <EpisodeDownloadProgress>[];

      final EpisodeDownloadManifest manifest = await run(
        http,
        onProgress: progress.add,
      );

      expect(manifest.format, EpisodeMediaFormat.hls);
      expect(manifest.file, 'index.m3u8');
      expect(manifest.quality, '720p');
      expect(manifest.subtitles.single.file, 'subs/0.vtt');
      expect(manifest.subtitles.single.format, PlayableSubtitleFormat.vtt);
      expect(manifest.subtitles.single.language, 'en');

      expect(http.urls, isNot(contains('https://cdn.example/v360/index.m3u8')));
      final Iterable<FakeRequest> streamRequests = http.requests.where(
        (FakeRequest r) => r.url != subtitleUrl,
      );
      expect(streamRequests, hasLength(6));
      for (final FakeRequest request in streamRequests) {
        expect(
          request.header('referer'),
          'https://anime.example/',
          reason: request.url,
        );
        expect(request.header('accept'), '*/*', reason: request.url);
        expect(request.header('accept-language'), 'uk-UA', reason: request.url);
        expect(
          request.headers.keys.where(
            (String key) => key.toLowerCase() == 'accept-language',
          ),
          hasLength(1),
        );
      }
      final FakeRequest subtitleRequest = http.requests.firstWhere(
        (FakeRequest r) => r.url == subtitleUrl,
      );
      expect(subtitleRequest.header('accept-language'), 'en-US,en;q=0.9');

      expect(await fileIn('keys/0.key').readAsBytes(), bytesOf('key', 16));
      for (int index = 0; index < 3; index++) {
        expect(
          await fileIn('v/00000${index + 1}.ts').readAsBytes(),
          bytesOf('seg$index', 40),
        );
      }
      expect(await fileIn('subs/0.vtt').readAsString(), subtitleBody);

      final String playlist = await fileIn('index.m3u8').readAsString();
      expect(
        playlist,
        contains('URI="keys/0.key",IV=0x00000000000000000000000000000001'),
      );
      expect(playlist, contains('\nv/000001.ts\n'));
      expect(playlist, contains('\nv/000003.ts\n'));
      expect(playlist, contains('#EXT-X-PLAYLIST-TYPE:VOD'));
      expect(playlist, contains('#EXT-X-ENDLIST'));
      expect(playlist, isNot(contains('http')));
      expect(fileIn('.plan.json').existsSync(), isTrue);
      expect(leftoverPartials(), isEmpty);

      final EpisodeDownloadProgress last = progress.last;
      expect(last.completedSegments, 3);
      expect(last.totalSegments, 3);
      expect(last.downloadedBytes, 120);
    },
  );

  test('resumes with fresh signed urls and skips finished segments', () async {
    await run(hlsSite());
    await fileIn('v/000002.ts').delete();
    await fileIn('index.m3u8').delete();

    final FakeEpisodeHttp second = hlsSite(token: 't2');
    final EpisodeDownloadManifest manifest = await run(second);

    expect(manifest.file, 'index.m3u8');
    expect(second.urls, contains(segmentUrl(1, token: 't2')));
    expect(second.urls, isNot(contains(segmentUrl(0, token: 't2'))));
    expect(second.urls, isNot(contains(segmentUrl(2, token: 't2'))));
    expect(second.urls, isNot(contains(keyUrl)));
    expect(second.urls, isNot(contains(subtitleUrl)));
    expect(fileIn('index.m3u8').existsSync(), isTrue);
    expect(await fileIn('v/000002.ts').readAsBytes(), bytesOf('seg1', 40));
  });

  test('wipes partial media when the plan signature changes', () async {
    await run(hlsSite());
    await fileIn('v/000099.ts').writeAsBytes(<int>[1, 2, 3]);

    final FakeEpisodeHttp changed = hlsSite();
    changed.serveText(
      '$cdn/index.m3u8?token=t1',
      mediaPlaylist(durations: const <String>['5.0', '5.0', '1.0']),
    );
    await run(changed);

    expect(fileIn('v/000099.ts').existsSync(), isFalse);
    for (int index = 0; index < 3; index++) {
      expect(changed.urls, contains(segmentUrl(index)));
    }
    expect(changed.urls, contains(keyUrl));
  });

  test(
    'throws EpisodeSourceExpired on 403 and resumes on the next call',
    () async {
      final FakeEpisodeHttp expired = hlsSite();
      expired.serve(segmentUrl(2), (_) => const FakeReply(403));

      await expectLater(run(expired), throwsA(isA<EpisodeSourceExpired>()));
      expect(
        expired.urls.where((String url) => url == segmentUrl(2)),
        hasLength(1),
      );
      expect(fileIn('index.m3u8').existsSync(), isFalse);

      final FakeEpisodeHttp refreshed = hlsSite(token: 't9');
      await run(refreshed);

      expect(refreshed.urls, contains(segmentUrl(2, token: 't9')));
      expect(refreshed.urls, isNot(contains(segmentUrl(0, token: 't9'))));
      expect(fileIn('index.m3u8').existsSync(), isTrue);
    },
  );

  test('retries a rate limited request honoring Retry-After', () async {
    final FakeEpisodeHttp http = hlsSite();
    int calls = 0;
    http.serve(segmentUrl(1), (FakeRequest request) {
      calls++;
      if (calls == 1) {
        return const FakeReply(
          429,
          headers: <String, String>{'Retry-After': '7'},
        );
      }
      return FakeReply(200, body: bytesOf('seg1', 40));
    });

    await run(http);

    expect(calls, 2);
    expect(throttle.rateLimitedCount, 1);
    expect(throttle.retryAfterHeaders, <String?>['7']);
    expect(await fileIn('v/000002.ts').readAsBytes(), bytesOf('seg1', 40));
  });

  test('gives up after repeated rate limits', () async {
    final FakeEpisodeHttp http = hlsSite();
    http.serve(segmentUrl(0), (_) => const FakeReply(503));

    await expectLater(run(http), throwsA(isA<EpisodeDownloadFailure>()));
    expect(http.urls.where((String url) => url == segmentUrl(0)), hasLength(6));
  });

  test('downloads a separate audio rendition behind a local master', () async {
    final FakeEpisodeHttp http = FakeEpisodeHttp();
    http.serveText(masterUrl, '''
#EXTM3U
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aac",NAME="Japanese",LANGUAGE="ja",DEFAULT=YES,URI="audio/ja.m3u8"
#EXT-X-MEDIA:TYPE=AUDIO,GROUP-ID="aac",NAME="English",LANGUAGE="en",URI="audio/en.m3u8"
#EXT-X-STREAM-INF:BANDWIDTH=2000000,RESOLUTION=1920x1080,CODECS="avc1.640028,mp4a.40.2",AUDIO="aac"
video/1080.m3u8
''');
    http.serveText(
      'https://origin.example/hls/video/1080.m3u8',
      '#EXTM3U\n#EXT-X-TARGETDURATION:4\n#EXTINF:4,\nv0.ts\n#EXTINF:4,\nv1.ts\n#EXT-X-ENDLIST\n',
    );
    http.serveText(
      'https://origin.example/hls/audio/ja.m3u8',
      '#EXTM3U\n#EXT-X-TARGETDURATION:4\n#EXTINF:4,\na0.aac\n#EXTINF:4,\na1.aac\n#EXT-X-ENDLIST\n',
    );
    for (final String name in <String>[
      'video/v0.ts',
      'video/v1.ts',
      'audio/a0.aac',
      'audio/a1.aac',
    ]) {
      http.serveBytes('https://origin.example/hls/$name', bytesOf(name, 20));
    }

    final EpisodeDownloadManifest manifest = await run(
      http,
      video: hlsVideo(subtitles: const <PlayableSubtitle>[]),
      quality: const QualityPreference(),
    );

    expect(manifest.quality, '1080p');
    expect(
      http.urls,
      isNot(contains('https://origin.example/hls/audio/en.m3u8')),
    );
    final String index = await fileIn('index.m3u8').readAsString();
    expect(index, contains('URI="audio.m3u8"'));
    expect(index, contains('RESOLUTION=1920x1080'));
    expect(index, contains('CODECS="avc1.640028,mp4a.40.2"'));
    expect(index, contains('\nvideo.m3u8\n'));
    expect(await fileIn('video.m3u8').readAsString(), contains('v/000002.ts'));
    expect(await fileIn('audio.m3u8').readAsString(), contains('a/000002.aac'));
    expect(
      await fileIn('a/000001.aac').readAsBytes(),
      bytesOf('audio/a0.aac', 20),
    );
  });

  test('fetches byte-range segments as separate files', () async {
    final List<int> media = bytesOf('range', 100);
    final FakeEpisodeHttp http = FakeEpisodeHttp();
    http.serveText('https://origin.example/r/index.m3u8', '''
#EXTM3U
#EXT-X-TARGETDURATION:4
#EXT-X-MAP:URI="main.mp4",BYTERANGE="20@0"
#EXTINF:4,
#EXT-X-BYTERANGE:30@20
main.mp4
#EXTINF:4,
#EXT-X-BYTERANGE:50
main.mp4
''');
    http.serve(
      'https://origin.example/r/main.mp4',
      (FakeRequest request) => FakeReply(200, body: media),
    );

    await run(
      http,
      video: const PlayableVideo(
        streams: <PlayableStream>[
          PlayableStream(url: 'https://origin.example/r/index.m3u8'),
        ],
      ),
    );

    expect(await fileIn('v/init0.mp4').readAsBytes(), media.sublist(0, 20));
    expect(await fileIn('v/000001.mp4').readAsBytes(), media.sublist(20, 50));
    expect(await fileIn('v/000002.mp4').readAsBytes(), media.sublist(50, 100));
    final List<String?> ranges = http.requests
        .map((FakeRequest request) => request.header('range'))
        .whereType<String>()
        .toList();
    expect(
      ranges,
      containsAll(<String>['bytes=0-19', 'bytes=20-49', 'bytes=50-99']),
    );
    expect(
      await fileIn('index.m3u8').readAsString(),
      isNot(contains('BYTERANGE')),
    );
  });

  group('mp4', () {
    const String mp4Url = 'https://mp4upload.example/files/ep1.mp4';
    final List<int> content = bytesOf('mp4', 1000);
    const PlayableVideo mp4Video = PlayableVideo(
      streams: <PlayableStream>[
        PlayableStream(
          url: mp4Url,
          quality: '720p',
          headers: <String, String>{'Referer': 'https://mp4upload.example/'},
        ),
      ],
    );

    Future<void> seedPartial(int length) async {
      await run(
        FakeEpisodeHttp()..serveBytes(mp4Url, content),
        video: mp4Video,
      );
      await fileIn('video.mp4').rename(p.join(dir.path, 'video.mp4.part'));
      final RandomAccessFile handle = await fileIn(
        'video.mp4.part',
      ).open(mode: FileMode.append);
      await handle.truncate(length);
      await handle.close();
    }

    test('downloads progressively with the source headers', () async {
      final FakeEpisodeHttp http = FakeEpisodeHttp()
        ..serveBytes(mp4Url, content);
      final List<EpisodeDownloadProgress> progress =
          <EpisodeDownloadProgress>[];

      final EpisodeDownloadManifest manifest = await run(
        http,
        video: mp4Video,
        onProgress: progress.add,
      );

      expect(manifest.format, EpisodeMediaFormat.mp4);
      expect(manifest.file, 'video.mp4');
      expect(manifest.quality, '720p');
      expect(await fileIn('video.mp4').readAsBytes(), content);
      expect(
        http.requests.single.header('referer'),
        'https://mp4upload.example/',
      );
      expect(http.requests.single.header('range'), 'bytes=0-');
      expect(progress.last.downloadedBytes, 1000);
      expect(progress.last.totalBytes, 1000);
      expect(progress.last.totalSegments, 0);
    });

    test('appends to a partial file on 206', () async {
      await seedPartial(400);
      final FakeEpisodeHttp http = FakeEpisodeHttp()
        ..serveBytes(mp4Url, content);

      await run(http, video: mp4Video);

      expect(http.requests.single.header('range'), 'bytes=400-');
      expect(await fileIn('video.mp4').readAsBytes(), content);
      expect(fileIn('video.mp4.part').existsSync(), isFalse);
    });

    test('restarts from zero when the server ignores the range', () async {
      await seedPartial(400);
      final FakeEpisodeHttp http = FakeEpisodeHttp()
        ..serve(mp4Url, (_) => FakeReply(200, body: content));

      await run(http, video: mp4Video);

      expect(await fileIn('video.mp4').readAsBytes(), content);
    });

    test('treats 416 on a complete partial file as done', () async {
      await seedPartial(1000);
      final FakeEpisodeHttp http = FakeEpisodeHttp()
        ..serveBytes(mp4Url, content);

      await run(http, video: mp4Video);

      expect(http.requests.single.header('range'), 'bytes=1000-');
      expect(await fileIn('video.mp4').readAsBytes(), content);
    });

    test('resumes after the connection drops mid-file', () async {
      final FakeEpisodeHttp http = FakeEpisodeHttp();
      int calls = 0;
      http.serve(mp4Url, (FakeRequest request) {
        calls++;
        final FakeReply full = rangeAware(request, content);
        if (calls == 1) {
          return FakeReply(
            206,
            body: full.body.sublist(0, 300),
            headers: full.headers,
          );
        }
        return full;
      });

      await run(http, video: mp4Video);

      expect(http.requests.map((FakeRequest r) => r.header('range')), <String>[
        'bytes=0-',
        'bytes=300-',
      ]);
      expect(await fileIn('video.mp4').readAsBytes(), content);
    });

    test('probes auto streams to tell mp4 from hls', () async {
      const String autoUrl = 'https://host.example/stream?id=1';
      final FakeEpisodeHttp http = FakeEpisodeHttp()
        ..serveBytes(autoUrl, content);

      final EpisodeDownloadManifest manifest = await run(
        http,
        video: const PlayableVideo(
          streams: <PlayableStream>[PlayableStream(url: autoUrl)],
        ),
      );

      expect(manifest.format, EpisodeMediaFormat.mp4);
      expect(await fileIn('video.mp4').readAsBytes(), content);
    });
  });

  test('probes an auto stream that turns out to be hls', () async {
    const String autoUrl = 'https://host.example/play?id=1';
    final FakeEpisodeHttp http = FakeEpisodeHttp();
    http.serveText(
      autoUrl,
      '#EXTM3U\n#EXT-X-TARGETDURATION:4\n#EXTINF:4,\nchunk0\n#EXT-X-ENDLIST\n',
    );
    http.serveBytes('https://host.example/chunk0', bytesOf('chunk', 30));

    final EpisodeDownloadManifest manifest = await run(
      http,
      video: const PlayableVideo(
        streams: <PlayableStream>[PlayableStream(url: autoUrl, quality: 'SD')],
      ),
    );

    expect(manifest.format, EpisodeMediaFormat.hls);
    expect(manifest.quality, 'SD');
    expect(http.urls.where((String url) => url == autoUrl), hasLength(1));
    expect(await fileIn('v/000001.ts').readAsBytes(), bytesOf('chunk', 30));
  });

  test(
    'keeps going when a subtitle fails and detects srt by content',
    () async {
      final FakeEpisodeHttp http = hlsSite();
      const String srt = '1\n00:00:01,000 --> 00:00:02,000\nhi\n';
      http.serveText('https://subs.example/track?lang=uk', srt);

      final EpisodeDownloadManifest manifest = await run(
        http,
        video: hlsVideo(
          subtitles: const <PlayableSubtitle>[
            PlayableSubtitle(
              url: 'https://subs.example/missing.vtt',
              label: 'Gone',
            ),
            PlayableSubtitle(
              url: 'https://subs.example/track?lang=uk',
              label: 'Ukrainian',
              headers: <String, String>{'X-Token': 'abc'},
            ),
          ],
        ),
      );

      expect(manifest.subtitles, hasLength(1));
      expect(manifest.subtitles.single.file, 'subs/1.srt');
      expect(manifest.subtitles.single.format, PlayableSubtitleFormat.srt);
      expect(manifest.subtitles.single.label, 'Ukrainian');
      expect(await fileIn('subs/1.srt').readAsString(), srt);
      final FakeRequest subtitleRequest = http.requests.firstWhere(
        (FakeRequest r) => r.url == 'https://subs.example/track?lang=uk',
      );
      expect(subtitleRequest.header('x-token'), 'abc');
      expect(subtitleRequest.header('referer'), isNull);
      expect(fileIn('index.m3u8').existsSync(), isTrue);
    },
  );

  test('refuses dash-only videos', () async {
    final FakeEpisodeHttp http = FakeEpisodeHttp();

    await expectLater(
      run(
        http,
        video: const PlayableVideo(
          streams: <PlayableStream>[
            PlayableStream(url: 'https://host.example/manifest.mpd'),
            PlayableStream(
              url: 'https://host.example/other',
              format: PlayableStreamFormat.dash,
            ),
          ],
        ),
      ),
      throwsA(isA<UnsupportedEpisodeDownload>()),
    );
    expect(http.requests, isEmpty);
  });

  test('falls through from a preferred dash stream to mp4', () async {
    const String mp4Url = 'https://host.example/ep.mp4';
    final FakeEpisodeHttp http = FakeEpisodeHttp()
      ..serveBytes(mp4Url, bytesOf('x', 50));

    final EpisodeDownloadManifest manifest = await run(
      http,
      video: const PlayableVideo(
        streams: <PlayableStream>[
          PlayableStream(
            url: 'https://host.example/manifest.mpd',
            quality: 'DASH',
          ),
          PlayableStream(url: mp4Url, quality: '480p'),
        ],
      ),
      quality: const QualityPreference(streamLabel: 'DASH'),
    );

    expect(manifest.format, EpisodeMediaFormat.mp4);
    expect(manifest.quality, '480p');
  });

  test('propagates cancellation', () async {
    final FakeEpisodeHttp http = hlsSite();
    final CancelToken cancelToken = CancelToken();
    http.serve(segmentUrl(0), (FakeRequest request) {
      cancelToken.cancel('stop');
      return FakeReply(200, body: bytesOf('seg0', 40));
    });

    Object? caught;
    try {
      await run(http, cancelToken: cancelToken);
    } catch (error) {
      caught = error;
    }

    expect(caught, isA<DioException>());
    expect(CancelToken.isCancel(caught! as DioException), isTrue);
    expect(fileIn('index.m3u8').existsSync(), isFalse);
  });
}
