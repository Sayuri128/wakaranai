import 'dart:async';

import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/global_search/global_search_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/migration/migration_bulk_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/ui/global_search/global_search_scope_sheet.dart';
import 'package:wakaranai/ui/migration/migration_arguments.dart';
import 'package:wakaranai/ui/migration/migration_launcher.dart';
import 'package:wakaranai/ui/migration/migration_widgets.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showMigrationBulkSheet(
  BuildContext context,
  List<MigrationSubject> subjects,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    isDismissible: false,
    enableDrag: false,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(sheetContext).height * 0.85,
      ),
      child: MigrationBulkSheet(subjects: subjects),
    ),
  );
}

ConfigInfoType? _sharedType(List<MigrationSubject> subjects) {
  final Set<ConfigInfoType?> types =
      subjects.map((MigrationSubject subject) => subject.type).toSet();
  if (types.length == 1) {
    return types.single;
  }
  return null;
}

class MigrationBulkSheet extends StatefulWidget {
  const MigrationBulkSheet({super.key, required this.subjects});

  final List<MigrationSubject> subjects;

  @override
  State<MigrationBulkSheet> createState() => _MigrationBulkSheetState();
}

class _MigrationBulkSheetState extends State<MigrationBulkSheet> {
  late final GlobalSearchCubit _search;
  late final MigrationBulkCubit _bulk;

  @override
  void initState() {
    super.initState();
    _search = createMigrationSearchCubit(
      context,
      type: _sharedType(widget.subjects),
    );
    _bulk = MigrationBulkCubit(
      search: _search,
      planner: createMigrationPlanner(context),
      subjects: widget.subjects,
    );
    unawaited(_search.init());
  }

  @override
  void dispose() {
    unawaited(_bulk.close());
    unawaited(_search.close());
    super.dispose();
  }

