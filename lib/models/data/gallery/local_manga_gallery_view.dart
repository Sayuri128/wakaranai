import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/gallery/local_gallery_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

class LocalMangaGalleryView extends LocalGalleryView {
  final String cover;
  final String title;

  LocalMangaGalleryView({
    int? id,
    required String uid,
    required this.cover,
    required this.title,
    required Map<String, dynamic> data,
  }) : super(id, uid, data);

  MangaGalleryView asGalleryView() =>
      MangaGalleryView(uid: uid, cover: cover, title: title, data: data);

  factory LocalMangaGalleryView.fromRemote(MangaGalleryView galleryView) =>
      LocalMangaGalleryView(
          uid: galleryView.uid,
          cover: galleryView.cover,
          title: galleryView.title,
          data: galleryView.data);

  factory LocalMangaGalleryView.fromDrift(DriftLocalMangaGalleryView drift) =>
      LocalMangaGalleryView(
          id: drift.id,
          uid: drift.uid,
          cover: drift.cover,
          title: drift.title,
          data: jsonDecode(drift.data));

  @override
  callFunction(String name, {List? ordinalArguments}) {
    throw UnimplementedError();
  }

  @override
  getField(String name) {
    throw UnimplementedError();
  }

  @override
  void setField(String name, value) {}
}
