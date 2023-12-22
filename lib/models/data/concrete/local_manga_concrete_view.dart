
import 'package:wakaranai/models/data/concrete/local_cocnrete_view.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_chapters_group.dart';
import 'package:wakascript/models/concrete_view.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_status.dart';

class LocalMangaConcreteView
    extends LocalConcreteView<LocalChaptersGroup, ChaptersGroup> {
  final String cover;
  final List<String> alternativeTitles;
  final List<String> tags;
  final MangaStatus status;

  LocalMangaConcreteView(
      {required String uid,
      required int? id,
      required List<LocalChaptersGroup> groups,
      required String title,
      required String description,
      required this.cover,
      required this.alternativeTitles,
      required this.tags,
      required this.status})
      : super(
            uid: uid,
            id: id,
            groups: groups.cast(),
            title: title,
            description: description);

  @override
  callFunction(String name, {List? ordinalArguments}) {}

  @override
  getField(String name) {}

  @override
  void setField(String name, value) {}

  @override
  ConcreteView<ChaptersGroup> toRemote() {
    return MangaConcreteView(
        uid: uid,
        cover: cover,
        title: title,
        alternativeTitles: alternativeTitles,
        description: description,
        tags: tags,
        status: status,
        groups:
            groups.map((e) => (e as LocalChaptersGroup).toRemote()).toList());
  }
}
