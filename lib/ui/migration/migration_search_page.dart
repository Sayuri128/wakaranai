import 'dart:async';

import 'package:capyscript/modules/waka_models/models/common/gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/migration/migration_candidates.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/services/migration/migration_title_match.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/global_search/global_search_navigation.dart';
import 'package:wakaranai/ui/global_search/global_search_rail_view.dart';
import 'package:wakaranai/ui/global_search/global_search_scope_sheet.dart';
import 'package:wakaranai/ui/migration/migration_arguments.dart';
import 'package:wakaranai/ui/migration/migration_launcher.dart';
import 'package:wakaranai/ui/migration/migration_widgets.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/search_field.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MigrationSearchPage extends StatefulWidget {
  const MigrationSearchPage({super.key, required this.arguments});

  final MigrationSearchArguments arguments;

  @override
  State<MigrationSearchPage> createState() => _MigrationSearchPageState();
}

class _MigrationSearchPageState extends State<MigrationSearchPage> {
  late final GlobalSearchCubit _cubit;
  late final TextEditingController _controller;
  late MigrationSubject _subject = widget.arguments.subject;
  String? _selectedKey;

  bool get _ownsCubit => widget.arguments.searchCubit == null;

  @override
  void initState() {
    super.initState();
    final GlobalSearchCubit? shared = widget.arguments.searchCubit;
    _cubit = shared ??
        createMigrationSearchCubit(context, type: widget.arguments.subject.type);
    final String initialQuery =
        shared?.state.query ?? widget.arguments.subject.title.trim();
    _controller = TextEditingController(text: initialQuery);
    if (_ownsCubit) {
      unawaited(_cubit.init(initialQuery: initialQuery));
    }
    unawaited(_completeSubject());
  }

