import 'package:json_annotation/json_annotation.dart';

part 'remote_script.g.dart';

@JsonSerializable()
class RemoteScript {

	factory RemoteScript.fromJson(Map<String, dynamic> json) => _$RemoteScriptFromJson(json);
	Map<String, dynamic> toJson() => _$RemoteScriptToJson(this);

  final String path;
  final String script;

  const RemoteScript({
    required this.path,
    required this.script,
  });
}