import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/nsfw_titles/nsfw_titles_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/shared_pref/downloads_order_preferences.dart';
import 'package:wakaranai/services/downloads/storage/download_sizes.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/downloads_page/cubit/download_sizes_cubit.dart';
import 'package:wakaranai/ui/home/downloads_page/download_cover.dart';
import 'package:wakaranai/ui/home/downloads_page/download_queue_sheet.dart';
import 'package:wakaranai/ui/home/downloads_page/download_runtime_banner.dart';
import 'package:wakaranai/ui/home/downloads_page/download_storage_actions.dart';
import 'package:wakaranai/ui/home/downloads_page/download_tile.dart';
import 'package:wakaranai/ui/home/downloads_page/free_up_space_sheet.dart';
import 'package:wakaranai/ui/home/downloads_page/download_translation.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/chapter_translation_actions.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final DownloadsOrderPreferences _orderPreferences =
      DownloadsOrderPreferences();
  bool _newestFirst = true;

  @override
  void initState() {
    super.initState();
    unawaited(_restoreOrder());
  }

  Future<void> _restoreOrder() async {
    final bool newestFirst = await _orderPreferences.isNewestFirst();
    if (mounted && newestFirst != _newestFirst) {
      setState(() => _newestFirst = newestFirst);
    }
  }

  void _toggleOrder() {
    setState(() => _newestFirst = !_newestFirst);
    unawaited(_orderPreferences.setNewestFirst(_newestFirst));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DownloadSizesCubit>(
      create: _createSizesCubit,
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: SafeArea(
          bottom: false,
          child: BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
            builder: (BuildContext context, DownloadManagerState state) {
              return Column(
                children: <Widget>[
                  Expanded(child: _buildSizedBody(state)),
                  if (state.downloads.isNotEmpty) _BottomBar(state: state),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  DownloadSizesCubit _createSizesCubit(BuildContext context) {
    final DownloadManagerCubit manager = context.read<DownloadManagerCubit>();
    return DownloadSizesCubit(
      downloads: manager.stream
          .map((DownloadManagerState state) => state.downloads),
      initial: manager.state.downloads,
    );
  }

  Widget _buildSizedBody(DownloadManagerState state) {
    return BlocBuilder<DownloadSizesCubit, DownloadSizesState>(
      builder: (BuildContext context, DownloadSizesState sizes) {
        return _buildBody(context, state, sizes.usage);
      },
    );
  }

  void _showTitleActions(
    List<DownloadDomain> titleDownloads,
    Map<String, int> itemBytes,
  ) {
    showDownloadTitleActions(
      context,
      titleDownloads: titleDownloads,
      itemBytes: itemBytes,
    );
  }

  Widget _buildBody(
    BuildContext context,
    DownloadManagerState state,
    DownloadStorageUsage usage,
  ) {
    final NsfwTitlesState nsfw = context.watch<NsfwTitlesCubit>().state;
    final List<DownloadDomain> visible = state.downloads
        .where((DownloadDomain download) => !nsfw.hides(download.extensionUid))
        .toList(growable: false);
    if (visible.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.download_done_rounded,
        title: S.current.downloads_empty_title,
        message: S.current.downloads_empty_message,
      );
    }

    final Map<String, List<DownloadDomain>> grouped =
        <String, List<DownloadDomain>>{};
    final Iterable<DownloadDomain> ordered =
        _newestFirst ? visible.reversed : visible;
    for (final DownloadDomain d in ordered) {
      grouped.putIfAbsent(d.concreteUid, () => <DownloadDomain>[]).add(d);
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 16),
      children: <Widget>[
        _OrderToggle(newestFirst: _newestFirst, onTap: _toggleOrder),
        DownloadRuntimeBanner(
          state: state,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        ),
        TranslationQueueCard(margin: const EdgeInsets.fromLTRB(16, 8, 16, 0)),
        for (final List<DownloadDomain> titleDownloads in grouped.values) ...<Widget>[
          _GroupHeader(
            downloads: titleDownloads,
            sizeBytes: usage.bytesOfTitle(titleDownloads.first.concreteUid),
            onMore: () => _showTitleActions(titleDownloads, usage.itemBytes),
          ),
          for (final DownloadDomain download in titleDownloads)
            DownloadTile(
              download: download,
              sizeBytes: usage.bytesOfItem(download.uid),
            ),
        ],
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.state});

  final DownloadManagerState state;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.overlay(0.06))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (state.queue.isNotEmpty) ...<Widget>[
            DownloadQueueControls(state: state),
            const SizedBox(height: 10),
          ],
          _StorageBar(),
        ],
      ),
    );
  }
}

