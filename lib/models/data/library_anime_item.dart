import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';

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
