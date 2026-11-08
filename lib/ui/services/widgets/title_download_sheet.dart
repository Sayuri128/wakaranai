import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/api_clients/audio_api_client.dart';
import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/common/element_of_elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/common/elements_group_of_concrete.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/repositories/database/anime_episode_activity_repository.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/repositories/database/concerete_data_repository.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/chapter_download_selection.dart';
import 'package:wakaranai/services/downloads/episode_title_downloader.dart';
import 'package:wakaranai/services/downloads/title_downloader.dart';
import 'package:wakaranai/ui/services/widgets/title_download_labels.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

export 'package:wakaranai/ui/services/widgets/title_download_labels.dart';

class TitleDownloadRequest {
  const TitleDownloadRequest({
    required this.uid,
    required this.extensionUid,
    required this.galleryData,
    required this.loadClient,
    this.type = ConfigInfoType.MANGA,
    this.releaseClient,
  });

  final String uid;
  final String extensionUid;
  final Map<String, dynamic> galleryData;
  final Future<ApiClient> Function() loadClient;
  final ConfigInfoType type;
  final Future<void> Function()? releaseClient;

  Future<T> loadWithClient<T>(Future<T> Function(ApiClient client) load) async {
    try {
      return await load(await loadClient());
    } finally {
      await releaseClient?.call();
    }
  }
}

T expectClient<T extends ApiClient>(ApiClient client) {
  if (client is T) {
    return client;
  }
  throw StateError('Expected a $T but got ${client.runtimeType}');
}

ConfigInfoType downloadTypeOf(ApiClient client) {
  if (client is AnimeApiClient) {
    return ConfigInfoType.ANIME;
  }
  if (client is NovelApiClient) {
    return ConfigInfoType.NOVEL;
  }
  if (client is AudioApiClient) {
    return ConfigInfoType.AUDIO;
  }
  return ConfigInfoType.MANGA;
}

ApiClient expectChapterClient(ApiClient client) {
  if (client is MangaApiClient || client is NovelApiClient) {
    return client;
  }
  throw StateError('Expected a chapter client but got ${client.runtimeType}');
}

typedef _QueueChoice<T> =
    void Function(T title, Set<int> groups, ChapterDownloadAmount amount);

Future<void> showTitleDownloadSheet(
  BuildContext context, {
  required TitleDownloadRequest request,
}) {
  final TitleDownloadLabels labels = TitleDownloadLabels.forType(request.type);
  return showActionSheet(
    context,
    title: labels.sheetTitle,
    child: _buildPanel(context, request, labels),
  );
}

Widget _buildPanel(
  BuildContext context,
  TitleDownloadRequest request,
  TitleDownloadLabels labels,
) {
  switch (request.type) {
    case ConfigInfoType.MANGA:
    case ConfigInfoType.NOVEL:
      return _buildChapterPanel(context, request, labels);
    case ConfigInfoType.ANIME:
      return _buildEpisodePanel(context, request, labels);
    case ConfigInfoType.AUDIO:
      return const SizedBox.shrink();
  }
}

Widget _buildChapterPanel(
  BuildContext context,
  TitleDownloadRequest request,
  TitleDownloadLabels labels,
) {
  final TitleDownloader downloader = TitleDownloader(
    downloadManager: context.read<DownloadManagerCubit>(),
    concreteDataRepository: context.read<ConcreteDataRepository>(),
    chapterActivityRepository: context.read<ChapterActivityRepository>(),
    downloadRepository: context.read<DownloadRepository>(),
  );
  return _TitleDownloadPanel<DownloadableTitle>(
    uid: request.uid,
    labels: labels,
    load: () => request.loadWithClient(
      (ApiClient client) => downloader.load(
        client: expectChapterClient(client),
        extensionUid: request.extensionUid,
        uid: request.uid,
        galleryData: request.galleryData,
      ),
    ),
    onQueue:
        (
          DownloadableTitle title,
          Set<int> groups,
          ChapterDownloadAmount amount,
        ) => _queue(
          context,
          labels,
          downloader.queue(title, groupIndexes: groups, amount: amount),
        ),
  );
}

