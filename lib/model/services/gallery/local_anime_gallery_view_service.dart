import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:wakaranai/model/services/gallery/local_gallery_view_service.dart';
import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/gallery/local_anime_gallery_view.dart';

class LocalAnimeGalleryViewService
    extends LocalGalleryViewService<LocalAnimeGalleryView> {
  static final LocalAnimeGalleryViewService instance =
      LocalAnimeGalleryViewService();

  LocalAnimeGalleryViewService()
      : super(
            idCol: waka.localAnimeGalleryViewTable.id,
            uidCol: waka.localAnimeGalleryViewTable.uid,
            select: () => waka.localAnimeGalleryViewTable.select(),
            del: () => waka.localAnimeGalleryViewTable.delete(),
            insert: () =>
                waka.into(waka.localAnimeGalleryViewTable),
            fromDrift: (dynamic element) =>
                LocalAnimeGalleryView.fromDrift(element),
            buildInsert: (element) =>
                LocalAnimeGalleryViewTableCompanion.insert(
                    uid: element.uid,
                    cover: element.cover,
                    title: element.title,
                    data: jsonEncode(element.data),
                    status: element.status));
}
