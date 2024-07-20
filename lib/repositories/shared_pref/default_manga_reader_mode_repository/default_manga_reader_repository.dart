import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';
import 'package:wakaranai/utils/enum_converters.dart';

class DefaultMangaReaderRepository {
  late final SharedPreferences sharedPreferences;

  String _getKey(String serviceUid, String mangaUid) =>
      "default_manga_reader_mode_${serviceUid}_$mangaUid";

  Future<void> init() async {
    sharedPreferences = await SharedPreferences.getInstance();
  }

  Future<void> setDefaultMangaReaderMode(
    ChapterViewMode mode,
    String serviceUid,
    String mangaUid,
  ) async {
    await sharedPreferences.setString(
      _getKey(serviceUid, mangaUid),
      encodeEnum(mode),
    );
  }

  Future<ChapterViewMode?> getDefaultMangaReaderMode(
    String serviceUid,
    String mangaUid,
  ) async {
    final mode = sharedPreferences.getString(_getKey(serviceUid, mangaUid));
    if (mode == null) return null;
    return decodeEnum(ChapterViewMode.values, mode);
  }
}
