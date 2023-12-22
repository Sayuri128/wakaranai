import 'dart:convert';

import 'package:wakaranai/model/wakaranai_db.dart';
import 'package:wakaranai/models/data/gallery/local_gallery_view.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';

class LocalAnimeGalleryView extends LocalGalleryView {
  final String cover;
  final String title;
  final AnimeStatus status;

  LocalAnimeGalleryView({
    int? id,
    required String uid,
    required this.cover,
    required this.title,
    required Map<String, dynamic> data,
    required this.status,
  }) : super(id, uid, data);

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
          data: jsonDecode(drift.data),
          status: drift.status);
}
