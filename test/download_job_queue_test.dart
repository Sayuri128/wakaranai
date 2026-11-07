import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/downloads/jobs/download_job.dart';
import 'package:wakaranai/services/downloads/queue/download_job_queue.dart';

EpisodeDownloadJob _job(String uid) {
  return EpisodeDownloadJob(
    extensionUid: 'ext',
    concreteTitle: 'Title',
    episode: AnimeVideo(
      type: AnimeVideoType.IFRAME,
      uid: uid,
      src: 'https://player.test/embed',
      title: 'Episode $uid',
      timestamp: null,
      data: <String, dynamic>{'uid': uid},
    ),
  );
}

List<String> _waitingUids(DownloadJobQueue queue) {
  return queue.waiting.map((DownloadJob job) => job.uid).toList();
}

void main() {
  group('DownloadJobQueue.sortBy', () {
    test('orders waiting jobs by the given uids', () {
      final DownloadJobQueue queue = DownloadJobQueue();
      queue.waiting.addAll(<DownloadJob>[_job('a'), _job('b'), _job('c')]);

      queue.sortBy(<String>['c', 'a', 'b']);

      expect(_waitingUids(queue), <String>['c', 'a', 'b']);
    });

    test('keeps unranked jobs after ranked ones in arrival order', () {
      final DownloadJobQueue queue = DownloadJobQueue();
      queue.waiting.addAll(
          <DownloadJob>[_job('x'), _job('a'), _job('y'), _job('b')]);

      queue.sortBy(<String>['b', 'a']);

      expect(_waitingUids(queue), <String>['b', 'a', 'x', 'y']);
    });

    test('ignores uids that are not waiting', () {
      final DownloadJobQueue queue = DownloadJobQueue();
      queue.waiting.addAll(<DownloadJob>[_job('a'), _job('b')]);

      queue.sortBy(<String>['gone', 'b', 'a']);

      expect(_waitingUids(queue), <String>['b', 'a']);
    });
  });

  group('DownloadJobQueue.orderWithActiveFirst', () {
    test('puts the picked uids first and keeps the rest in order', () {
      final DownloadJobQueue queue = DownloadJobQueue();

      expect(
        queue.orderWithActiveFirst(
          <String>['a', 'b', 'c', 'd'],
          <String>['c'],
        ),
        <String>['c', 'a', 'b', 'd'],
      );
    });

    test('pins the active job ahead of the picked uids', () {
      final DownloadJobQueue queue = DownloadJobQueue()..active = _job('b');

      expect(
        queue.orderWithActiveFirst(
          <String>['a', 'b', 'c'],
          <String>['c', 'a'],
        ),
        <String>['b', 'c', 'a'],
      );
    });

    test('drops picked uids that are no longer pending', () {
      final DownloadJobQueue queue = DownloadJobQueue()..active = _job('done');

      expect(
        queue.orderWithActiveFirst(
          <String>['a', 'b'],
          <String>['missing', 'b', 'b'],
        ),
        <String>['b', 'a'],
      );
    });
  });

  group('DownloadJobQueue membership', () {
    test('replace swaps a waiting job with the same uid to the end', () {
      final DownloadJobQueue queue = DownloadJobQueue();
      final DownloadJob first = _job('a');
      final DownloadJob replacement = _job('a');
      queue.waiting.addAll(<DownloadJob>[first, _job('b')]);

      queue.replace(replacement);

      expect(_waitingUids(queue), <String>['b', 'a']);
      expect(identical(queue.waiting.last, replacement), isTrue);
    });

    test('hasJob covers the active job and the waiting jobs', () {
      final DownloadJobQueue queue = DownloadJobQueue()..active = _job('a');
      queue.waiting.add(_job('b'));

      expect(queue.hasJob('a'), isTrue);
      expect(queue.hasJob('b'), isTrue);
      expect(queue.hasJob('c'), isFalse);
      expect(queue.isWaiting('a'), isFalse);
      expect(queue.isIdle, isFalse);
    });

    test('is idle without active or waiting jobs', () {
      expect(DownloadJobQueue().isIdle, isTrue);
    });
  });

  group('DownloadJobQueue batch counters', () {
    test('batch total counts the jobs still waiting', () {
      final DownloadJobQueue queue = DownloadJobQueue()..batchIndex = 2;
      queue.waiting.addAll(<DownloadJob>[_job('a'), _job('b')]);

      expect(queue.batchTotal, 4);
    });

    test('stepping back never goes below zero', () {
      final DownloadJobQueue queue = DownloadJobQueue()..batchIndex = 1;

      queue.stepBackInBatch();
      queue.stepBackInBatch();

      expect(queue.batchIndex, 0);
    });

    test('starting a batch resets the counters', () {
      final DownloadJobQueue queue = DownloadJobQueue()
        ..batchIndex = 3
        ..completedInBatch = 2
        ..previousInBatch = _job('a');

      queue.startBatch();

      expect(queue.batchIndex, 0);
      expect(queue.completedInBatch, 0);
      expect(queue.previousInBatch, isNull);
    });
  });
}
