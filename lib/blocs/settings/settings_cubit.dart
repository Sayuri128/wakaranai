import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:h_reader/repositories/settings/settings_repository.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

const String imageCachingManagerKey = 'imageCachingManagerKey';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit() : super(SettingsInitial());

  final SettingsRepository _settingsRepository = SettingsRepository();

  void getSettings() async {
    emit(SettingsLoaded(keepCachedImageDay: await _settingsRepository.getStoreCachedImageDays()));
  }

  void setStoreCachedImagePeriod(KeepCachedImageDay period) async {
    _settingsRepository.changeStoreCachedImageDays(period);
    emit((state as SettingsLoaded).copyWith(keepCachedImageDay: period));
  }

  void clearCache() async {
    await CacheManager(Config(imageCachingManagerKey)).emptyCache();
  }
}
