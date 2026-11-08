import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/downloads_page/download_tile.dart';
import 'package:wakaranai/ui/services/widgets/chapter_download_button.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showDownloadQueueSheet(BuildContext context) {
  final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return BlocProvider<DownloadManagerCubit>.value(
        value: manager,
        child: DownloadQueueSheet(),
      );
    },
  );
}

List<DownloadDomain> waitingDownloadsOf(List<DownloadDomain> queue) {
  return queue
      .where((DownloadDomain d) => d.status != DownloadStatus.downloading)
      .toList();
}

List<DownloadDomain> inFlightDownloadsOf(List<DownloadDomain> queue) {
  return queue
      .where((DownloadDomain d) => d.status == DownloadStatus.downloading)
      .toList();
}

List<String> reorderedUids(List<String> uids, int oldIndex, int newIndex) {
  final List<String> reordered = List<String>.of(uids);
  final String moved = reordered.removeAt(oldIndex);
  reordered.insert(newIndex, moved);
  return reordered;
}

class DownloadQueueSheet extends StatefulWidget {
  const DownloadQueueSheet({super.key});

  @override
  State<DownloadQueueSheet> createState() => _DownloadQueueSheetState();
}

class _DownloadQueueSheetState extends State<DownloadQueueSheet> {
  List<String>? _optimisticOrder;
  bool _reorderStored = false;
  int _reorderGeneration = 0;

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.85;
    return BlocConsumer<DownloadManagerCubit, DownloadManagerState>(
      listener: _onStateChanged,
      builder: (BuildContext context, DownloadManagerState state) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHandle(),
                _buildHeader(state.queue.length),
                Flexible(child: _buildQueue(state.queue)),
                _buildBulkActions(state),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onStateChanged(BuildContext context, DownloadManagerState state) {
    final List<String>? optimistic = _optimisticOrder;
    if (optimistic == null) {
      return;
    }
    final List<String> stored = _uidsOf(waitingDownloadsOf(state.queue));
    if (_reorderStored || listEquals(stored, optimistic)) {
      setState(_dropOptimisticOrder);
    }
  }

  void _dropOptimisticOrder() {
    _optimisticOrder = null;
    _reorderStored = false;
  }

  static List<String> _uidsOf(List<DownloadDomain> downloads) {
    return downloads.map((DownloadDomain d) => d.uid).toList();
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

  Widget _buildHeader(int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(S.of(context).downloads_queue_title,
                  style: semibold(size: 18)),
              const SizedBox(width: 8),
              _CountBadge(count: count),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            S.of(context).downloads_queue_reorder_hint,
            style: regular(size: 12, color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildQueue(List<DownloadDomain> queue) {
    if (queue.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Text(
          S.of(context).downloads_queue_empty,
          textAlign: TextAlign.center,
          style: regular(size: 14, color: AppColors.mainGrey),
        ),
      );
    }
    final List<DownloadDomain> inFlight = inFlightDownloadsOf(queue);
    final List<DownloadDomain> waiting = _orderedWaiting(queue);
    return CustomScrollView(
      shrinkWrap: true,
      slivers: <Widget>[
        SliverList(
          delegate: SliverChildListDelegate(<Widget>[
            for (final DownloadDomain download in inFlight)
              _QueueRow(
                download: download,
                pinned: true,
                onTogglePause: () => _togglePause(download),
                onRemove: () => _remove(download),
              ),
          ]),
        ),
        SliverReorderableList(
          itemCount: waiting.length,
          onReorderItem: (int oldIndex, int newIndex) =>
              _reorder(waiting, oldIndex, newIndex),
          itemBuilder: (BuildContext context, int index) {
            final DownloadDomain download = waiting[index];
            return _QueueRow(
              key: ValueKey<String>(download.uid),
              download: download,
              index: index,
              onTogglePause: () => _togglePause(download),
              onDownloadNext: () => _downloadNext(download),
              onRemove: () => _remove(download),
            );
          },
        ),
      ],
    );
  }

  List<DownloadDomain> _orderedWaiting(List<DownloadDomain> queue) {
    final List<DownloadDomain> waiting = waitingDownloadsOf(queue);
    final List<String>? optimistic = _optimisticOrder;
    if (optimistic == null) {
      return waiting;
    }
    final Map<String, int> rank = <String, int>{
      for (int index = 0; index < optimistic.length; index++)
        optimistic[index]: index,
    };
    final Map<String, int> storedRank = <String, int>{
      for (int index = 0; index < waiting.length; index++)
        waiting[index].uid: index,
    };
    int rankOf(DownloadDomain d) =>
        rank[d.uid] ?? optimistic.length + storedRank[d.uid]!;
    waiting.sort(
        (DownloadDomain a, DownloadDomain b) => rankOf(a).compareTo(rankOf(b)));
    return waiting;
  }

  void _reorder(List<DownloadDomain> waiting, int oldIndex, int newIndex) {
    final List<String> order =
        reorderedUids(_uidsOf(waiting), oldIndex, newIndex);
    final int generation = ++_reorderGeneration;
    setState(() {
      _optimisticOrder = order;
      _reorderStored = false;
    });
    unawaited(
      context.read<DownloadManagerCubit>().reorderQueue(order).then((_) {
        if (mounted && generation == _reorderGeneration) {
          _reorderStored = true;
        }
      }),
    );
  }

  void _togglePause(DownloadDomain download) {
    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    if (download.isPaused) {
      unawaited(manager.resumeDownload(download.uid));
      return;
    }
    unawaited(manager.pauseDownload(download.uid));
  }

  void _downloadNext(DownloadDomain download) {
    setState(_dropOptimisticOrder);
    unawaited(context.read<DownloadManagerCubit>().downloadNext(download.uid));
  }

  void _remove(DownloadDomain download) {
    deleteDownloadWithConfirmation(context, download);
  }

  Widget _buildBulkActions(DownloadManagerState state) {
    if (!state.canPauseAny && !state.canResumeAny) {
      return const SizedBox(height: 8);
    }
    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Row(
        children: <Widget>[
          if (state.canPauseAny)
            Expanded(
              child: DownloadQueueButton(
                icon: Icons.pause_rounded,
                label: S.of(context).downloads_queue_pause_all,
                onTap: () => unawaited(manager.pauseAll()),
              ),
            ),
          if (state.canPauseAny && state.canResumeAny)
            const SizedBox(width: 12),
          if (state.canResumeAny)
            Expanded(
              child: DownloadQueueButton(
                icon: Icons.play_arrow_rounded,
                label: S.of(context).downloads_queue_resume_all,
                primary: true,
                onTap: () => unawaited(manager.resumeAll()),
              ),
            ),
        ],
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        '$count',
        style: medium(size: 12, color: AppColors.mainGrey),
      ),
    );
  }
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({
    super.key,
    required this.download,
    required this.onTogglePause,
    required this.onRemove,
    this.onDownloadNext,
    this.index = 0,
    this.pinned = false,
  });

  final DownloadDomain download;
  final VoidCallback onTogglePause;
  final VoidCallback onRemove;
  final VoidCallback? onDownloadNext;
  final int index;
  final bool pinned;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: _fillColor(),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 4, 6),
          child: Row(
            children: <Widget>[
              _buildLeading(),
              const SizedBox(width: 4),
              Expanded(child: _buildDetails(context)),
              ..._buildActions(context),
            ],
          ),
        ),
      ),
    );
  }

  Color _fillColor() {
    if (pinned) {
      return AppColors.primary.withValues(alpha: 0.14);
    }
    return AppColors.overlay(0.04);
  }

  Widget _buildLeading() {
    if (pinned) {
      return SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.downloading_rounded, color: AppColors.primary),
      );
    }
    return ReorderableDragStartListener(
      index: index,
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(Icons.drag_indicator_rounded, color: AppColors.mainGrey),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    final String status = pinned
        ? S.of(context).downloads_queue_now_downloading
        : downloadStatusLabel(download);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          download.title.trim(),
          style: medium(size: 14),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          '${download.concreteTitle} · $status',
          style: regular(size: 12, color: AppColors.mainGrey),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final VoidCallback? downloadNext = onDownloadNext;
    return <Widget>[
      if (downloadNext != null)
        IconButton(
          tooltip: S.of(context).downloads_queue_download_next,
          icon: Icon(Icons.vertical_align_top_rounded,
              color: AppColors.mainGrey),
          onPressed: downloadNext,
        ),
      IconButton(
        tooltip: download.isPaused
            ? S.of(context).downloads_queue_resume
            : S.of(context).downloads_queue_pause,
        icon: Icon(
          download.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
          color: download.isPaused ? AppColors.primary : AppColors.mainGrey,
        ),
        onPressed: onTogglePause,
      ),
      IconButton(
        tooltip: S.of(context).downloads_queue_remove,
        icon: Icon(Icons.close_rounded, color: AppColors.mainGrey),
        onPressed: onRemove,
      ),
    ];
  }
}

