import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/services/audiobooks/audio_progress.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';

ChapterActivityDomain _activity(int read, int total) {
  return ChapterActivityDomain(
    id: 1,
    uid: 't1',
    title: 'Part 1',
    timestamp: null,
    data: '{}',
    concreteId: 1,
    readPages: read,
    totalPages: total,
    createdAt: DateTime(2025),
  );
}

const Chapter _track = Chapter(uid: 't1', title: 'Part 1', data: <String, dynamic>{});

void main() {
  test('position and duration are stored in whole seconds', () {
    final ChapterActivityDomain? activity = AudioProgress.activityFor(
      track: _track,
      concreteId: 7,
      position: const Duration(minutes: 3, milliseconds: 900),
      duration: const Duration(minutes: 40),
    );

    expect(activity!.readPages, 180);
    expect(activity.totalPages, 2400);
    expect(activity.concreteId, 7);
    expect(AudioProgress.isFinished(activity), isFalse);
    expect(isChapterFinished(activity), isFalse);
  });

  test('an unknown duration is not stored', () {
    expect(
      AudioProgress.activityFor(
        track: _track,
        concreteId: 1,
        position: const Duration(seconds: 30),
        duration: Duration.zero,
      ),
      isNull,
    );
  });

  test('the last seconds of a track count as finished', () {
    final ChapterActivityDomain? nearEnd = AudioProgress.activityFor(
      track: _track,
      concreteId: 1,
      position: const Duration(minutes: 39, seconds: 50),
      duration: const Duration(minutes: 40),
    );
    final ChapterActivityDomain? marked = AudioProgress.activityFor(
      track: _track,
      concreteId: 1,
      position: const Duration(minutes: 2),
      duration: const Duration(minutes: 40),
      finished: true,
    );

    expect(nearEnd!.readPages, nearEnd.totalPages);
    expect(AudioProgress.isFinished(nearEnd), isTrue);
    expect(isChapterFinished(nearEnd), isTrue);
    expect(AudioProgress.isFinished(marked), isTrue);
  });

  test('a short track is not finished before its end', () {
    final ChapterActivityDomain? activity = AudioProgress.activityFor(
      track: _track,
      concreteId: 1,
      position: const Duration(seconds: 5),
      duration: const Duration(seconds: 10),
    );

    expect(AudioProgress.isFinished(activity), isFalse);
    expect(
      AudioProgress.reachedEnd(
        position: const Duration(milliseconds: 9500),
        duration: const Duration(seconds: 10),
      ),
      isTrue,
    );
    expect(
      AudioProgress.reachedEnd(
        position: const Duration(seconds: 30),
        duration: const Duration(minutes: 10),
      ),
      isFalse,
    );
  });

  test('resuming rewinds a little and restarts finished tracks', () {
    expect(
      AudioProgress.resumePositionOf(_activity(120, 600)),
      const Duration(seconds: 118),
    );
    expect(AudioProgress.resumePositionOf(_activity(1, 600)), Duration.zero);
    expect(AudioProgress.resumePositionOf(_activity(600, 600)), Duration.zero);
    expect(AudioProgress.resumePositionOf(null), Duration.zero);
    expect(AudioProgress.resumePositionOf(_activity(0, 0)), Duration.zero);
  });

  test('marking as listened keeps a known duration', () {
    expect(AudioProgress.completedUnits(_activity(120, 600)), 600);
    expect(AudioProgress.completedUnits(null), 1);
    expect(AudioProgress.completedUnits(_activity(0, 0)), 1);
  });

  test('clock labels use minutes or hours', () {
    expect(AudioProgress.formatClock(const Duration(seconds: 65)), '1:05');
    expect(AudioProgress.formatClock(const Duration(hours: 1, minutes: 2, seconds: 3)), '1:02:03');
    expect(AudioProgress.formatClock(const Duration(seconds: -4)), '0:00');
    expect(AudioProgress.progressLabel(_activity(90, 3600)), '1:30 / 1:00:00');
    expect(AudioProgress.fractionOf(_activity(300, 600)), 0.5);
  });
}
