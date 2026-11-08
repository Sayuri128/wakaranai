import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/shared_pref/reader_preferences.dart';
import 'package:wakaranai/services/incognito/incognito_mode.dart';

class ReaderPreferencesCubit extends Cubit<ReaderPreferences> {
  ReaderPreferencesCubit({ReaderPreferencesStore? store})
      : _store = store ?? ReaderPreferencesStore(),
        super(const ReaderPreferences());

  final ReaderPreferencesStore _store;

  Future<void> init() async {
    final ReaderPreferences stored = await _store.read();
    IncognitoMode.active = stored.incognito;
    if (!isClosed) {
      emit(stored);
    }
  }

  Future<void> setVolumeKeys(bool value) =>
      _update(state.copyWith(volumeKeys: value));

  Future<void> setInvertVolumeKeys(bool value) =>
      _update(state.copyWith(invertVolumeKeys: value));

  Future<void> setPageFit(ReaderPageFit value) =>
      _update(state.copyWith(pageFit: value));

  Future<void> setBackground(ReaderBackground value) =>
      _update(state.copyWith(background: value));

  Future<void> setCropBorders(bool value) =>
      _update(state.copyWith(cropBorders: value));

  Future<void> setDoublePageSpread(bool value) =>
      _update(state.copyWith(doublePageSpread: value));

  Future<void> setIncognito(bool value) =>
      _update(state.copyWith(incognito: value));

  Future<void> _update(ReaderPreferences value) async {
    if (value == state) {
      return;
    }
    IncognitoMode.active = value.incognito;
    emit(value);
    await _store.write(value);
  }
}
