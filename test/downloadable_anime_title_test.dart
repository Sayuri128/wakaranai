import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_status.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/episode_title_downloader.dart';

AnimeVideo _episode(String uid, int number) => AnimeVideo(
      type: AnimeVideoType.IFRAME,
      uid: uid,
      src: 'https://player.test/$uid',
      title: 'Episode $number',
      timestamp: null,
      data: const <String, dynamic>{},
      number: number.toDouble(),
    );

AnimeVideoGroup _ascendingGroup(String name, String prefix, int count) =>
    AnimeVideoGroup(
      title: name,
      elements: <AnimeVideo>[
        for (int number = 1; number <= count; number++)
          _episode('$prefix$number', number),
      ],
    );

AnimeVideoGroup _descendingGroup(String name, String prefix, int count) =>
    AnimeVideoGroup(
      title: name,
      elements: <AnimeVideo>[
        for (int number = count; number >= 1; number--)
          _episode('$prefix$number', number),
      ],
    );

DownloadableAnimeTitle _title({
  required List<AnimeVideoGroup> groups,
  Set<String> watched = const <String>{},
  Set<String> downloaded = const <String>{},
}) {
  return DownloadableAnimeTitle(
    extensionUid: 'ext',
    concrete: AnimeConcreteView(
      uid: 'anime',
      cover: '',
      title: 'Anime',
      alternativeTitles: const <String>[],
      description: '',
      tags: const <String>[],
      status: AnimeStatus.ONGOING,
      groups: groups,
    ),
    concreteId: 1,
    watchedUids: watched,
    downloadedUids: downloaded,
  );
}

List<String> _uids(List<AnimeVideo> episodes) =>
    episodes.map((AnimeVideo episode) => episode.uid).toList();

void main() {
  test('a group listed newest first is downloaded in watch order', () {
    final DownloadableAnimeTitle title = _title(
      groups: <AnimeVideoGroup>[_descendingGroup('Dub · Player', 'e', 6)],
    );

    expect(
      _uids(title.select(<int>{0}, ChapterDownloadAmount.nextFive)),
      <String>['e1', 'e2', 'e3', 'e4', 'e5'],
    );
  });

  test('next episodes continue after the furthest watched one', () {
    final DownloadableAnimeTitle title = _title(
      groups: <AnimeVideoGroup>[_descendingGroup('Dub · Player', 'e', 12)],
      watched: <String>{'e1', 'e4'},
      downloaded: <String>{'e6'},
    );

    expect(
      _uids(title.select(<int>{0}, ChapterDownloadAmount.nextFive)),
      <String>['e5', 'e7', 'e8', 'e9'],
    );
    expect(
      _uids(title.select(<int>{0}, ChapterDownloadAmount.next)),
      <String>['e5'],
    );
  });

  test('unwatched skips watched and downloaded episodes', () {
    final DownloadableAnimeTitle title = _title(
      groups: <AnimeVideoGroup>[_ascendingGroup('Dub · Player', 'e', 5)],
      watched: <String>{'e1', 'e3'},
      downloaded: <String>{'e4'},
    );

    expect(
      _uids(title.select(<int>{0}, ChapterDownloadAmount.unread)),
      <String>['e2', 'e5'],
    );
    expect(
      _uids(title.select(<int>{0}, ChapterDownloadAmount.all)),
      <String>['e1', 'e2', 'e3', 'e5'],
    );
  });

  test('only the chosen dub and player groups are downloaded', () {
    final DownloadableAnimeTitle title = _title(
      groups: <AnimeVideoGroup>[
        _ascendingGroup('Dub A · Player 1', 'a', 3),
        _descendingGroup('Dub B · Player 1', 'b', 3),
        _ascendingGroup('Dub C · Player 2', 'c', 3),
      ],
      watched: <String>{'b1'},
    );

    expect(
      _uids(title.select(<int>{1, 2}, ChapterDownloadAmount.next)),
      <String>['b2', 'c1'],
    );
  });

  test('an episode shared by two groups is queued once', () {
    final AnimeVideo shared = _episode('shared', 2);
    final DownloadableAnimeTitle title = _title(
      groups: <AnimeVideoGroup>[
        AnimeVideoGroup(
          title: 'Dub A',
          elements: <AnimeVideo>[_episode('a1', 1), shared],
        ),
        AnimeVideoGroup(
          title: 'Dub B',
          elements: <AnimeVideo>[shared, _episode('b3', 3)],
        ),
      ],
    );

    expect(
      _uids(title.select(<int>{0, 1}, ChapterDownloadAmount.all)),
      <String>['a1', 'shared', 'b3'],
    );
  });

  test('selected episodes are queued in watch order', () {
    final AnimeVideoGroup group = _descendingGroup('Dub', 'e', 5);

    expect(
      _uids(selectedEpisodesInWatchOrder(
        group.elements,
        <String>['e4', 'e1', 'e3'],
      )),
      <String>['e1', 'e3', 'e4'],
    );
  });

  test('selection ignores uids that are not in the group', () {
    final AnimeVideoGroup group = _ascendingGroup('Dub', 'e', 3);

    expect(
      _uids(selectedEpisodesInWatchOrder(
        group.elements,
        <String>['e2', 'missing'],
      )),
      <String>['e2'],
    );
  });
}
