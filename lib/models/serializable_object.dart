abstract class SqSerializableObject {
  Map<String, dynamic> toMap({bool lazy = true});
  int? getId();
}
