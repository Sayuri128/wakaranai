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
    return Card(
      elevation: 8.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              if (configInfo.logoUrl.contains('.svg'))
                SvgPicture.network(configInfo.logoUrl,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholderBuilder: (BuildContext context) =>
                        _buildSourceLogoPlaceholder(),
                    headers: const <String, String>{
                      "user-agent":
                          "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                    })
              else
                CachedNetworkImage(
                  imageUrl: configInfo.logoUrl,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (BuildContext context, String url) =>
                      _buildSourceLogoPlaceholder(),
                  errorWidget:
                      (BuildContext context, String url, Object error) =>
                          _buildSourceLogoPlaceholder(),
                  httpHeaders: const <String, String>{
                    "user-agent":
                        "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                  },
                ),
              const SizedBox(height: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    configInfo.name.trim(),
                    style: medium(size: 16),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        configInfo.language.trim(),
                        style: regular(size: 14),
                      ),
                      const SizedBox(width: 8),
                      if (configInfo.nsfw)
                        Text(
                          S.current.home_nsfw_suffix,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        )
                    ],
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSourceLogoPlaceholder() {
    return Container(
      height: 80,
      width: 120,
      decoration: BoxDecoration(
          color: AppColors.backgroundColor,
          borderRadius: BorderRadius.circular(16.0)),
    );
  }
}
