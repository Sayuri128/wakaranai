import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';

Chapter _chapter(String uid) {
  return Chapter(uid: uid, title: 'Chapter $uid', data: const <String, dynamic>{});
}

ChapterActivityDomain _read(
  String uid, {
  required int readPages,
  int totalPages = 10,
  required DateTime at,
}) {
  return ChapterActivityDomain(
    id: 0,
    uid: uid,
    title: uid,
    timestamp: null,
    data: null,
    concreteId: 1,
    readPages: readPages,
    totalPages: totalPages,
    createdAt: at,
    updatedAt: at,
  );
}

AnimeVideo _episode(String uid, double number) {
  return AnimeVideo(
    uid: uid,
    title: 'Episode $uid',
    src: '',
    type: AnimeVideoType.IFRAME,
    timestamp: null,
    data: const <String, dynamic>{},
    number: number,
  );
}

AnimeEpisodeActivityDomain _watched(
  String uid, {
  int? watchedTime,
  int? totalTime,
  bool markedWatched = false,
  required DateTime at,
}) {
  return AnimeEpisodeActivityDomain(
    id: 0,
    uid: uid,
    title: uid,
    concreteId: 1,
    watchedTime: watchedTime,
    totalTime: totalTime,
    markedWatched: markedWatched,
    createdAt: at,
    updatedAt: at,
  );
}

void main() {
  final DateTime earlier = DateTime(2026, 1, 1);
  final DateTime later = DateTime(2026, 1, 2);
  final List<ChaptersGroup> chapters = <ChaptersGroup>[
    ChaptersGroup(
      title: 'Main',
      elements: <Chapter>[_chapter('1'), _chapter('2'), _chapter('3')],
    ),
  ];

  test('starts with the first chapter when nothing was read', () {
    final ContinueTarget<Chapter>? target = resolveChapterContinue(
      groups: chapters,
      preferredGroup: 0,
      activities: const <String, ChapterActivityDomain>{},
    );
    expect(target?.element.uid, '1');
    expect(target?.kind, ContinueKind.start);
  });

  test('resumes the last touched chapter while it is unfinished', () {
    final ContinueTarget<Chapter>? target = resolveChapterContinue(
      groups: chapters,
      preferredGroup: 0,
      activities: <String, ChapterActivityDomain>{
        '1': _read('1', readPages: 10, at: earlier),
        '2': _read('2', readPages: 4, at: later),
      },
    );
    expect(target?.element.uid, '2');
    expect(target?.kind, ContinueKind.resume);
  });

  test('moves to the next unfinished chapter after a finished one', () {
    final ContinueTarget<Chapter>? target = resolveChapterContinue(
      groups: chapters,
      preferredGroup: 0,
      activities: <String, ChapterActivityDomain>{
        '1': _read('1', readPages: 10, at: later),
        '2': _read('2', readPages: 10, at: earlier),
      },
    );
    expect(target?.element.uid, '3');
    expect(target?.kind, ContinueKind.next);
  });

  test('returns nothing once the last chapter is finished', () {
    final ContinueTarget<Chapter>? target = resolveChapterContinue(
      groups: chapters,
      preferredGroup: 0,
      activities: <String, ChapterActivityDomain>{
        '3': _read('3', readPages: 10, at: later),
      },
    );
    expect(target, isNull);
  });

  test('follows the group of the last touched chapter', () {
    final List<ChaptersGroup> groups = <ChaptersGroup>[
      ChaptersGroup(title: 'A', elements: <Chapter>[_chapter('a1')]),
      ChaptersGroup(
        title: 'B',
        elements: <Chapter>[_chapter('b1'), _chapter('b2')],
      ),
    ];
    final ContinueTarget<Chapter>? target = resolveChapterContinue(
      groups: groups,
      preferredGroup: 0,
      activities: <String, ChapterActivityDomain>{
        'b1': _read('b1', readPages: 10, at: later),
      },
    );
    expect(target?.groupIndex, 1);
    expect(target?.element.uid, 'b2');
  });

  test('walks episodes in ascending order even when listed newest first', () {
    final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
      AnimeVideoGroup(
        title: 'Dub',
        elements: <AnimeVideo>[
          _episode('e3', 3),
          _episode('e2', 2),
          _episode('e1', 1),
        ],
      ),
    ];
    final ContinueTarget<AnimeVideo>? target = resolveEpisodeContinue(
      groups: groups,
      preferredGroup: 0,
      activities: <String, AnimeEpisodeActivityDomain>{
        'e1': _watched('e1', markedWatched: true, at: later),
      },
    );
    expect(target?.element.uid, 'e2');
    expect(target?.kind, ContinueKind.next);
  });

  test('resumes an episode stopped midway', () {
    final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
      AnimeVideoGroup(
        title: 'Dub',
        elements: <AnimeVideo>[_episode('e1', 1), _episode('e2', 2)],
      ),
    ];
    final ContinueTarget<AnimeVideo>? target = resolveEpisodeContinue(
      groups: groups,
      preferredGroup: 0,
      activities: <String, AnimeEpisodeActivityDomain>{
        'e1': _watched('e1', watchedTime: 300, totalTime: 1400, at: later),
      },
    );
    expect(target?.element.uid, 'e1');
    expect(target?.kind, ContinueKind.resume);
  });

  test('treats an episode opened in the web player as watched', () {
    final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
      AnimeVideoGroup(
        title: 'Dub',
        elements: <AnimeVideo>[_episode('e1', 1), _episode('e2', 2)],
      ),
    ];
    final ContinueTarget<AnimeVideo>? target = resolveEpisodeContinue(
      groups: groups,
      preferredGroup: 0,
      activities: <String, AnimeEpisodeActivityDomain>{
        'e1': _watched('e1', at: later),
      },
    );
    expect(target?.element.uid, 'e2');
  });
}
