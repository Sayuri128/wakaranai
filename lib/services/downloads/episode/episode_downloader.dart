import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:path/path.dart' as p;
import 'package:wakaranai/blocs/downloads/download_throttle.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_manifest.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_plan.dart';
import 'package:wakaranai/services/downloads/episode/episode_download_progress.dart';
import 'package:wakaranai/services/downloads/episode/episode_fetcher.dart';
import 'package:wakaranai/services/downloads/episode/episode_file_io.dart';
import 'package:wakaranai/services/downloads/episode/episode_http.dart';
import 'package:wakaranai/services/downloads/episode/episode_mp4_downloader.dart';
import 'package:wakaranai/services/downloads/episode/episode_quality_selection.dart';
import 'package:wakaranai/services/downloads/episode/episode_subtitle_downloader.dart';
import 'package:wakaranai/services/downloads/episode/hls_local_playlist.dart';
import 'package:wakaranai/services/downloads/episode/hls_playlist.dart';

export 'package:wakaranai/services/downloads/episode/episode_download_errors.dart';
export 'package:wakaranai/services/downloads/episode/episode_download_progress.dart';
export 'package:wakaranai/services/downloads/episode/episode_http.dart'
    show DioEpisodeHttp, EpisodeHttp, EpisodeHttpResponse;

typedef EpisodeProgressCallback =
    void Function(EpisodeDownloadProgress progress);

const int _aesKeyLength = 16;
const Duration _progressInterval = Duration(milliseconds: 250);

class EpisodeDownloader {
  EpisodeDownloader({
    EpisodeHttp? http,
    DownloadThrottle? throttle,
    int concurrency = kDefaultSegmentConcurrency,
    Duration failureBackoff = const Duration(milliseconds: 500),
  }) : _http = http ?? DioEpisodeHttp(),
       _throttle = throttle ?? DownloadThrottle(),
       _concurrency = max(1, concurrency),
       _failureBackoff = failureBackoff;

  final EpisodeHttp _http;
  final DownloadThrottle _throttle;
  final int _concurrency;
  final Duration _failureBackoff;

  Future<EpisodeDownloadManifest> download({
    required PlayableVideo video,
    required QualityPreference quality,
    required Directory dir,
    required String throttleKey,
    required CancelToken cancelToken,
    EpisodeProgressCallback? onProgress,
  }) async {
    await dir.create(recursive: true);
    final EpisodeFetcher fetcher = EpisodeFetcher(
      http: _http,
      throttle: _throttle,
      throttleKey: throttleKey,
      cancelToken: cancelToken,
      failureBackoff: _failureBackoff,
    );
    return _EpisodeDownloadRun(
      video: video,
      quality: quality,
      dir: dir,
      fetcher: fetcher,
      concurrency: segmentConcurrencyFor(throttleKey),
      onProgress: onProgress,
    ).run();
  }

  int segmentConcurrencyFor(String throttleKey) {
    return resolveSegmentConcurrency(
      _throttle.segmentConcurrency(throttleKey),
      fallback: _concurrency,
    );
  }
}

class _EpisodeDownloadRun {
  _EpisodeDownloadRun({
    required this.video,
    required this.quality,
    required this.dir,
    required this.fetcher,
    required this.concurrency,
    required this.onProgress,
  });

  final PlayableVideo video;
  final QualityPreference quality;
  final Directory dir;
  final EpisodeFetcher fetcher;
  final int concurrency;
  final EpisodeProgressCallback? onProgress;
  final Stopwatch _sinceLastReport = Stopwatch();
  int _completedSegments = 0;
  int _totalSegments = 0;
  int _downloadedBytes = 0;
  int _totalBytes = 0;

  Future<EpisodeDownloadManifest> run() async {
    final List<int> order = downloadableStreamOrder(
      video.streams,
      quality.streamLabel,
    );
    if (order.isEmpty) {
      throw const UnsupportedEpisodeDownload(
        'No downloadable stream (DASH is not supported)',
      );
    }
    UnsupportedEpisodeDownload? lastUnsupported;
    for (final int streamIndex in order) {
      try {
        return await _downloadStream(streamIndex);
      } on UnsupportedEpisodeDownload catch (error) {
        logger.w('Stream $streamIndex cannot be downloaded: $error');
        lastUnsupported = error;
      }
    }
    throw lastUnsupported!;
  }

