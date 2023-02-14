import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/local_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';

class LocalMangaGalleryViewService
    extends LocalGalleryViewService<LocalMangaGalleryView> {
  static final LocalMangaGalleryViewService _instance =
      LocalMangaGalleryViewService();

  static LocalMangaGalleryViewService get instance => _instance;

  LocalMangaGalleryViewService()
      : super(
            idCol: wakaranaiDb.localMangaGalleryViewTable.id,
            uidCol: wakaranaiDb.localMangaGalleryViewTable.uid,
            select: () => wakaranaiDb.localMangaGalleryViewTable.select(),
            del: () => wakaranaiDb.localMangaGalleryViewTable.delete(),
            insert: () =>
                wakaranaiDb.into(wakaranaiDb.localMangaGalleryViewTable),
            fromDrift: (dynamic element) =>
                LocalMangaGalleryView.fromDrift(element),
            buildInsert: (element) =>
                LocalMangaGalleryViewTableCompanion.insert(
                    uid: element.uid,
                    cover: element.cover,
                    title: element.title,
                    data: jsonEncode(element.data)));
}
