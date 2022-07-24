import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class ConfigCard extends StatelessWidget {
  const ConfigCard({Key? key, this.onTap, required this.configInfo}) : super(key: key);

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
                SvgPicture.network(
                  configInfo.logoUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                )
              else
                Image.network(
                  configInfo.logoUrl,
                  height: 80,
                  fit: BoxFit.cover,
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
