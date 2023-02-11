import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/services/local_anime_gallery_view_service/local_anime_gallery_view_service.dart';
import 'package:wakaranai/services/local_api_clients_service/local_api_clients_service.dart';
import 'package:wakaranai/services/local_manga_gallery_view_service/local_manga_gallery_view_service.dart';
import 'package:wakaranai/services/sqflite_service/query_item.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_exists_check_result.dart';
import 'package:wakaranai/services/sqflite_service/sqflite_service.dart';
import 'package:collection/collection.dart';

class LibraryService extends SqfliteService<LibraryItem> {
  LibraryService(
      {required this.localApiClientsService,
      required this.localAnimeGalleryViewService,
      required this.localMangaGalleryViewService})
      : super(tableName: libraryTableName);

  final LocalApiClientsService localApiClientsService;
  final LocalAnimeGalleryViewService localAnimeGalleryViewService;
  final LocalMangaGalleryViewService localMangaGalleryViewService;
  final Map<int, LocalApiClient> cachedClients = {};

  static const String libraryTableName = 'library';
  static const String createLibraryTable = '''
          create table $libraryTableName (
            id integer PRIMARY KEY AUTOINCREMENT,
            localApiClientId integer NOT NULL,
            localGalleryViewId integer NOT NULL,
            type integer NOT NULL,
            created DATETIME DEFAULT CURRENT_TIMESTAMP,
            FOREIGN KEY(localApiClientId) REFERENCES ${LocalApiClientsService.apiConfigsTableName}(id)
          );
      ''';

  @override
  Future<int> insert(LibraryItem item) async {
    final exists =
        await localApiClientsService.checkExists(item.localApiClient);
    if (!exists.value) {
      item.localApiClient.id =
          await localApiClientsService.insert(item.localApiClient);
    } else {
      item.localApiClient.id = exists.data!['id'];
    }

    switch (item.type) {
      case LibraryItemType.ANIME:
        item.localGalleryView.id = await localAnimeGalleryViewService
            .insert(item.localGalleryView as LocalAnimeGalleryView);
        break;
      case LibraryItemType.MANGA:
        item.localGalleryView.id = await localMangaGalleryViewService
            .insert(item.localGalleryView as LocalMangaGalleryView);
        break;
    }

    cachedClients.putIfAbsent(
        item.localApiClient.id!, () => item.localApiClient);
    return super.insert(item);
  }

  @override
  Future<LibraryItem> mapConfig(Map<String, dynamic> map) async {
    final Map<String, dynamic> res = Map.from(map);

    final id = map['localApiClientId'];

    if (cachedClients[id] == null) {
      final apiClient = await localApiClientsService.get(id);
      res['localApiClient'] = apiClient.toMap(lazy: false);
      cachedClients.putIfAbsent(apiClient.id!, () => apiClient);
    } else {
      res['localApiClient'] = cachedClients[id]!.toMap(lazy: false);
    }

    final LibraryItemType type = LibraryItemType.values.elementAt(res['type']);

    switch (type) {
      case LibraryItemType.ANIME:
        res['localGalleryView'] = await localAnimeGalleryViewService
            .getMap(map['localGalleryViewId']);
        break;
      case LibraryItemType.MANGA:
        res['localGalleryView'] = await localMangaGalleryViewService
            .getMap(map['localGalleryViewId']);
        break;
    }

    return LibraryItem.fromMap(res);
  }

  Future<SqfliteExistsCheckResult> checkExists(
      LibraryItemType type, String localGalleryViewId) async {
    late final List<Map<String, dynamic>> data;

    final query =
        SqfliteQueryKeyValueItem(key: "uid", value: localGalleryViewId);

    switch (type) {
      case LibraryItemType.ANIME:
        data = await localAnimeGalleryViewService.queryMap(query: [query]);
        break;
      case LibraryItemType.MANGA:
        data = await localMangaGalleryViewService.queryMap(query: [query]);
        break;
    }
    ;
    return SqfliteExistsCheckResult(
        value: data.isNotEmpty, data: data.firstOrNull);
  }
}
