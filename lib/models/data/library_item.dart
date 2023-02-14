import 'package:wakaranai/models/data/local_gallery_view.dart';

class LibraryItem<G extends LocalGalleryView> {
  final int? id;
  final int localApiClientId;
  final G localGalleryView;

  LibraryItem(
      {this.id,
      required this.localApiClientId,
      required this.localGalleryView});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
