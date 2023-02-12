import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/gallery_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

abstract class LocalGalleryView extends GalleryView {
  final int? id;
  final int? libraryItemId;

  LocalGalleryView(
      this.id, this.libraryItemId, String uid, Map<String, dynamic> data)
      : super(uid: uid, data: data);
}

class LocalAnimeGalleryView extends LocalGalleryView {
  final String cover;
  final String title;
  final AnimeStatus status;

  LocalAnimeGalleryView({
    int? id,
    int? libraryItemId,
    required String uid,
    required this.cover,
    required this.title,
    required Map<String, dynamic> data,
    required this.status,
  }) : super(id, libraryItemId, uid, data);

  AnimeGalleryView asGalleryView() => AnimeGalleryView(
      uid: uid, cover: cover, title: title, data: data, status: status);

  factory LocalAnimeGalleryView.fromRemote(AnimeGalleryView galleryView) =>
      LocalAnimeGalleryView(
          uid: galleryView.uid,
          cover: galleryView.cover,
          title: galleryView.title,
          data: galleryView.data,
          status: galleryView.status);

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

  factory LocalAnimeGalleryView.fromDrift(DriftLocalAnimeGalleryView drift) =>
      LocalAnimeGalleryView(
          id: drift.id,
          uid: drift.uid,
          cover: drift.cover,
          title: drift.title,
          libraryItemId: drift.libraryItemId,
          data: jsonDecode(drift.data),
          status: drift.status);
}

class LocalMangaGalleryView extends LocalGalleryView {
  final String cover;
  final String title;

  LocalMangaGalleryView({
    int? id,
    int? libraryItemId,
    required String uid,
    required this.cover,
    required this.title,
    required Map<String, dynamic> data,
  }) : super(id, libraryItemId, uid, data);

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
          libraryItemId: drift.libraryItemId,
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
