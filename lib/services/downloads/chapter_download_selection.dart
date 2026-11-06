import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';

enum ChapterDownloadAmount { next, nextFive, nextTen, unread, all }

List<T> chaptersToDownload<T extends ElementOfElementsGroupOfConcrete>(
  List<T> chaptersInReadingOrder, {
  required Set<String> readUids,
  required Set<String> downloadedUids,
  required ChapterDownloadAmount amount,
}) {
  final List<T> notDownloaded = chaptersInReadingOrder
      .where((T chapter) => !downloadedUids.contains(chapter.uid))
      .toList();
  switch (amount) {
    case ChapterDownloadAmount.all:
      return notDownloaded;
    case ChapterDownloadAmount.unread:
      return notDownloaded
          .where((T chapter) => !readUids.contains(chapter.uid))
          .toList();
    case ChapterDownloadAmount.next:
      return _nextUnread(chaptersInReadingOrder, readUids, downloadedUids, 1);
    case ChapterDownloadAmount.nextFive:
      return _nextUnread(chaptersInReadingOrder, readUids, downloadedUids, 5);
    case ChapterDownloadAmount.nextTen:
      return _nextUnread(chaptersInReadingOrder, readUids, downloadedUids, 10);
  }
}

List<T> _nextUnread<T extends ElementOfElementsGroupOfConcrete>(
  List<T> chapters,
  Set<String> readUids,
  Set<String> downloadedUids,
  int count,
) {
  int lastReadIndex = -1;
  for (int i = 0; i < chapters.length; i++) {
    if (readUids.contains(chapters[i].uid)) {
      lastReadIndex = i;
    }
  }
  return chapters
      .sublist(lastReadIndex + 1)
      .take(count)
      .where((T chapter) => !downloadedUids.contains(chapter.uid))
      .toList();
}
