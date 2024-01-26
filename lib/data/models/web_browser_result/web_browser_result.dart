import 'package:json_annotation/json_annotation.dart';

part 'web_browser_result.g.dart';

@JsonSerializable(explicitToJson: true)
class WebBrowserPageResult {
  factory WebBrowserPageResult.fromJson(Map<String, dynamic> json) =>
      _$WebBrowserPageResultFromJson(json);

  Map<String, dynamic> toJson() => _$WebBrowserPageResultToJson(this);

  final Map<String, String> headers;
  final Map<String, String> cookies;
  final String body;

  const WebBrowserPageResult({
    required this.headers,
    required this.cookies,
    required this.body,
  });
}
