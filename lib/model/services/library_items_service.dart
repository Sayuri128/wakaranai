
import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/local_anime_gallery_view_service.dart';
import 'package:wakaranai/model/services/local_api_sources_service.dart';
import 'package:wakaranai/model/services/local_manga_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/gallery_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class LibraryItemsService {
  static final LibraryItemsService _instance = LibraryItemsService();

  static LibraryItemsService get instance => _instance;

  WakaranaiDb get waka => wakaranaiDb;

  Future<void> delete(int id) async {
    final item = await get(id);

    switch (item.type) {
      case LocalApiClientType.MANGA:
        await LocalMangaGalleryViewService.instance.deleteByLibraryId(item.id!);
        break;
      case LocalApiClientType.ANIME:
        await LocalMangaGalleryViewService.instance.deleteByLibraryId(item.id!);
        break;
    }

    await (waka.delete(waka.libraryItemTable)
          ..where((tbl) => tbl.id.equals(id)))
        .go();

    final attachedToTheSameApiClient =
        await (waka.selectOnly(waka.libraryItemTable)
              ..addColumns([waka.libraryItemTable.type])
              ..where(waka.libraryItemTable.localApiClientId
                  .equals(item.localApiClientId)))
            .get();

    if (attachedToTheSameApiClient.isEmpty) {
      await LocalApiSourcesService.instance.delete(item.localApiClientId);
    }
  }

  Future<int> count({required LocalApiClientType type}) async {
    final res = await (waka.selectOnly(waka.libraryItemTable)
          ..addColumns([waka.libraryItemTable.type])
          ..where(waka.libraryItemTable.type.equals(type.index)))
        .get();
    return res.length;
  }

  Future<List<LibraryItem>> query(
      {required int limit,
      required int offset,
      required LocalApiClientType type}) async {
    final res = await (waka.select(waka.libraryItemTable)
          ..where((tbl) => tbl.type.equals(type.index))
          ..limit(limit, offset: offset))
        .join([
      if (type == LocalApiClientType.ANIME)
        leftOuterJoin(
            waka.localAnimeGalleryViewTable,
            waka.localAnimeGalleryViewTable.libraryItemId
                .equalsExp(waka.libraryItemTable.id))
      else if (type == LocalApiClientType.MANGA)
        leftOuterJoin(
            waka.localMangaGalleryViewTable,
            waka.localMangaGalleryViewTable.libraryItemId
                .equalsExp(waka.libraryItemTable.id))
    ]).get();

    return res.map((element) {
      switch (type) {
        case LocalApiClientType.MANGA:
          return LibraryItem(
              id: element.readTable(waka.libraryItemTable).id,
              localApiClientId:
                  element.readTable(waka.libraryItemTable).localApiClientId,
              localGalleryView: LocalMangaGalleryView.fromDrift(
                  element.readTable(waka.localMangaGalleryViewTable)),
              type: type);
        case LocalApiClientType.ANIME:
          return LibraryItem(
              id: element.readTable(waka.libraryItemTable).id,
              localApiClientId:
                  element.readTable(waka.libraryItemTable).localApiClientId,
              localGalleryView: LocalAnimeGalleryView.fromDrift(
                  element.readTable(waka.localAnimeGalleryViewTable)),
              type: type);
      }
    }).toList();
  }

  Future<LibraryItem> get(int id) async {
    final libRes = await (waka.select(waka.libraryItemTable)
          ..where((tbl) => tbl.id.equals(id)))
        .get();

    if (libRes.isEmpty) {
      throw Exception("Library item with id $id does not exist");
    }

    late final LocalGalleryView localGalleryView;

    switch (libRes.first.type) {
      case LocalApiClientType.MANGA:
        localGalleryView = await LocalMangaGalleryViewService.instance
            .getByLibraryId(libRes.first.id);
        break;
      case LocalApiClientType.ANIME:
        localGalleryView = await LocalAnimeGalleryViewService.instance
            .getByLibraryId(libRes.first.id);
        break;
    }

    return LibraryItem(
        id: libRes.first.id,
        localApiClientId: libRes.first.localApiClientId,
        localGalleryView: localGalleryView,
        type: libRes.first.type);
  }

  Future<int> add(
      {required ApiClient client,
      required GalleryView galleryView,
      required RemoteConfig remoteConfig,
      required LocalApiClientType type}) async {
    return (await waka.transaction(() async {
      int? apiId;

      final existingConfig = await (waka.select(waka.localConfigInfoTable)
            ..where((tbl) => tbl.uid.equals(remoteConfig.config.uid)))
          .get();

      if (existingConfig.isEmpty) {
        apiId = await LocalApiSourcesService.instance.add(
            code: client.parser.code,
            type: type,
            configInfo: remoteConfig.config);
      } else {
        final existingApi = await (waka.selectOnly(waka.localApiSourceTable)
              ..addColumns([waka.localApiSourceTable.id])
              ..where(waka.localApiSourceTable.localConfigInfoId
                  .equals(existingConfig.first.id)))
            .get();
        apiId = existingApi.first.read(waka.localApiSourceTable.id);
      }

      final libraryId = await waka
          .into(waka.libraryItemTable)
          .insert(LibraryItemTableCompanion.insert(
            localApiClientId: apiId!,
            type: type,
          ));

      switch (type) {
        case LocalApiClientType.MANGA:
          await LocalMangaGalleryViewService.instance.add(LocalMangaGalleryView(
              uid: (galleryView as MangaGalleryView).uid,
              cover: galleryView.cover,
              title: galleryView.title,
              data: galleryView.data,
              libraryItemId: libraryId));
          break;
        case LocalApiClientType.ANIME:
          await LocalAnimeGalleryViewService.instance.add(LocalAnimeGalleryView(
              uid: (galleryView as AnimeGalleryView).uid,
              cover: galleryView.cover,
              title: galleryView.title,
              data: galleryView.data,
              libraryItemId: libraryId,
              status: galleryView.status));
          break;
      }

      return libraryId;
    }));
  }
}
