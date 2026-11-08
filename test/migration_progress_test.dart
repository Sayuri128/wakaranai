import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/services/migration/migration_progress.dart';

ChapterActivityDomain _chapterActivity(
  String uid,
  String title, {
  int readPages = 10,
  int totalPages = 10,
}) {
  return ChapterActivityDomain(
    id: 0,
    uid: uid,
    title: title,
    timestamp: null,
    data: null,
    concreteId: 1,
    readPages: readPages,
    totalPages: totalPages,
    createdAt: DateTime(2026),
  );
}

MigrationTargetElement _chapter(String uid, String title, {double? number}) {
  return MigrationTargetElement.fromChapter(Chapter(
    uid: uid,
    title: title,
    data: const <String, dynamic>{},
    number: number,
  ));
}

MigrationTargetElement _episode(String uid, double number, {int? season}) {
  return MigrationTargetElement.fromEpisode(AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: '',
    title: 'Episode',
    timestamp: null,
    data: const <String, dynamic>{},
    number: number,
    season: season,
  ));
}

void main() {
  group('MigrationOldProgress', () {
    test('parses the chapter number from the title when none is saved', () {
      final MigrationOldProgress progress = MigrationOldProgress.fromChapter(
        _chapterActivity('old-3', 'Chapter 3.5: Night'),
      );
      expect(progress.number, 3.5);
      expect(progress.finished, isTrue);
    });

    test('prefers a saved number over the title', () {
      final MigrationOldProgress progress = MigrationOldProgress.fromChapter(
        _chapterActivity('old-3', 'Chapter 3'),
        number: 30,
      );
      expect(progress.number, 30);
    });

    test('treats a manually marked episode as finished', () {
      final MigrationOldProgress progress = MigrationOldProgress.fromEpisode(
        AnimeEpisodeActivityDomain(
          id: 0,
          uid: 'ep',
          title: 'Episode 4',
          concreteId: 1,
          watchedTime: 10,
          totalTime: 1400,
          markedWatched: true,
          createdAt: DateTime(2026),
        ),
      );
      expect(progress.number, 4);
      expect(progress.finished, isTrue);
    });
  });

  group('mapMigrationProgress', () {
    test('matches chapters by number and lists the rest as unmatched', () {
      final MigrationProgressPlan plan = mapMigrationProgress(
        kind: MigrationMediaKind.chapters,
        progress: <MigrationOldProgress>[
          MigrationOldProgress.fromChapter(_chapterActivity('o1', 'Ch. 1')),
          MigrationOldProgress.fromChapter(_chapterActivity('o2', 'Ch. 2')),
          MigrationOldProgress.fromChapter(_chapterActivity('o9', 'Ch. 9')),
          MigrationOldProgress.fromChapter(_chapterActivity('ox', 'Prologue')),
        ],
        targetGroups: <List<MigrationTargetElement>>[
          <MigrationTargetElement>[
            _chapter('n2', 'Second', number: 2),
            _chapter('n1', 'Глава 1'),
          ],
        ],
      );
      expect(
        plan.matches.map((MigrationProgressMatch m) => m.from.uid),
        <String>['o1', 'o2'],
      );
      expect(plan.matches.first.targets.single.uid, 'n1');
      expect(
        plan.unmatched.map((MigrationOldProgress p) => p.uid),
        <String>['o9', 'ox'],
      );
    });

    test('marks a chapter in every branch of the new title', () {
      final MigrationProgressPlan plan = mapMigrationProgress(
        kind: MigrationMediaKind.chapters,
        progress: <MigrationOldProgress>[
          MigrationOldProgress.fromChapter(_chapterActivity('o1', 'Ch. 1')),
        ],
        targetGroups: <List<MigrationTargetElement>>[
          <MigrationTargetElement>[_chapter('a1', 'x', number: 1)],
          <MigrationTargetElement>[_chapter('b1', 'y', number: 1)],
        ],
      );
      expect(
        plan.writes.map((MigrationProgressWrite w) => w.target.uid).toSet(),
        <String>{'a1', 'b1'},
      );
    });

    test('keeps the most advanced of duplicate old chapters', () {
      final MigrationProgressPlan plan = mapMigrationProgress(
        kind: MigrationMediaKind.chapters,
        progress: <MigrationOldProgress>[
          MigrationOldProgress.fromChapter(
            _chapterActivity('a5', 'Ch. 5', readPages: 2, totalPages: 20),
          ),
          MigrationOldProgress.fromChapter(_chapterActivity('b5', 'Ch. 5')),
        ],
        targetGroups: <List<MigrationTargetElement>>[
          <MigrationTargetElement>[_chapter('n5', 'x', number: 5)],
        ],
      );
      expect(plan.matches.single.from.uid, 'b5');
      expect(plan.unmatched, isEmpty);
      expect(plan.writes.single.progress.finished, isTrue);
    });

    test('respects seasons only when both sides know them', () {
      final MigrationProgressPlan plan = mapMigrationProgress(
        kind: MigrationMediaKind.episodes,
        progress: <MigrationOldProgress>[
          const MigrationOldProgress(
            uid: 's2e1',
            title: 'S2E1',
            number: 1,
            season: 2,
            finished: true,
          ),
          const MigrationOldProgress(
            uid: 'e3',
            title: 'Episode 3',
            number: 3,
            finished: true,
          ),
        ],
        targetGroups: <List<MigrationTargetElement>>[
          <MigrationTargetElement>[
            _episode('n-s1e1', 1, season: 1),
            _episode('n-s2e1', 1, season: 2),
            _episode('n-s1e3', 3, season: 1),
          ],
        ],
      );
      final Map<String, String> pairs = <String, String>{
        for (final MigrationProgressWrite write in plan.writes)
          write.progress.uid: write.target.uid,
      };
      expect(pairs, <String, String>{'s2e1': 'n-s2e1', 'e3': 'n-s1e3'});
    });

    test('is empty without progress', () {
      final MigrationProgressPlan plan = mapMigrationProgress(
        kind: MigrationMediaKind.chapters,
        progress: const <MigrationOldProgress>[],
        targetGroups: <List<MigrationTargetElement>>[
          <MigrationTargetElement>[_chapter('n1', 'x', number: 1)],
        ],
      );
      expect(plan.isEmpty, isTrue);
    });
  });
}