class DownloadQueueControls extends StatelessWidget {
  const DownloadQueueControls({super.key, required this.state});

  final DownloadManagerState state;

  @override
  Widget build(BuildContext context) {
    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    return Row(
      children: <Widget>[
        Expanded(
          child: DownloadQueueButton(
            icon: Icons.queue_rounded,
            label: S.of(context).downloads_queue_button(state.queue.length),
            onTap: () => unawaited(showDownloadQueueSheet(context)),
          ),
        ),
        if (state.canPauseAny) ...<Widget>[
          const SizedBox(width: 8),
          Flexible(
            child: DownloadQueueButton(
              icon: Icons.pause_rounded,
              label: S.of(context).downloads_queue_pause_all,
              onTap: () => unawaited(manager.pauseAll()),
            ),
          ),
        ],
        if (state.canResumeAny) ...<Widget>[
          const SizedBox(width: 8),
          Flexible(
            child: DownloadQueueButton(
              icon: Icons.play_arrow_rounded,
              label: S.of(context).downloads_queue_resume_all,
              primary: true,
              onTap: () => unawaited(manager.resumeAll()),
            ),
          ),
        ],
      ],
    );
  }
}

class DownloadQueueButton extends StatelessWidget {
  const DownloadQueueButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color foreground = primary ? AppColors.mainBlack : AppColors.mainWhite;
    return Material(
      color: primary ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: semibold(size: 14, color: foreground),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
