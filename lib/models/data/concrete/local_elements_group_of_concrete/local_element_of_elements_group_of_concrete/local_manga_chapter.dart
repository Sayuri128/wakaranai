import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_element_of_elements_group_of_concrete/local_element_of_elements_group_of_concrete.dart';
import 'package:wakascript/models/element_of_elements_group_of_concrete.dart';
import 'package:wakascript/models/manga/manga_concrete_view/chapter/chapter.dart';

class LocalChapter extends LocalElementOfElementsGroupOfConcrete {
  final String? timestamp;

  LocalChapter(
      {required int? id,
      required String uid,
      required String title,
      this.timestamp,
      required Map<String, dynamic> data})
      : super(id: id, uid: uid, title: title, data: data);

  @override
  callFunction(String name, {List? ordinalArguments}) {}

  @override
  getField(String name) {}

  @override
  void setField(String name, value) {}

  @override
  ElementOfElementsGroupOfConcrete toRemote() {
    return Chapter(uid: uid, title: title, data: data);
  }

  factory LocalChapter.fromDrift(DriftLocalChapter drift) => LocalChapter(
      id: drift.id,
      uid: drift.uid,
      title: drift.title,
      data: jsonDecode(drift.data));
}
