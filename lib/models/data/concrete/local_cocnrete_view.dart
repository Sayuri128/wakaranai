import 'package:wakaranai/models/data/concrete/local_elements_group_of_concrete/local_elements_group_of_concrete.dart';
import 'package:wakascript/models/concrete_view.dart';
import 'package:wakascript/models/elements_group_of_concrete.dart';

abstract class LocalConcreteView<C extends LocalElementsGroupOfConcrete,
    G extends ElementsGroupOfConcrete> extends ConcreteView {
  final int? id;

  const LocalConcreteView({
    required this.id,
    required String uid,
    required List<C> groups,
    required String title,
    required String description,
  }) : super(uid: uid, groups: groups, title: title, description: description);

  ConcreteView<G> toRemote();
}
