import 'package:h_reader/models/nhentai/doujinshi/images/images.dart';

class NHentaiUrls {
  static String thumbnailUrl(String mediaId, ImageType type) =>
      'https://t5.nhentai.net/galleries/${mediaId}/thumb.${_imageType(type)}';

  static String _imageType(ImageType type) {
    switch (type) {
      case ImageType.p:
        return 'png';
      case ImageType.j:
        return 'jpg';
    }
  }
}
