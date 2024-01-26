import 'package:json_annotation/json_annotation.dart';

T? decodeEnum<T>(List<T> values, String? value) {
  if (value == null) return null;
  return values.firstWhere((element) => element.toString() == value);
}

String encodeEnum<T>(T value) {
  return value.toString();
}
