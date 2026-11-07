import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';

AnimeVideo _video(String uid, String title, {double? number, int? season}) {
  return AnimeVideo(
    type: AnimeVideoType.IFRAME,
    uid: uid,
    src: 'https://player.test/$uid',
    title: title,
    timestamp: null,
    data: const <String, dynamic>{},
    number: number,
    season: season,
  );
}

AnimeVideoGroup _group(String title, List<AnimeVideo> episodes) {
  return AnimeVideoGroup(title: title, elements: episodes);
}

EpisodePlaylist _playlistAt(
  List<AnimeVideoGroup> groups,
  String uid, {
  int groupIndex = 0,
}) {
  final AnimeVideo current = groups[groupIndex]
      .elements
      .firstWhere((AnimeVideo video) => video.uid == uid);
  return EpisodePlaylist(
    groups: groups,
    groupIndex: groupIndex,
    current: current,
  );
}

void main() {
  group('episode number parsing', () {
    final Map<String, double?> cases = <String, double?>{
      'Серія 5': 5,
      '5 серія': 5,
      'Episode 5': 5,
      'episode 12': 12,
      'Ep. 5': 5,
      'Ep 7': 7,
      'EP05': 5,
      'Эпизод 5': 5,
      'Серия 5': 5,
      '5-я серия': 5,
      '#5': 5,
      '№ 8': 8,
      'Naruto 24': 24,
      '12': 12,
      'Episode 12.5': 12.5,
      'Серія 12,5': 12.5,
      'S02E07': 7,
      'Серія 3 (FanWoxUA)': 3,
      '1 сезон 4 серія': 4,
      'Фільм': null,
      'Opening': null,
      '': null,
    };
    cases.forEach((String title, double? expected) {
      test('"$title" -> $expected', () {
        expect(parseEpisodeNumber(title), expected);
      });
    });

    test('an explicit number wins over the title', () {
      expect(episodeNumberOf(_video('a', 'Серія 5', number: 6)), 6);
      expect(episodeNumberOf(_video('a', 'Серія 5')), 5);
      expect(episodeNumberOf(_video('a', 'Special')), isNull);
    });
  });

  group('next and previous', () {
    test('ascending numbered episodes', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('1', 'Серія 1'),
          _video('2', 'Серія 2'),
          _video('3', 'Серія 3'),
        ]),
      ];

      final EpisodePlaylist middle = _playlistAt(groups, '2');
      expect(middle.next?.uid, '3');
      expect(middle.previous?.uid, '1');
      expect(_playlistAt(groups, '3').next, isNull);
      expect(_playlistAt(groups, '1').previous, isNull);
    });

    test('newest-first numbered episodes still go forward in numbers', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('3', 'Episode 3'),
          _video('2', 'Episode 2'),
          _video('1', 'Episode 1'),
        ]),
      ];

      final EpisodePlaylist middle = _playlistAt(groups, '2');
      expect(middle.next?.uid, '3');
      expect(middle.previous?.uid, '1');
      expect(_playlistAt(groups, '3').next, isNull);
    });

    test('unnumbered episodes follow the display order', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('a', 'Pilot'),
          _video('b', 'The Return'),
          _video('c', 'Finale'),
        ]),
      ];

      expect(_playlistAt(groups, 'a').next?.uid, 'b');
      expect(_playlistAt(groups, 'b').previous?.uid, 'a');
      expect(_playlistAt(groups, 'c').next, isNull);
    });

    test('an unnumbered episode in a descending list moves up the list', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('3', 'Episode 3'),
          _video('sp', 'Special'),
          _video('2', 'Episode 2'),
          _video('1', 'Episode 1'),
        ]),
      ];

      final EpisodePlaylist special = _playlistAt(groups, 'sp');
      expect(special.next?.uid, '3');
      expect(special.previous?.uid, '2');
    });

    test('gaps jump to the closest number', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('1', 'Серія 1'),
          _video('2', 'Серія 2'),
          _video('5', 'Серія 5'),
          _video('9', 'Серія 9'),
        ]),
      ];

      expect(_playlistAt(groups, '2').next?.uid, '5');
      expect(_playlistAt(groups, '5').next?.uid, '9');
      expect(_playlistAt(groups, '9').previous?.uid, '5');
    });

    test('decimal episodes slot between their neighbours', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('13', 'Episode 13'),
          _video('12', 'Episode 12'),
          _video('12.5', 'Episode 12.5'),
          _video('11', 'Episode 11'),
        ]),
      ];

      expect(_playlistAt(groups, '12').next?.uid, '12.5');
      expect(_playlistAt(groups, '12.5').next?.uid, '13');
      expect(_playlistAt(groups, '12.5').previous?.uid, '12');
    });

    test('repeated numbers fall back to the display order', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('All seasons', <AnimeVideo>[
          _video('s1e1', 'Серія 1'),
          _video('s1e2', 'Серія 2'),
          _video('s2e1', 'Серія 1'),
          _video('s2e2', 'Серія 2'),
        ]),
      ];

      expect(_playlistAt(groups, 's1e2').next?.uid, 's2e1');
    });

    test('seasons order numbers across a combined list', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('All seasons', <AnimeVideo>[
          _video('s2e1', 'Серія 1', number: 1, season: 2),
          _video('s1e2', 'Серія 2', number: 2, season: 1),
          _video('s1e1', 'Серія 1', number: 1, season: 1),
        ]),
      ];

      expect(_playlistAt(groups, 's1e2').next?.uid, 's2e1');
      expect(_playlistAt(groups, 's2e1').previous?.uid, 's1e2');
    });

    test('explicit numbers drive the order when titles have none', () {
      final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
        _group('Dub', <AnimeVideo>[
          _video('c', 'The End', number: 3),
          _video('a', 'The Start', number: 1),
          _video('b', 'The Middle', number: 2),
        ]),
      ];

      expect(_playlistAt(groups, 'a').next?.uid, 'b');
      expect(_playlistAt(groups, 'b').next?.uid, 'c');
    });
  });

  group('same episode in another group', () {
    final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
      _group('FanWoxUA · ASHDI', <AnimeVideo>[
        _video('a1', 'Серія 1'),
        _video('a2', 'Серія 2'),
        _video('a3', 'Серія 3'),
      ]),
      _group('Other · TORTUGA', <AnimeVideo>[
        _video('b3', 'Серія 3'),
        _video('b2', 'Серія 2'),
        _video('b1', 'Серія 1'),
      ]),
      _group('Untitled', <AnimeVideo>[
        _video('c1', 'First'),
        _video('c2', 'Second'),
      ]),
      _group('Empty', <AnimeVideo>[]),
    ];

    test('matches by number regardless of order', () {
      expect(_playlistAt(groups, 'a2').sameEpisodeIn(1)?.uid, 'b2');
      expect(
        _playlistAt(groups, 'b3', groupIndex: 1).sameEpisodeIn(0)?.uid,
        'a3',
      );
    });

    test('falls back to the position from the start', () {
      expect(_playlistAt(groups, 'a2').sameEpisodeIn(2)?.uid, 'c2');
      expect(
        _playlistAt(groups, 'c1', groupIndex: 2).sameEpisodeIn(1)?.uid,
        'b1',
      );
    });

    test('falls back to the first episode when out of range', () {
      expect(_playlistAt(groups, 'a3').sameEpisodeIn(2)?.uid, 'c1');
    });

    test('an empty or unknown group has no match', () {
      expect(_playlistAt(groups, 'a1').sameEpisodeIn(3), isNull);
      expect(_playlistAt(groups, 'a1').sameEpisodeIn(9), isNull);
    });

    test('switching groups moves the playlist', () {
      final EpisodePlaylist switched = _playlistAt(groups, 'a2').switchGroup(1)!;

      expect(switched.groupIndex, 1);
      expect(switched.current.uid, 'b2');
      expect(switched.next?.uid, 'b3');
      expect(switched.group?.title, 'Other · TORTUGA');
    });
  });

  test('the playlist is a snapshot of the groups', () {
    final List<AnimeVideo> episodes = <AnimeVideo>[
      _video('1', 'Серія 1'),
      _video('2', 'Серія 2'),
    ];
    final List<AnimeVideoGroup> groups = <AnimeVideoGroup>[
      _group('Dub', episodes),
    ];
    final EpisodePlaylist playlist = _playlistAt(groups, '1');

    episodes.add(_video('3', 'Серія 3'));
    groups.add(_group('Late', <AnimeVideo>[]));

    expect(playlist.episodes, hasLength(2));
    expect(playlist.groups, hasLength(1));
  });
}
