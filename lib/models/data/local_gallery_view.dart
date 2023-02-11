import 'dart:convert';

import 'package:wakaranai/models/serializable_object.dart';
import 'package:wakascript/models/anime/anime_concrete_view/anime_status.dart';
import 'package:wakascript/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:wakascript/models/manga/manga_gallery_view/manga_gallery_view.dart';

abstract class LocalGalleryView extends SqSerializableObject {
  int? id;

  LocalGalleryView(this.id);
}

class LocalAnimeGalleryView extends LocalGalleryView {
  final String uid;
  final String cover;
  final String title;
  final Map<String, dynamic> data;
  final AnimeStatus status;

  LocalAnimeGalleryView({
    int? id,
    required this.uid,
    required this.cover,
    required this.title,
    required this.data,
    required this.status,
  }) : super(id);

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
  Map<String, dynamic> toMap({bool lazy = true}) {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'cover': cover,
      'title': title,
      'data': jsonEncode(data),
      'status': status.index,
    };
  }

  factory LocalAnimeGalleryView.fromMap(Map<String, dynamic> map) {
    return LocalAnimeGalleryView(
      id: map['id'] as int,
      uid: map['uid'] as String,
      cover: map['cover'] as String,
      title: map['title'] as String,
      data: jsonDecode(map['data']),
      status: AnimeStatus.values.elementAt(map['status']),
    );
  }

  @override
  int? getId() => id;
}

class LocalMangaGalleryView extends LocalGalleryView {
  final String uid;
  final String cover;
  final String title;
  final Map<String, dynamic> data;

  LocalMangaGalleryView({
    int? id,
    required this.uid,
    required this.cover,
    required this.title,
    required this.data,
  }) : super(id);

  MangaGalleryView asGalleryView() =>
      MangaGalleryView(uid: uid, cover: cover, title: title, data: data);

  @override
  int? getId() => id;

  factory LocalMangaGalleryView.fromRemote(MangaGalleryView galleryView) =>
      LocalMangaGalleryView(
          uid: galleryView.uid,
          cover: galleryView.cover,
          title: galleryView.title,
          data: galleryView.data);

  @override
  Map<String, dynamic> toMap({bool lazy = true}) {
    return {
      if (id != null) 'id': id,
      'uid': uid,
      'cover': cover,
      'title': title,
      'data': jsonEncode(data),
    };
  }

  factory LocalMangaGalleryView.fromMap(Map<String, dynamic> map) {
    return LocalMangaGalleryView(
      id: map['id'] as int,
      uid: map['uid'] as String,
      cover: map['cover'] as String,
      title: map['title'] as String,
      data: jsonDecode(map['data']),
    );
  }
}
