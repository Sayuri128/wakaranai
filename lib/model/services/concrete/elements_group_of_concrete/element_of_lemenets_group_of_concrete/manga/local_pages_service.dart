import 'package:wakaranai/model/services/concrete/elements_group_of_concrete/element_of_lemenets_group_of_concrete/manga/local_page_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapter/pages/pages.dart';

class LocalPagesService {
  static final LocalPagesService instance = LocalPagesService();

  Future<DriftLocalPages> getDriftByChapterId(int chapterId) async {
    final res = await (waka.select(waka.localPagesTable)
          ..where((tbl) => tbl.chapterId.equals(chapterId)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalPages with chapterId $chapterId does not exist");
    }

    return res.first;
  }

  Future<int> add(Pages pages, int chapterId) async {
    return waka.transaction(() async {
      final pagesId = await waka.into(waka.localPagesTable).insert(
          LocalPagesTableCompanion.insert(
              chapterUid: pages.chapterUid, chapterId: chapterId));

      await Future.wait(pages.value
          .map((e) async => await LocalPageService.instance.add(e, pagesId)));

      return pagesId;
    });
  }

  Future<void> delete(int chapterId) async {
    await waka.transaction(() async {
      final id = await (waka.selectOnly(waka.localChapterTable)
            ..addColumns([
              waka.localChapterTable.id,
              waka.localChapterTable.chaptersGroupId
            ])
            ..where(waka.localChapterTable.chaptersGroupId.equals(chapterId)))
          .get();

      if (id.isNotEmpty) {
        await LocalPageService.instance
            .delete(id.first.read(waka.localChapterTable.id)!);
      }
    });
  }
}
