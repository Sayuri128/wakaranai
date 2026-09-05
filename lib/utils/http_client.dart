import 'package:dio/dio.dart';

const Duration kHttpConnectTimeout = Duration(seconds: 20);
const Duration kHttpReceiveTimeout = Duration(seconds: 60);
const Duration kHttpSendTimeout = Duration(seconds: 30);

Dio createDio({
  Map<String, String>? headers,
  bool acceptAllStatuses = false,
  Duration? receiveTimeout,
}) {
  return Dio(
    BaseOptions(
      connectTimeout: kHttpConnectTimeout,
      receiveTimeout: receiveTimeout ?? kHttpReceiveTimeout,
      sendTimeout: kHttpSendTimeout,
      headers: headers,
      validateStatus: acceptAllStatuses ? (_) => true : null,
    ),
  );
}
