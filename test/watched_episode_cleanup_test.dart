import 'dart:async';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_cleanup.dart';
import 'package:wakaranai/ui/services/anime/native_player/episode_progress_store.dart';

DownloadDomain _download(
  String uid, {
  DownloadKind kind = DownloadKind.episode,
  DownloadStatus status = DownloadStatus.done,
}) {
  return DownloadDomain(
    id: 1,
    uid: uid,
    extensionUid: 'ext',
    concreteUid: 'concrete',
    concreteId: 1,
    concreteTitle: 'Title',
    title: uid,
    status: status,
    downloadedPages: 0,
    totalPages: 0,
    dirPath: '/downloads/$uid',
    kind: kind,
    createdAt: DateTime(2026),
  );
}

AnimeVideo _episode(String uid) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: '',
    title: uid,
    timestamp: null,
    data: const <String, dynamic>{},
  );
}

class _RecordingStore implements EpisodeProgressStore {
  final List<EpisodeProgress> saved = <EpisodeProgress>[];

  @override
  Future<EpisodeProgress?> start() async => null;

  @override
  Future<void> save(EpisodeProgress progress) async {
    saved.add(progress);
  }
}

class _Harness {
  _Harness({this.enabled = true, Map<String, DownloadDomain>? downloads})
      : downloads = downloads ?? <String, DownloadDomain>{};

  bool enabled;
  final Map<String, DownloadDomain> downloads;
  final List<String> deleted = <String>[];

  late final WatchedEpisodeCleanup cleanup = WatchedEpisodeCleanup(
    isEnabled: () async => enabled,
    findDownload: (String uid) async => downloads[uid],
    deleteDownload: (DownloadDomain download) async {
      deleted.add(download.uid);
    },
  );
}

const EpisodeProgress _finished =
    EpisodeProgress(watchedSeconds: 1380, totalSeconds: 1440);
const EpisodeProgress _halfway =
    EpisodeProgress(watchedSeconds: 700, totalSeconds: 1440);

void main() {
  group('isWatchedToTheEnd', () {
    test('needs a known duration and the finished fraction', () {
      expect(isWatchedToTheEnd(_finished), isTrue);
      expect(isWatchedToTheEnd(_halfway), isFalse);
      expect(
        isWatchedToTheEnd(const EpisodeProgress(watchedSeconds: 1400)),
        isFalse,
      );
      expect(
        isWatchedToTheEnd(
          const EpisodeProgress(watchedSeconds: 10, totalSeconds: 0),
        ),
        isFalse,
      );
    });
  });

  group('WatchedEpisodeCleanup', () {
    test('forwards progress and remembers finished episodes', () async {
      final _Harness harness = _Harness();
      final _RecordingStore inner = _RecordingStore();
      final EpisodeProgressStore tracked =
          harness.cleanup.track(inner, _episode('e1'));

      await tracked.save(_halfway);
      expect(harness.cleanup.finishedEpisodeUids, isEmpty);

      await tracked.save(_finished);
      expect(inner.saved, <EpisodeProgress>[_halfway, _finished]);
      expect(harness.cleanup.finishedEpisodeUids, <String>{'e1'});

      await tracked.save(_halfway);
      expect(harness.cleanup.finishedEpisodeUids, isEmpty);
    });

    test('deletes finished episode downloads once playback closes', () async {
      final _Harness harness = _Harness(
        downloads: <String, DownloadDomain>{
          'e1': _download('e1'),
          'e2': _download('e2'),
        },
      );
      harness.cleanup.record('e1', _finished);
      harness.cleanup.record('e2', _halfway);
      final Completer<void> closed = Completer<void>();

      final Future<int> deletion =
          harness.cleanup.deleteFinishedAfter(closed.future);
      await pumpEventQueue();
      expect(harness.deleted, isEmpty);

      closed.complete();
      expect(await deletion, 1);
      expect(harness.deleted, <String>['e1']);
      expect(harness.cleanup.finishedEpisodeUids, isEmpty);
    });

    test('keeps downloads while the setting is off', () async {
      final _Harness harness = _Harness(
        enabled: false,
        downloads: <String, DownloadDomain>{'e1': _download('e1')},
      );
      harness.cleanup.record('e1', _finished);

      expect(await harness.cleanup.deleteFinished(), 0);
      expect(harness.deleted, isEmpty);
    });

    test('skips episodes that are missing or not finished downloading',
        () async {
      final _Harness harness = _Harness(
        downloads: <String, DownloadDomain>{
          'queued': _download('queued', status: DownloadStatus.downloading),
        },
      );
      harness.cleanup.record('queued', _finished);
      harness.cleanup.record('missing', _finished);

      expect(await harness.cleanup.deleteFinished(), 0);
      expect(harness.deleted, isEmpty);
    });

    test('a failed delete does not stop the others', () async {
      final List<String> attempted = <String>[];
      final WatchedEpisodeCleanup cleanup = WatchedEpisodeCleanup(
        isEnabled: () async => true,
        findDownload: (String uid) async => _download(uid),
        deleteDownload: (DownloadDomain download) async {
          attempted.add(download.uid);
          if (download.uid == 'e1') {
            throw StateError('locked');
          }
        },
      );
      cleanup.record('e1', _finished);
      cleanup.record('e2', _finished);

      expect(await cleanup.deleteFinished(), 1);
      expect(attempted, <String>['e1', 'e2']);
    });
  });
}
