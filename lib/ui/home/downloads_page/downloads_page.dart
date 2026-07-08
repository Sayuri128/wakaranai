import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/downloads_page/download_reader_launcher.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

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
                _Header(hasDownloads: state.downloads.isNotEmpty),
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
    for (final DownloadDomain d in state.downloads) {
      grouped.putIfAbsent(d.concreteUid, () => <DownloadDomain>[]).add(d);
    }

    final double bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 24 + bottomInset),
      children:
          grouped.entries.expand((MapEntry<String, List<DownloadDomain>> e) {
        return <Widget>[
          _GroupHeader(title: e.value.first.concreteTitle),
          ...e.value.map((DownloadDomain d) => _DownloadTile(download: d)),
        ];
      }).toList(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.hasDownloads});

  final bool hasDownloads;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Row(
        children: <Widget>[
          _CircleButton(
            icon: Icons.arrow_back_rounded,
            onTap: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(S.current.downloads_title, style: semibold(size: 24)),
          ),
          if (hasDownloads)
            _CircleButton(
              icon: Icons.delete_sweep_outlined,
              onTap: () => _confirmDeleteAll(context),
            ),
          const SizedBox(width: 8),
        ],
      ),
    );
  }

  void _confirmDeleteAll(BuildContext context) {
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
}

class _GroupHeader extends StatelessWidget {
  const _GroupHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: semibold(size: 16),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

class _DownloadTile extends StatelessWidget {
  const _DownloadTile({required this.download});

  final DownloadDomain download;

  @override
  Widget build(BuildContext context) {
    final bool openable = download.status == DownloadStatus.done;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: openable ? () => _open(context) : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(download.title.trim(), style: medium(size: 15)),
                      const SizedBox(height: 6),
                      _buildSubtitle(context),
                      if (download.status ==
                          DownloadStatus.downloading) ...<Widget>[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: download.progress > 0
                                ? download.progress
                                : null,
                            minHeight: 4,
                            backgroundColor: AppColors.overlay(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.primary),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      color: AppColors.mainGrey),
                  onPressed: () => _confirmDelete(context),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    Navigator.of(context).pushNamed(
      Routes.downloadReader,
      arguments: DownloadReaderData(download: download),
    );
  }

  Widget _buildSubtitle(BuildContext context) {
    late final String label;
    late final Color color;

    switch (download.status) {
      case DownloadStatus.done:
        label = S.current
            .downloads_pages_progress(download.totalPages, download.totalPages);
        color = AppColors.mainGrey;
        break;
      case DownloadStatus.downloading:
        label = S.current.downloads_pages_progress(
            download.downloadedPages, download.totalPages);
        color = AppColors.primary;
        break;
      case DownloadStatus.queued:
        label = S.current.downloads_status_queued;
        color = AppColors.mainGrey;
        break;
      case DownloadStatus.failed:
        label = S.current.downloads_status_failed;
        color = AppColors.red;
        break;
    }

    return Text(label, style: regular(size: 12, color: color));
  }

  void _confirmDelete(BuildContext context) {
    showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        title: S.current.downloads_delete_confirmation_title,
        message: S.current.downloads_delete_confirmation_message,
        yesText: S.current.downloads_confirm_delete,
        noText: S.current.downloads_confirm_cancel,
        destructive: true,
      ),
    ).then((bool? confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<DownloadManagerCubit>().deleteDownload(download);
      }
    });
  }
}

class _CircleButton extends StatelessWidget {
  const _CircleButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.06),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 22, color: AppColors.mainWhite),
        ),
      ),
    );
  }
}
