import 'package:wakaranai/models/data/concrete/local_cocnrete_view.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_anime_videos.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:wakascript/models/concrete_view.dart';

class LocalAnimeConcreteView
    extends LocalConcreteView<LocalAnimeVideoGroup, AnimeVideoGroup> {
  final String cover;
  final List<String> alternativeTitles;
  final List<String> tags;
  final AnimeStatus status;

  LocalAnimeConcreteView(
      {required int? id,
      required String uid,
      required List<LocalAnimeVideoGroup> groups,
      required String title,
      required String description,
      required this.cover,
      required this.alternativeTitles,
      required this.tags,
      required this.status})
      : super(
            id: id,
            uid: uid,
            groups: groups,
            title: title,
            description: description);

  @override
  callFunction(String name, {List? ordinalArguments}) {}

  @override
  getField(String name) {}

  @override
  void setField(String name, value) {}

  @override
  ConcreteView<AnimeVideoGroup> toRemote() {
    return AnimeConcreteView(
        uid: uid,
        cover: cover,
        title: title,
        alternativeTitles: alternativeTitles,
        description: description,
        tags: tags,
        groups:
            groups.map((e) => (e as LocalAnimeVideoGroup).toRemote()).toList(),
        status: status);
  }
}
