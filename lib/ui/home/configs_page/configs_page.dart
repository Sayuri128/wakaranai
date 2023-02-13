import 'package:cached_network_image/cached_network_image.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/local_configs/local_configs_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/ui/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/home/configs_page/configs_group.dart';
import 'package:wakaranai/ui/home/configs_page/configs_source_dialog.dart';
import 'package:wakaranai/ui/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/models/config_info/config_info.dart';

class ConfigPage extends StatelessWidget {
  ConfigPage({Key? key}) : super(key: key);

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
              padding: const EdgeInsets.only(top: 60),
              child: PageView(
                controller: _pageController,
                children: [_buildRemoteConfigsPage(), _buildLocalConfigsPage()],
              )),
          Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 60 + MediaQuery.of(context).padding.top,
                decoration:
                    BoxDecoration(color: AppColors.backgroundColor, boxShadow: [
                  BoxShadow(
                      color: AppColors.mainBlack.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2)
                ]),
                child: Padding(
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text(S.current.remote_configs_page_appbar_title,
                            style: medium(size: 24)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ConfigsSourceDialog());
                            },
                            icon: const Icon(
                              Icons.filter_list_rounded,
                              color: AppColors.mainWhite,
                            )),
                      )
                    ],
                  ),
                ),
              ))
        ],
      ),
    );
  }

  BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>
      _buildRemoteConfigsPage() {
    return BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
      builder: (context, state) {
        if (state is RemoteConfigsError) {
          return Center(
              child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  state.message,
                  style: regular(size: 18, color: AppColors.red),
                ),
                IconButton(
                  onPressed: () {
                    context.read<RemoteConfigsCubit>().getConfigs();
                  },
                  icon: const Icon(Icons.refresh),
                  splashRadius: 18,
                )
              ],
            ),
          ));
        } else if (state is RemoteConfigsLoading) {
          return const Center(
            child: CircularProgressIndicator(
              color: AppColors.primary,
            ),
          );
        } else if (state is RemoteConfigsLoaded) {
          return _buildRemoteConfigs(context, state);
        }

        return const SizedBox();
      },
    );
  }

  BlocBuilder<LocalConfigsCubit, LocalConfigsState> _buildLocalConfigsPage() {
    return BlocBuilder<LocalConfigsCubit, LocalConfigsState>(
      builder: (context, state) {
        if (state is LocalConfigsLoaded) {
          if (state.localConfigsInfo.isEmpty) {
            return Center(
              child: Text(
                S.current.local_configs_0_length,
                style: medium(color: AppColors.mainGrey),
              ),
            );
          } else {
            return BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
              builder: (context, remoteConfigsState) {
                return RefreshIndicator(
                  color: AppColors.primary,
                  onRefresh: () {
                    return Future.delayed(
                      const Duration(milliseconds: 250),
                      () {
                        context.read<LocalConfigsCubit>().init();
                      },
                    );
                  },
                  child: ListView.builder(
                    itemCount: state.localConfigsInfo.length,
                    itemBuilder: (context, index) {
                      final item = state.localConfigsInfo[index];

                      return ListTile(
                        leading: CachedNetworkImage(
                          imageUrl: item.logoUrl,
                          width: 32,
                          height: 32,
                        ),
                        onTap: () {
                          switch (item.type) {
                            case ConfigInfoType.MANGA:
                              Navigator.of(context).pushNamed(
                                  Routes.mangaServiceViewer,
                                  arguments: MangaServiceViewData(
                                      localConfigInfo: item));
                              break;
                            case ConfigInfoType.ANIME:
                              Navigator.of(context).pushNamed(
                                  Routes.animeServiceViewer,
                                  arguments: AnimeServiceViewerData(
                                      localConfigInfo: item));
                              break;
                          }
                        },
                        title: Text(item.name, style: medium(size: 18)),
                        trailing: Builder(
                          builder: (context) {
                            if (remoteConfigsState is RemoteConfigsLoaded) {
                              final RemoteConfig? remoteConfig =
                                  remoteConfigsState.mangaRemoteConfigs
                                          .firstWhereOrNull((element) =>
                                              element.config.uid == item.uid) ??
                                      remoteConfigsState.animeRemoteConfigs
                                          .firstWhereOrNull((element) =>
                                              element.config.uid == item.uid);

                              if (remoteConfig?.config.version !=
                                  item.version) {
                                return TextButton(
                                    onPressed: () {
                                      context
                                          .read<LocalConfigsCubit>()
                                          .update(item, remoteConfig!);
                                    },
                                    child: Text(
                                      S.current.local_configs_update_button,
                                      style:
                                          medium(color: AppColors.mediumDark),
                                    ));
                              }

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14.0),
                                child: Text(
                                  S.current.local_configs_no_updates,
                                  style: medium(color: AppColors.mainGrey),
                                ),
                              );
                            }

                            return const CircularProgressIndicator(
                              color: AppColors.primary,
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
        } else {
          return Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildRemoteConfigs(BuildContext context, RemoteConfigsLoaded state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return Future.delayed(
          const Duration(milliseconds: 300),
          () {
            context.read<RemoteConfigsCubit>().getConfigs();
          },
        );
      },
      child: ListView(
        children: [
          const SizedBox(
            height: 12,
          ),
          ConfigsGroup(
            title: S.current.home_manga_group_title,
            remoteConfigs: state.mangaRemoteConfigs,
          ),
          const SizedBox(
            height: 48,
          ),
          ConfigsGroup(
              title: S.current.home_anime_group_title,
              remoteConfigs: state.animeRemoteConfigs)
        ],
      ),
    );
  }
}
