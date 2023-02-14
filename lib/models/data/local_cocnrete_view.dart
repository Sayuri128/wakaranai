import 'package:wakascript/models/gallery_view.dart';

class LocalConcreteView extends GalleryView {
  late final int? id;

  LocalConcreteView(
      {required int? id,
      required String uid,
      required Map<String, dynamic> data})
      : super(uid: uid, data: data);

  @override
  callFunction(String name, {List? ordinalArguments}) {}

  @override
  getField(String name) {}

  @override
  void setField(String name, value) {}
}
