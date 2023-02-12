import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/local_configs/local_configs_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/configs_group.dart';
import 'package:wakaranai/ui/home/configs_page/configs_source_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class RemoteConfigPage extends StatelessWidget {
  RemoteConfigPage({Key? key}) : super(key: key);

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
                children: [
                  BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
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
                                  context
                                      .read<RemoteConfigsCubit>()
                                      .getConfigs();
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
                        return _buildRemoteConfigs(state);
                      }

                      return const SizedBox();
                    },
                  ),
                  BlocBuilder<LocalConfigsCubit, LocalConfigsState>(
                    builder: (context, state) {
                      if (state is LocalConfigsLoaded) {
                        if (state.localApiClients.isEmpty) {
                          return Center(
                            child: Text(
                              "No saved configs",
                              style: medium(color: AppColors.mainGrey),
                            ),
                          );
                        } else {
                          return ListView.builder(
                            itemCount: state.localApiClients.length,
                            itemBuilder: (context, index) {
                              final item = state.localApiClients[index];

                              return ListTile(
                                leading: CachedNetworkImage(
                                  imageUrl: item.localConfigInfo.logoUrl,
                                  width: 32,
                                  height: 32,
                                ),
                                title: Text(item.localConfigInfo.name,
                                    style: medium(size: 18)),
                                trailing: BlocBuilder<RemoteConfigsCubit,
                                    RemoteConfigsState>(
                                  builder: (context, state) {
                                    if (state is RemoteConfigsLoaded) {
                                      return const SizedBox();
                                    }

                                    return const CircularProgressIndicator(
                                      color: AppColors.primary,
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
                  )
                ],
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

  Widget _buildRemoteConfigs(RemoteConfigsLoaded state) {
    return Stack(
      children: [
        ListView(
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
      ],
    );
  }
}
