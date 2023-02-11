import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class LocalAnimeGalleryViewService
    extends SqfliteService<LocalAnimeGalleryView> {

  LocalAnimeGalleryViewService() : super(tableName: localAnimeGalleryViewTableName);

  static const localAnimeGalleryViewTableName = 'local_anime_gallery_view';
  static const createAnimeMangaGalleryViewTableName = '''
    create table $localAnimeGalleryViewTableName (
      id integer PRIMARY KEY AUTOINCREMENT,
      uid text NOT NULL,
      cover text NOT NULL,
      title text NOT NULL,
      data text NOT NULL,
      status integer NOT NULL
    );
  ''';

  @override
  Future<LocalAnimeGalleryView> mapConfig(Map<String, dynamic> map) async =>
      LocalAnimeGalleryView.fromMap(map);

}
