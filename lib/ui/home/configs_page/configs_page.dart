import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/configs_group.dart';
import 'package:wakaranai/ui/home/configs_page/configs_list_skeleton.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigPage extends StatelessWidget {
  const ConfigPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: _buildRemoteConfigsPage(),
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

  Widget _buildRemoteConfigs(BuildContext context, RemoteConfigsState state) {
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
        slivers: <Widget>[
          _buildAppBar(context, state),
          if (state is RemoteConfigsLoading)
            const SliverToBoxAdapter(child: ConfigsListSkeleton())
          else if (state is RemoteConfigsError)
            SliverFillRemaining(
              hasScrollBody: false,
              child: ServiceViewerMessage(
                icon: Icons.error_outline_rounded,
                title: S.current.home_extensions_error_title,
                message: state.message,
                actions: <Widget>[
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.mainBlack,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    onPressed: () => context.read<RemoteConfigsCubit>().init(),
                    icon: const Icon(Icons.refresh_rounded),
                    label: Text(S.current.service_view_retry_button_title),
                  ),
                ],
              ),
            )
          else if (state is RemoteConfigsLoaded)
            ..._buildLoaded(context, state),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, RemoteConfigsState state) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundColor,
      surfaceTintColor: AppColors.backgroundColor,
      foregroundColor: AppColors.mainWhite,
      elevation: 0,
      scrolledUnderElevation: 0,
      pinned: true,
      floating: true,
      snap: true,
      centerTitle: false,
      titleSpacing: 16,
      automaticallyImplyLeading: false,
      title: Text(
        state is RemoteConfigsLoaded
            ? state.sourceName
            : S.current.home_remote_configs_page_appbar_title,
        style: semibold(size: 22),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: _buildSourcesButton(context),
        ),
      ],
    );
  }

  Widget _buildSourcesButton(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.08),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context)
              .pushNamed(Routes.myExtensionSources)
              .then((Object? value) {
            if (value is ExtensionSourcesPageResult) {
              context.read<RemoteConfigsCubit>().changeSource(value);
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.swap_horiz_rounded,
                  size: 18, color: AppColors.mainWhite),
              const SizedBox(width: 6),
              Text(S.current.home_sources_button, style: medium(size: 14)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildLoaded(BuildContext context, RemoteConfigsLoaded state) {
    final SettingsState settingsState = context.watch<SettingsCubit>().state;
    final bool showNsfw =
        settingsState is SettingsInitialized && settingsState.showNsfw;

    final List<BaseExtension> mangaConfigs =
        _filterNsfw(state.mangaRemoteConfigs, showNsfw);
    final List<BaseExtension> animeConfigs =
        _filterNsfw(state.animeRemoteConfigs, showNsfw);

    if (mangaConfigs.isEmpty && animeConfigs.isEmpty) {
      return <Widget>[
        SliverFillRemaining(
          hasScrollBody: false,
          child: ServiceViewerMessage(
            icon: Icons.extension_off_rounded,
            title: S.current.home_no_extensions_title,
            message: S.current.home_no_extensions_message,
          ),
        ),
      ];
    }

    return <Widget>[
      if (mangaConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('manga'),
          title: S.current.home_manga_group_title,
          remoteConfigs: mangaConfigs,
        ),
      if (animeConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('anime'),
          title: S.current.home_anime_group_title,
          remoteConfigs: animeConfigs,
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  List<BaseExtension> _filterNsfw(
      List<BaseExtension> configs, bool showNsfw) {
    if (showNsfw) return configs;
    return configs
        .where((BaseExtension e) => !e.config.nsfw)
        .toList(growable: false);
  }
}
