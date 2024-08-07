import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
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
    return SliverList(
      delegate: SliverChildListDelegate(
        <Widget>[
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(title,
                style: semibold(size: 18, color: AppColors.mainWhite)),
          ),
          const SizedBox(height: 16.0),
          ...remoteConfigs.map(
            (BaseExtension e) => ConfigCard(
              configInfo: e.config,
              onTap: () {
                _onCardClick(context, e);
              },
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  void _onCardClick(
    BuildContext context,
    BaseExtension remoteConfig,
  ) async {
    if (remoteConfig.config.type == ConfigInfoType.MANGA) {
      Navigator.of(context)
          .pushNamed(
              Routes.mangaServiceViewer,
              arguments: MangaServiceViewData(remoteConfig: remoteConfig))
          .then((_) {
        context.read<MangaActivityHistoryCubit>().init();
      });
    } else if (remoteConfig.config.type == ConfigInfoType.ANIME) {
      Navigator.of(context)
          .pushNamed(
              Routes.animeServiceViewer,
              arguments: AnimeServiceViewerData(remoteConfig: remoteConfig))
          .then((_) {
        context.read<AnimeActivityHistoryCubit>().init();
      });
    }
  }
}
