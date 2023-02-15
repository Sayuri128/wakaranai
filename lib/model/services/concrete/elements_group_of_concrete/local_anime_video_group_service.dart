import 'dart:convert';

import 'package:wakaranai/model/services/concrete/elements_group_of_concrete/element_of_lemenets_group_of_concrete/local_anime_video_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_anime_videos.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';

class LocalAnimeVideoGroupService {
  static final LocalAnimeVideoGroupService instance =
      LocalAnimeVideoGroupService();

  Future<List<LocalAnimeVideoGroup>> getConcreteGroups(int id) async {
    return Future.wait((await (waka.select(waka.localAnimeVideosGroupTable)
              ..where((tbl) => tbl.animeConcreteId.equals(id)))
            .get())
        .map((e) async => LocalAnimeVideoGroup.fromDrift(e,
            await LocalAnimeVideoService.instance.getDriftGroupVideos(e.id))));
  }

  Future<void> delete(int concreteId) async {
    await waka.transaction(() async {
      final groups = (await (waka.selectOnly(waka.localAnimeVideosGroupTable)
                ..addColumns([
                  waka.localAnimeVideosGroupTable.animeConcreteId,
                  waka.localAnimeVideosGroupTable.id
                ])
                ..where(waka.localAnimeVideosGroupTable.animeConcreteId
                    .equals(concreteId)))
              .get())
          .map((e) => e.read(waka.localAnimeVideosGroupTable.id));
      await Future.wait(groups
          .map((e) async => await LocalAnimeVideoService.instance.delete(e!)));

      await (waka.delete(waka.localAnimeVideosGroupTable)
            ..where((tbl) => tbl.animeConcreteId.equals(concreteId)))
          .go();
    });
  }

  Future<int> add(AnimeVideoGroup group, int concreteId) async {
    return waka.transaction(() async {
      final groupId = await waka.into(waka.localAnimeVideosGroupTable).insert(
          LocalAnimeVideosGroupTableCompanion.insert(
              title: group.title,
              data: jsonEncode(group.data),
              animeConcreteId: concreteId));

      await Future.wait(group.elements.map(
          (e) async => await LocalAnimeVideoService.instance.add(e, groupId)));

      return groupId;
    });
  }
}
