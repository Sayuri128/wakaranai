import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_anime_video.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_elements_group_of_concrete.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';

class LocalAnimeVideoGroup
    extends LocalElementsGroupOfConcrete<LocalAnimeVideo, AnimeVideoGroup> {
  LocalAnimeVideoGroup(
      {required int? id,
      required String title,
      required List<LocalAnimeVideo> elements,
      required Map<String, dynamic> data})
      : super(id: id, elements: elements, data: data, title: title);

  @override
  AnimeVideoGroup toRemote() {
    return AnimeVideoGroup(
        title: title,
        elements: elements
            .map((e) => (e as LocalAnimeVideo).toRemote())
            .toList()
            .cast(),
        data: data);
  }

  factory LocalAnimeVideoGroup.fromDrift(
          DriftLocalAnimeVideosGroup drift, List<DriftLocalAnimeVideo> driftVideos) =>
      LocalAnimeVideoGroup(
          id: drift.id,
          title: drift.title,
          elements:
              driftVideos.map((e) => LocalAnimeVideo.fromDrift(e)).toList(),
          data: jsonDecode(drift.data));
}
