import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

const int _inlineImageCacheSize = 64;

final LinkedHashMap<String, MemoryImage> _inlineImages =
    LinkedHashMap<String, MemoryImage>();

ImageProvider getImageProvider(
  String url, {
  Map<String, String>? headers,
  int? decodeWidth,
}) {
  final ImageProvider provider = _providerFor(url, headers);
  return ResizeImage.resizeIfNeeded(decodeWidth, null, provider);
}

ImageProvider _providerFor(String url, Map<String, String>? headers) {
  if (url.startsWith("data:")) {
    return _inlineImage(url);
  }
  if (isLocalFilePath(url)) {
    return FileImage(File(url));
  }
  return CachedNetworkImageProvider(url, headers: headers);
}

bool isLocalFilePath(String url) {
  return url.startsWith('/') || RegExp(r'^[A-Za-z]:[\/]').hasMatch(url);
}

int decodeWidthFor(BuildContext context, double logicalWidth) {
  return (logicalWidth * MediaQuery.devicePixelRatioOf(context)).ceil();
}

MemoryImage _inlineImage(String url) {
  final MemoryImage? cached = _inlineImages.remove(url);
  final MemoryImage image =
      cached ?? MemoryImage(base64Decode(url.split(',').last));
  _inlineImages[url] = image;
  if (_inlineImages.length > _inlineImageCacheSize) {
    _inlineImages.remove(_inlineImages.keys.first);
  }
  return image;
}
