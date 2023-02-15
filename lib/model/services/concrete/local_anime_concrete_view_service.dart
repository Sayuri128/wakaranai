import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/concrete/elements_group_of_concrete/local_anime_video_group_service.dart';
import 'package:wakaranai/model/services/gallery/local_anime_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/concrete/local_anime_concrete_view.dart';
import 'package:wakaranai/models/data/gallery/local_anime_gallery_view.dart';
import 'package:wakaranai/utils/decoders.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';

class LocalAnimeConcreteViewService {
  static final LocalAnimeConcreteViewService instance =
      LocalAnimeConcreteViewService();

  Future<LocalAnimeConcreteView> getByUid(String uid) async {
    final res = await (waka.select(waka.localAnimeConcreteViewTable)
          ..where((tbl) => tbl.uid.equals(uid)))
        .get();

    if (res.isEmpty) {
      throw Exception("LocalAnimeConcreteView with uid $uid does not exist");
    }

    return LocalAnimeConcreteView(
        uid: res.first.uid,
        groups: await LocalAnimeVideoGroupService.instance
            .getConcreteGroups(res.first.id),
        id: res.first.id,
        title: res.first.title,
        description: res.first.description,
        cover: res.first.cover,
        alternativeTitles: decodeJsonStringList(res.first.alternativeTitles),
        tags: decodeJsonStringList(res.first.tags),
        status: res.first.status);
  }

  Future<void> delete(int galleryViewId) async {
    await waka.transaction(() async {
      final id = (await (waka.selectOnly(waka.localAnimeConcreteViewTable)
                ..addColumns([
                  waka.localAnimeConcreteViewTable.id,
                  waka.localAnimeConcreteViewTable.galleryViewId
                ])
                ..where(waka.localAnimeConcreteViewTable.galleryViewId
                    .equals(galleryViewId)))
              .get())
          .firstOrNull
          ?.read(waka.localAnimeConcreteViewTable.id);
      if (id != null) {
        await LocalAnimeVideoGroupService.instance.delete(id);
      }

      await (waka.delete(waka.localAnimeConcreteViewTable)
            ..where((tbl) => tbl.galleryViewId.equals(galleryViewId)))
          .go();
    });
  }

  Future<int> add(
      AnimeConcreteView concreteView, AnimeGalleryView galleryView) async {
    return waka.transaction(() async {
      late final int galleryViewId;

      try {
        galleryViewId = (await LocalAnimeGalleryViewService.instance
                .getByUid(galleryView.uid))
            .id!;
      } on Exception {
        galleryViewId = await LocalAnimeGalleryViewService.instance
            .add(LocalAnimeGalleryView.fromRemote(galleryView));
      }

      final concreteId = await waka
          .into(waka.localAnimeConcreteViewTable)
          .insert(
              LocalAnimeConcreteViewTableCompanion.insert(
                  uid: concreteView.uid,
                  galleryViewId: galleryViewId,
                  cover: concreteView.cover,
                  title: concreteView.title,
                  alternativeTitles: jsonEncode(concreteView.alternativeTitles),
                  tags: jsonEncode(concreteView.tags),
                  description: concreteView.description,
                  status: concreteView.status),
              mode: InsertMode.insertOrReplace);

      Future.wait(concreteView.groups.map((e) async =>
          await LocalAnimeVideoGroupService.instance.add(e, concreteId)));

      return concreteId;
    });
  }
}
