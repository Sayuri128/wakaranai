import 'package:drift/src/runtime/query_builder/query_builder.dart';
import 'package:wakaranai/model/services/local_api_sources_service.dart';
import 'package:wakaranai/model/services/local_manga_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/library_manga_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';
import 'package:wakascript/models/config_info/config_info.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class LibraryMangaItemsService {
  static final LibraryMangaItemsService _instance = LibraryMangaItemsService();

  static LibraryMangaItemsService get instance => _instance;

  WakaranaiDb get waka => wakaranaiDb;

  Future<void> delete(int id) async {
    final item = await get(id);

    LocalMangaGalleryViewService.instance.delete(item.localGalleryView.id!);

    await (waka.delete(waka.mangaLibraryItemTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    final attachedToTheSameApiClient =
        await (waka.selectOnly(waka.mangaLibraryItemTable)
              ..addColumns([waka.mangaLibraryItemTable.id])
              ..where(waka.mangaLibraryItemTable.localApiClientId
                  .equals(item.localApiClientId)))
            .get();

    if (attachedToTheSameApiClient.isEmpty) {
      await LocalApiSourcesService.instance.delete(item.localApiClientId);
    }
  }

  Future<int> count() async {
    final res = await (waka.selectOnly(waka.mangaLibraryItemTable)
          ..addColumns([waka.mangaLibraryItemTable.id]))
        .get();
    return res.length;
  }

  Future<List<LibraryMangaItem>> query(
      {required int limit, required int offset}) async {
    final res = await (waka.select(waka.mangaLibraryItemTable)
          ..limit(limit, offset: offset))
        .join([
      leftOuterJoin(
          waka.localMangaGalleryViewTable,
          waka.localMangaGalleryViewTable.id
              .equalsExp(waka.mangaLibraryItemTable.localMangaGalleryViewId))
    ]).get();

    return res.map((element) {
      return LibraryMangaItem(
          id: element.readTable(waka.mangaLibraryItemTable).id,
          localApiClientId:
              element.readTable(waka.mangaLibraryItemTable).localApiClientId,
          localGalleryView: LocalMangaGalleryView.fromDrift(
              element.readTable(waka.localMangaGalleryViewTable)));
    }).toList();
  }

  Future<LibraryMangaItem> getByGalleryId(int id) async {
    final res = await (waka.select(waka.mangaLibraryItemTable)
          ..where((tbl) => tbl.localMangaGalleryViewId.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception(
          "Library manga item with galleryViewId $id does not exist");
    }

    return LibraryMangaItem(
        id: res.first.id,
        localApiClientId: res.first.localApiClientId,
        localGalleryView: await LocalMangaGalleryViewService.instance
            .get(res.first.localMangaGalleryViewId));
  }

  Future<LibraryMangaItem> get(int id) async {
    final libRes = await (waka.select(waka.mangaLibraryItemTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (libRes.isEmpty) {
      throw Exception("Library item with id $id does not exist");
    }

    return LibraryMangaItem(
        id: libRes.first.id,
        localApiClientId: libRes.first.localApiClientId,
        localGalleryView: await LocalMangaGalleryViewService.instance
            .get(libRes.first.localMangaGalleryViewId));
  }

  Future<int> add(
      {required MangaApiClient client,
      required MangaGalleryView galleryView,
      required ConfigInfo configInfo,
      required ConfigInfoType type}) async {
    return (await waka.transaction(() async {
      int? apiId;

      final existingConfig = await (waka.select(waka.localConfigInfoTable)
            ..where((tbl) => tbl.uid.equals(configInfo.uid)))
          .get();

      if (existingConfig.isEmpty) {
        apiId = await LocalApiSourcesService.instance
            .add(code: client.parser.code, type: type, configInfo: configInfo);
      } else {
        final existingApi = await (waka.selectOnly(waka.localApiSourceTable)
              ..addColumns([waka.localApiSourceTable.id])
              ..where(waka.localApiSourceTable.localConfigInfoId
                  .equals(existingConfig.first.id)))
            .get();
        apiId = existingApi.first.read(waka.localApiSourceTable.id);
      }

      final libraryId = await waka.into(waka.mangaLibraryItemTable).insert(
          MangaLibraryItemTableCompanion.insert(
              localApiClientId: apiId!,
              localMangaGalleryViewId: await LocalMangaGalleryViewService
                  .instance
                  .add(LocalMangaGalleryView(
                      uid: (galleryView).uid,
                      cover: galleryView.cover,
                      title: galleryView.title,
                      data: galleryView.data))));

      return libraryId;
    }));
  }
}
