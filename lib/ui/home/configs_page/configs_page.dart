import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/configs_group.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/elevated_appbar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigPage extends StatelessWidget {
  ConfigPage({super.key});

  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: PageView(
        controller: _pageController,
        children: <Widget>[
          _buildRemoteConfigsPage(),
        ],
      ),
    );
  }

  BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>
      _buildRemoteConfigsPage() {
    return BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
      builder: (BuildContext context, RemoteConfigsState state) {
        return _buildRemoteConfigs(context, state);
      },
    );
  }

  Widget _buildRemoteConfigs(
    BuildContext context,
    RemoteConfigsState state,
  ) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () {
        return Future.delayed(
          const Duration(milliseconds: 300),
          () {
            context.read<RemoteConfigsCubit>().init();
          },
        );
      },
      child: CustomScrollView(
        slivers: [
          BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
            builder: (context, state) {
              return ElevatedAppbar(
                title: Text(
                  state is RemoteConfigsLoaded
                      ? state.sourceName
                      : "",
                  style: medium(size: 24),
                ),
                actions: IconButton(
                  onPressed: () {
                    Navigator.of(context)
                        .pushNamed(Routes.myExtensionSources)
                        .then((value) {
                      if (value is ExtensionSourcesPageResult) {
                        context.read<RemoteConfigsCubit>().changeSource(value);
                      }
                    });
                  },
                  icon: const Icon(
                    Icons.filter_list_rounded,
                    color: AppColors.mainWhite,
                  ),
                ),
              );
            },
          ),
          if (state is RemoteConfigsLoading) ...[
            SliverToBoxAdapter(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
          if (state is RemoteConfigsError) ...[
            SliverToBoxAdapter(
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 200,
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        state.message,
                        style: regular(size: 18, color: AppColors.red),
                      ),
                      IconButton(
                        onPressed: () {
                          context.read<RemoteConfigsCubit>().init();
                        },
                        icon: const Icon(Icons.refresh),
                        splashRadius: 18,
                      )
                    ],
                  ),
                )),
              ),
            ),
          ],
          if (state is RemoteConfigsLoaded) ...[
            ConfigsGroup(
              title: S.current.home_manga_group_title,
              remoteConfigs: state.mangaRemoteConfigs,
            ),
            ConfigsGroup(
                title: S.current.home_anime_group_title,
                remoteConfigs: state.animeRemoteConfigs),
          ]
        ],
      ),
    );
  }
}
