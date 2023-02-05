import 'dart:io';

import 'package:wakascript/api_clients/manga_api_client.dart';

class LocalConfig {

  final File file;
  final String code;
  final MangaApiClient client;

  const LocalConfig({
    required this.file,
    required this.code,
    required this.client,
  });
}
