import 'dart:collection';
import 'dart:convert';

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
  final ImageProvider provider = url.startsWith("data:")
      ? _inlineImage(url)
      : CachedNetworkImageProvider(url, headers: headers);
  return ResizeImage.resizeIfNeeded(decodeWidth, null, provider);
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
