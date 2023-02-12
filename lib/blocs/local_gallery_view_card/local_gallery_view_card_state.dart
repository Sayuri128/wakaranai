part of 'local_gallery_view_card_cubit.dart';

@immutable
abstract class LocalGalleryViewCardState {}

class LocalGalleryViewCardInitial extends LocalGalleryViewCardState {}

class LocalGalleryViewCardLoaded extends LocalGalleryViewCardState {
  final LibraryItem? libraryItem;

  LocalGalleryViewCardLoaded({
    this.libraryItem,
  });
}
