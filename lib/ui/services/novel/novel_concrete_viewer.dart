import 'dart:async';

import 'package:capyscript/api_clients/novel_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/novels/novel_progress.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/services/trackers/tracker_progress.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/concrete_viewer_page.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_button.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/novel/novel_service_viewer.dart';
import 'package:wakaranai/ui/services/novel/reader/novel_reader.dart';
import 'package:wakaranai/ui/services/widgets/chapter_download_button.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef NovelConcreteState = ConcreteViewInitialized<NovelApiClient,
    MangaConcreteView, MangaGalleryView>;

class NovelConcreteViewerData {
  final String uid;
  final Map<String, String> coverHeaders;
  final String? galleryCover;
  final Map<String, dynamic> galleryData;
  final NovelApiClient client;
  final ConfigInfo configInfo;
  final bool fromLibrary;
  final AutoContinueRequest? autoContinue;

  const NovelConcreteViewerData({
    required this.uid,
    required this.coverHeaders,
    required this.galleryCover,
    required this.galleryData,
    required this.client,
    required this.configInfo,
    this.fromLibrary = false,
    this.autoContinue,
  });

  NovelConcreteViewerData copyWith({
    NovelApiClient? client,
    ConfigInfo? configInfo,
  }) {
    return NovelConcreteViewerData(
      uid: uid,
      coverHeaders: coverHeaders,
      galleryCover: galleryCover,
      galleryData: galleryData,
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      fromLibrary: fromLibrary,
      autoContinue: autoContinue,
    );
  }
}

