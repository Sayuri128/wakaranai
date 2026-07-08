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

class ConfigsGroup extends StatefulWidget {
  const ConfigsGroup(
      {super.key, required this.title, required this.remoteConfigs});

  final String title;
  final List<BaseExtension> remoteConfigs;

  @override
  State<ConfigsGroup> createState() => _ConfigsGroupState();
}

class _ConfigsGroupState extends State<ConfigsGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ...widget.remoteConfigs.map(
                        (BaseExtension e) => ConfigCard(
                          configInfo: e.config,
                          onTap: () => _onCardClick(context, e),
                        ),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
        child: Row(
          children: <Widget>[
            Text(widget.title,
                style: semibold(size: 18, color: AppColors.mainWhite)),
            const SizedBox(width: 8),
            _buildCountBadge(widget.remoteConfigs.length),
            const Spacer(),
            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              turns: _expanded ? 0.5 : 0.0,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.mainGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$count', style: medium(size: 12, color: AppColors.mainGrey)),
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
