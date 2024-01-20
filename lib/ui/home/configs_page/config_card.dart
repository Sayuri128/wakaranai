import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigCard extends StatelessWidget {
  const ConfigCard({Key? key, this.onTap, required this.configInfo})
      : super(key: key);

  final VoidCallback? onTap;
  final ConfigInfo configInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 8.0,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              if (configInfo.logoUrl.contains('.svg'))
                SvgPicture.network(configInfo.logoUrl,
                    height: 80,
                    fit: BoxFit.cover,
                    placeholderBuilder: (context) =>
                        _buildSourceLogoPlaceholder(),
                    headers: const {
                      "user-agent":
                          "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                    })
              else
                CachedNetworkImage(
                  imageUrl: configInfo.logoUrl,
                  height: 80,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => _buildSourceLogoPlaceholder(),
                  errorWidget: (context, url, error) =>
                      _buildSourceLogoPlaceholder(),
                  httpHeaders: const {
                    "user-agent":
                        "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                  },
                ),
              const SizedBox(height: 8),
              Text(
                configInfo.name,
                style: medium(),
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
