import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/trackers/trackers_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/tracker_link_repository.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_sync_service.dart';
import 'package:wakaranai/ui/services/widgets/tracking/tracker_labels.dart';
import 'package:wakaranai/ui/services/widgets/tracking/tracker_search_sheet.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConcreteTrackingChip extends StatelessWidget {
  const ConcreteTrackingChip({super.key, required this.request});

  final TrackerLinkRequest request;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackersCubit, TrackersState>(
      builder: (BuildContext context, TrackersState trackers) {
        if (!trackers.hasAccounts) {
          return const SizedBox.shrink();
        }
        return StreamBuilder<List<TrackerLink>>(
          stream: context
              .read<TrackerLinkRepository>()
              .watchLinksFor(request.concreteUid),
          builder: (BuildContext context, AsyncSnapshot<List<TrackerLink>> snapshot) {
            final List<TrackerLink> links = snapshot.data ?? <TrackerLink>[];
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Material(
                  color: links.isEmpty
                      ? AppColors.overlay(0.06)
                      : AppColors.primary.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(12),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => unawaited(showTrackingSheet(context, request)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            links.isEmpty
                                ? Icons.sync_disabled_rounded
                                : Icons.sync_rounded,
                            size: 18,
                            color: links.isEmpty
                                ? AppColors.mainGrey
                                : AppColors.primary,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              _label(context, links),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: medium(
                                size: 13,
                                color: links.isEmpty
                                    ? AppColors.mainWhite
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  String _label(BuildContext context, List<TrackerLink> links) {
    if (links.isEmpty) {
      return S.of(context).tracker_chip_untracked;
    }
    final TrackersCubit trackers = context.read<TrackersCubit>();
    return links
        .map((TrackerLink link) =>
            '${trackers.nameOf(link.trackerId)} ${trackerProgressLabel(link.progress, link.totalCount)}')
        .join(' · ');
  }
}

Future<void> showTrackingSheet(
  BuildContext context,
  TrackerLinkRequest request,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _TrackingSheet(request: request),
  );
}

class _TrackingSheet extends StatelessWidget {
  const _TrackingSheet({required this.request});

  final TrackerLinkRequest request;

  @override
  Widget build(BuildContext context) {
    final TrackersState trackers = context.watch<TrackersCubit>().state;
    return SafeArea(
      child: StreamBuilder<List<TrackerLink>>(
        stream: context
            .read<TrackerLinkRepository>()
            .watchLinksFor(request.concreteUid),
        builder: (BuildContext context, AsyncSnapshot<List<TrackerLink>> snapshot) {
          final Map<TrackerId, TrackerLink> links = <TrackerId, TrackerLink>{
            for (final TrackerLink link in snapshot.data ?? <TrackerLink>[])
              link.trackerId: link,
          };
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  decoration: BoxDecoration(
                    color: AppColors.overlay(0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: Text(
                  S.of(context).tracker_sheet_title,
                  style: semibold(size: 18),
                ),
              ),
              for (final TrackerId id in trackers.loggedIn)
                _TrackerRow(
                  trackerId: id,
                  name: context.read<TrackersCubit>().nameOf(id),
                  link: links[id],
                  request: request,
                ),
              const SizedBox(height: 12),
            ],
          );
        },
      ),
    );
  }
}

class _TrackerRow extends StatelessWidget {
  const _TrackerRow({
    required this.trackerId,
    required this.name,
    required this.link,
    required this.request,
  });

  final TrackerId trackerId;
  final String name;
  final TrackerLink? link;
  final TrackerLinkRequest request;

  @override
  Widget build(BuildContext context) {
    final TrackerLink? current = link;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: current == null
              ? _buildUnlinked(context)
              : _buildLinked(context, current),
        ),
      ),
    );
  }

  Widget _buildUnlinked(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(child: Text(name, style: semibold(size: 15))),
        TextButton.icon(
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
          onPressed: () => unawaited(showTrackerSearchSheet(
            context,
            trackerId: trackerId,
            request: request,
          )),
          icon: const Icon(Icons.link_rounded),
          label: Text(S.of(context).tracker_link_action),
        ),
      ],
    );
  }

  Widget _buildLinked(BuildContext context, TrackerLink current) {
    final TrackerSyncService sync = context.read<TrackerSyncService>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(name, style: semibold(size: 15)),
                  const SizedBox(height: 2),
                  Text(
                    current.remoteTitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: regular(size: 13, color: AppColors.mainGrey),
                  ),
                ],
              ),
            ),
            if (current.pendingProgress != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(
                  Icons.cloud_off_rounded,
                  size: 18,
                  color: AppColors.mainGrey,
                ),
              ),
            IconButton(
              tooltip: S.of(context).tracker_unlink_action,
              icon: Icon(Icons.link_off_rounded, color: AppColors.mainGrey),
              onPressed: () =>
                  unawaited(sync.unlink(current.concreteUid, current.trackerId)),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: <Widget>[
            Expanded(
              child: Material(
                color: AppColors.overlay(0.06),
                borderRadius: BorderRadius.circular(12),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => _pickStatus(context, sync, current),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: Text(
                            trackerStatusLabel(current.status, current.mediaType),
                            style: medium(size: 14),
                          ),
                        ),
                        Icon(
                          Icons.arrow_drop_down_rounded,
                          color: AppColors.mainGrey,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            _StepButton(
              icon: Icons.remove_rounded,
              onTap: current.progress > 0
                  ? () => unawaited(
                        sync.setProgress(current, current.progress - 1),
                      )
                  : null,
            ),
            SizedBox(
              width: 72,
              child: Text(
                trackerProgressLabel(current.progress, current.totalCount),
                textAlign: TextAlign.center,
                style: medium(size: 14),
              ),
            ),
            _StepButton(
              icon: Icons.add_rounded,
              onTap: () => unawaited(
                sync.setProgress(current, current.progress + 1),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _pickStatus(
    BuildContext context,
    TrackerSyncService sync,
    TrackerLink current,
  ) {
    unawaited(showActionSheet(
      context,
      title: name,
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            for (final TrackerStatus status in TrackerStatus.values)
              ActionSheetRow(
                label: trackerStatusLabel(status, current.mediaType),
                selected: status == current.status,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(sync.setStatus(current, status));
                },
              ),
          ],
        ),
      ),
    ));
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            icon,
            size: 20,
            color: onTap == null ? AppColors.mainGrey : AppColors.mainWhite,
          ),
        ),
      ),
    );
  }
}
