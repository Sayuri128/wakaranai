import 'package:wakaranai/models/data/gallery/local_manga_gallery_view.dart';
import 'package:wakaranai/models/data/library/library_item.dart';

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
