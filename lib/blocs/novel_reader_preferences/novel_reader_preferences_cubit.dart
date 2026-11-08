import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/shared_pref/novel_reader_preferences.dart';

class NovelReaderPreferencesCubit extends Cubit<NovelReaderPreferences> {
  NovelReaderPreferencesCubit({NovelReaderPreferencesStore? store})
      : _store = store ?? NovelReaderPreferencesStore(),
        super(const NovelReaderPreferences());

  final NovelReaderPreferencesStore _store;

  Future<void> init() async {
    final NovelReaderPreferences stored = await _store.read();
    if (!isClosed) {
      emit(stored);
    }
  }

  Future<void> changeFontSize(int steps) => _update(state.copyWith(
        fontSize: state.fontSize + steps * NovelReaderPreferences.fontSizeStep,
      ));

  Future<void> changeLineHeight(int steps) => _update(state.copyWith(
        lineHeight:
            state.lineHeight + steps * NovelReaderPreferences.lineHeightStep,
      ));

  Future<void> changeMargin(int steps) => _update(state.copyWith(
        horizontalMargin:
            state.horizontalMargin + steps * NovelReaderPreferences.marginStep,
      ));

  Future<void> setFont(NovelReaderFont value) =>
      _update(state.copyWith(font: value));

  Future<void> setBackground(NovelReaderBackground value) =>
      _update(state.copyWith(background: value));

  Future<void> setJustify(bool value) =>
      _update(state.copyWith(justify: value));

  Future<void> setKeepScreenOn(bool value) =>
      _update(state.copyWith(keepScreenOn: value));

  Future<void> _update(NovelReaderPreferences value) async {
    if (value == state) {
      return;
    }
    emit(value);
    await _store.write(value);
  }
}
