import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/downloads/storage/download_sizes.dart';
import 'package:wakaranai/services/downloads/storage/watched_episode_downloads.dart';
import 'package:wakaranai/ui/home/downloads_page/cubit/download_sizes_cubit.dart';
import 'package:wakaranai/ui/home/downloads_page/download_cover.dart';
import 'package:wakaranai/ui/home/downloads_page/download_storage_actions.dart';
import 'package:wakaranai/ui/home/downloads_page/download_tile.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showFreeUpSpaceSheet(BuildContext context) {
  final DownloadSizesCubit sizes = context.read<DownloadSizesCubit>();
  final DownloadStorageActions actions = DownloadStorageActions.of(context);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return BlocProvider<DownloadSizesCubit>.value(
        value: sizes,
        child: FreeUpSpaceSheet(actions: actions),
      );
    },
  );
}

class FreeUpSpaceSheet extends StatefulWidget {
  const FreeUpSpaceSheet({super.key, required this.actions});

  final DownloadStorageActions actions;

  @override
  State<FreeUpSpaceSheet> createState() => _FreeUpSpaceSheetState();
}

class _FreeUpSpaceSheetState extends State<FreeUpSpaceSheet> {
  Map<String, Set<String>> _watchedByTitle = <String, Set<String>>{};
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    unawaited(_loadWatched());
  }

  Future<void> _loadWatched() async {
    final DownloadStorageUsage usage = context
        .read<DownloadSizesCubit>()
        .state
        .usage;
    final Map<String, Set<String>> watched = <String, Set<String>>{};
    for (final TitleStorageUsage title in usage.titles.values) {
      if (!title.isEpisode) {
        continue;
      }
      final List<DownloadDomain> titleWatched = await widget.actions
          .watchedDownloadsOf(title.downloads);
      if (titleWatched.isNotEmpty) {
        watched[title.concreteUid] = <String>{
          for (final DownloadDomain download in titleWatched) download.uid,
        };
      }
    }
    if (mounted) {
      setState(() => _watchedByTitle = watched);
    }
  }

  Future<void> _runAction(Future<bool> Function() action) async {
    if (_busy) {
      return;
    }
    setState(() => _busy = true);
    try {
      await action();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  void _deleteWatched(TitleStorageUsage title, Map<String, int> itemBytes) {
    unawaited(
      _runAction(
        () => widget.actions.deleteWatchedWithConfirmation(
          context,
          titleDownloads: title.downloads,
          itemBytes: itemBytes,
        ),
      ),
    );
  }

  void _deleteTitle(TitleStorageUsage title, Map<String, int> itemBytes) {
    unawaited(
      _runAction(
        () => widget.actions.deleteTitleWithConfirmation(
          context,
          titleDownloads: title.downloads,
          itemBytes: itemBytes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadSizesCubit, DownloadSizesState>(
      builder: (BuildContext context, DownloadSizesState state) {
        final DownloadStorageUsage usage = state.usage;
        final List<TitleStorageUsage> titles = usage.titlesBySize
            .where((TitleStorageUsage title) => title.bytes > 0)
            .toList(growable: false);
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.85,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHandle(),
                _buildHeader(context, usage, titles),
                if (_busy)
                  LinearProgressIndicator(
                    minHeight: 2,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
                  ),
                Flexible(child: _buildTitles(context, titles, usage.itemBytes)),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
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

  Widget _buildHeader(
    BuildContext context,
    DownloadStorageUsage usage,
    List<TitleStorageUsage> titles,
  ) {
    final String subtitle = titles.isEmpty
        ? S.of(context).downloads_storage_free_up_empty
        : S
              .of(context)
              .downloads_storage_free_up_reclaimable(
                formatDownloadSize(usage.totalBytes),
              );
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.of(context).downloads_storage_free_up,
            style: semibold(size: 18),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: regular(size: 14, color: AppColors.mainGrey)),
        ],
      ),
    );
  }

  Widget _buildTitles(
    BuildContext context,
    List<TitleStorageUsage> titles,
    Map<String, int> itemBytes,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: titles.length,
      itemBuilder: (BuildContext context, int index) {
        final TitleStorageUsage title = titles[index];
        final List<DownloadDomain> watched = watchedEpisodeDownloads(
          title.downloads,
          _watchedByTitle[title.concreteUid] ?? const <String>{},
        );
        return _FreeUpTitleRow(
          title: title,
          watchedCount: watched.length,
          watchedBytes: bytesOfDownloads(watched, itemBytes),
          enabled: !_busy,
          onDeleteWatched: () => _deleteWatched(title, itemBytes),
          onDeleteTitle: () => _deleteTitle(title, itemBytes),
        );
      },
    );
  }
}

class _FreeUpTitleRow extends StatelessWidget {
  const _FreeUpTitleRow({
    required this.title,
    required this.watchedCount,
    required this.watchedBytes,
    required this.enabled,
    required this.onDeleteWatched,
    required this.onDeleteTitle,
  });

  final TitleStorageUsage title;
  final int watchedCount;
  final int watchedBytes;
  final bool enabled;
  final VoidCallback onDeleteWatched;
  final VoidCallback onDeleteTitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              DownloadCover(
                url: title.concreteCover,
                isEpisode: title.isEpisode,
                width: 40,
                height: 54,
              ),
              const SizedBox(width: 12),
              Expanded(child: _buildDetails(context)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          title.concreteTitle,
          style: semibold(size: 15),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          S
              .of(context)
              .downloads_storage_title_size(
                title.downloads.length,
                formatDownloadSize(title.bytes),
              ),
          style: regular(size: 12, color: AppColors.mainGrey),
        ),
        if (watchedCount > 0) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            S
                .of(context)
                .downloads_storage_watched_size(
                  watchedCount,
                  formatDownloadSize(watchedBytes),
                ),
            style: regular(size: 12, color: AppColors.primary),
          ),
        ],
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            if (watchedCount > 0)
              _SheetChip(
                label: S.of(context).downloads_storage_delete_watched,
                icon: Icons.playlist_remove_rounded,
                tint: AppColors.primary,
                onTap: enabled ? onDeleteWatched : null,
              ),
            _SheetChip(
              label: S.of(context).downloads_storage_delete_all_short,
              icon: Icons.delete_outline_rounded,
              tint: AppColors.red,
              onTap: enabled ? onDeleteTitle : null,
            ),
          ],
        ),
      ],
    );
  }
}

class _SheetChip extends StatelessWidget {
  const _SheetChip({
    required this.label,
    required this.icon,
    required this.tint,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: tint.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: 6),
              Text(label, style: medium(size: 13, color: tint)),
            ],
          ),
        ),
      ),
    );
  }
}
