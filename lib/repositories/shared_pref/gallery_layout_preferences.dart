import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';

class GalleryLayoutPreferences {
  static const String _layoutKey = 'GALLERY_LAYOUT';

  SharedPreferences? _preferences;

  Future<SharedPreferences> _load() async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  Future<GalleryLayout> getLayout() async {
    final SharedPreferences preferences = await _load();
    return galleryLayoutFromName(preferences.getString(_layoutKey));
  }

  Future<void> setLayout(GalleryLayout layout) async {
    final SharedPreferences preferences = await _load();
    await preferences.setString(_layoutKey, layout.name);
  }
}
