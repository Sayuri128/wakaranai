import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';

class LocalMangaGalleryViewService
    extends SqfliteService<LocalMangaGalleryView> {
  LocalMangaGalleryViewService() : super(tableName: localMangaGalleryViewTableName);

  static const localMangaGalleryViewTableName = 'local_manga_gallery_view';
  static const createLocalMangaGalleryViewTableName = '''
    create table $localMangaGalleryViewTableName (
      id integer PRIMARY KEY AUTOINCREMENT,
      uid text NOT NULL,
      cover text NOT NULL,
      title text NOT NULL,
      data text NOT NULL
    );
  ''';

  @override
  Future<LocalMangaGalleryView> mapConfig(Map<String, dynamic> map) async =>
      LocalMangaGalleryView.fromMap(map);
}
