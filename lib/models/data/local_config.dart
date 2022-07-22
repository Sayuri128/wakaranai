import 'dart:io';

import 'package:wakascript/api_controller.dart';

class LocalConfig {

  final File file;
  final String code;
  final ApiClient client;

  const LocalConfig({
    required this.file,
    required this.code,
    required this.client,
  });
}
