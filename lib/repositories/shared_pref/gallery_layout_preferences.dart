import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';

class GalleryLayoutPreferences {
  GalleryLayoutPreferences({this.key = galleryKey});

  static const String galleryKey = 'GALLERY_LAYOUT';
  static const String libraryKey = 'LIBRARY_LAYOUT';

  final String key;

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<GalleryLayout> getLayout() async {
    final SharedPreferences preferences = await _load();
    return galleryLayoutFromName(preferences.getString(key));
  }

  Future<void> setLayout(GalleryLayout layout) async {
    final SharedPreferences preferences = await _load();
    await preferences.setString(key, layout.name);
  }
}
