import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/concrete/local_anime_concrete_view_service.dart';
import 'package:wakaranai/model/services/configs/local_api_sources_service.dart';
import 'package:wakaranai/model/services/gallery/local_anime_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/gallery/local_anime_gallery_view.dart';
import 'package:wakaranai/models/data/library/library_anime_item.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LibraryAnimeItemsService {
  static final LibraryAnimeItemsService instance = LibraryAnimeItemsService();

  Future<void> delete(int id) async {
    await waka.transaction(() async {
      final item = await get(id);

      await LocalAnimeConcreteViewService.instance.delete(item.id!);
      await LocalAnimeGalleryViewService.instance.delete(item.id!);

      await (waka.delete(waka.animeLibraryItemTable)
        ..where((tbl) => tbl.id.equals(id)))
          .go();

      final attachedToTheSameApiClient =
      await (waka.selectOnly(waka.animeLibraryItemTable)
        ..addColumns([waka.animeLibraryItemTable.id])
        ..where(waka.animeLibraryItemTable.localApiClientId
            .equals(item.localApiClientId)))
          .get();

      if (attachedToTheSameApiClient.isEmpty) {
        await LocalApiSourcesService.instance.delete(item.localApiClientId);
      }
    });
  }

  Future<int> count() async {
    final res = await (waka.selectOnly(waka.animeLibraryItemTable)
          ..addColumns([waka.animeLibraryItemTable.id]))
        .get();
    return res.length;
  }

  Future<LibraryAnimeItem> getByGalleryId(int id) async {
    final res = await (waka.select(waka.animeLibraryItemTable)
          ..where((tbl) => tbl.localAnimeGalleryViewId.equals(id)))
        .get();

    if (res.isEmpty) {
      throw Exception(
          "Library manga item with galleryViewId $id does not exist");
    }

    return LibraryAnimeItem(
        id: res.first.id,
        localApiClientId: res.first.localApiClientId,
        localGalleryView: await LocalAnimeGalleryViewService.instance
            .get(res.first.localAnimeGalleryViewId));
  }

  Future<List<LibraryAnimeItem>> query(
      {required int limit, required int offset}) async {
    final res = await (waka.select(waka.animeLibraryItemTable)
          ..limit(limit, offset: offset))
        .join([
      leftOuterJoin(
          waka.localAnimeGalleryViewTable,
          waka.localAnimeGalleryViewTable.id
              .equalsExp(waka.animeLibraryItemTable.localAnimeGalleryViewId))
    ]).get();

    return res.map((element) {
      return LibraryAnimeItem(
          id: element.readTable(waka.animeLibraryItemTable).id,
          localApiClientId:
              element.readTable(waka.animeLibraryItemTable).localApiClientId,
          localGalleryView: LocalAnimeGalleryView.fromDrift(
              element.readTable(waka.localAnimeGalleryViewTable)));
    }).toList();
  }

  Future<LibraryAnimeItem> get(int id) async {
    final libRes = await (waka.select(waka.animeLibraryItemTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (libRes.isEmpty) {
      throw Exception("Library item with id $id does not exist");
    }

    return LibraryAnimeItem(
        id: libRes.first.id,
        localApiClientId: libRes.first.localApiClientId,
        localGalleryView: await LocalAnimeGalleryViewService.instance
            .get(libRes.first.localAnimeGalleryViewId));
  }

  Future<int> add(
      {required AnimeApiClient client,
      required AnimeGalleryView galleryView,
      required ConfigInfo configInfo}) async {
    return (await waka.transaction(() async {
      int? apiId;

      final existingConfig = await (waka.select(waka.localConfigInfoTable)
            ..where((tbl) => tbl.uid.equals(configInfo.uid)))
          .get();

      if (existingConfig.isEmpty) {
        apiId = await LocalApiSourcesService.instance.add(
            code: client.parser.code,
            type: configInfo.type,
            configInfo: configInfo);
      } else {
        final existingApi = await (waka.selectOnly(waka.localApiSourceTable)
              ..addColumns([waka.localApiSourceTable.id])
              ..where(waka.localApiSourceTable.localConfigInfoId
                  .equals(existingConfig.first.id)))
            .get();
        apiId = existingApi.first.read(waka.localApiSourceTable.id);
      }

      final libraryId = await waka.into(waka.animeLibraryItemTable).insert(
          AnimeLibraryItemTableCompanion.insert(
              localApiClientId: apiId!,
              localAnimeGalleryViewId: await LocalAnimeGalleryViewService
                  .instance
                  .add(LocalAnimeGalleryView(
                      uid: (galleryView).uid,
                      cover: galleryView.cover,
                      title: galleryView.title,
                      data: galleryView.data,
                      status: galleryView.status))));

      return libraryId;
    }));
  }
}
