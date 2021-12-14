import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:h_reader/blocs/settings/settings_cubit.dart';
import 'package:meta/meta.dart';

part 'caching_image_state.dart';

class CachingImageCubit extends Cubit<CachingImageState> {
  CachingImageCubit()
      : super(CachingImageInitial(cacheManager: CacheManager(Config(imageCachingManagerKey))));
}
