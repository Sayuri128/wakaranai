import 'package:bloc/bloc.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:wakaranai/main.dart';

part 'concrete_view_state.dart';

enum ConcreteViewOrder { DEFAULT, DEFAULT_REVERSE }

class A<G extends ElementsGroupOfConcrete<dynamic>> {}

class ConcreteViewCubit<T extends ApiClient, C extends ConcreteView<dynamic>,
    G extends GalleryView> extends Cubit<ConcreteViewState<T, C, G>> {
  ConcreteViewCubit(super.state);

  Future<C> _getConcrete(String uid, Map<String, dynamic> data) async {
    return await (state.apiClient as dynamic) // TODO: avoid dynamic
        .getConcrete(uid: uid, data: data);
  }

  Future<void> getConcrete(String uid, G galleryView,
      {bool forceRemote = false}) async {
    try {
      final ConcreteView<dynamic> concreteView =
          await _getConcrete(uid, galleryView.data);

      final imageHeaders = await state.apiClient
          .getImageHeaders(uid: uid, data: galleryView.data);

      emit(ConcreteViewInitialized<T, C, G>(
          concreteView: concreteView as dynamic,
          galleryView: galleryView,
          apiClient: state.apiClient,
          groupIndex: concreteView.groups.isNotEmpty ? 0 : -1,
          imageHeaders: imageHeaders,
          order: ConcreteViewOrder.DEFAULT));
    } catch (e, s) {
      logger.e(e);
      logger.e(s);

      emit(
        ConcreteViewError<T, C, G>(
          message: e.toString(),
          apiClient: state.apiClient,
        ),
      );
    }
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

      final List<ElementsGroupOfConcrete> copyGroups = List.from(groups);
      groups.clear();
      for (ElementsGroupOfConcrete element in copyGroups) {
        final reversed = List.of(element.elements.reversed);
        element.elements.clear();
        reversed.forEach(element.elements.add);
        groups.add(element);
      }

      emit(state.copyWith(order: order));
    }
  }
}
