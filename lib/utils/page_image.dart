import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/widgets.dart';

bool isLocalPagePath(String path) =>
    !path.startsWith('http') && !path.startsWith('data:');

ImageProvider pageImageProvider(String path, Map<String, String> headers) {
  if (isLocalPagePath(path)) {
    return FileImage(File(path));
  }
  return CachedNetworkImageProvider(path, headers: headers);
}
