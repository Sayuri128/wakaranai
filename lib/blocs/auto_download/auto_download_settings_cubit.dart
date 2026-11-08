import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';

class AutoDownloadSettingsCubit extends Cubit<AutoDownloadSettings> {
  AutoDownloadSettingsCubit({AutoDownloadPreferences? preferences})
      : _preferences = preferences ?? AutoDownloadPreferences(),
        super(const AutoDownloadSettings());

  final AutoDownloadPreferences _preferences;

  Future<void> load() async {
    final AutoDownloadSettings stored = await _preferences.read(reload: true);
    if (!isClosed) {
      emit(stored);
    }
  }

  void setEnabled(bool enabled) {
    _update(state.copyWith(enabled: enabled));
  }

  void setScope(AutoDownloadScope scope) {
    _update(state.copyWith(scope: scope));
  }

  void toggleCategory(int categoryId) {
    final Set<int> categoryIds = Set<int>.of(state.categoryIds);
    if (!categoryIds.remove(categoryId)) {
      categoryIds.add(categoryId);
    }
    _update(state.copyWith(categoryIds: categoryIds));
  }

  void setMaxPerTitle(int maxPerTitle) {
    _update(state.copyWith(maxPerTitle: maxPerTitle));
  }

  void _update(AutoDownloadSettings next) {
    emit(next);
    unawaited(_preferences.write(next));
  }
}
