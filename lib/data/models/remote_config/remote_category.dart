import 'package:json_annotation/json_annotation.dart';

enum RemoteCategory {
  @JsonValue("anime")
  anime,
  @JsonValue("manga")
  manga
}
