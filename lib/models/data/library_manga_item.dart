import 'package:wakaranai/models/data/library_item.dart';
import 'package:wakaranai/models/data/local_gallery_view.dart';

class LibraryMangaItem extends LibraryItem<LocalMangaGalleryView> {
  LibraryMangaItem(
      {int? id,
      required int localApiClientId,
      required LocalMangaGalleryView localGalleryView})
      : super(
            id: id,
            localApiClientId: localApiClientId,
            localGalleryView: localGalleryView);
}
