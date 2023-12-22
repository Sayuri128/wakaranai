import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_manga_chapter.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_elements_group_of_concrete.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';

class LocalChaptersGroup
    extends LocalElementsGroupOfConcrete<LocalChapter, ChaptersGroup> {
  LocalChaptersGroup(
      {required int? id,
      required String title,
      required List<LocalChapter> elements,
      required Map<String, dynamic> data})
      : super(id: id, title: title, elements: elements, data: data);

  @override
  ChaptersGroup toRemote() {
    return ChaptersGroup(
        title: title,
        elements:
            elements.map((e) => (e as LocalChapter).toRemote()).toList().cast(),
        data: data);
  }

  factory LocalChaptersGroup.fromDrift(DriftLocalChaptersGroup drift,
          List<DriftLocalChapter> driftChapters) =>
      LocalChaptersGroup(
          id: drift.id,
          title: drift.title,
          elements:
              driftChapters.map((e) => LocalChapter.fromDrift(e)).toList(),
          data: jsonDecode(drift.data));
}
