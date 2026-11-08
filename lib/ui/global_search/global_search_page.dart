import 'dart:async';

import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/blocs/nsfw_titles/nsfw_titles_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_source_repository.dart';
import 'package:wakaranai/repositories/database/library_entry_repository.dart';
import 'package:wakaranai/services/configs_service/extension_resolver.dart';
import 'package:wakaranai/services/global_search/global_search_backend.dart';
import 'package:wakaranai/services/global_search/global_search_catalog.dart';
import 'package:wakaranai/services/global_search/global_search_preferences.dart';
import 'package:wakaranai/services/global_search/global_search_scope.dart';
import 'package:wakaranai/services/global_search/global_search_source.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/global_search/global_search_arguments.dart';
import 'package:wakaranai/ui/global_search/global_search_navigation.dart';
import 'package:wakaranai/ui/global_search/global_search_rail_view.dart';
import 'package:wakaranai/ui/global_search/global_search_scope_sheet.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/ui/home/settings_page/cubit/settings/settings_cubit.dart';
import 'package:wakaranai/ui/widgets/search_field.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GlobalSearchPage extends StatelessWidget {
  const GlobalSearchPage({super.key, required this.arguments});

  final GlobalSearchArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GlobalSearchCubit>(
      create: (BuildContext context) =>
          createGlobalSearchCubit(context)..init(initialQuery: arguments.query),
      child: GlobalSearchView(arguments: arguments),
    );
  }
}

GlobalSearchCubit createGlobalSearchCubit(
  BuildContext context, {
  GlobalSearchPreferences preferences = const GlobalSearchPreferences(),
  ConfigInfoType? type,
}) {
  final ExtensionRepository extensionRepository =
      context.read<ExtensionRepository>();
  final ExtensionResolver resolver = ExtensionResolver(
    extensionRepository: extensionRepository,
    extensionSourceRepository: context.read<ExtensionSourceRepository>(),
  );
  final SettingsState settings = context.read<SettingsCubit>().state;
  return GlobalSearchCubit(
    backend: PooledGlobalSearchBackend(
      extensionRepository: extensionRepository,
      resolver: resolver,
    ),
    catalog: RepositoryGlobalSearchCatalog(
      extensionRepository: extensionRepository,
      libraryEntryRepository: context.read<LibraryEntryRepository>(),
      resolver: resolver,
      remoteConfigsCubit: context.read<RemoteConfigsCubit>(),
    ),
    rules: GlobalSearchScopeRules(
      showNsfw: settings is SettingsInitialized && settings.showNsfw,
      hideNsfwTitles: context.read<NsfwTitlesCubit>().state.hideTitles,
      type: type,
    ),
    preferences: preferences,
  );
}

class GlobalSearchView extends StatefulWidget {
  const GlobalSearchView({super.key, required this.arguments});

  final GlobalSearchArguments arguments;

  @override
  State<GlobalSearchView> createState() => _GlobalSearchViewState();
}

class _GlobalSearchViewState extends State<GlobalSearchView> {
  late final TextEditingController _controller =
      TextEditingController(text: widget.arguments.query?.trim() ?? '');

  GlobalSearchCubit get _cubit => context.read<GlobalSearchCubit>();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit(String query) {
    FocusScope.of(context).unfocus();
    _cubit.search(query);
  }

  void _searchFor(String query) {
    _controller.text = query;
    _submit(query);
  }

  Future<void> _openSource(GlobalSearchRail rail) async {
    final GlobalSearchCubit cubit = _cubit;
    BaseExtension extension = rail.source.extension;
    try {
      extension = await cubit.backend.openable(rail.source);
    } catch (e) {
      logger.w('Opening ${rail.source.name} without its cached script: $e');
    }
    if (!mounted) {
      return;
    }
    await openGlobalSearchSource(context, extension);
    cubit.retry(rail.source.uid);
  }

  void _editScope() {
    unawaited(showGlobalSearchScopeSheet(context, _cubit));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
          builder: (BuildContext context, GlobalSearchState state) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHeader(),
                Expanded(child: _buildContent(state)),
                _buildBottomPanel(state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Text(S.current.global_search_title, style: semibold(size: 24)),
    );
  }

