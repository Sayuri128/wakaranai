import 'package:json_annotation/json_annotation.dart';
import 'package:wakaranai/data/models/github/payload/github_payload_model.dart';

part 'github_response_model.g.dart';

@JsonSerializable(explicitToJson: true)
class GithubResponseModel {
  factory GithubResponseModel.fromJson(Map<String, dynamic> json) =>
      _$GithubResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$GithubResponseModelToJson(this);

  final GithubPayloadModel payload;

  const GithubResponseModel({
    required this.payload,
  });
}
