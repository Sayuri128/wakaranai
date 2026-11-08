import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/services/novels/novel_progress.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';

ChapterActivityDomain _activity(
  String uid, {
  required int readPages,
  int totalPages = NovelProgress.scale,
  DateTime? updatedAt,
}) {
  return ChapterActivityDomain(
    id: 0,
    uid: uid,
    title: uid,
    timestamp: null,
    data: '{}',
    concreteId: 1,
    readPages: readPages,
    totalPages: totalPages,
    createdAt: DateTime(2025),
    updatedAt: updatedAt,
  );
}

void main() {
  group('NovelProgress.unitsFor', () {
    test('scales the scroll fraction to the stored range', () {
      expect(NovelProgress.unitsFor(0), 0);
      expect(NovelProgress.unitsFor(0.25), 250);
      expect(NovelProgress.unitsFor(0.5004), 500);
      expect(NovelProgress.unitsFor(0.979), 979);
    });

    test('treats the last two percent as finished', () {
      expect(NovelProgress.unitsFor(0.98), NovelProgress.scale);
      expect(NovelProgress.unitsFor(1), NovelProgress.scale);
      expect(NovelProgress.isCompletedFraction(0.98), isTrue);
      expect(NovelProgress.isCompletedFraction(0.97), isFalse);
    });

    test('clamps invalid fractions', () {
      expect(NovelProgress.unitsFor(-3), 0);
      expect(NovelProgress.unitsFor(7), NovelProgress.scale);
      expect(NovelProgress.unitsFor(double.nan), 0);
    });

    test('keeps a finished chapter finished while it is re-read', () {
      expect(NovelProgress.unitsFor(0.1, keepCompleted: true),
          NovelProgress.scale);
    });
  });

  group('NovelProgress reading activities', () {
    test('reads the fraction back from an activity', () {
      expect(NovelProgress.fractionOf(_activity('a', readPages: 400)), 0.4);
      expect(NovelProgress.fractionOf(null), 0);
      expect(
        NovelProgress.fractionOf(_activity('a', readPages: 0, totalPages: 0)),
        0,
      );
      expect(NovelProgress.percentOf(_activity('a', readPages: 437)), 43);
    });

    test('resumes unfinished chapters and restarts finished ones', () {
      expect(
        NovelProgress.resumeFractionOf(_activity('a', readPages: 600)),
        0.6,
      );
      expect(
        NovelProgress.resumeFractionOf(
          _activity('a', readPages: NovelProgress.scale),
        ),
        0,
      );
      expect(NovelProgress.isFinished(_activity('a', readPages: 999)), isFalse);
      expect(
        NovelProgress.isFinished(_activity('a', readPages: 0, totalPages: 0)),
        isFalse,
      );
    });

    test('a chapter shorter than the screen counts as read to the end', () {
      expect(NovelProgress.scrollFraction(offset: 0, maxExtent: 0), 1);
      expect(NovelProgress.scrollFraction(offset: 250, maxExtent: 1000), 0.25);
      expect(NovelProgress.scrollFraction(offset: 1200, maxExtent: 1000), 1);
    });
  });

  group('continue reading for novels', () {
    final List<ChaptersGroup> groups = <ChaptersGroup>[
      ChaptersGroup(
        title: 'Volume 1',
        elements: const <Chapter>[
          Chapter(uid: 'c1', title: 'One', data: <String, dynamic>{}),
          Chapter(uid: 'c2', title: 'Two', data: <String, dynamic>{}),
          Chapter(uid: 'c3', title: 'Three', data: <String, dynamic>{}),
        ],
      ),
    ];

    test('resumes a partly read chapter', () {
      final ContinueTarget<Chapter>? target = resolveChapterContinue(
        groups: groups,
        preferredGroup: 0,
        activities: <String, ChapterActivityDomain>{
          'c2': _activity('c2', readPages: 420),
        },
      );

      expect(target?.element.uid, 'c2');
      expect(target?.kind, ContinueKind.resume);
    });

    test('moves to the next chapter after a finished one', () {
      final ContinueTarget<Chapter>? target = resolveChapterContinue(
        groups: groups,
        preferredGroup: 0,
        activities: <String, ChapterActivityDomain>{
          'c1': _activity('c1', readPages: NovelProgress.unitsFor(0.99)),
        },
      );

      expect(target?.element.uid, 'c2');
      expect(target?.kind, ContinueKind.next);
    });
  });
}
