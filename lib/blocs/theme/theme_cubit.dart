import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/utils/app_palette.dart';

class ThemeState {
  const ThemeState({required this.palette});

  final AppPalette palette;

  AppThemeId get id => palette.id;
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit()
      : super(const ThemeState(palette: AppPalette.midnight));

  final SettingsService _settingsService = SettingsService();

  Future<void> init() async {
    final AppThemeId id = await _settingsService.getThemeId();
    emit(ThemeState(palette: AppPalette.fromId(id)));
  }

  Future<void> changeTheme(AppThemeId id) async {
    if (id == state.id) return;
    await _settingsService.setThemeId(id);
    emit(ThemeState(palette: AppPalette.fromId(id)));
  }
}
