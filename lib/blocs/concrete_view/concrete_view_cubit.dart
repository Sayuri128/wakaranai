import 'package:bloc/bloc.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/concrete_view.dart';
import 'package:wakascript/models/gallery_view.dart';
import 'package:wakascript/models/group_of_concrete.dart';

part 'concrete_view_state.dart';

enum ConcreteViewOrder { DEFAULT, DEFAULT_REVERSE }

class ConcreteViewCubit<
    T extends ApiClient,
    C extends ConcreteView<GroupOfConcrete<dynamic>>,
    G extends GalleryView> extends Cubit<ConcreteViewState<T, C, G>> {
  ConcreteViewCubit(initialState) : super(initialState);

  Future<void> getConcrete(String uid, G galleryView) async {
    final ConcreteView<GroupOfConcrete<dynamic>> concreteView =
        await (state.apiClient as dynamic) // TODO: avoid dynamic
            .getConcrete(uid: uid, data: galleryView.data);
    emit(ConcreteViewInitialized<T, C, G>(
        concreteView: concreteView as dynamic,
        galleryView: galleryView,
        apiClient: state.apiClient,
        groupIndex: concreteView.groups.isNotEmpty ? 0 : -1,
        order: ConcreteViewOrder.DEFAULT));
  }

  void changeGroup(int index) async {
    if (state is ConcreteViewInitialized<T, C, G>) {
      emit((state as ConcreteViewInitialized<T, C, G>)
          .copyWith(groupIndex: index));
    }
  }

  void changeOrder(ConcreteViewOrder order) {
    if (state is ConcreteViewInitialized<T, C, G>) {
      final state = this.state as ConcreteViewInitialized<T, C, G>;

      final groups = state.concreteView.groups;

      final List<GroupOfConcrete> copyGroups = List.of(groups);
      groups.clear();
      for (GroupOfConcrete element in copyGroups) {
        final reversed = List.of(element.elements.reversed);
        element.elements.clear();
        reversed.forEach(element.elements.add);
        groups.add(element);
      }

      emit(state.copyWith(order: order));
    }
  }
}