  Widget _buildContent(GlobalSearchState state) {
    if (!state.scopeReady) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: GlobalSearchRailsSkeleton(),
      );
    }
    if (state.scope.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.manage_search_rounded,
        title: S.current.global_search_no_scope_title,
        message: S.current.global_search_no_scope_message,
        actions: <Widget>[
          _buildPrimaryButton(
            label: S.current.global_search_scope_edit,
            icon: Icons.tune_rounded,
            onPressed: _editScope,
          ),
        ],
      );
    }
    if (!state.hasQuery) {
      return _buildIdle(state);
    }
    return _buildResults(state);
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.mainBlack,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
    );
  }

  Widget _buildIdle(GlobalSearchState state) {
    if (state.history.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.travel_explore_rounded,
        title: S.current.global_search_idle_title,
        message: S.current.global_search_idle_message,
      );
    }
    return SingleChildScrollView(
      reverse: true,
      padding: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHistoryHeader(),
          for (final String query in state.history) _buildHistoryRow(query),
        ],
      ),
    );
  }

  Widget _buildHistoryHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              S.current.global_search_recent_title,
              style: semibold(size: 18),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            onPressed: () => unawaited(_cubit.clearHistory()),
            child: Text(
              S.current.global_search_recent_clear,
              style: medium(size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(String query) {
    return InkWell(
      splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
      onTap: () => _searchFor(query),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 4, 4),
        child: Row(
          children: <Widget>[
            Icon(Icons.history_rounded, size: 20, color: AppColors.mainGrey),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                query,
                style: regular(size: 15),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            IconButton(
              icon: Icon(
                Icons.close_rounded,
                size: 18,
                color: AppColors.mainGrey,
              ),
              onPressed: () => unawaited(_cubit.removeFromHistory(query)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResults(GlobalSearchState state) {
    final List<GlobalSearchRail> visible = state.visibleRails;
    final List<GlobalSearchRail> empty = state.emptyRails;
    if (!state.isSearching && visible.isEmpty && empty.isNotEmpty) {
      return ServiceViewerMessage(
        icon: Icons.search_off_rounded,
        title: S.current.global_search_no_results_title,
        message: S.current.global_search_no_results_message(state.query),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        for (final GlobalSearchRail rail in visible)
          GlobalSearchRailView(
            key: ValueKey<String>(rail.source.uid),
            rail: rail,
            onOpenItem: (GalleryView item) =>
                unawaited(openGlobalSearchResult(context, rail, item)),
            onRetry: () => _cubit.retry(rail.source.uid),
            onOpenSource: () => unawaited(_openSource(rail)),
          ),
        if (empty.isNotEmpty) _buildEmptySummary(empty),
      ],
    );
  }

  Widget _buildEmptySummary(List<GlobalSearchRail> empty) {
    final String names =
        empty.map((GlobalSearchRail rail) => rail.source.name).join(', ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        S.current.global_search_empty_sources(names),
        style: regular(size: 13, color: AppColors.mainGrey),
      ),
    );
  }

  Widget _buildBottomPanel(GlobalSearchState state) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.overlay(0.06))),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            if (widget.arguments.alternativeQueries.length > 1)
              _buildAlternatives(state),
            _buildScopeChips(state),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  _buildBackButton(),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SearchField(
                      controller: _controller,
                      hintText: S.current.global_search_hint,
                      autofocus: widget.arguments.query == null,
                      onSubmitted: _submit,
                      onClear: _cubit.clear,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackButton() {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      child: IconButton(
        tooltip: S.current.common_go_back,
        icon: Icon(Icons.arrow_back_rounded, color: AppColors.mainWhite),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
    );
  }

  Widget _buildAlternatives(GlobalSearchState state) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        children: <Widget>[
          Center(
            child: Text(
              S.current.global_search_try_titles,
              style: medium(size: 13, color: AppColors.mainGrey),
            ),
          ),
          for (final String title
              in widget.arguments.alternativeQueries) ...<Widget>[
            const SizedBox(width: 8),
            _buildChip(
              label: title,
              selected: title == state.query,
              onTap: () => _searchFor(title),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildScopeChips(GlobalSearchState state) {
    if (!state.scopeReady) {
      return SizedBox(
        height: 36,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Shimmer(
              child: ShimmerBox(width: 180, height: 36, borderRadius: 12),
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          _buildScopeSummaryChip(state),
          for (final GlobalSearchSource source in state.scope) ...<Widget>[
            const SizedBox(width: 8),
            _buildChip(label: source.name, onTap: _editScope),
          ],
        ],
      ),
    );
  }

  Widget _buildScopeSummaryChip(GlobalSearchState state) {
    return Material(
      color: AppColors.primary.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: _editScope,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(Icons.tune_rounded, size: 16, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                '${S.current.global_search_scope_summary(state.scope.length)}'
                ' · ${S.current.global_search_scope_edit}',
                style: medium(size: 13, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    final Color fill = selected ? AppColors.primary : AppColors.overlay(0.06);
    final Color text = selected ? AppColors.mainBlack : AppColors.mainWhite;
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            widthFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                label,
                style: medium(size: 13, color: text),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
