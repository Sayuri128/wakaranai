import 'dart:convert';

List<String> decodeJsonStringList(String data) {
  return (jsonDecode(data) as List<dynamic>).map((e) => e.toString()).toList();
}
