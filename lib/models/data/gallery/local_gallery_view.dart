
import 'package:wakascript/models/gallery_view.dart';

abstract class LocalGalleryView extends GalleryView {
  final int? id;

  LocalGalleryView(
      this.id, String uid, Map<String, dynamic> data)
      : super(uid: uid, data: data);
}
