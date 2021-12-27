import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:h_reader/blocs/nhentai/cache/image/image_cache_cubit.dart';
import 'package:h_reader/repositories/settings/settings_repository.dart';
import 'package:h_reader/services/sqlite/cache/doujinshi/doujinshi_cache_service.dart';
import 'package:h_reader/services/sqlite/cache/image/image_cache_service.dart';
import 'package:meta/meta.dart';

part 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({required this.imageCacheCubit}) : super(SettingsInitial());

  final ImageCacheCubit imageCacheCubit;
  final ImageCacheService _imageCacheService = ImageCacheService();
  final DoujinshiCacheService _doujinshiCacheService = DoujinshiCacheService();
  final SettingsRepository _settingsRepository = SettingsRepository();

  void getSettings() async {
    emit(SettingsLoaded(keepCachedImageDay: await _settingsRepository.getStoreCachedImageDays()));
  }

  void setStoreCachedImagePeriod(KeepCachedImageDay period) async {
    _settingsRepository.changeStoreCachedImageDays(period);
    emit((state as SettingsLoaded).copyWith(keepCachedImageDay: period));
  }

  void clearCache() async {
    await _imageCacheService.clear();
    await _doujinshiCacheService.clear();
    await ImageCacheCubit.instance.emptyCache();
    imageCacheCubit.getAll();
  }
}
