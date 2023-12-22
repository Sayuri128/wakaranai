import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:wakaranai/model/services/concrete/elements_group_of_concrete/local_chapters_group_service.dart';
import 'package:wakaranai/model/services/gallery/local_manga_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_manga_concrete_view.dart';
import 'package:wakaranai/models/data/gallery/local_manga_gallery_view.dart';
import 'package:wakaranai/utils/decoders.dart';
import 'package:wakascript/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class LocalMangaConcreteViewService {
  static final LocalMangaConcreteViewService instance =
      LocalMangaConcreteViewService();

  Future<LocalMangaConcreteView> getByUid(String uid) async {
    final res = await (waka.select(waka.localMangaConcreteViewTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalMangaConcreteView with uid $uid does not exist");
    }

    final groups = await LocalChaptersGroupService.instance
        .getConcreteGroups(res.first.id);
    return LocalMangaConcreteView(
        uid: res.first.uid,
        id: res.first.id,
        groups: groups,
        title: res.first.title,
        description: res.first.description,
        cover: res.first.cover,
        alternativeTitles: decodeJsonStringList(res.first.alternativeTitles),
        tags: decodeJsonStringList(res.first.tags),
        status: res.first.status);
  }

  Future<void> delete(int galleryViewId) async {
    await waka.transaction(() async {
      final id = (await (waka.selectOnly(waka.localMangaConcreteViewTable)
                ..addColumns([
                  waka.localMangaConcreteViewTable.id,
                  waka.localMangaConcreteViewTable.galleryViewId
                ])
                ..where(waka.localMangaConcreteViewTable.galleryViewId
                    .equals(galleryViewId)))
              .get())
          .firstOrNull
          ?.read(waka.localMangaConcreteViewTable.id);
      if (id != null) {
        await LocalChaptersGroupService.instance.delete(id);
      }
      await (waka.delete(waka.localMangaConcreteViewTable)
            ..where((tbl) => tbl.galleryViewId.equals(galleryViewId)))
          .go();
    });
  }

  Future<int> add(
      MangaConcreteView concreteView, MangaGalleryView galleryView) async {
    return waka.transaction(() async {
      late final int galleryViewId;

      try {
        galleryViewId = (await LocalMangaGalleryViewService.instance
                .getByUid(galleryView.uid))
            .id!;
      } on Exception {
        galleryViewId = await LocalMangaGalleryViewService.instance
            .add(LocalMangaGalleryView.fromRemote(galleryView));
      }

      final concreteId = await waka
          .into(waka.localMangaConcreteViewTable)
          .insert(LocalMangaConcreteViewTableCompanion.insert(
              uid: concreteView.uid,
              galleryViewId: galleryViewId,
              cover: concreteView.cover,
              title: concreteView.title,
              alternativeTitles: jsonEncode(concreteView.alternativeTitles),
              tags: jsonEncode(concreteView.tags),
              description: concreteView.description,
              status: concreteView.status));

      await Future.wait(concreteView.groups.map((e) async =>
          await LocalChaptersGroupService.instance.add(e, concreteId)));

      return concreteId;
    });
  }
}