  Future<EpisodeDownloadManifest> _downloadStream(int streamIndex) async {
    final PlayableStream stream = video.streams[streamIndex];
    final Map<String, String> headers = mergeEpisodeHeaders(stream.headers);
    PlayableStreamFormat format = resolveStreamFormat(stream);
    String? playlistText;
    if (format == PlayableStreamFormat.auto) {
      final EpisodeProbeResult probe = await fetcher.probe(stream.url, headers);
      playlistText = probe.playlistText;
      format = probe.isHls
          ? PlayableStreamFormat.hls
          : PlayableStreamFormat.mp4;
    }
    if (format == PlayableStreamFormat.hls) {
      return _downloadHls(
        streamIndex: streamIndex,
        stream: stream,
        headers: headers,
        playlistText: playlistText,
      );
    }
    return _downloadMp4(
      streamIndex: streamIndex,
      stream: stream,
      headers: headers,
    );
  }

  Future<EpisodeDownloadManifest> _downloadMp4({
    required int streamIndex,
    required PlayableStream stream,
    required Map<String, String> headers,
  }) async {
    await applyDownloadPlan(
      dir,
      EpisodeDownloadPlan.mp4(
        streamIndex: streamIndex,
        streamQuality: stream.quality,
      ),
    );
    await EpisodeMp4Downloader(
      fetcher: fetcher,
      url: stream.url,
      headers: headers,
      dir: dir,
      onProgress: _reportMp4Progress,
    ).run();
    _report(force: true);
    final List<DownloadedSubtitle> subtitles = await _downloadSubtitles();
    return EpisodeDownloadManifest(
      format: EpisodeMediaFormat.mp4,
      file: kLocalMp4File,
      quality: stream.quality,
      subtitles: subtitles,
      skipMarkers: stream.skipMarkers,
      audioLabel: stream.audioLabel,
    );
  }

  void _reportMp4Progress(int downloadedBytes, int totalBytes) {
    _downloadedBytes = downloadedBytes;
    _totalBytes = totalBytes;
    _report();
  }

  Future<EpisodeDownloadManifest> _downloadHls({
    required int streamIndex,
    required PlayableStream stream,
    required Map<String, String> headers,
    required String? playlistText,
  }) async {
    final _HlsSelection selection = await _selectHls(
      stream: stream,
      headers: headers,
      playlistText: playlistText,
    );
    final HlsKeyFiles keyFiles = HlsKeyFiles();
    final HlsLocalTrack videoTrack = HlsLocalTrack.build(
      selection.video,
      folder: kLocalVideoFolder,
      keyFiles: keyFiles,
    );
    final HlsMediaPlaylist? audioPlaylist = selection.audio;
    final HlsLocalTrack? audioTrack = audioPlaylist == null
        ? null
        : HlsLocalTrack.build(
            audioPlaylist,
            folder: kLocalAudioFolder,
            keyFiles: keyFiles,
          );
    final List<HlsLocalTrack> tracks = <HlsLocalTrack>[videoTrack, ?audioTrack];
    await applyDownloadPlan(
      dir,
      EpisodeDownloadPlan.hls(
        streamIndex: streamIndex,
        streamQuality: stream.quality,
        variant: selection.variant,
        audio: selection.audioRendition,
        tracks: <HlsMediaPlaylist>[
          for (final HlsLocalTrack track in tracks) track.playlist,
        ],
      ),
    );
    await _downloadTracks(tracks, headers);
    final List<DownloadedSubtitle> subtitles = await _downloadSubtitles();
    await _writePlaylists(selection, videoTrack, audioTrack);
    return EpisodeDownloadManifest(
      format: EpisodeMediaFormat.hls,
      file: kLocalIndexPlaylist,
      quality: _hlsQualityLabel(selection, stream),
      subtitles: subtitles,
      skipMarkers: stream.skipMarkers,
      audioLabel: stream.audioLabel,
    );
  }

