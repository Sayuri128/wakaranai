import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';

List<Chapter> _chapters(int count) => List<Chapter>.generate(
  count,
  (int i) => Chapter(uid: 'c$i', title: 'Chapter $i', data: const {}),
);

List<String> _uids(List<Chapter> chapters) =>
    chapters.map((Chapter chapter) => chapter.uid).toList();

List<String> _select(
  ChapterDownloadAmount amount, {
  int total = 12,
  Set<String> read = const <String>{},
  Set<String> downloaded = const <String>{},
}) {
  return _uids(
    chaptersToDownload<Chapter>(
      _chapters(total),
      readUids: read,
      downloadedUids: downloaded,
      amount: amount,
    ),
  );
}

void main() {
  test('next chapters start at the beginning of an unread title', () {
    expect(_select(ChapterDownloadAmount.next), <String>['c0']);
    expect(_select(ChapterDownloadAmount.nextFive), <String>[
      'c0',
      'c1',
      'c2',
      'c3',
      'c4',
    ]);
  });

  test('next chapters continue after the furthest read chapter', () {
    expect(
      _select(ChapterDownloadAmount.nextFive, read: <String>{'c0', 'c3'}),
      <String>['c4', 'c5', 'c6', 'c7', 'c8'],
    );
  });

  test('next chapters only fill in the missing ones of that window', () {
    expect(
      _select(
        ChapterDownloadAmount.nextFive,
        read: <String>{'c1'},
        downloaded: <String>{'c2', 'c4'},
      ),
      <String>['c3', 'c5', 'c6'],
    );
  });

  test('next ten stops at the end of the title', () {
    expect(
      _select(ChapterDownloadAmount.nextTen, read: <String>{'c8'}),
      <String>['c9', 'c10', 'c11'],
    );
    expect(_select(ChapterDownloadAmount.next, read: <String>{'c11'}), isEmpty);
  });

  test('unread skips read and already downloaded chapters', () {
    expect(
      _select(
        ChapterDownloadAmount.unread,
        total: 5,
        read: <String>{'c0', 'c3'},
        downloaded: <String>{'c1'},
      ),
      <String>['c2', 'c4'],
    );
  });

  test('all includes read chapters but never re-downloads', () {
    expect(
      _select(
        ChapterDownloadAmount.all,
        total: 4,
        read: <String>{'c0'},
        downloaded: <String>{'c2'},
      ),
      <String>['c0', 'c1', 'c3'],
    );
  });
}
