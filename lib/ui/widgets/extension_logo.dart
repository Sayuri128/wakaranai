import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_source.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/images.dart';

class ExtensionLogo extends StatelessWidget {
  const ExtensionLogo({super.key, required this.configInfo, this.size = 56});

  final ConfigInfo configInfo;
  final double size;

  static const Map<String, String> _logoHeaders = <String, String>{
    "user-agent":
        "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
  };

  double get _radius => size >= 48 ? 12 : 10;

  double get _iconSize => size < 32 ? size * 0.6 : 24;

  @override
  Widget build(BuildContext context) {
    final IconData? builtInIcon = _builtInIcon();
    if (builtInIcon != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(_radius),
        child: SizedBox(
          width: size,
          height: size,
          child: ColoredBox(
            color: AppColors.primary.withValues(alpha: 0.16),
            child: Icon(
              builtInIcon,
              color: AppColors.primary,
              size: _iconSize,
            ),
          ),
        ),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(_radius),
      child: SizedBox(
        width: size,
        height: size,
        child: configInfo.logoUrl.contains('.svg')
            ? SvgPicture.network(
                configInfo.logoUrl,
                fit: BoxFit.cover,
                placeholderBuilder: (BuildContext context) =>
                    _buildPlaceholder(),
                headers: _logoHeaders,
              )
            : CachedNetworkImage(
                imageUrl: configInfo.logoUrl,
                memCacheWidth: decodeWidthFor(context, size),
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    _buildPlaceholder(),
                errorWidget: (BuildContext context, String url, Object error) =>
                    _buildPlaceholder(),
                httpHeaders: _logoHeaders,
              ),
      ),
    );
  }

  IconData? _builtInIcon() {
    if (LocalSource.isLocal(configInfo.uid)) {
      return Icons.folder_rounded;
    }
    if (LocalBooksSource.isLocal(configInfo.uid)) {
      return Icons.menu_book_rounded;
    }
    return null;
  }

  Widget _buildPlaceholder() {
    return ColoredBox(
      color: AppColors.shimmerBase,
      child: Center(
        child: Icon(
          Icons.extension_rounded,
          color: Colors.white24,
          size: _iconSize,
        ),
      ),
    );
  }
}
