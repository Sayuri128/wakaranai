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
      appBar: PreferredSize(
        preferredSize: const Size(60, double.maxFinite),
        child: BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
          builder: (context, state) {
            return ElevatedAppbar(
              title: Text(
                state is RemoteConfigsLoaded
                    ? state.sourceName
                    : S.current.home_remote_configs_page_appbar_title,
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
      ),
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
        if (state is RemoteConfigsError) {
          return Center(
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

  Widget _buildRemoteConfigs(BuildContext context, RemoteConfigsLoaded state) {
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
      child: ListView(
        children: <Widget>[
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
