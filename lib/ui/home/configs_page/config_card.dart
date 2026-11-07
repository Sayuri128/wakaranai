import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';
import 'package:wakaranai/ui/home/configs_page/extension_compatibility_texts.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/images.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigCard extends StatelessWidget {
  const ConfigCard({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.configInfo,
    this.listingStatus = ExtensionListingStatus.available,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ConfigInfo configInfo;
  final ExtensionListingStatus listingStatus;

  static const double _disabledOpacity = 0.5;

  static const Map<String, String> _logoHeaders = <String, String>{
    "user-agent":
        "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
  };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Opacity(
                  opacity: _contentOpacity,
                  child: _buildLogo(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Opacity(
                        opacity: _contentOpacity,
                        child: Text(
                          configInfo.name.trim(),
                          style: semibold(size: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          if (configInfo.language.trim().isNotEmpty)
                            _buildChip(configInfo.language.trim()),
                          if (configInfo.nsfw)
                            _buildChip(S.current.home_nsfw_suffix,
                                color: AppColors.red),
                        ],
                      ),
                      ..._buildStatusMessage(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildTrailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _contentOpacity {
    if (listingStatus.isDisabled) {
      return _disabledOpacity;
    }
    return 1;
  }

  List<Widget> _buildStatusMessage() {
    final String? message = extensionListingStatusMessage(listingStatus);
    if (message == null) {
      return const <Widget>[];
    }
    final Color color = listingStatus.isDisabled
        ? AppColors.mainGrey
        : AppColors.primary;
    return <Widget>[
      const SizedBox(height: 6),
      Text(
        message,
        style: regular(size: 12, color: color),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }

  Widget _buildTrailingIcon() {
    if (listingStatus.isDisabled) {
      return Icon(Icons.system_update_rounded, color: AppColors.mainGrey);
    }
    return Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey);
  }

  Widget _buildLogo(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 56,
        height: 56,
        child: configInfo.logoUrl.contains('.svg')
            ? SvgPicture.network(
                configInfo.logoUrl,
                fit: BoxFit.cover,
                placeholderBuilder: (BuildContext context) =>
                    _buildLogoPlaceholder(),
                headers: _logoHeaders,
              )
            : CachedNetworkImage(
                imageUrl: configInfo.logoUrl,
                memCacheWidth: decodeWidthFor(context, 56),
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String url) =>
                    _buildLogoPlaceholder(),
                errorWidget:
                    (BuildContext context, String url, Object error) =>
                        _buildLogoPlaceholder(),
                httpHeaders: _logoHeaders,
              ),
      ),
    );
  }

  Widget _buildLogoPlaceholder() {
    return ColoredBox(
      color: AppColors.shimmerBase,
      child: const Center(
        child: Icon(Icons.extension_rounded, color: Colors.white24, size: 24),
      ),
    );
  }

  Widget _buildChip(String label, {Color? color}) {
    final Color tint = color ?? AppColors.mainGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: medium(size: 11, color: color ?? AppColors.mainWhite),
      ),
    );
  }
}
