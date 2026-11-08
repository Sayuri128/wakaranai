import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/home/configs_page/configs_view_options.dart';
import 'package:wakaranai/services/configs_service/extension_instances.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_source.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/configs_filter.dart';
import 'package:wakaranai/ui/home/configs_page/configs_filter_bar.dart';
import 'package:wakaranai/ui/home/configs_page/configs_group.dart';
import 'package:wakaranai/ui/home/configs_page/configs_list_skeleton.dart';
import 'package:wakaranai/ui/home/configs_page/extension_sources/extension_sources_page_result.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/global_search/global_search_arguments.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigPage extends StatefulWidget {
  const ConfigPage({super.key});

  @override
  State<ConfigPage> createState() => _ConfigPageState();
}

class _ConfigPageState extends State<ConfigPage> {
  final ConfigsFilterPreferences _filterPreferences = ConfigsFilterPreferences();
  ConfigsFilter _filter = const ConfigsFilter();
  List<ExtensionDomain> _instances = const <ExtensionDomain>[];
  final ConfigsViewOptionsCubit _viewOptions = ConfigsViewOptionsCubit();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void initState() {
    super.initState();
    unawaited(_restoreFilter());
    unawaited(_loadInstances());
    unawaited(_viewOptions.init());
  }

  @override
  void dispose() {
    unawaited(_viewOptions.close());
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInstances() async {
    final List<ExtensionDomain> instances = await ExtensionInstances(
      repository: context.read<ExtensionRepository>(),
    ).all();
    if (mounted) {
      setState(() => _instances = instances);
    }
  }

  void _reloadInstances() {
    unawaited(_loadInstances());
  }

  List<BaseExtension> _withInstances(List<BaseExtension> extensions) {
    if (_instances.isEmpty) {
      return extensions;
    }
    final List<BaseExtension> result = <BaseExtension>[];
    for (final BaseExtension extension in extensions) {
      result.add(extension);
      result.addAll(_instances.where(
        (ExtensionDomain instance) =>
            instance.baseUid == extension.config.uid,
      ));
    }
    return result;
  }

  Future<void> _restoreFilter() async {
    final ConfigsFilter stored = await _filterPreferences.read();
    if (mounted) {
      setState(() => _filter = stored);
    }
  }

  void _changeFilter(ConfigsFilter filter) {
    setState(() => _filter = filter);
    unawaited(_filterPreferences.write(filter));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ConfigsViewOptionsCubit>.value(
      value: _viewOptions,
      child: BlocBuilder<ConfigsViewOptionsCubit, ConfigsViewOptions>(
        builder: (BuildContext context, ConfigsViewOptions options) => Scaffold(
          backgroundColor: AppColors.backgroundColor,
          body: _buildRemoteConfigsPage(),
        ),
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

  Widget _buildRemoteConfigs(BuildContext context, RemoteConfigsState state) {
    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () => context.read<RemoteConfigsCubit>().refresh(),
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
      titleSpacing: 8,
      automaticallyImplyLeading: false,
      title: _buildSourceSwitcher(context, state),
      actions: <Widget>[
        IconButton(
          tooltip: S.current.discover_open_tooltip,
          icon: Icon(Icons.explore_outlined, color: AppColors.mainWhite),
          onPressed: () => Navigator.of(context).pushNamed(Routes.discover),
        ),
        IconButton(
          tooltip: S.current.global_search_open_tooltip,
          icon: Icon(Icons.search_rounded, color: AppColors.mainWhite),
          onPressed: () => Navigator.of(context).pushNamed(
            Routes.globalSearch,
            arguments: const GlobalSearchArguments(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            tooltip: S.current.configs_view_options,
            icon: Icon(Icons.tune_rounded, color: AppColors.mainWhite),
            onPressed: () => _showViewOptions(context),
          ),
        ),
      ],
    );
  }

  Widget _buildSourceSwitcher(BuildContext context, RemoteConfigsState state) {
    final String title = state is RemoteConfigsLoaded
        ? state.sourceName
        : S.current.home_remote_configs_page_appbar_title;
    return Semantics(
      button: true,
      label: S.current.home_sources_button,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openSources(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    title,
                    style: semibold(size: 22),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 2),
                Icon(
                  Icons.expand_more_rounded,
                  size: 24,
                  color: AppColors.mainGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openSources(BuildContext context) {
    Navigator.of(context)
        .pushNamed(Routes.myExtensionSources)
        .then((Object? value) {
      if (value is ExtensionSourcesPageResult && context.mounted) {
        context.read<RemoteConfigsCubit>().changeSource(value);
      }
    });
  }

  List<Widget> _buildLoaded(BuildContext context, RemoteConfigsLoaded state) {
    final SettingsState settingsState = context.watch<SettingsCubit>().state;
    final bool showNsfw =
        settingsState is SettingsInitialized && settingsState.showNsfw;

    final List<BaseExtension> visibleManga = <BaseExtension>[
      LocalSource.extension(S.current.local_source_name),
      ..._withInstances(_filterNsfw(state.mangaRemoteConfigs, showNsfw)),
    ];
    final List<BaseExtension> visibleVideo =
        _withInstances(_filterNsfw(state.animeRemoteConfigs, showNsfw));
    final List<BaseExtension> visibleNovels = <BaseExtension>[
      LocalBooksSource.extension(S.current.local_books_name),
      ..._withInstances(_filterNsfw(state.novelRemoteConfigs, showNsfw)),
    ];
    final List<BaseExtension> visibleAudio =
        _withInstances(_filterNsfw(state.audioRemoteConfigs, showNsfw));
    final List<BaseExtension> visible = <BaseExtension>[
      ...visibleManga,
      ...visibleVideo,
      ...visibleNovels,
      ...visibleAudio,
    ];
    final List<String> kinds = availableContentKinds(visible);
    final List<String> languages = availableLanguages(visible);
    final List<String> pricings = availablePricings(visible);
    final ConfigsFilter filter = _applicableFilter(kinds, languages, pricings);
    final ConfigsViewOptions options = _viewOptions.state;
    final bool searchable =
        visible.length > kConfigsSearchThreshold || _query.isNotEmpty;
    bool shown(BaseExtension extension) {
      return filter.matches(extension) &&
          matchesConfigsQuery(extension, searchable ? _query : '');
    }

    final List<BaseExtension> pinnedConfigs =
        options.pinnedIn(visible.where(shown));
    final List<BaseExtension> mangaConfigs =
        options.unpinned(visibleManga.where(shown).toList());
    final List<BaseExtension> animeConfigs =
        options.unpinned(visibleVideo.where(shown).toList());
    final List<BaseExtension> novelConfigs =
        options.unpinned(visibleNovels.where(shown).toList());
    final List<BaseExtension> audioConfigs =
        options.unpinned(visibleAudio.where(shown).toList());
    final Widget? searchField =
        searchable ? _buildSearchField(context) : null;
    final ConfigsFilterBar filterBar = ConfigsFilterBar(
      kinds: kinds,
      languages: languages,
      pricings: pricings,
      filter: filter,
      onChanged: _changeFilter,
    );

    if (pinnedConfigs.isEmpty &&
        mangaConfigs.isEmpty &&
        animeConfigs.isEmpty &&
        novelConfigs.isEmpty &&
        audioConfigs.isEmpty) {
      return <Widget>[
        if (searchField != null) SliverToBoxAdapter(child: searchField),
        if (filterBar.isUseful) SliverToBoxAdapter(child: filterBar),
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
      if (searchField != null) SliverToBoxAdapter(child: searchField),
      if (filterBar.isUseful) SliverToBoxAdapter(child: filterBar),
      if (pinnedConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('pinned'),
          title: S.current.configs_pinned_group_title,
          remoteConfigs: pinnedConfigs,
          listingStatusOf: state.listingStatusOf,
          onInstancesChanged: _reloadInstances,
        ),
      if (mangaConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('manga'),
          title: S.current.home_manga_group_title,
          remoteConfigs: mangaConfigs,
          listingStatusOf: state.listingStatusOf,
          onInstancesChanged: _reloadInstances,
        ),
      if (animeConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('anime'),
          title: S.current.home_anime_group_title,
          remoteConfigs: animeConfigs,
          listingStatusOf: state.listingStatusOf,
          onInstancesChanged: _reloadInstances,
        ),
      if (novelConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('novel'),
          title: S.current.home_novel_group_title,
          remoteConfigs: novelConfigs,
          listingStatusOf: state.listingStatusOf,
          onInstancesChanged: _reloadInstances,
        ),
      if (audioConfigs.isNotEmpty)
        ConfigsGroup(
          key: const ValueKey<String>('audio'),
          title: S.current.home_audio_group_title,
          remoteConfigs: audioConfigs,
          listingStatusOf: state.listingStatusOf,
          onInstancesChanged: _reloadInstances,
        ),
      const SliverToBoxAdapter(child: SizedBox(height: 24)),
    ];
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
      child: TextField(
        controller: _searchController,
        onChanged: (String value) => setState(() => _query = value),
        textInputAction: TextInputAction.search,
        style: regular(size: 15),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          isDense: true,
          filled: true,
          fillColor: AppColors.overlay(0.06),
          hintText: S.current.configs_search_hint,
          hintStyle: regular(size: 15, color: AppColors.mainGrey),
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.mainGrey),
          suffixIcon: _query.isEmpty
              ? null
              : IconButton(
                  icon: Icon(Icons.close_rounded, color: AppColors.mainGrey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() => _query = '');
                  },
                ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  void _showViewOptions(BuildContext context) {
    unawaited(showActionSheet(
      context,
      title: S.current.configs_view_options,
      child: BlocBuilder<ConfigsViewOptionsCubit, ConfigsViewOptions>(
        bloc: _viewOptions,
        builder: (BuildContext sheetContext, ConfigsViewOptions options) =>
            Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _sheetLabel(S.current.configs_view_layout),
            ActionSheetRow(
              icon: Icons.view_agenda_outlined,
              label: S.current.configs_layout_cards,
              selected: options.layout == ConfigsLayout.cards,
              onTap: () => _viewOptions.setLayout(ConfigsLayout.cards),
            ),
            ActionSheetRow(
              icon: Icons.view_list_rounded,
              label: S.current.configs_layout_compact,
              selected: options.layout == ConfigsLayout.compact,
              onTap: () => _viewOptions.setLayout(ConfigsLayout.compact),
            ),
            ActionSheetRow(
              icon: Icons.grid_view_rounded,
              label: S.current.configs_layout_grid,
              selected: options.layout == ConfigsLayout.grid,
              onTap: () => _viewOptions.setLayout(ConfigsLayout.grid),
            ),
            _sheetLabel(S.current.configs_view_sort),
            ActionSheetRow(
              icon: Icons.format_list_numbered_rounded,
              label: S.current.configs_sort_listing,
              selected: options.sort == ConfigsSort.listing,
              onTap: () => _viewOptions.setSort(ConfigsSort.listing),
            ),
            ActionSheetRow(
              icon: Icons.sort_by_alpha_rounded,
              label: S.current.configs_sort_name,
              selected: options.sort == ConfigsSort.name,
              onTap: () => _viewOptions.setSort(ConfigsSort.name),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _sheetLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(label, style: medium(size: 13, color: AppColors.mainGrey)),
    );
  }

  ConfigsFilter _applicableFilter(
    List<String> kinds,
    List<String> languages,
    List<String> pricings,
  ) {
    ConfigsFilter filter = _filter;
    if (filter.kind != null && !kinds.contains(filter.kind)) {
      filter = filter.withKind(null);
    }
    if (filter.language != null && !languages.contains(filter.language)) {
      filter = filter.withLanguage(null);
    }
    if (filter.pricing != null && !pricings.contains(filter.pricing)) {
      filter = filter.withPricing(null);
    }
    return filter;
  }

  List<BaseExtension> _filterNsfw(
      List<BaseExtension> configs, bool showNsfw) {
    if (showNsfw) return configs;
    return configs
        .where((BaseExtension e) => !e.config.nsfw)
        .toList(growable: false);
  }
}
