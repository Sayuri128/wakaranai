import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/repositories/shared_pref/app_language_preferences.dart';
import 'package:wakaranai/services/app_language/app_language.dart';

class AppLanguageCubit extends Cubit<AppLanguage> {
  AppLanguageCubit({
    AppLanguage initialLanguage = AppLanguage.system,
    AppLanguagePreferences? preferences,
  })  : _preferences = preferences ?? AppLanguagePreferences(),
        super(initialLanguage);

  final AppLanguagePreferences _preferences;

  Future<void> init() async {
    final AppLanguage language = await _preferences.read();
    if (isClosed) {
      return;
    }
    emit(language);
  }

  Future<void> changeLanguage(AppLanguage language) async {
    if (language == state) {
      return;
    }
    emit(language);
    await _preferences.write(language);
  }
}
