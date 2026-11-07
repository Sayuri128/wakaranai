import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/shared_pref/downloads_order_preferences.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/downloads_page/download_tile.dart';
import 'package:wakaranai/ui/home/downloads_page/download_translation.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/chapter_translation_actions.dart';
import 'package:wakaranai/ui/home/library_page/library_concrete_viewer.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/images.dart';
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
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
          builder: (BuildContext context, DownloadManagerState state) {
            return Column(
              children: <Widget>[
                Expanded(child: _buildBody(context, state)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, DownloadManagerState state) {
    if (state.downloads.isEmpty) {
      return ServiceViewerMessage(
        icon: Icons.download_done_rounded,
        title: S.current.downloads_empty_title,
        message: S.current.downloads_empty_message,
      );
    }

    final Map<String, List<DownloadDomain>> grouped =
        <String, List<DownloadDomain>>{};
    final Iterable<DownloadDomain> ordered =
        _newestFirst ? state.downloads.reversed : state.downloads;
    for (final DownloadDomain d in ordered) {
      grouped.putIfAbsent(d.concreteUid, () => <DownloadDomain>[]).add(d);
    }

    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24 + bottomInset),
      children: <Widget>[
        _OrderToggle(newestFirst: _newestFirst, onTap: _toggleOrder),
        TranslationQueueCard(margin: const EdgeInsets.fromLTRB(16, 8, 16, 0)),
        for (final List<DownloadDomain> titleDownloads in grouped.values) ...<Widget>[
          _GroupHeader(downloads: titleDownloads),
          for (final DownloadDomain download in titleDownloads)
            DownloadTile(download: download),
        ],
      ],
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
  const _GroupHeader({required this.downloads});

  final List<DownloadDomain> downloads;

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
              _Cover(url: sample.concreteCover, isEpisode: sample.isEpisode),
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
              if (!sample.isEpisode) TranslateAllButton(downloads: downloads),
              Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
            ],
          ),
        ),
      ),
    );
  }

  String _summary(DownloadDomain sample, int doneCount) {
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

class _Cover extends StatelessWidget {
  const _Cover({required this.url, required this.isEpisode});

  final String? url;
  final bool isEpisode;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: 48,
        height: 64,
        child: url == null
            ? _placeholder()
            : CachedNetworkImage(
                imageUrl: url!,
                memCacheWidth: decodeWidthFor(context, 48),
                fit: BoxFit.cover,
                placeholder: (BuildContext context, String _) => _placeholder(),
                errorWidget: (BuildContext context, String _, Object __) =>
                    _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.overlay(0.08),
      child: Center(
        child: Icon(
          isEpisode ? Icons.movie_rounded : Icons.menu_book_rounded,
          color: AppColors.mainGrey,
          size: 22,
        ),
      ),
    );
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