class _StorageBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadSizesCubit, DownloadSizesState>(
      builder: (BuildContext context, DownloadSizesState sizes) {
        return Row(
          children: <Widget>[
            Expanded(child: _buildUsage(sizes)),
            const SizedBox(width: 12),
            _buildFreeUpButton(context),
          ],
        );
      },
    );
  }

  Widget _buildUsage(DownloadSizesState sizes) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          S.current.downloads_storage_used,
          style: regular(size: 12, color: AppColors.mainGrey),
        ),
        const SizedBox(height: 2),
        Text(_usageLabel(sizes), style: semibold(size: 16)),
      ],
    );
  }

  String _usageLabel(DownloadSizesState sizes) {
    if (!sizes.measured) {
      return S.current.downloads_storage_calculating;
    }
    return formatDownloadSize(sizes.usage.totalBytes);
  }

  Widget _buildFreeUpButton(BuildContext context) {
    return Material(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => unawaited(showFreeUpSpaceSheet(context)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Icon(
                Icons.cleaning_services_rounded,
                size: 18,
                color: AppColors.mainBlack,
              ),
              const SizedBox(width: 8),
              Text(
                S.current.downloads_storage_free_up,
                style: semibold(size: 14, color: AppColors.mainBlack),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OrderToggle extends StatelessWidget {
  const _OrderToggle({required this.newestFirst, required this.onTap});

  final bool newestFirst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Align(
        alignment: Alignment.centerRight,
        child: Material(
          color: AppColors.overlay(0.06),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  AnimatedRotation(
                    turns: newestFirst ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    child: Icon(
                      Icons.arrow_downward_rounded,
                      size: 18,
                      color: AppColors.mainGrey,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    newestFirst
                        ? S.current.downloads_order_newest
                        : S.current.downloads_order_oldest,
                    style: medium(size: 13),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({
    required this.downloads,
    required this.sizeBytes,
    required this.onMore,
  });

  final List<DownloadDomain> downloads;
  final int sizeBytes;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    final DownloadDomain sample = downloads.first;
    final int doneCount = downloads
        .where((DownloadDomain d) => d.status == DownloadStatus.done)
        .length;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _openConcrete(context, sample),
          child: Row(
            children: <Widget>[
              DownloadCover(
                url: sample.concreteCover,
                isEpisode: sample.isEpisode,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      sample.concreteTitle,
                      style: semibold(size: 16),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _summary(sample, doneCount),
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                  ],
                ),
              ),
              if (sample.hasPageImages) TranslateAllButton(downloads: downloads),
              IconButton(
                tooltip: MaterialLocalizations.of(context).moreButtonTooltip,
                icon: Icon(Icons.more_horiz_rounded, color: AppColors.mainGrey),
                onPressed: onMore,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _summary(DownloadDomain sample, int doneCount) {
    final String counts = _countSummary(sample, doneCount);
    if (sizeBytes <= 0) {
      return counts;
    }
    return S.current.downloads_storage_summary_with_size(
      counts,
      formatDownloadSize(sizeBytes),
    );
  }

  String _countSummary(DownloadDomain sample, int doneCount) {
    if (sample.isEpisode) {
      return S.current.downloads_episode_summary(doneCount, downloads.length);
    }
    return S.current.downloads_chapters_summary(doneCount, downloads.length);
  }

  Future<void> _openConcrete(
      BuildContext context, DownloadDomain sample) async {
    final ConcreteDataRepository repo = context.read<ConcreteDataRepository>();
    final cached = await repo.getByUid(sample.concreteUid);
    if (!context.mounted) return;

    final LibraryEntryDomain entry = LibraryEntryDomain(
      id: 0,
      uid: sample.concreteUid,
      extensionUid: sample.extensionUid,
      title: sample.concreteTitle,
      cover: sample.concreteCover ?? cached?.cover,
      data: cached?.data,
      createdAt: DateTime.now(),
    );

    unawaited(Navigator.of(context).pushNamed(
      Routes.libraryConcreteViewer,
      arguments: LibraryConcreteViewerData(entry: entry),
    ));
  }
}

void confirmDeleteAllDownloads(BuildContext context) {
  showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => ConfirmationDialog(
      title: S.current.downloads_delete_all_confirmation_title,
      message: S.current.downloads_delete_all_confirmation_message,
      yesText: S.current.downloads_confirm_delete,
      noText: S.current.downloads_confirm_cancel,
      destructive: true,
    ),
  ).then((bool? confirmed) {
    if (confirmed == true && context.mounted) {
      context.read<DownloadManagerCubit>().deleteAll();
    }
  });
}
