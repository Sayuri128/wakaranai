import 'package:wakaranai/models/data/local_gallery_view.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class LibraryItem {
  final int? id;
  final int localApiClientId;
  final LocalGalleryView localGalleryView;
  final ConfigInfoType type;

  LibraryItem(
      {this.id,
      required this.localApiClientId,
      required this.localGalleryView,
      required this.type});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LibraryItem &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
