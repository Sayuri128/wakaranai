import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/local_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';

class LocalAnimeGalleryViewService
    extends LocalGalleryViewService<LocalAnimeGalleryView> {
  static final LocalAnimeGalleryViewService _instance =
      LocalAnimeGalleryViewService();

  static LocalAnimeGalleryViewService get instance => _instance;

  LocalAnimeGalleryViewService()
      : super(
            idCol: wakaranaiDb.localAnimeGalleryViewTable.id,
            uidCol: wakaranaiDb.localAnimeGalleryViewTable.uid,
            libraryItemId: wakaranaiDb.localAnimeGalleryViewTable.libraryItemId,
            select: () => wakaranaiDb.localAnimeGalleryViewTable.select(),
            delete: () => wakaranaiDb.localAnimeGalleryViewTable.delete(),
            insert: () =>
                wakaranaiDb.into(wakaranaiDb.localAnimeGalleryViewTable),
            fromDrift: (dynamic element) =>
                LocalAnimeGalleryView.fromDrift(element),
            buildInsert: (element) =>
                LocalAnimeGalleryViewTableCompanion.insert(
                    uid: element.uid,
                    cover: element.cover,
                    title: element.title,
                    data: jsonEncode(element.data),
                    status: element.status,
                    libraryItemId: element.libraryItemId!));
}
