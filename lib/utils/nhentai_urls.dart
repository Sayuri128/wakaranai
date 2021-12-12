import 'package:flutter/material.dart';
import 'package:h_reader/models/nhentai/doujinshi/images/images.dart';

class NHentaiUrls {
  static String thumbnailUrl(String mediaId, ImageType type) =>
      'https://t5.nhentai.net/galleries/$mediaId/thumb.${_imageType(type)}';

  static String coverUrl(String mediaId, ImageType type) =>
      'https://t5.nhentai.net/galleries/$mediaId/cover.${_imageType(type)}';

  static String _imageType(ImageType type) {
    switch (type) {
      case ImageType.p:
        return 'png';
      case ImageType.j:
        return 'jpg';
    }
  }
}

extension StringX on String {
  String get overflow =>
      Characters(this).replaceAll(Characters(''), Characters('\u{200B}')).toString();
}
