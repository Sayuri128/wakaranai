import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/shared_pref/gallery_layout_preferences.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';

class GalleryLayoutCubit extends Cubit<GalleryLayout> {
  GalleryLayoutCubit({GalleryLayoutPreferences? preferences})
    : _preferences = preferences ?? GalleryLayoutPreferences(),
      super(GalleryLayout.comfortable);

  final GalleryLayoutPreferences _preferences;

  Future<void> init() async {
    try {
      final GalleryLayout layout = await _preferences.getLayout();
      if (!isClosed) {
        emit(layout);
      }
    } catch (e, s) {
      logger.w('Failed to load gallery layout: $e');
      logger.w(s);
    }
  }

  Future<void> cycle() => select(nextGalleryLayout(state));

  Future<void> select(GalleryLayout layout) async {
    if (layout == state) {
      return;
    }
    emit(layout);
    try {
      await _preferences.setLayout(layout);
    } catch (e, s) {
      logger.w('Failed to save gallery layout: $e');
      logger.w(s);
    }
  }
}

class LibraryLayoutCubit extends GalleryLayoutCubit {
  LibraryLayoutCubit({GalleryLayoutPreferences? preferences})
    : super(
        preferences: preferences ??
            GalleryLayoutPreferences(key: GalleryLayoutPreferences.libraryKey),
      );
}
