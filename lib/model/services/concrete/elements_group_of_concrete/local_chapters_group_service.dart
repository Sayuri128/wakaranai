import 'dart:convert';

import 'package:wakaranai/model/services/concrete/elements_group_of_concrete/element_of_lemenets_group_of_concrete/local_chapter_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_chapters_group.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';

class LocalChaptersGroupService {
  static final LocalChaptersGroupService instance = LocalChaptersGroupService();

  Future<LocalChaptersGroup> get(int id) async {
    final res = await (waka.select(waka.localChaptersGroupTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalChaptersGroup with id $id does not exist");
    }

    return LocalChaptersGroup.fromDrift(res.first,
        await LocalChapterService.instance.getDriftGroupChapters(res.first.id));
  }

  Future<List<DriftLocalChaptersGroup>> getDriftConcreteGroups(
      int concreteId) async {
    return await (waka.select(waka.localChaptersGroupTable)
          ..where((tbl) => tbl.mangaConcreteId.equals(concreteId)))
        .get();
  }

  Future<List<LocalChaptersGroup>> getConcreteGroups(int concreteId) async {
    return Future.wait((await getDriftConcreteGroups(concreteId)).map(
        (e) async => LocalChaptersGroup.fromDrift(e,
            await LocalChapterService.instance.getDriftGroupChapters(e.id))));
  }

  Future<void> delete(int concreteId) async {
    await waka.transaction(() async {
      final groups = (await (waka.selectOnly(waka.localChaptersGroupTable)
                ..addColumns([
                  waka.localChaptersGroupTable.mangaConcreteId,
                  waka.localChaptersGroupTable.id
                ])
                ..where(waka.localChaptersGroupTable.mangaConcreteId
                    .equals(concreteId)))
              .get())
          .map((e) => e.read(waka.localChaptersGroupTable.id));
      await Future.wait(groups
          .map((e) async => await LocalChapterService.instance.delete(e!)));

      await (waka.delete(waka.localChaptersGroupTable)
            ..where((tbl) => tbl.mangaConcreteId.equals(concreteId)))
          .go();
    });
  }

  Future<int> add(ChaptersGroup chaptersGroup, int mangaConcreteId) async {
    return await waka.transaction(() async {
      final chaptersGroupId = await waka
          .into(waka.localChaptersGroupTable)
          .insert(LocalChaptersGroupTableCompanion.insert(
              title: chaptersGroup.title,
              data: jsonEncode(chaptersGroup.data),
              mangaConcreteId: mangaConcreteId));

      await Future.wait(chaptersGroup.elements.map((e) async =>
          await LocalChapterService.instance.add(e, chaptersGroupId)));

      return chaptersGroupId;
    });
  }
}
