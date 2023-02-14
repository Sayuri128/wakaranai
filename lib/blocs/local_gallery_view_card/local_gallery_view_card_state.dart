part of 'local_gallery_view_card_cubit.dart';

@immutable
abstract class LocalGalleryViewCardState<I extends LibraryItem<G>,
    G extends LocalGalleryView> {}

class LocalGalleryViewCardInitial<I extends LibraryItem<G>, G extends LocalGalleryView>
    extends LocalGalleryViewCardState<I, G> {}

class LocalGalleryViewCardLoaded<I extends LibraryItem<G>, G extends LocalGalleryView>
    extends LocalGalleryViewCardState<I, G> {
  final I? libraryItem;

  LocalGalleryViewCardLoaded({
    this.libraryItem,
  });
}
