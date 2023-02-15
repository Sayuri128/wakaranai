import 'package:drift/drift.dart';
import 'package:wakaranai/models/data/gallery/local_gallery_view.dart';

abstract class LocalGalleryViewService<T extends LocalGalleryView> {
  final SimpleSelectStatement Function() select;
  final DeleteStatement Function() del;
  final InsertStatement Function() insert;
  final GeneratedColumn<int> idCol;
  final GeneratedColumn<String> uidCol;
  final dynamic Function(T element) buildInsert;
  final T Function(dynamic element) fromDrift;

  LocalGalleryViewService(
      {required this.idCol,
      required this.uidCol,
      required this.select,
      required this.del,
      required this.insert,
      required this.buildInsert,
      required this.fromDrift});


  Future<T> get(int id) async {
    final res = await (select()..where((tbl) => idCol.equals(id))).get();
    if (res.isEmpty) {
      throw Exception("Local magna gallery view with id: $id not found");
    }
    return fromDrift(res.first);
  }

  Future<T> getByUid(String uid) async {
    final res = await (select()..where((tbl) => uidCol.equals(uid))).get();
    if (res.isEmpty) {
      throw Exception("Local magna gallery view with uid: $uid not found");
    }
    return fromDrift(res.first);
  }

  Future<void> delete(int id) async {
    await (del()..where((tbl) => idCol.equals(id))).go();
  }

  Future<int> add(T element) async {
    return insert().insert(buildInsert(element));
  }
}
