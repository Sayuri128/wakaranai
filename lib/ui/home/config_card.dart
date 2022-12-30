import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakascript/models/config_info/config_info.dart';

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
                    width: 80,
                    height: 80,
                    fit: BoxFit.cover,
                    headers: const {
                      "user-agent":
                          "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                    })
              else
                Image.network(
                  configInfo.logoUrl,
                  height: 80,
                  fit: BoxFit.cover,
                  headers: const {
                    "user-agent":
                        "Mozilla/5.0 (Linux; Android 9; SM-G960N Build/PQ3B.190801.002; wv) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.114 Safari/537.36"
                  },
                ),
              const SizedBox(height: 8),
              Text(configInfo.name)
            ],
          ),
        ),
      ),
    );
  }
}
