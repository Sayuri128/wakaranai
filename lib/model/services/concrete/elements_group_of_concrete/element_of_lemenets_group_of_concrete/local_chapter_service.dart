import 'dart:convert';

import 'package:wakaranai/model/services/concrete/elements_group_of_concrete/element_of_lemenets_group_of_concrete/manga/local_pages_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_manga_chapter.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapter/chapter.dart';

class LocalChapterService {
  static final LocalChapterService instance = LocalChapterService();

  Future<LocalChapter> get(int id) async {
    final res = await (waka.select(waka.localChapterTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalChapter with id $id does not exist");
    }

    return LocalChapter.fromDrift(res.first);
  }

  Future<List<DriftLocalChapter>> getDriftGroupChapters(int groupId) async {
    final res = await (waka.select(waka.localChapterTable)
          ..where((tbl) => tbl.chaptersGroupId.equals(groupId)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalChapter with groupId $groupId does not exist");
    }

    return res;
  }

  Future<List<LocalChapter>> getGroupChapters(int groupId) async {
    return (await getDriftGroupChapters(groupId))
        .map((e) => LocalChapter.fromDrift(e))
        .toList();
  }

  Future<void> delete(int groupId) async {
    await waka.transaction(() async {
      final chapters = (await (waka.selectOnly(waka.localChapterTable)
                ..addColumns([
                  waka.localChapterTable.id,
                  waka.localChapterTable.chaptersGroupId
                ])
                ..where(waka.localChapterTable.chaptersGroupId.equals(groupId)))
              .get())
          .map((e) => e.read(waka.localChapterTable.id));

      await Future.wait(chapters
          .map((e) async => await LocalPagesService.instance.delete(e!)));

      await (waka.delete(waka.localChapterTable)
            ..where((tbl) => tbl.chaptersGroupId.equals(groupId)))
          .go();
    });
  }

  Future<int> add(Chapter chapter, int chaptersGroupId) async {
    return waka.into(waka.localChapterTable).insert(
        LocalChapterTableCompanion.insert(
            uid: chapter.uid,
            title: chapter.title,
            data: jsonEncode(chapter.data),
            chaptersGroupId: chaptersGroupId));
  }
}
