import 'package:bloc/bloc.dart';

part 'multi_select_state.dart';

class MultiSelectCubit extends Cubit<MultiSelectState> {
  MultiSelectCubit() : super(const MultiSelectState(items: []));

  void selectItem(String index) {
    final newList = List.of(state.items);
    if (!newList.contains(index)) {
      newList.add(index);
    }
    emit(MultiSelectState(items: newList));
  }

  void unselectItem(String key) {
    final newList = List.of(state.items);
    newList.remove(key);
    emit(MultiSelectState(items: newList));
  }

  void selectMultiple(List<String> keys) {
    final newList = List.of(state.items);
    for (String element in keys) {
      if (!newList.contains(element)) {
        newList.add(element);
      }
    }
    emit(MultiSelectState(items: newList));
  }

  void unselectMultiple(List<String> keys) {
    final newList = List.of(state.items);
    for (String element in keys) {
      newList.remove(element);
    }
    emit(MultiSelectState(items: newList));
  }

  void clear() {
    emit(const MultiSelectState(items: []));
  }
}
