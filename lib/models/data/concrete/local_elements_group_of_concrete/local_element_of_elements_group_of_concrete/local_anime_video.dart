import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_element_of_elements_group_of_concrete.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video/anime_view_type.dart';

class LocalAnimeVideo
    extends LocalElementOfElementsGroupOfConcrete<AnimeVideo> {
  final AnimeVideoType type;
  final String src;
  final String? timestamp;

  LocalAnimeVideo({required int? id,
    required String uid,
    required String title,
    required Map<String, dynamic> data,
    this.timestamp,
    required this.src,
    required this.type})
      : super(id: id, uid: uid, title: title, data: data);

  @override
  callFunction(String name, {List? ordinalArguments}) {}

  @override
  getField(String name) {}

  @override
  void setField(String name, value) {}

  @override
  AnimeVideo toRemote() {
    return AnimeVideo(
        type: type,
        uid: uid,
        src: src,
        title: title,
        timestamp: timestamp,
        data: data);
  }

  factory LocalAnimeVideo.fromDrift(DriftLocalAnimeVideo drift) =>
      LocalAnimeVideo(id: drift.id,
          uid: drift.uid,
          title: drift.title,
          data: jsonDecode(drift.data),
          src: drift.src,
          type: drift.type);
}
