import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakaranai/models/serializable_object.dart';

part 'configs_source_item.g.dart';

@JsonSerializable()
class ConfigsSourceItem implements SerializableObject {
  factory ConfigsSourceItem.fromJson(Map<String, dynamic> json) =>
      _$ConfigsSourceItemFromJson(json);

  Map<String, dynamic> toJson() => _$ConfigsSourceItemToJson(this);

  int? id;
  final String baseUrl;
  final String name;
  final ConfigsSourceType type;

  ConfigsSourceItem({
    this.id,
    required this.baseUrl,
    required this.name,
    required this.type,
  });

  @override
  Map<String, dynamic> toMap() => toJson();
}
