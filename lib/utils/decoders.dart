import 'dart:convert';

List<String> decodeJsonStringList(String data) {
  return (jsonDecode(data) as List<dynamic>)
      .map((dynamic e) => e.toString())
      .toList();
}
