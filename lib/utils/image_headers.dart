import 'package:capyscript/api_clients/api_client.dart';

const String _imageHeadersFunction = 'getImageHeaders';

extension OptionalImageHeaders on ApiClient {
  Future<Map<String, String>> imageHeadersOrEmpty({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    if (!interpreter.hasFunction(_imageHeadersFunction)) {
      return const <String, String>{};
    }
    return getImageHeaders(uid: uid, data: data);
  }
}
