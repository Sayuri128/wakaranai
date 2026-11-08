import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/title_downloader.dart';

ChaptersGroup _group(String name, List<String> uids) => ChaptersGroup(
      title: name,
      elements: <Chapter>[
        for (final String uid in uids)
          Chapter(uid: uid, title: uid, data: const <String, dynamic>{}),
      ],
    );

DownloadableTitle _title({
  required List<ChaptersGroup> groups,
  Set<String> read = const <String>{},
  Set<String> downloaded = const <String>{},
}) {
  return DownloadableTitle(
    client: MangaApiClient(code: ''),
    extensionUid: 'ext',
    concrete: MangaConcreteView(
      uid: 'title',
      cover: '',
      title: 'Title',
      alternativeTitles: const <String>[],
      description: '',
      tags: const <String>[],
      status: MangaStatus.ONGOING,
      groups: groups,
    ),
    concreteId: 1,
    readUids: read,
    downloadedUids: downloaded,
  );
}

List<String> _uids(List<Chapter> chapters) =>
    chapters.map((Chapter chapter) => chapter.uid).toList();

void main() {
  final List<ChaptersGroup> teams = <ChaptersGroup>[
    _group('Team A', <String>['a1', 'a2', 'a3']),
    _group('Team B', <String>['b1', 'b2', 'b3']),
    _group('Team C', <String>['c1', 'c2']),
  ];

  test('only the selected groups are downloaded, in group order', () {
    final DownloadableTitle title = _title(groups: teams);

    expect(
      _uids(title.select(<int>{2, 0}, ChapterDownloadAmount.next)),
      <String>['a1', 'c1'],
    );
  });

  test('each group follows its own reading progress', () {
    final DownloadableTitle title = _title(
      groups: teams,
      read: <String>{'a1', 'a2', 'b1'},
    );

    expect(
      _uids(title.select(<int>{0, 1}, ChapterDownloadAmount.nextFive)),
      <String>['a3', 'b2', 'b3'],
    );
  });

  test('a chapter shared by two groups is queued once', () {
    final DownloadableTitle title = _title(
      groups: <ChaptersGroup>[
        _group('Team A', <String>['x1', 'x2']),
        _group('Team B', <String>['x2', 'y3']),
      ],
      downloaded: <String>{'x1'},
    );

    expect(
      _uids(title.select(<int>{0, 1}, ChapterDownloadAmount.all)),
      <String>['x2', 'y3'],
    );
  });
}
