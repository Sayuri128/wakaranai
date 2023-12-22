import 'package:wakascript/models/element_of_elements_group_of_concrete.dart';
import 'package:wakascript/models/elements_group_of_concrete.dart';

abstract class LocalElementsGroupOfConcrete<
        T extends ElementOfElementsGroupOfConcrete,
        G extends ElementsGroupOfConcrete<dynamic>>
    extends ElementsGroupOfConcrete {
  final int? id;

  LocalElementsGroupOfConcrete(
      {required this.id,
      required String title,
      required List<T> elements,
      required Map<String, dynamic> data})
      : super(elements: elements, data: data, title: title);

  G toRemote();
}
