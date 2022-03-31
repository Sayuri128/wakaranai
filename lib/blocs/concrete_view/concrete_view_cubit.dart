import 'package:bloc/bloc.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';
import 'package:wakaranai_json_runtime/models/concrete_view/concrete_view.dart';

part 'concrete_view_state.dart';

class ConcreteViewCubit extends Cubit<ConcreteViewState> {
  ConcreteViewCubit(initialState) : super(initialState);

  void getConcrete(String uid) async {
    emit(ConcreteViewInitialized(
        concreteView: await state.apiClient.makeGetConcreteRequest(uid: uid),
        apiClient: state.apiClient));
  }
}
