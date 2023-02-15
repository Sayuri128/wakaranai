import 'package:wakascript/models/element_of_elements_group_of_concrete.dart';

abstract class LocalElementOfElementsGroupOfConcrete<T> extends ElementOfElementsGroupOfConcrete {
  final int? id;

  LocalElementOfElementsGroupOfConcrete(
      {required this.id,
      required String uid,
      required String title,
      required Map<String, dynamic> data})
      : super(uid: uid, title: title, data: data);

  T toRemote();

}
