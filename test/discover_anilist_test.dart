import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/discover/discover_feed_cubit.dart';
import 'package:wakaranai/services/discover/anilist_discover_client.dart';
import 'package:wakaranai/services/discover/discover_models.dart';

Object? _fixture(String name) {
  return jsonDecode(File('test/fixtures/anilist/$name').readAsStringSync());
}

DiscoverMedia _media(int id) => DiscoverMedia(id: id, romajiTitle: 'T$id');

class _FakeClient implements DiscoverClient {
  _FakeClient(this.pages);

  final Map<int, Object> pages;
  final List<int> requested = <int>[];
  bool? lastIncludeAdult;

  @override
  Future<DiscoverMediaPage> fetch(
    DiscoverCategory category, {
    required int page,
    bool includeAdult = false,
  }) async {
    requested.add(page);
    lastIncludeAdult = includeAdult;
    final Object? result = pages[page];
    if (result is DiscoverMediaPage) {
      return result;
    }
    throw result ?? const DiscoverException('missing page');
  }
}

void main() {
  group('parsing recorded AniList pages', () {
    test('this season anime page', () {
      final DiscoverMediaPage page = DiscoverMediaPage.fromResponse(
        _fixture('season_anime_page.json'),
        page: 1,
      );
      expect(page.hasNextPage, isTrue);
      expect(page.page, 1);
      expect(page.media, hasLength(3));

      final DiscoverMedia first = page.media.first;
      expect(first.id, 195539);
      expect(first.isAnime, isTrue);
      expect(first.format, 'ONA');
      expect(first.englishTitle, 'Cyberpunk: Edgerunners 2');
      expect(first.nativeTitle, 'サイバーパンク: エッジランナーズ2');
      expect(first.episodes, 10);
      expect(first.year, 2026);
      expect(first.cover, contains('/cover/large/'));
      expect(first.genres, isNotEmpty);
      expect(first.description, isNot(contains('<br')));

      final DiscoverMedia airing = page.media.last;
      expect(airing.episodes, isNull);
    });

    test('popular light novels page', () {
      final DiscoverMediaPage page = DiscoverMediaPage.fromResponse(
        _fixture('popular_novels_page.json'),
        page: 1,
      );
      final DiscoverMedia novel = page.media.first;
      expect(novel.format, 'NOVEL');
      expect(novel.isAnime, isFalse);
      expect(
          novel.romajiTitle, 'Youkoso Jitsuryoku Shijou Shugi no Kyoushitsu e');
      expect(novel.englishTitle, 'Classroom of the Elite');
      expect(novel.synonyms, contains('Youjitsu'));
      expect(novel.description, contains('Class D'));
      expect(novel.description, isNot(contains('<')));
      expect(novel.description, isNot(contains('\n\n\n')));
    });

    test('errors without data are raised', () {
      expect(
        () => DiscoverMediaPage.fromResponse(<String, Object?>{
          'data': null,
          'errors': <Object?>[
            <String, Object?>{'message': 'Too Many Requests.', 'status': 429},
          ],
        }, page: 1),
        throwsA(isA<DiscoverException>().having(
          (DiscoverException e) => e.message,
          'message',
          'Too Many Requests.',
        )),
      );
    });

    test('items without an id are skipped and blanks become null', () {
      final DiscoverMediaPage page = DiscoverMediaPage.fromResponse(
        <String, Object?>{
          'data': <String, Object?>{
            'Page': <String, Object?>{
              'media': <Object?>[
                <String, Object?>{'title': <String, Object?>{}},
                <String, Object?>{
                  'id': 7,
                  'title': <String, Object?>{'romaji': 'Mono', 'english': ' '},
                  'description': '  ',
                  'startDate': <String, Object?>{'year': 2001},
                },
              ],
            },
          },
        },
        page: 4,
      );
      expect(page.page, 4);
      expect(page.hasNextPage, isFalse);
      final DiscoverMedia media = page.media.single;
      expect(media.englishTitle, isNull);
      expect(media.description, isNull);
      expect(media.year, 2001);
      expect(media.displayTitle, 'Mono');
    });
  });

  group('DiscoverMedia titles', () {
    test('prefers native, then romaji, then english without duplicates', () {
      const DiscoverMedia media = DiscoverMedia(
        id: 1,
        nativeTitle: '薬屋のひとりごと',
        romajiTitle: 'Kusuriya no Hitorigoto',
        englishTitle: 'kusuriya no hitorigoto',
      );
      expect(media.searchTitles, <String>[
        '薬屋のひとりごと',
        'Kusuriya no Hitorigoto',
      ]);
      expect(media.bestSearchTitle, '薬屋のひとりごと');
      expect(media.displayTitle, 'kusuriya no hitorigoto');
    });

    test('falls back to whatever title exists', () {
      expect(
        const DiscoverMedia(id: 2, englishTitle: 'Only English')
            .bestSearchTitle,
        'Only English',
      );
      expect(const DiscoverMedia(id: 3).bestSearchTitle, '');
    });

    test('cleans html out of descriptions', () {
      expect(
        DiscoverMedia.cleanDescription(
          'A <i>tale</i> &amp; more.<br><br>\n<br>(Source: X&#039;s)',
        ),
        'A tale & more.\n\n(Source: X\'s)',
      );
    });
  });

  group('AniList discover query', () {
    test('seasons follow the anime calendar', () {
      final DiscoverSeason december = DiscoverSeason.of(DateTime(2026, 12, 5));
      expect(december.apiName, 'WINTER');
      expect(december.year, 2027);
      expect(DiscoverSeason.of(DateTime(2026, 2, 1)).apiName, 'WINTER');
      expect(DiscoverSeason.of(DateTime(2026, 4, 1)).apiName, 'SPRING');
      expect(DiscoverSeason.of(DateTime(2026, 7, 1)).apiName, 'SUMMER');
      final DiscoverSeason fall = DiscoverSeason.of(DateTime(2026, 11, 8));
      expect(fall.apiName, 'FALL');
      expect(fall.year, 2026);
    });

    test('variables per category', () {
      final DateTime now = DateTime(2026, 11, 8);
      expect(
        AniListDiscoverClient.variables(
          DiscoverCategory.seasonAnime,
          page: 2,
          now: now,
        ),
        <String, Object?>{
          'page': 2,
          'perPage': AniListDiscoverClient.perPage,
          'isAdult': false,
          'type': 'ANIME',
          'season': 'FALL',
          'seasonYear': 2026,
          'sort': <String>['POPULARITY_DESC'],
        },
      );
      final Map<String, Object?> manga = AniListDiscoverClient.variables(
        DiscoverCategory.trendingManga,
        page: 1,
        now: now,
        includeAdult: true,
      );
      expect(manga.containsKey('isAdult'), isFalse);
      expect(manga['type'], 'MANGA');
      expect(manga['formatNot'], 'NOVEL');
      final Map<String, Object?> novels = AniListDiscoverClient.variables(
        DiscoverCategory.popularNovels,
        page: 1,
        now: now,
      );
      expect(novels['format'], 'NOVEL');
      expect(novels['sort'], <String>['POPULARITY_DESC']);
    });
  });

  group('DiscoverFeedCubit', () {
    test('pages forward and drops duplicates between pages', () async {
      final _FakeClient client = _FakeClient(<int, Object>{
        1: DiscoverMediaPage(
          media: <DiscoverMedia>[_media(1), _media(2)],
          page: 1,
          hasNextPage: true,
        ),
        2: DiscoverMediaPage(
          media: <DiscoverMedia>[_media(2), _media(3)],
          page: 2,
          hasNextPage: false,
        ),
      });
      final DiscoverFeedCubit cubit = DiscoverFeedCubit(
        client: client,
        category: DiscoverCategory.trendingAnime,
        includeAdult: true,
      );
      addTearDown(cubit.close);

      await cubit.start();
      await cubit.start();
      expect(client.requested, <int>[1]);
      expect(client.lastIncludeAdult, isTrue);

      await cubit.loadMore();
      expect(
        cubit.state.items.map((DiscoverMedia media) => media.id),
        <int>[1, 2, 3],
      );
      expect(cubit.state.canLoadMore, isFalse);
      await cubit.loadMore();
      expect(client.requested, <int>[1, 2]);
    });

    test('a failed first page can be retried', () async {
      final _FakeClient client = _FakeClient(<int, Object>{
        1: const DiscoverException('offline'),
      });
      final DiscoverFeedCubit cubit = DiscoverFeedCubit(
        client: client,
        category: DiscoverCategory.popularNovels,
      );
      addTearDown(cubit.close);

      await cubit.start();
      expect(cubit.state.error, isA<DiscoverException>());
      expect(cubit.state.items, isEmpty);

      client.pages[1] = DiscoverMediaPage(
        media: <DiscoverMedia>[_media(9)],
        page: 1,
        hasNextPage: true,
      );
      await cubit.load();
      expect(cubit.state.error, isNull);
      expect(cubit.state.items.single.id, 9);
    });

    test('a failed next page keeps items and waits for a retry', () async {
      final _FakeClient client = _FakeClient(<int, Object>{
        1: DiscoverMediaPage(
          media: <DiscoverMedia>[_media(1)],
          page: 1,
          hasNextPage: true,
        ),
        2: const DiscoverException('offline'),
      });
      final DiscoverFeedCubit cubit = DiscoverFeedCubit(
        client: client,
        category: DiscoverCategory.seasonAnime,
      );
      addTearDown(cubit.close);

      await cubit.start();
      await cubit.loadMore();
      expect(cubit.state.loadMoreFailed, isTrue);
      expect(cubit.state.items, hasLength(1));
      await cubit.loadMore();
      expect(client.requested, <int>[1, 2]);

      client.pages[2] = DiscoverMediaPage(
        media: <DiscoverMedia>[_media(2)],
        page: 2,
        hasNextPage: true,
      );
      await cubit.retryMore();
      expect(cubit.state.items, hasLength(2));
      expect(cubit.state.loadMoreFailed, isFalse);
    });
  });
}