  String? _hlsQualityLabel(_HlsSelection selection, PlayableStream stream) {
    final HlsVariant? variant = selection.variant;
    if (variant == null) {
      return stream.quality;
    }
    return variantQualityLabel(variant) ?? stream.quality;
  }

  Future<_HlsSelection> _selectHls({
    required PlayableStream stream,
    required Map<String, String> headers,
    required String? playlistText,
  }) async {
    final Uri playlistUri = Uri.parse(stream.url);
    final String text =
        playlistText ?? await fetcher.fetchText(stream.url, headers);
    final HlsPlaylist playlist = _parse(text, playlistUri);
    if (playlist is HlsMediaPlaylist) {
      return _HlsSelection(video: playlist);
    }
    final HlsMasterPlaylist master = playlist as HlsMasterPlaylist;
    if (master.variants.isEmpty) {
      throw const UnsupportedEpisodeDownload('Master playlist has no variants');
    }
    final HlsVariant variant = pickHlsVariant(
      master.variants,
      wantedHeightFor(quality),
    );
    final HlsMediaPlaylist videoPlaylist = await _fetchMediaPlaylist(
      variant.uri,
      headers,
    );
    final HlsAudioRendition? audioRendition = pickAudioRendition(
      master,
      variant,
    );
    final Uri? audioUri = audioRendition?.uri;
    final HlsMediaPlaylist? audioPlaylist = audioUri == null
        ? null
        : await _fetchMediaPlaylist(audioUri, headers);
    return _HlsSelection(
      video: videoPlaylist,
      variant: variant,
      audio: audioPlaylist,
      audioRendition: audioPlaylist == null ? null : audioRendition,
    );
  }

  Future<HlsMediaPlaylist> _fetchMediaPlaylist(
    Uri uri,
    Map<String, String> headers,
  ) async {
    final String url = uri.toString();
    final HlsPlaylist playlist = _parse(
      await fetcher.fetchText(url, headers),
      uri,
    );
    if (playlist is! HlsMediaPlaylist) {
      throw const UnsupportedEpisodeDownload('Nested master playlists');
    }
    if (playlist.segments.isEmpty) {
      throw EpisodeDownloadFailure(url: url, cause: 'Playlist has no segments');
    }
    return playlist;
  }

  HlsPlaylist _parse(String text, Uri uri) {
    try {
      return parseHlsPlaylist(text, uri);
    } on HlsParseException catch (error) {
      throw EpisodeDownloadFailure(url: uri.toString(), cause: error);
    }
  }

  Future<void> _downloadTracks(
    List<HlsLocalTrack> tracks,
    Map<String, String> headers,
  ) async {
    final Map<String, HlsFileTask> auxiliary = <String, HlsFileTask>{
      for (final HlsLocalTrack track in tracks)
        for (final HlsFileTask task in track.auxiliaryTasks)
          task.relativePath: task,
    };
    for (final HlsFileTask task in auxiliary.values) {
      await _downloadFile(task, headers);
    }
    await _downloadSegments(<HlsFileTask>[
      for (final HlsLocalTrack track in tracks) ...track.segmentTasks,
    ], headers);
  }

  Future<void> _downloadSegments(
    List<HlsFileTask> tasks,
    Map<String, String> headers,
  ) async {
    _totalSegments = tasks.length;
    final List<HlsFileTask> pending = <HlsFileTask>[];
    for (final HlsFileTask task in tasks) {
      final File file = _fileOf(task);
      if (await file.exists()) {
        _completedSegments++;
        _downloadedBytes += await file.length();
      } else {
        pending.add(task);
      }
    }
    _report(force: true);
    await _SegmentPool(
      tasks: pending,
      concurrency: concurrency,
      throttled: () => fetcher.wasRateLimited,
      download: (HlsFileTask task) => _downloadSegment(task, headers),
    ).run();
  }

