import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/blocs/migration/migration_candidates.dart';
import 'package:wakaranai/blocs/migration/migration_preview_cubit.dart';
import 'package:wakaranai/data/domain/database/category_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/migration/migration_models.dart';
import 'package:wakaranai/services/migration/migration_planner.dart';
import 'package:wakaranai/services/migration/migration_progress.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/migration/migration_arguments.dart';
import 'package:wakaranai/ui/migration/migration_launcher.dart';
import 'package:wakaranai/ui/migration/migration_widgets.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const int _maxMappingRows = 60;

class MigrationPreviewPage extends StatelessWidget {
  const MigrationPreviewPage({super.key, required this.arguments});

  final MigrationPreviewArguments arguments;

  @override
  Widget build(BuildContext context) {
    return BlocProvider<MigrationPreviewCubit>(
      create: (BuildContext context) => MigrationPreviewCubit(
        planner: createMigrationPlanner(context),
        subject: arguments.subject,
        candidate: arguments.candidate,
      )..load(),
      child: const MigrationPreviewView(),
    );
  }
}

class MigrationPreviewView extends StatelessWidget {
  const MigrationPreviewView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MigrationPreviewCubit, MigrationPreviewState>(
      listenWhen: (MigrationPreviewState previous, MigrationPreviewState next) =>
          previous.status != next.status,
      listener: (BuildContext context, MigrationPreviewState state) {
        final MigrationResult? result = state.result;
        if (state.status == MigrationPreviewStatus.done && result != null) {
          Navigator.of(context).pop(result);
        }
      },
      builder: (BuildContext context, MigrationPreviewState state) {
        return PopScope<Object?>(
          canPop: state.status != MigrationPreviewStatus.applying,
          child: Scaffold(
            backgroundColor: AppColors.backgroundColor,
            body: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(child: _buildBody(context, state)),
                  _buildBottomBar(context, state),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, MigrationPreviewState state) {
    final MigrationPreparation? preparation = state.preparation;
    if (state.status == MigrationPreviewStatus.loadFailed) {
      return ServiceViewerMessage(
        icon: Icons.error_outline_rounded,
        title: S.current.migration_load_failed_title,
        message: state.error?.toString(),
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: () =>
                unawaited(context.read<MigrationPreviewCubit>().load()),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.current.migration_retry),
          ),
        ],
      );
    }
    if (preparation == null) {
      return const MigrationPreviewSkeleton();
    }
    return _MigrationPreviewContent(
      preparation: preparation,
      state: state,
      candidate: context.read<MigrationPreviewCubit>().candidate,
    );
  }

