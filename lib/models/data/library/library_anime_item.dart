import 'package:wakaranai/models/data/gallery/local_anime_gallery_view.dart';
import 'package:wakaranai/models/data/library/library_item.dart';

class LibraryAnimeItem extends LibraryItem<LocalAnimeGalleryView> {
  LibraryAnimeItem(
      {int? id,
      required int localApiClientId,
      required LocalAnimeGalleryView localGalleryView})
      : super(
            id: id,
            localApiClientId: localApiClientId,
            localGalleryView: localGalleryView);
}
