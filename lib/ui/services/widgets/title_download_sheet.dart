import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/title_downloader.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class TitleDownloadRequest {
  const TitleDownloadRequest({
    required this.uid,
    required this.extensionUid,
    required this.galleryData,
    required this.loadClient,
  });

  final String uid;
  final String extensionUid;
  final Map<String, dynamic> galleryData;
  final Future<MangaApiClient> Function() loadClient;
}

typedef _QueueChoice =
    void Function(
      DownloadableTitle title,
      Set<int> groups,
      ChapterDownloadAmount amount,
    );

Future<void> showTitleDownloadSheet(
  BuildContext context, {
  required TitleDownloadRequest request,
}) {
  final TitleDownloader downloader = TitleDownloader(
    downloadManager: context.read<DownloadManagerCubit>(),
    concreteDataRepository: context.read<ConcreteDataRepository>(),
    chapterActivityRepository: context.read<ChapterActivityRepository>(),
    downloadRepository: context.read<DownloadRepository>(),
  );
  return showActionSheet(
    context,
    title: S.current.title_download_title,
    child: _TitleDownloadPanel(
      request: request,
      downloader: downloader,
      onQueue:
          (
            DownloadableTitle title,
            Set<int> groups,
            ChapterDownloadAmount amount,
          ) => _queue(context, downloader, title, groups, amount),
    ),
  );
}

Future<void> _queue(
  BuildContext context,
  TitleDownloader downloader,
  DownloadableTitle title,
  Set<int> groups,
  ChapterDownloadAmount amount,
) async {
  final int queued = await downloader.queue(
    title,
    groupIndexes: groups,
    amount: amount,
  );
  if (!context.mounted) {
    return;
  }
  SnackBars.showSnackBar(
    context: context,
    message: queued == 0
        ? S.current.title_download_nothing
        : S.current.title_download_queued(queued),
  );
}

class _TitleDownloadPanel extends StatefulWidget {
  const _TitleDownloadPanel({
    required this.request,
    required this.downloader,
    required this.onQueue,
  });

  final TitleDownloadRequest request;
  final TitleDownloader downloader;
  final _QueueChoice onQueue;

  @override
  State<_TitleDownloadPanel> createState() => _TitleDownloadPanelState();
}

class _TitleDownloadPanelState extends State<_TitleDownloadPanel> {
  late Future<DownloadableTitle> _title;
  final Set<int> _selectedGroups = <int>{0};

  @override
  void initState() {
    super.initState();
    _title = _load();
  }

  Future<DownloadableTitle> _load() async {
    try {
      return await widget.downloader.load(
        client: await widget.request.loadClient(),
        extensionUid: widget.request.extensionUid,
        uid: widget.request.uid,
        galleryData: widget.request.galleryData,
      );
    } catch (error, stack) {
      logger.w('Loading chapters for ${widget.request.uid} failed: $error');
      logger.w(stack);
      rethrow;
    }
  }

  void _retry() {
    setState(() => _title = _load());
  }

  void _toggleGroup(int index) {
    setState(() {
      if (!_selectedGroups.remove(index)) {
        _selectedGroups.add(index);
      }
      if (_selectedGroups.isEmpty) {
        _selectedGroups.add(index);
      }
    });
  }

  void _choose(DownloadableTitle title, ChapterDownloadAmount amount) {
    Navigator.of(context).pop();
    widget.onQueue(title, Set<int>.of(_selectedGroups), amount);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DownloadableTitle>(
      future: _title,
      builder: (BuildContext context, AsyncSnapshot<DownloadableTitle> snap) {
        if (snap.hasError) {
          return _buildError();
        }
        final DownloadableTitle? title = snap.data;
        if (title == null) {
          return _buildLoading();
        }
        if (title.groups.every(
          (ChaptersGroup group) => group.elements.isEmpty,
        )) {
          return _buildMessage(S.current.title_download_no_chapters);
        }
        return _buildOptions(title);
      },
    );
  }

  Widget _buildOptions(DownloadableTitle title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title.groups.length > 1) ...<Widget>[
          _buildSectionLabel(S.current.title_download_groups),
          for (int index = 0; index < title.groups.length; index++)
            ActionSheetRow(
              label: _groupLabel(title.groups[index], index),
              selected: _selectedGroups.contains(index),
              onTap: () => _toggleGroup(index),
            ),
          _buildSectionLabel(S.current.title_download_how_many),
        ],
        for (final ChapterDownloadAmount amount in ChapterDownloadAmount.values)
          ActionSheetRow(
            icon: Icons.download_rounded,
            label: chapterDownloadAmountLabel(amount),
            onTap: () => _choose(title, amount),
          ),
      ],
    );
  }

  String _groupLabel(ChaptersGroup group, int index) {
    final String name = group.title.trim().isEmpty
        ? S.current.title_download_untitled_group(index + 1)
        : group.title.trim();
    final String count = S.current.title_download_chapter_count(
      group.elements.length,
    );
    return '$name · $count';
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(text, style: medium(size: 12, color: AppColors.mainGrey)),
    );
  }

  Widget _buildLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 18,
            height: 18,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            S.current.title_download_loading,
            style: regular(size: 14, color: AppColors.mainGrey),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(String message) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Text(message, style: regular(size: 14, color: AppColors.mainGrey)),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 12, 8),
      child: Row(
        children: <Widget>[
          Icon(Icons.error_outline_rounded, color: AppColors.red, size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              S.current.title_download_failed,
              style: regular(size: 14, color: AppColors.mainWhite),
            ),
          ),
          TextButton(
            onPressed: _retry,
            child: Text(
              S.current.concrete_viewer_retry_button,
              style: medium(size: 14, color: AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}

String chapterDownloadAmountLabel(ChapterDownloadAmount amount) {
  switch (amount) {
    case ChapterDownloadAmount.next:
      return S.current.title_download_next;
    case ChapterDownloadAmount.nextFive:
      return S.current.title_download_next_count(5);
    case ChapterDownloadAmount.nextTen:
      return S.current.title_download_next_count(10);
    case ChapterDownloadAmount.unread:
      return S.current.title_download_unread;
    case ChapterDownloadAmount.all:
      return S.current.title_download_all;
  }
}