  Future<void> _completeSubject() async {
    try {
      final MigrationSubject completed =
          await createMigrationPlanner(context).complete(_subject);
      if (!mounted) {
        return;
      }
      setState(() => _subject = completed);
      if (_ownsCubit && _controller.text.trim().isEmpty) {
        _searchFor(completed.title);
      }
    } catch (e) {
      logger.w('Saved titles are unavailable for migration: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    if (_ownsCubit) {
      unawaited(_cubit.close());
    }
    super.dispose();
  }

  void _submit(String query) {
    FocusScope.of(context).unfocus();
    setState(() => _selectedKey = null);
    _cubit.search(query);
  }

  void _searchFor(String query) {
    _controller.text = query;
    _submit(query);
  }

  void _editScope() {
    unawaited(showGlobalSearchScopeSheet(context, _cubit));
  }

  Future<void> _openSource(GlobalSearchRail rail) async {
    BaseExtension extension = rail.source.extension;
    try {
      extension = await _cubit.backend.openable(rail.source);
    } catch (e) {
      logger.w('Opening ${rail.source.name} without its cached script: $e');
    }
    if (!mounted) {
      return;
    }
    await openGlobalSearchSource(context, extension);
    _cubit.retry(rail.source.uid);
  }

  Future<void> _continue(MigrationCandidate candidate) async {
    if (widget.arguments.pickOnly) {
      Navigator.of(context).pop(candidate);
      return;
    }
    final Object? result = await Navigator.of(context).pushNamed(
      Routes.migrationPreview,
      arguments: MigrationPreviewArguments(
        subject: _subject,
        candidate: candidate,
      ),
    );
    if (result is MigrationResult && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<GlobalSearchCubit>.value(
      value: _cubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          child: BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
            builder: (BuildContext context, GlobalSearchState state) {
              final List<RankedMigrationCandidate> ranked =
                  rankMigrationSearch(_subject, state);
              final RankedMigrationCandidate? best =
                  bestMigrationCandidate(ranked);
              final RankedMigrationCandidate? selected =
                  _selectedFrom(ranked, best);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHeader(),
                  Expanded(
                    child: _buildContent(state, ranked, best, selected),
                  ),
                  _buildBottomPanel(state, selected, best),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  RankedMigrationCandidate? _selectedFrom(
    List<RankedMigrationCandidate> ranked,
    RankedMigrationCandidate? best,
  ) {
    final String? key = _selectedKey;
    if (key == null) {
      return best;
    }
    for (final RankedMigrationCandidate candidate in ranked) {
      if (candidate.candidate.key == key) {
        return candidate;
      }
    }
    return best;
  }

  Widget _buildHeader() {
    final Map<String, String> headers = context
            .read<LibraryCubit>()
            .state
            .coverHeaders[_subject.extensionUid] ??
        const <String, String>{};
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            S.current.migration_search_title,
            style: semibold(size: 24),
          ),
        ),
        MigrationSubjectHeader(subject: _subject, coverHeaders: headers),
      ],
    );
  }

  Widget _buildContent(
    GlobalSearchState state,
    List<RankedMigrationCandidate> ranked,
    RankedMigrationCandidate? best,
    RankedMigrationCandidate? selected,
  ) {
    if (!state.scopeReady) {
      return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: GlobalSearchRailsSkeleton(),
      );
    }
    if (state.scope.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.manage_search_rounded,
        title: S.current.migration_no_scope_title,
        message: S.current.migration_no_scope_message,
        actions: <Widget>[_buildScopeButton()],
      );
    }
    if (!state.hasQuery) {
      return ServiceViewerMessage(
        icon: Icons.travel_explore_rounded,
        title: S.current.migration_search_idle_title,
        message: S.current.migration_search_idle_message,
      );
    }
    final List<GlobalSearchRail> rails = _visibleRails(state);
    if (!state.isSearching && ranked.isEmpty && !_hasNotices(rails)) {
      return ServiceViewerMessage(
        icon: Icons.search_off_rounded,
        title: S.current.migration_no_candidates_title,
        message: S.current.migration_no_candidates_message,
        actions: <Widget>[_buildScopeButton()],
      );
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        for (final GlobalSearchRail rail in rails)
          GlobalSearchRailView(
            key: ValueKey<String>(rail.source.uid),
            rail: rail,
            onOpenItem: (GalleryView item) => setState(
              () => _selectedKey = '${rail.source.uid}::${item.uid}',
            ),
            onRetry: () => _cubit.retry(rail.source.uid),
            onOpenSource: () => unawaited(_openSource(rail)),
            isSelected: (GalleryView item) =>
                selected?.candidate.key == '${rail.source.uid}::${item.uid}',
            badgeOf: (GalleryView item) => _badgeFor(rail, item, ranked, best),
          ),
      ],
    );
  }

  bool _hasNotices(List<GlobalSearchRail> rails) {
    return rails.any((GlobalSearchRail rail) =>
        rail.status == GlobalSearchRailStatus.failed ||
        rail.status == GlobalSearchRailStatus.needsSignIn);
  }

  List<GlobalSearchRail> _visibleRails(GlobalSearchState state) {
    final List<GlobalSearchRail> rails = <GlobalSearchRail>[];
    for (final GlobalSearchRail rail in state.visibleRails) {
      final List<GalleryView> items = rail.items
          .where((GalleryView item) => !(rail.source.uid ==
                  _subject.extensionUid &&
              item.uid == _subject.uid))
          .toList(growable: false);
      if (rail.status == GlobalSearchRailStatus.loaded && items.isEmpty) {
        continue;
      }
      rails.add(GlobalSearchRail(
        source: rail.source,
        status: rail.status,
        items: items,
        coverHeaders: rail.coverHeaders,
        client: rail.client,
        config: rail.config,
        error: rail.error,
      ));
    }
    return rails;
  }

  String? _badgeFor(
    GlobalSearchRail rail,
    GalleryView item,
    List<RankedMigrationCandidate> ranked,
    RankedMigrationCandidate? best,
  ) {
    final String key = '${rail.source.uid}::${item.uid}';
    if (best?.candidate.key == key) {
      return S.current.migration_best_match;
    }
    for (final RankedMigrationCandidate candidate in ranked) {
      if (candidate.candidate.key == key && candidate.exact) {
        return S.current.migration_exact_match;
      }
    }
    return null;
  }

  Widget _buildScopeButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.mainBlack,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      onPressed: _editScope,
      icon: const Icon(Icons.tune_rounded),
      label: Text(S.current.migration_choose_sources),
    );
  }

  Widget _buildBottomPanel(
    GlobalSearchState state,
    RankedMigrationCandidate? selected,
    RankedMigrationCandidate? best,
  ) {
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
            _buildChips(state),
            if (state.hasQuery) ...<Widget>[
              const SizedBox(height: 10),
              _buildSelection(state, selected, best),
            ],
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  MigrationCircleButton(
                    icon: Icons.arrow_back_rounded,
                    tooltip: S.current.common_go_back,
                    onPressed: () => Navigator.of(context).maybePop(),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SearchField(
                      controller: _controller,
                      hintText: S.current.migration_search_hint,
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

  Widget _buildChips(GlobalSearchState state) {
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
    final List<String> titles = _subject.searchTitles;
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: <Widget>[
          _buildScopeChip(state),
          if (titles.length > 1)
            for (final String title in titles) ...<Widget>[
              const SizedBox(width: 8),
              _buildTitleChip(title, selected: title == state.query),
            ],
        ],
      ),
    );
  }

  Widget _buildScopeChip(GlobalSearchState state) {
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
                S.current.migration_targets_summary(state.scope.length),
                style: medium(size: 13, color: AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleChip(String title, {required bool selected}) {
    final Color fill = selected ? AppColors.primary : AppColors.overlay(0.06);
    final Color text = selected ? AppColors.mainBlack : AppColors.mainWhite;
    return Material(
      color: fill,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: () => _searchFor(title),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Center(
            widthFactor: 1,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 220),
              child: Text(
                title,
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

  Widget _buildSelection(
    GlobalSearchState state,
    RankedMigrationCandidate? selected,
    RankedMigrationCandidate? best,
  ) {
    if (selected == null) {
      return _buildSelectionPlaceholder(state);
    }
    final MigrationCandidate candidate = selected.candidate;
    final String label = identical(selected, best) && _selectedKey == null
        ? S.current.migration_best_match
        : S.current.migration_selected;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: <Widget>[
              MigrationCoverThumb(
                url: migrationCandidateCoverOf(candidate.item),
                headers: candidate.coverHeaders,
                width: 40,
                height: 56,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(label, style: medium(size: 12, color: AppColors.primary)),
                    const SizedBox(height: 2),
                    Text(
                      migrationCandidateTitleOf(candidate.item),
                      style: medium(size: 15),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      candidate.config.name.trim(),
                      style: regular(size: 12, color: AppColors.mainGrey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              MigrationPrimaryButton(
                label: widget.arguments.pickOnly
                    ? S.current.migration_use_this
                    : S.current.migration_continue,
                onPressed: () => unawaited(_continue(candidate)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionPlaceholder(GlobalSearchState state) {
    if (state.isSearching) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Shimmer(
          child: ShimmerBox(height: 76, borderRadius: 14),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        S.current.migration_pick_hint,
        style: regular(size: 13, color: AppColors.mainGrey),
      ),
    );
  }
}