Widget _buildEpisodePanel(
  BuildContext context,
  TitleDownloadRequest request,
  TitleDownloadLabels labels,
) {
  final EpisodeTitleDownloader downloader = EpisodeTitleDownloader(
    downloadManager: context.read<DownloadManagerCubit>(),
    concreteDataRepository: context.read<ConcreteDataRepository>(),
    episodeActivityRepository: context.read<AnimeEpisodeActivityRepository>(),
    downloadRepository: context.read<DownloadRepository>(),
  );
  return _TitleDownloadPanel<DownloadableAnimeTitle>(
    uid: request.uid,
    labels: labels,
    load: () => request.loadWithClient(
      (ApiClient client) => downloader.load(
        client: expectClient<AnimeApiClient>(client),
        extensionUid: request.extensionUid,
        uid: request.uid,
        galleryData: request.galleryData,
      ),
    ),
    onQueue:
        (
          DownloadableAnimeTitle title,
          Set<int> groups,
          ChapterDownloadAmount amount,
        ) => _queue(
          context,
          labels,
          downloader.queue(title, groupIndexes: groups, amount: amount),
        ),
  );
}

Future<void> _queue(
  BuildContext context,
  TitleDownloadLabels labels,
  Future<int> queueing,
) async {
  final int queued = await queueing;
  if (!context.mounted) {
    return;
  }
  SnackBars.showSnackBar(
    context: context,
    message: queued == 0 ? labels.nothing : labels.queued(queued),
  );
}

class _TitleDownloadPanel<T extends TitleDownloadContent>
    extends StatefulWidget {
  const _TitleDownloadPanel({
    required this.uid,
    required this.labels,
    required this.load,
    required this.onQueue,
  });

  final String uid;
  final TitleDownloadLabels labels;
  final Future<T> Function() load;
  final _QueueChoice<T> onQueue;

  @override
  State<_TitleDownloadPanel<T>> createState() => _TitleDownloadPanelState<T>();
}

class _TitleDownloadPanelState<T extends TitleDownloadContent>
    extends State<_TitleDownloadPanel<T>> {
  late Future<T> _title;
  final Set<int> _selectedGroups = <int>{0};

  TitleDownloadLabels get _labels => widget.labels;

  @override
  void initState() {
    super.initState();
    _title = _load();
  }

  Future<T> _load() async {
    try {
      return await widget.load();
    } catch (error, stack) {
      logger.w('Loading downloadable content for ${widget.uid} failed: $error');
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

  void _choose(T title, ChapterDownloadAmount amount) {
    Navigator.of(context).pop();
    widget.onQueue(title, Set<int>.of(_selectedGroups), amount);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<T>(
      future: _title,
      builder: (BuildContext context, AsyncSnapshot<T> snap) {
        if (snap.hasError) {
          return _buildError();
        }
        final T? title = snap.data;
        if (title == null) {
          return _buildLoading();
        }
        if (title.groups.every(
          (ElementsGroupOfConcrete<ElementOfElementsGroupOfConcrete> group) =>
              group.elements.isEmpty,
        )) {
          return _buildMessage(_labels.empty);
        }
        return _buildOptions(title);
      },
    );
  }

  Widget _buildOptions(T title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (title.groups.length > 1) ...<Widget>[
          _buildSectionLabel(_labels.groups),
          for (int index = 0; index < title.groups.length; index++)
            ActionSheetRow(
              label: _groupLabel(title.groups[index], index),
              selected: _selectedGroups.contains(index),
              onTap: () => _toggleGroup(index),
            ),
          _buildSectionLabel(_labels.howMany),
        ],
        for (final ChapterDownloadAmount amount in ChapterDownloadAmount.values)
          ActionSheetRow(
            icon: Icons.download_rounded,
            label: _labels.amount(amount),
            onTap: () => _choose(title, amount),
          ),
      ],
    );
  }

  String _groupLabel(
    ElementsGroupOfConcrete<ElementOfElementsGroupOfConcrete> group,
    int index,
  ) {
    final String name = group.title.trim().isEmpty
        ? S.current.title_download_untitled_group(index + 1)
        : group.title.trim();
    final String count = _labels.elementCount(group.elements.length);
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
            _labels.loading,
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
              _labels.failed,
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