  Widget _buildBottomBar(BuildContext context, MigrationPreviewState state) {
    final MigrationPreviewCubit cubit = context.read<MigrationPreviewCubit>();
    final bool applying = state.status == MigrationPreviewStatus.applying;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(top: BorderSide(color: AppColors.overlay(0.06))),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Row(
          children: <Widget>[
            MigrationCircleButton(
              icon: Icons.arrow_back_rounded,
              tooltip: S.current.common_go_back,
              onPressed:
                  applying ? null : () => Navigator.of(context).maybePop(),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MigrationPrimaryButton(
                label: S.current.migration_apply,
                icon: Icons.swap_horiz_rounded,
                busy: applying,
                onPressed:
                    state.canApply ? () => unawaited(cubit.apply()) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MigrationPreviewContent extends StatelessWidget {
  const _MigrationPreviewContent({
    required this.preparation,
    required this.state,
    required this.candidate,
  });

  final MigrationPreparation preparation;
  final MigrationPreviewState state;
  final MigrationCandidate candidate;

  MigrationOptions get _options => state.options;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Text(
            S.current.migration_preview_title,
            style: semibold(size: 24),
          ),
        ),
        _buildMoveHeader(context),
        if (state.applyFailed) _buildFailureBanner(),
        MigrationSectionTitle(title: S.current.migration_options_title),
        _buildOptions(context),
        MigrationSectionTitle(title: S.current.migration_mapping_title),
        ..._buildMapping(),
      ],
    );
  }

  Widget _buildMoveHeader(BuildContext context) {
    final MigrationSubject subject = preparation.subject;
    final Map<String, String> oldHeaders = context
            .read<LibraryCubit>()
            .state
            .coverHeaders[subject.extensionUid] ??
        const <String, String>{};
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _MigrationSideCard(
              label: S.current.migration_preview_old,
              cover: subject.cover,
              headers: oldHeaders,
              title: subject.title,
              source: subject.sourceName ??
                  S.current.migration_search_unknown_source,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              color: AppColors.primary,
            ),
          ),
          Expanded(
            child: _MigrationSideCard(
              label: S.current.migration_preview_new,
              cover: preparation.target.concrete.cover.isNotEmpty
                  ? preparation.target.concrete.cover
                  : migrationCandidateCoverOf(candidate.item),
              headers: candidate.coverHeaders,
              title: preparation.target.concrete.title,
              source: candidate.config.name.trim(),
              highlighted: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFailureBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.red.withValues(alpha: 0.14),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.error_outline_rounded, size: 18, color: AppColors.red),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                S.current.migration_apply_failed,
                style: regular(size: 13, color: AppColors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    final MigrationPreviewCubit cubit = context.read<MigrationPreviewCubit>();
    final bool enabled = state.status == MigrationPreviewStatus.ready;
    final String? category = _categoryName(context);
    final MigrationProgressPlan plan = preparation.progress;
    return MigrationSectionCard(
      children: <Widget>[
        MigrationSwitchTile(
          icon: Icons.library_books_outlined,
          title: S.current.migration_option_remove_old,
          subtitle: _options.keepOld
              ? S.current.migration_option_keep_old_hint
              : S.current.migration_option_remove_old_hint,
          value: !_options.keepOld,
          onChanged: enabled
              ? (bool value) =>
                  cubit.setOptions(_options.copyWith(keepOld: !value))
              : null,
        ),
        if (category != null)
          MigrationSwitchTile(
            icon: Icons.drive_file_move_outline,
            title: S.current.migration_option_category,
            subtitle: S.current.migration_option_category_hint(category),
            value: _options.moveCategory,
            onChanged: enabled
                ? (bool value) =>
                    cubit.setOptions(_options.copyWith(moveCategory: value))
                : null,
          ),
        if (plan.matches.isNotEmpty)
          MigrationSwitchTile(
            icon: Icons.done_all_rounded,
            title: plan.kind == MigrationMediaKind.chapters
                ? S.current.migration_option_read_progress
                : S.current.migration_option_watch_progress,
            subtitle: plan.kind == MigrationMediaKind.chapters
                ? S.current.migration_option_chapters_hint(plan.matches.length)
                : S.current.migration_option_episodes_hint(plan.matches.length),
            value: _options.moveProgress,
            onChanged: enabled
                ? (bool value) =>
                    cubit.setOptions(_options.copyWith(moveProgress: value))
                : null,
          ),
        if (preparation.trackerLinks > 0)
          MigrationSwitchTile(
            icon: Icons.sync_rounded,
            title: S.current.migration_option_trackers,
            subtitle: S.current
                .migration_option_trackers_hint(preparation.trackerLinks),
            value: _options.moveTrackers,
            onChanged: enabled
                ? (bool value) =>
                    cubit.setOptions(_options.copyWith(moveTrackers: value))
                : null,
          ),
        if (preparation.downloads > 0)
          MigrationNoteRow(
            icon: Icons.download_done_rounded,
            text: S.current.migration_downloads_note(preparation.downloads),
          ),
      ],
    );
  }

  String? _categoryName(BuildContext context) {
    final int? categoryId = preparation.categoryId;
    if (categoryId == null) {
      return null;
    }
    for (final CategoryDomain category
        in context.read<LibraryCubit>().state.categories) {
      if (category.id == categoryId) {
        return category.name;
      }
    }
    return null;
  }

  List<Widget> _buildMapping() {
    final MigrationProgressPlan plan = preparation.progress;
    if (plan.isEmpty) {
      return <Widget>[
        MigrationNoteRow(
          icon: Icons.info_outline_rounded,
          text: S.current.migration_mapping_empty,
        ),
      ];
    }
    final bool dimmed = !_options.moveProgress;
    final List<MigrationProgressMatch> shown =
        plan.matches.take(_maxMappingRows).toList(growable: false);
    return <Widget>[
      if (plan.matches.isNotEmpty)
        Opacity(
          opacity: dimmed ? 0.45 : 1,
          child: MigrationSectionCard(
            children: <Widget>[
              for (final MigrationProgressMatch match in shown)
                _MigrationMappingRow(match: match, kind: plan.kind),
              if (plan.matches.length > shown.length)
                MigrationNoteRow(
                  icon: Icons.more_horiz_rounded,
                  text: S.current
                      .migration_mapping_more(plan.matches.length - shown.length),
                ),
            ],
          ),
        ),
      if (plan.unmatched.isNotEmpty) ...<Widget>[
        MigrationSectionTitle(
          title: S.current.migration_mapping_unmatched_title,
        ),
        MigrationSectionCard(
          children: <Widget>[
            for (final MigrationOldProgress progress
                in plan.unmatched.take(_maxMappingRows))
              _MigrationUnmatchedRow(progress: progress),
            if (plan.unmatched.length > _maxMappingRows)
              MigrationNoteRow(
                icon: Icons.more_horiz_rounded,
                text: S.current.migration_mapping_more(
                    plan.unmatched.length - _maxMappingRows),
              ),
          ],
        ),
      ],
    ];
  }
}

String _progressLabel(MigrationOldProgress progress, MigrationMediaKind kind) {
  if (progress.finished) {
    if (kind == MigrationMediaKind.chapters) {
      return S.current.migration_mapping_read;
    }
    return S.current.migration_mapping_watched;
  }
  return S.current.migration_mapping_partial((progress.fraction * 100).round());
}

class _MigrationSideCard extends StatelessWidget {
  const _MigrationSideCard({
    required this.label,
    required this.cover,
    required this.headers,
    required this.title,
    required this.source,
    this.highlighted = false,
  });

  final String label;
  final String? cover;
  final Map<String, String> headers;
  final String title;
  final String source;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final Color labelColor =
        highlighted ? AppColors.primary : AppColors.mainGrey;
    return Material(
      color: highlighted
          ? AppColors.primary.withValues(alpha: 0.14)
          : AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(label, style: medium(size: 12, color: labelColor)),
            const SizedBox(height: 8),
            MigrationCoverThumb(
              url: cover,
              headers: headers,
              width: 64,
              height: 92,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: medium(size: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              source,
              style: regular(size: 12, color: AppColors.mainGrey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _MigrationMappingRow extends StatelessWidget {
  const _MigrationMappingRow({required this.match, required this.kind});

  final MigrationProgressMatch match;
  final MigrationMediaKind kind;

  @override
  Widget build(BuildContext context) {
    final MigrationOldProgress from = match.from;
    final String targets = match.targets
        .map((MigrationTargetElement target) => target.title)
        .toSet()
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  from.title,
                  style: medium(size: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _progressLabel(from, kind),
                  style: regular(size: 12, color: AppColors.primary),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.arrow_forward_rounded,
              size: 18,
              color: AppColors.mainGrey,
            ),
          ),
          Expanded(
            child: Text(
              targets,
              style: regular(size: 14),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MigrationUnmatchedRow extends StatelessWidget {
  const _MigrationUnmatchedRow({required this.progress});

  final MigrationOldProgress progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      child: Row(
        children: <Widget>[
          Icon(Icons.link_off_rounded, size: 18, color: AppColors.mainGrey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              progress.title,
              style: regular(size: 14),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class MigrationPreviewSkeleton extends StatelessWidget {
  const MigrationPreviewSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Shimmer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            ShimmerBox(width: 200, height: 26),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                Expanded(child: ShimmerBox(height: 170, borderRadius: 14)),
                const SizedBox(width: 40),
                Expanded(child: ShimmerBox(height: 170, borderRadius: 14)),
              ],
            ),
            const SizedBox(height: 28),
            ShimmerBox(width: 160, height: 18),
            const SizedBox(height: 12),
            ShimmerBox(height: 180, borderRadius: 14),
            const SizedBox(height: 28),
            ShimmerBox(width: 120, height: 18),
            const SizedBox(height: 12),
            ShimmerBox(height: 220, borderRadius: 14),
          ],
        ),
      ),
    );
  }
}
