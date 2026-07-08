import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigCard extends StatelessWidget {
  const ConfigCard({super.key, this.onTap, required this.configInfo});

  final VoidCallback? onTap;
  final ConfigInfo configInfo;

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
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                _buildLogo(),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        configInfo.name.trim(),
                        style: semibold(size: 16),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.mainGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
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
