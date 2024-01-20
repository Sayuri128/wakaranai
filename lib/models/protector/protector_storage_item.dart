import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/models/web_browser_result/web_browser_result.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';

part 'protector_storage_item.g.dart';

@JsonSerializable(explicitToJson: true)
class ProtectorStorageItem {
  factory ProtectorStorageItem.fromJson(Map<String, dynamic> json) =>
      _$ProtectorStorageItemFromJson(json);
  Map<String, dynamic> toJson() => _$ProtectorStorageItemToJson(this);

  final String uid;
  final WebBrowserPageResult data;

  const ProtectorStorageItem({
    required this.uid,
    required this.data,
  });
}
