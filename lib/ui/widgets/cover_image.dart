import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/utils/images.dart';

class CoverImage extends StatelessWidget {
  const CoverImage({
    super.key,
    required this.url,
    required this.logicalWidth,
    required this.placeholder,
  });

  final String url;
  final double logicalWidth;
  final WidgetBuilder placeholder;

  @override
  Widget build(BuildContext context) {
    final int decodeWidth = decodeWidthFor(context, logicalWidth);
    if (isLocalFilePath(url)) {
      return Image.file(
        File(url),
        cacheWidth: decodeWidth,
        fit: BoxFit.cover,
        errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
            placeholder(context),
      );
    }
    return CachedNetworkImage(
      imageUrl: url,
      memCacheWidth: decodeWidth,
      fit: BoxFit.cover,
      placeholder: (BuildContext context, String _) => placeholder(context),
      errorWidget: (BuildContext context, String _, Object __) =>
          placeholder(context),
    );
  }
}
