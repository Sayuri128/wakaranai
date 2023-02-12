import 'package:wakaranai/models/data/local_api_client.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakaranai/models/serializable_object.dart';

enum LibraryItemType { ANIME, MANGA }

class LibraryItem extends SqSerializableObject {
  int? id;
  final LocalApiClient localApiClient;
  final LocalGalleryView localGalleryView;
  final String galleryViewId;
  final LibraryItemType type;

  LibraryItem(
      {this.id,
      required this.localApiClient,
      required this.localGalleryView,
      required this.galleryViewId,
      required this.type});

  @override
  Map<String, dynamic> toMap({bool lazy = true}) {
    return {
      if (id != null) 'id': id,
      'type': type.index,
      'galleryViewId': galleryViewId,
      if (lazy)
        'localApiClientId': localApiClient.getId()
      else
        'localApiClient': localApiClient.toMap(lazy: lazy),
      if (lazy)
        'localGalleryViewId': localGalleryView.getId()
      else
        'localGalleryView': localGalleryView.toMap(lazy: lazy)
    };
  }

  factory LibraryItem.fromMap(Map<String, dynamic> map) {
    final type = LibraryItemType.values.elementAt(map['type']);
    late LocalGalleryView galleryView;

    switch (type) {
      case LibraryItemType.ANIME:
        galleryView = LocalAnimeGalleryView.fromMap(map['localGalleryView']);
        break;
      case LibraryItemType.MANGA:
        galleryView = LocalMangaGalleryView.fromMap(map['localGalleryView']);
        break;
    }
    return LibraryItem(
        id: map['id'] as int,
        type: type,
        galleryViewId: map['galleryViewId'],
        localApiClient: LocalApiClient.fromMap(map['localApiClient']),
        localGalleryView: galleryView);
  }

  @override
  int? getId() => id;
}
