import 'package:bloc/bloc.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/concrete_view/concrete_view.dart';

part 'concrete_view_state.dart';

class ConcreteViewCubit extends Cubit<ConcreteViewState> {
  ConcreteViewCubit(initialState) : super(initialState);

  void getConcrete(String uid) async {
    emit(ConcreteViewInitialized(
        concreteView: await state.apiClient.getConcrete(uid: uid),
        apiClient: state.apiClient));
  }
}
