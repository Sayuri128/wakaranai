import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

ImageProvider getImageProvider(String url, {Map<String, String>? headers}) {
  return url.startsWith("data:")
      ? Image.memory(base64Decode(url.split(',').last)).image
      : CachedNetworkImageProvider(url, headers: headers);
}
