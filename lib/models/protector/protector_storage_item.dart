import 'package:json_annotation/json_annotation.dart';

part 'protector_storage_item.g.dart';

@JsonSerializable()
class ProtectorStorageItem {

	factory ProtectorStorageItem.fromJson(Map<String, dynamic> json) => _$ProtectorStorageItemFromJson(json);
	Map<String, dynamic> toJson() => _$ProtectorStorageItemToJson(this);

  final String uid;
  final Map<String, dynamic> headers;

  const ProtectorStorageItem({
    required this.uid,
    required this.headers,
  });


}