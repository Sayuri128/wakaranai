import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wakaranai_json_runtime/models/config_info/config_info.dart';

class ConfigCard extends StatelessWidget {
  const ConfigCard({Key? key, required this.configInfo}) : super(key: key);

  final ConfigInfo configInfo;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      elevation: 8.0,
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
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            const SizedBox(height: 8),
            Text(configInfo.name)
          ],
        ),
      ),
    );
  }
}
