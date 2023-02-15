import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_anime_video.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video/anime_video.dart';

class LocalAnimeVideoService {
  static final LocalAnimeVideoService instance = LocalAnimeVideoService();

  Future<List<DriftLocalAnimeVideo>> getDriftGroupVideos(int groupId) async {
    return (await (waka.select(waka.localAnimeVideoTable)
          ..where((tbl) => tbl.animeVideosGroupId.equals(groupId)))
        .get());
  }

  Future<List<LocalAnimeVideo>> getGroupVideos(int groupId) async {
    return (await getDriftGroupVideos(groupId))
        .map((e) => LocalAnimeVideo.fromDrift(e))
        .toList();
  }

  Future<void> delete(int groupId) async {
    await (waka.delete(waka.localAnimeVideoTable)
          ..where((tbl) => tbl.animeVideosGroupId.equals(groupId)))
        .go();
  }

  Future<int> add(AnimeVideo video, int groupId) async {
    return await waka.into(waka.localAnimeVideoTable).insert(
        LocalAnimeVideoTableCompanion.insert(
            uid: video.uid,
            title: video.title,
            data: jsonEncode(video.data),
            animeVideosGroupId: groupId,
            src: video.src,
            type: video.type));
  }
}