  Future<void> _choose(int index, MigrationSubject subject) async {
    final Object? picked = await Navigator.of(context).pushNamed(
      Routes.migration,
      arguments: MigrationSearchArguments(
        subject: subject,
        pickOnly: true,
        searchCubit: _search,
      ),
    );
    if (picked is MigrationCandidate) {
      _bulk.resolvePick(index, picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: <BlocProvider<dynamic>>[
        BlocProvider<GlobalSearchCubit>.value(value: _search),
        BlocProvider<MigrationBulkCubit>.value(value: _bulk),
      ],
      child: BlocBuilder<MigrationBulkCubit, MigrationBulkState>(
        builder: (BuildContext context, MigrationBulkState state) {
          return PopScope<Object?>(
            canPop: state.phase != MigrationBulkPhase.running,
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHandle(),
                  _buildTitle(state),
                  Flexible(child: _buildBody(state)),
                  _buildActions(state),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 8),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle(MigrationBulkState state) {
    if (state.phase == MigrationBulkPhase.setup) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
        child: Text(
          S.current.migration_bulk_title(state.items.length),
          style: semibold(size: 18),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  S.current.migration_bulk_running_title,
                  style: semibold(size: 18),
                ),
              ),
              Text(
                S.current.migration_bulk_progress(
                  state.settledCount,
                  state.items.length,
                ),
                style: medium(size: 13, color: AppColors.mainGrey),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: state.items.isEmpty
                  ? 0
                  : state.settledCount / state.items.length,
              minHeight: 6,
              color: AppColors.primary,
              backgroundColor: AppColors.overlay(0.08),
            ),
          ),
          if (state.phase == MigrationBulkPhase.finished) ...<Widget>[
            const SizedBox(height: 10),
            Text(
              S.current.migration_bulk_summary(
                state.countOf(MigrationBulkItemStatus.done),
                state.countOf(MigrationBulkItemStatus.skipped),
                state.countOf(MigrationBulkItemStatus.failed),
              ),
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBody(MigrationBulkState state) {
    if (state.phase == MigrationBulkPhase.setup) {
      return SingleChildScrollView(child: _buildSetup(state));
    }
    return ListView.builder(
      shrinkWrap: true,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      itemCount: state.items.length,
      itemBuilder: (BuildContext context, int index) =>
          _buildItem(index, state.items[index]),
    );
  }

  Widget _buildSetup(MigrationBulkState state) {
    final MigrationOptions options = state.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildTargetsRow(),
        const SizedBox(height: 12),
        MigrationSectionCard(
          children: <Widget>[
            MigrationSwitchTile(
              icon: Icons.auto_awesome_rounded,
              title: S.current.migration_bulk_auto_pick,
              subtitle: S.current.migration_bulk_auto_pick_hint,
              value: state.autoPickExact,
              onChanged: _bulk.setAutoPickExact,
            ),
            MigrationSwitchTile(
              icon: Icons.library_books_outlined,
              title: S.current.migration_option_remove_old,
              subtitle: options.keepOld
                  ? S.current.migration_option_keep_old_hint
                  : S.current.migration_option_remove_old_hint,
              value: !options.keepOld,
              onChanged: (bool value) =>
                  _bulk.setOptions(options.copyWith(keepOld: !value)),
            ),
            MigrationSwitchTile(
              icon: Icons.drive_file_move_outline,
              title: S.current.migration_option_category,
              value: options.moveCategory,
              onChanged: (bool value) =>
                  _bulk.setOptions(options.copyWith(moveCategory: value)),
            ),
            MigrationSwitchTile(
              icon: Icons.done_all_rounded,
              title: S.current.migration_option_read_progress,
              value: options.moveProgress,
              onChanged: (bool value) =>
                  _bulk.setOptions(options.copyWith(moveProgress: value)),
            ),
            MigrationSwitchTile(
              icon: Icons.sync_rounded,
              title: S.current.migration_option_trackers,
              value: options.moveTrackers,
              onChanged: (bool value) =>
                  _bulk.setOptions(options.copyWith(moveTrackers: value)),
            ),
            MigrationNoteRow(
              icon: Icons.download_done_rounded,
              text: S.current.migration_bulk_downloads_note,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTargetsRow() {
    return BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
      builder: (BuildContext context, GlobalSearchState searchState) {
        final String summary = searchState.scopeReady
            ? S.current.migration_targets_summary(searchState.scope.length)
            : '…';
        return MigrationSectionCard(
          children: <Widget>[
            InkWell(
              splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
              onTap: () =>
                  unawaited(showGlobalSearchScopeSheet(context, _search)),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
                child: Row(
                  children: <Widget>[
                    Icon(Icons.tune_rounded, color: AppColors.primary),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            S.current.migration_bulk_targets,
                            style: medium(size: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            summary,
                            style: regular(size: 12, color: AppColors.mainGrey),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: AppColors.mainGrey,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildItem(int index, MigrationBulkItem item) {
    final Map<String, String> headers = context
            .read<LibraryCubit>()
            .state
            .coverHeaders[item.subject.extensionUid] ??
        const <String, String>{};
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
      child: Row(
        children: <Widget>[
          MigrationCoverThumb(
            url: item.subject.cover,
            headers: headers,
            width: 36,
            height: 52,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.subject.title,
                  style: medium(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _statusLabel(item),
                  style: regular(size: 12, color: _statusColor(item)),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _buildTrailing(index, item),
        ],
      ),
    );
  }

  Widget _buildTrailing(int index, MigrationBulkItem item) {
    switch (item.status) {
      case MigrationBulkItemStatus.needsPick:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextButton(
              style: TextButton.styleFrom(foregroundColor: AppColors.mainGrey),
              onPressed: () => _bulk.resolvePick(index, null),
              child: Text(S.current.migration_bulk_skip),
            ),
            _buildChoosePill(index, item),
          ],
        );
      case MigrationBulkItemStatus.searching:
      case MigrationBulkItemStatus.migrating:
        return SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.4,
            color: AppColors.primary,
          ),
        );
      case MigrationBulkItemStatus.done:
        return Icon(Icons.check_circle_rounded, color: AppColors.primary);
      case MigrationBulkItemStatus.failed:
        return Icon(Icons.error_outline_rounded, color: AppColors.red);
      case MigrationBulkItemStatus.skipped:
        return Icon(Icons.remove_circle_outline_rounded,
            color: AppColors.mainGrey);
      case MigrationBulkItemStatus.waiting:
        return Icon(Icons.schedule_rounded, color: AppColors.mainGrey);
    }
  }

  Widget _buildChoosePill(int index, MigrationBulkItem item) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: () => unawaited(_choose(index, item.subject)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Text(
            S.current.migration_bulk_choose,
            style: medium(size: 13, color: AppColors.mainBlack),
          ),
        ),
      ),
    );
  }

  String _statusLabel(MigrationBulkItem item) {
    final String source = item.targetSource ?? '';
    switch (item.status) {
      case MigrationBulkItemStatus.waiting:
        return S.current.migration_bulk_status_waiting;
      case MigrationBulkItemStatus.searching:
        return S.current.migration_bulk_status_searching;
      case MigrationBulkItemStatus.needsPick:
        return S.current.migration_bulk_status_pick(item.candidateCount);
      case MigrationBulkItemStatus.migrating:
        if (item.autoPicked) {
          return S.current.migration_bulk_status_auto(source);
        }
        return S.current.migration_bulk_status_migrating(source);
      case MigrationBulkItemStatus.done:
        return S.current.migration_bulk_status_done(source);
      case MigrationBulkItemStatus.skipped:
        return S.current.migration_bulk_status_skipped;
      case MigrationBulkItemStatus.failed:
        return S.current.migration_bulk_status_failed;
    }
  }

  Color _statusColor(MigrationBulkItem item) {
    switch (item.status) {
      case MigrationBulkItemStatus.needsPick:
      case MigrationBulkItemStatus.done:
        return AppColors.primary;
      case MigrationBulkItemStatus.failed:
        return AppColors.red;
      case MigrationBulkItemStatus.waiting:
      case MigrationBulkItemStatus.searching:
      case MigrationBulkItemStatus.migrating:
      case MigrationBulkItemStatus.skipped:
        return AppColors.mainGrey;
    }
  }

  Widget _buildActions(MigrationBulkState state) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: <Widget>[
          if (state.phase == MigrationBulkPhase.setup) ...<Widget>[
            Expanded(child: _buildSecondaryButton(
              label: S.current.common_cancel,
              onPressed: () => Navigator.of(context).pop(),
            )),
            const SizedBox(width: 10),
            Expanded(child: _buildStartButton()),
          ],
          if (state.phase == MigrationBulkPhase.running)
            Expanded(
              child: _buildSecondaryButton(
                label: S.current.migration_bulk_stop,
                onPressed: state.stopping ? null : _bulk.stop,
              ),
            ),
          if (state.phase == MigrationBulkPhase.finished)
            Expanded(
              child: MigrationPrimaryButton(
                label: S.current.migration_bulk_done,
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return BlocBuilder<GlobalSearchCubit, GlobalSearchState>(
      builder: (BuildContext context, GlobalSearchState searchState) {
        VoidCallback? onPressed;
        if (searchState.scopeReady && searchState.scope.isEmpty) {
          onPressed =
              () => unawaited(showGlobalSearchScopeSheet(context, _search));
        } else if (searchState.scopeReady) {
          onPressed = () => unawaited(_bulk.start());
        }
        return MigrationPrimaryButton(
          label: S.current.migration_bulk_start,
          icon: Icons.swap_horiz_rounded,
          onPressed: onPressed,
        );
      },
    );
  }

  Widget _buildSecondaryButton({
    required String label,
    required VoidCallback? onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: AppColors.overlay(0.06),
          foregroundColor: AppColors.mainWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: semibold(size: 15)),
      ),
    );
  }
}
