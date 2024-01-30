import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/extension/base_extension.dart';
import 'package:wakaranai/data/models/remote_config/remote_category.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/ui/home/configs_page/config_card.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

import '../../routes.dart';

class ConfigsGroup extends StatelessWidget {
  const ConfigsGroup(
      {super.key, required this.title, required this.remoteConfigs});

  final String title;
  final List<BaseExtension> remoteConfigs;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(title,
                style: semibold(size: 18, color: AppColors.mainWhite)),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Wrap(
              children: <Widget>[
                ...remoteConfigs.map((BaseExtension e) => ConfigCard(
                    configInfo: e.config,
                    onTap: () {
                      _onCardClick(context, e);
                    })),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCardClick(
    BuildContext context,
    BaseExtension remoteConfig,
  ) async {
    if (remoteConfig.category == RemoteCategory.manga) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.mangaServiceViewer, (Route route) => false,
          arguments: MangaServiceViewData(remoteConfig: remoteConfig));
    } else if (remoteConfig.category == RemoteCategory.anime) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.animeServiceViewer, (Route route) => false,
          arguments: AnimeServiceViewerData(remoteConfig: remoteConfig));
    }
  }
}
