// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'web_browser_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WebBrowserPageResult _$WebBrowserPageResultFromJson(Map json) =>
    WebBrowserPageResult(
      headers: Map<String, String>.from(json['headers'] as Map),
      cookies: Map<String, String>.from(json['cookies'] as Map),
      body: json['body'] as String,
    );

Map<String, dynamic> _$WebBrowserPageResultToJson(
        WebBrowserPageResult instance) =>
    <String, dynamic>{
      'headers': instance.headers,
      'cookies': instance.cookies,
      'body': instance.body,
    };
