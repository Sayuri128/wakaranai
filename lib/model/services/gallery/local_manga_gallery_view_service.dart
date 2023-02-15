import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/gallery/local_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/gallery/local_manga_gallery_view.dart';

class LocalMangaGalleryViewService
    extends LocalGalleryViewService<LocalMangaGalleryView> {
  static final LocalMangaGalleryViewService instance =
      LocalMangaGalleryViewService();


  LocalMangaGalleryViewService()
      : super(
            idCol: waka.localMangaGalleryViewTable.id,
            uidCol: waka.localMangaGalleryViewTable.uid,
            select: () => waka.localMangaGalleryViewTable.select(),
            del: () => waka.localMangaGalleryViewTable.delete(),
            insert: () =>
                waka.into(waka.localMangaGalleryViewTable),
            fromDrift: (dynamic element) =>
                LocalMangaGalleryView.fromDrift(element),
            buildInsert: (element) =>
                LocalMangaGalleryViewTableCompanion.insert(
                    uid: element.uid,
                    cover: element.cover,
                    title: element.title,
                    data: jsonEncode(element.data)));
}