class NovelConcreteViewer extends ConcreteViewerPage<NovelApiClient,
    MangaConcreteView, MangaGalleryView> {
  static const String chapterDateFormat = 'yyyy-MM-dd HH:mm';

  NovelConcreteViewer({super.key, required this.data});

  final NovelConcreteViewerData data;

  @override
  NovelApiClient get client => data.client;

  @override
  ConfigInfo get configInfo => data.configInfo;

  @override
  String get concreteUid => data.uid;

  @override
  Map<String, dynamic> get galleryData => data.galleryData;

  @override
  String? get galleryCover => data.galleryCover;

  @override
  bool get fromLibrary => data.fromLibrary;

  @override
  Map<String, String> get coverHeaders => data.coverHeaders;

  @override
  bool get showsAlternativeTitles => true;

  @override
  String get elementsSectionTitle =>
      S.current.concrete_viewer_chapters_section_title;

  @override
  ServiceGalleryKind<NovelApiClient, MangaGalleryView> get galleryKind =>
      const NovelGalleryKind();

  @override
  AutoContinueRequest? get autoContinue => data.autoContinue;

  @override
  TrackerMediaType get trackerMediaType => TrackerMediaType.manga;

  @override
  int? trackerLocalProgress(NovelConcreteState state) {
    return finishedChapterProgress(
      groups: state.concreteView.groups,
      activities: state.chapterActivities,
    );
  }

  @override
  ConcreteContinueAction? continueAction(
    BuildContext context,
    NovelConcreteState state,
  ) {
    final ContinueTarget<Chapter>? target = resolveChapterContinue(
      groups: state.concreteView.groups,
      preferredGroup: state.groupIndex,
      activities: state.chapterActivities,
    );
    if (target == null) {
      return null;
    }
    return ConcreteContinueAction(
      kind: target.kind,
      title: target.element.title,
      onTap: () => _openContinueTarget(context, state, target),
    );
  }

  void _openContinueTarget(
    BuildContext context,
    NovelConcreteState state,
    ContinueTarget<Chapter> target,
  ) {
    if (target.groupIndex != state.groupIndex) {
      getConcreteViewCubit(context).changeGroup(target.groupIndex);
    }
    final ChapterActivityDomain? activity =
        state.chapterActivities[target.element.uid];
    double fraction = 0;
    if (target.kind == ContinueKind.resume) {
      fraction = NovelProgress.resumeFractionOf(activity);
    }
    _openChapter(
      context,
      state,
      chapter: target.element,
      group: state.concreteView.groups[target.groupIndex],
      initialFraction: fraction,
    );
  }

  void _openChapter(
    BuildContext context,
    NovelConcreteState state, {
    required Chapter chapter,
    required ChaptersGroup group,
    required double initialFraction,
  }) {
    unawaited(Navigator.of(context)
        .pushNamed(
      Routes.novelReader,
      arguments: NovelReaderData(
        apiClient: data.client,
        configInfo: data.configInfo,
        concreteUid: state.concreteView.uid,
        chapters: _readingOrder(state, group),
        chapter: chapter,
        initialFraction: initialFraction,
      ),
    )
        .then((_) {
      getConcreteViewCubit(context).updateActivities();
    }));
  }

  List<Chapter> _readingOrder(NovelConcreteState state, ChaptersGroup group) {
    if (state.order == ConcreteViewOrder.defReverse) {
      return group.elements.reversed.toList(growable: false);
    }
    return List<Chapter>.of(group.elements, growable: false);
  }

  @override
  Widget buildCoverImage(BuildContext context, String cover) {
    return ImageWidget(
      uid: data.uid,
      url: cover,
      headers: data.coverHeaders,
    );
  }

  @override
  Widget buildElementTile(
    BuildContext context,
    NovelConcreteState state,
    int index,
  ) {
    final ChaptersGroup group = state.concreteView.groups[state.groupIndex];
    final Chapter chapter = group.elements[index];
    final ChapterActivityDomain? activity = state.chapterActivities[chapter.uid];
    return BlocSelector<LibraryUpdatesCubit, LibraryUpdatesState, bool>(
      selector: (LibraryUpdatesState updates) => updates.isUnseen(chapter.uid),
      builder: (BuildContext tileContext, bool isNew) => ConcreteListTile(
        title: chapter.title,
        isNew: isNew,
        selected: state.selection.contains(chapter.uid),
        dim: NovelProgress.isFinished(activity),
        progress: _tileProgress(activity),
        trailing: _buildDownloadButton(context, chapter, state),
        subtitle: _buildChapterSubtitle(chapter, activity),
        onLongPress: () {
          getConcreteViewCubit(context).changeSelection(chapter.uid);
        },
        onTap: () {
          if (state.selection.isEmpty) {
            _openChapter(
              context,
              state,
              chapter: chapter,
              group: group,
              initialFraction: NovelProgress.resumeFractionOf(activity),
            );
          } else {
            getConcreteViewCubit(context).changeSelection(chapter.uid);
          }
        },
      ),
    );
  }

  double? _tileProgress(ChapterActivityDomain? activity) {
    if (activity == null) {
      return null;
    }
    return NovelProgress.fractionOf(activity);
  }

  Widget _buildDownloadButton(
    BuildContext context,
    Chapter chapter,
    NovelConcreteState state,
  ) {
    return BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
      builder: (BuildContext context, DownloadManagerState downloads) {
        final DownloadDomain? download = downloads.forChapter(chapter.uid);
        return ChapterDownloadButton(
          download: download,
          onDownload: () => _enqueueChapter(context, chapter, state),
          onRetry: () => _enqueueChapter(context, chapter, state),
          onDelete: () {
            if (download != null) {
              deleteDownloadWithConfirmation(context, download);
            }
          },
          onResume: () => unawaited(
            context.read<DownloadManagerCubit>().resumeDownload(chapter.uid),
          ),
        );
      },
    );
  }

  void _enqueueChapter(
    BuildContext context,
    Chapter chapter,
    NovelConcreteState state,
  ) {
    final ConcreteDataDomain? domain = state.domain;
    if (domain == null) {
      return;
    }
    context.read<DownloadManagerCubit>().enqueueChapter(
          client: data.client,
          extensionUid: data.configInfo.uid,
          concreteUid: state.concreteView.uid,
          concreteId: domain.id,
          concreteTitle: state.concreteView.title,
          concreteCover: state.concreteView.cover,
          chapterUid: chapter.uid,
          title: chapter.title,
          data: chapter.data,
        );
  }

  Widget? _buildChapterSubtitle(
    Chapter chapter,
    ChapterActivityDomain? activity,
  ) {
    final String timestamp = formatTimestamp(chapter);
    final bool hasTimestamp = timestamp.isNotEmpty;
    final bool hasProgress = activity != null &&
        activity.totalPages > 0 &&
        !NovelProgress.isFinished(activity);

    if (!hasTimestamp && !hasProgress) {
      return null;
    }

    return Row(
      children: <Widget>[
        if (hasTimestamp)
          Text(
            timestamp,
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
        if (hasTimestamp && hasProgress)
          Text('  ·  ', style: TextStyle(color: AppColors.mainGrey)),
        if (hasProgress)
          Text(
            S.current.novel_progress_percent(NovelProgress.percentOf(activity)),
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
      ],
    );
  }

  String formatTimestamp(Chapter chapter) {
    final String? raw = chapter.timestamp;
    if (raw == null) {
      return '';
    }
    final int? millis = int.tryParse(raw);
    if (millis == null) {
      return raw;
    }
    return DateFormat(chapterDateFormat)
        .format(DateTime.fromMillisecondsSinceEpoch(millis));
  }
}
