// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'github_response_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GithubResponseModel _$GithubResponseModelFromJson(Map json) =>
    GithubResponseModel(
      payload: GithubPayloadModel.fromJson(
          Map<String, dynamic>.from(json['payload'] as Map)),
    );

Map<String, dynamic> _$GithubResponseModelToJson(
        GithubResponseModel instance) =>
    <String, dynamic>{
      'payload': instance.payload.toJson(),
    };
