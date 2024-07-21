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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: InkWell(
        splashColor: AppColors.mediumLight.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            color: AppColors.backgroundColor,
            boxShadow: [
              BoxShadow(
                color: AppColors.shadowColor,
                offset: const Offset(0, 2),
                blurRadius: 4.0,
              ),
            ],
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppColors.backgroundColor,
                    borderRadius: BorderRadius.circular(8.0),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.shadowColor,
                        offset: const Offset(0, 2),
                        blurRadius: 4.0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: configInfo.logoUrl.contains('.svg')
                        ? SvgPicture.network(configInfo.logoUrl,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholderBuilder: (BuildContext context) =>
                                _buildSourceLogoPlaceholder(),
                            headers: const <String, String>{
                                "user-agent":
                                    "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                              })
                        : CachedNetworkImage(
                            imageUrl: configInfo.logoUrl,
                            height: 64,
                            fit: BoxFit.cover,
                            placeholder: (BuildContext context, String url) =>
                                _buildSourceLogoPlaceholder(),
                            errorWidget: (BuildContext context, String url,
                                    Object error) =>
                                _buildSourceLogoPlaceholder(),
                            httpHeaders: const <String, String>{
                              "user-agent":
                                  "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                            },
                          ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Text(configInfo.name.trim(), style: medium(size: 16)),
                        if (configInfo.nsfw) ...[
                          const SizedBox(width: 8),
                          Text(
                            S.current.home_nsfw_suffix,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ]
                      ],
                    ),
                    Text(configInfo.language.trim(), style: regular(size: 14)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceLogoPlaceholder() {
    return Container(
      height: 64,
      width: 64,
      decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16.0)),
    );
  }
}
