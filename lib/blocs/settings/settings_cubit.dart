import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  static const defaultReaderModePrefsKey = 'DEFAULT_CHAPTER_READER_MODE';

  late final SharedPreferences _prefs;

  void init() async {
    _prefs = await SharedPreferences.getInstance();

    final defaultModeStr = _prefs.getString(defaultReaderModePrefsKey);

    late ChapterViewMode defaultMode;

    if (defaultModeStr != null) {
      defaultMode = ChapterViewMode.values
          .firstWhere((element) => element.toString() == defaultModeStr);
    } else {
      defaultMode = ChapterViewMode.RIGHT_TO_LEFT;
      _prefs.setString(
          defaultReaderModePrefsKey, ChapterViewMode.RIGHT_TO_LEFT.toString());
    }

    emit(SettingsInitialized(defaultMode: defaultMode));
  }

  void onChangedDefaultReadMode(ChapterViewMode mode) {
    _prefs.setString(defaultReaderModePrefsKey, mode.toString());

    emit((state as SettingsInitialized).copyWith(defaultMode: mode));
  }
}