  Future<void> _downloadSegment(
    HlsFileTask task,
    Map<String, String> headers,
  ) async {
    final int bytes = await _downloadFile(task, headers);
    _completedSegments++;
    _downloadedBytes += bytes;
    _report(force: true);
  }

  Future<int> _downloadFile(
    HlsFileTask task,
    Map<String, String> headers,
  ) async {
    final File file = _fileOf(task);
    if (await file.exists()) {
      return file.length();
    }
    return fetcher.downloadToFile(
      url: task.uri.toString(),
      headers: headers,
      target: file,
      range: task.byteRange,
      validate: task.kind == HlsFileKind.key ? _validateKey : null,
    );
  }

  void _validateKey(File part) {
    final int length = part.lengthSync();
    if (length != _aesKeyLength) {
      throw HttpException('AES-128 key has $length bytes');
    }
  }

  File _fileOf(HlsFileTask task) {
    return File(p.joinAll(<String>[dir.path, ...task.relativePath.split('/')]));
  }

  Future<List<DownloadedSubtitle>> _downloadSubtitles() {
    return downloadEpisodeSubtitles(
      subtitles: video.subtitles,
      dir: dir,
      fetcher: fetcher,
    );
  }

  Future<void> _writePlaylists(
    _HlsSelection selection,
    HlsLocalTrack videoTrack,
    HlsLocalTrack? audioTrack,
  ) async {
    final HlsVariant? variant = selection.variant;
    final HlsAudioRendition? audioRendition = selection.audioRendition;
    if (audioTrack == null || variant == null || audioRendition == null) {
      await _writePlaylist(kLocalIndexPlaylist, videoTrack.render());
      return;
    }
    await _writePlaylist(kLocalVideoPlaylist, videoTrack.render());
    await _writePlaylist(kLocalAudioPlaylist, audioTrack.render());
    await _writePlaylist(
      kLocalIndexPlaylist,
      renderLocalMasterPlaylist(variant: variant, audio: audioRendition),
    );
  }

  Future<void> _writePlaylist(String name, String content) {
    return writeTextAtomically(File(p.join(dir.path, name)), content);
  }

  void _report({bool force = false}) {
    final EpisodeProgressCallback? callback = onProgress;
    if (callback == null) {
      return;
    }
    final bool due =
        !_sinceLastReport.isRunning ||
        _sinceLastReport.elapsed >= _progressInterval;
    if (!force && !due) {
      return;
    }
    _sinceLastReport
      ..reset()
      ..start();
    callback(
      EpisodeDownloadProgress(
        completedSegments: _completedSegments,
        totalSegments: _totalSegments,
        downloadedBytes: _downloadedBytes,
        totalBytes: _totalBytes,
      ),
    );
  }
}

class _HlsSelection {
  const _HlsSelection({
    required this.video,
    this.variant,
    this.audio,
    this.audioRendition,
  });

  final HlsMediaPlaylist video;
  final HlsVariant? variant;
  final HlsMediaPlaylist? audio;
  final HlsAudioRendition? audioRendition;
}

class _SegmentPool {
  _SegmentPool({
    required this.tasks,
    required this.concurrency,
    required this.throttled,
    required this.download,
  });

  final List<HlsFileTask> tasks;
  final int concurrency;
  final bool Function() throttled;
  final Future<void> Function(HlsFileTask task) download;
  int _next = 0;
  bool _stopped = false;

  Future<void> run() async {
    final int workers = min(concurrency, tasks.length);
    await Future.wait(<Future<void>>[
      for (int worker = 0; worker < workers; worker++) _work(worker),
    ]);
  }

  int get _activeWorkers => throttled() ? 1 : concurrency;

  Future<void> _work(int worker) async {
    while (!_stopped && worker < _activeWorkers && _next < tasks.length) {
      final HlsFileTask task = tasks[_next++];
      try {
        await download(task);
      } catch (_) {
        _stopped = true;
        rethrow;
      }
    }
  }
}
