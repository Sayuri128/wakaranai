import 'dart:async';


import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/services/concrete_viewer_page.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_button.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/services/widgets/chapter_download_button.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/chapter_translation_actions.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class MangaConcreteViewerData {
  final String uid;
  final Map<String, String> coverHeaders;

  // used for hero animation
  final String? galleryCover;
  final Map<String, dynamic> galleryData;
  final MangaApiClient client;
  final ConfigInfo configInfo;
  final bool fromLibrary;
  final AutoContinueRequest? autoContinue;

  const MangaConcreteViewerData({
    required this.uid,
    required this.coverHeaders,
    required this.galleryCover,
    required this.galleryData,
    required this.client,
    required this.configInfo,
    this.fromLibrary = false,
    this.autoContinue,
  });

  MangaConcreteViewerData copyWith({
    MangaApiClient? client,
    ConfigInfo? configInfo,
  }) {
    return MangaConcreteViewerData(
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

class MangaConcreteViewer extends ConcreteViewerPage<MangaApiClient,
    MangaConcreteView, MangaGalleryView> {
  static const String chapterDateFormat = 'yyyy-MM-dd HH:mm';

  MangaConcreteViewer({super.key, required this.data});

  final MangaConcreteViewerData data;

  @override
  MangaApiClient get client => data.client;

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
  ServiceGalleryKind<MangaApiClient, MangaGalleryView> get galleryKind =>
      const MangaGalleryKind();

  @override
  AutoContinueRequest? get autoContinue => data.autoContinue;

  @override
  ConcreteContinueAction? continueAction(
    BuildContext context,
    ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
            MangaGalleryView>
        state,
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
    ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
            MangaGalleryView>
        state,
    ContinueTarget<Chapter> target,
  ) {
    if (target.groupIndex != state.groupIndex) {
      getConcreteViewCubit(context).changeGroup(target.groupIndex);
    }
    final ChapterActivityDomain? activity =
        state.chapterActivities[target.element.uid];
    _openChapter(
      context,
      state,
      chapter: target.element,
      group: state.concreteView.groups[target.groupIndex],
      initialPage:
          target.kind == ContinueKind.resume ? activity?.readPages ?? 1 : 1,
    );
  }

  void _openChapter(
    BuildContext context,
    ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
            MangaGalleryView>
        state, {
    required Chapter chapter,
    required ChaptersGroup group,
    required int initialPage,
  }) {
    unawaited(Navigator.of(context)
        .pushNamed(
      Routes.chapterViewer,
      arguments: ChapterViewerData(
          initialPage: initialPage,
          apiClient: data.client,
          chapter: chapter,
          concreteView: state.concreteView,
          group: group,
          configInfo: data.configInfo),
    )
        .then((_) {
      getConcreteViewCubit(context).updateActivities();
    }));
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
    ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
            MangaGalleryView>
        state,
    int index,
  ) {
    final ChaptersGroup group = state.concreteView.groups[state.groupIndex];
    final Chapter chapter = group.elements[index];
    return _buildChapter(
      context: context,
      chapter: chapter,
      group: group,
      configInfo: data.configInfo,
      chapterActivityDomain: state.chapterActivities[chapter.uid],
      concreteViewInitialized: state,
    );
  }

  Widget _buildChapter(
      {required BuildContext context,
      required Chapter chapter,
      required ChaptersGroup group,
      required ConfigInfo configInfo,
      required ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          concreteViewInitialized,
      required ChapterActivityDomain? chapterActivityDomain}) {
    final bool hasProgress = chapterActivityDomain != null &&
        chapterActivityDomain.totalPages != 0;
    final double? progress = hasProgress
        ? (chapterActivityDomain.readPages / chapterActivityDomain.totalPages)
            .clamp(0.0, 1.0)
        : null;

    return BlocSelector<LibraryUpdatesCubit, LibraryUpdatesState, bool>(
      selector: (LibraryUpdatesState updates) => updates.isUnseen(chapter.uid),
      builder: (BuildContext tileContext, bool isNew) => ConcreteListTile(
      title: chapter.title,
      isNew: isNew,
      selected: concreteViewInitialized.selection.contains(chapter.uid),
      dim: chapterActivityDomain?.isCompleted == true,
      progress: progress,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ChapterTranslationBadge(
            chapterUid: chapter.uid,
            chapterTitle: chapter.title,
          ),
          _buildDownloadButton(context, chapter, concreteViewInitialized),
        ],
      ),
      subtitle: _buildChapterSubtitle(chapter, chapterActivityDomain),
      onLongPress: () {
        getConcreteViewCubit(context).changeSelection(chapter.uid);
      },
      onTap: () {
        if (concreteViewInitialized.selection.isEmpty) {
          _openChapter(
            context,
            concreteViewInitialized,
            chapter: chapter,
            group: group,
            initialPage: chapterActivityDomain?.readPages ?? 1,
          );
        } else {
          getConcreteViewCubit(context).changeSelection(chapter.uid);
        }
      },
    ),
    );
  }

  Widget _buildDownloadButton(
      BuildContext context,
      Chapter chapter,
      ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          state) {
    return BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
      builder: (BuildContext context, DownloadManagerState dlState) {
        final download = dlState.forChapter(chapter.uid);
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
      ConcreteViewInitialized<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          state) {
    if (state.domain == null) return;
    context.read<DownloadManagerCubit>().enqueueChapter(
          client: data.client,
          extensionUid: data.configInfo.uid,
          concreteUid: state.concreteView.uid,
          concreteId: state.domain!.id,
          concreteTitle: state.concreteView.title,
          concreteCover: state.concreteView.cover,
          chapterUid: chapter.uid,
          title: chapter.title,
          data: chapter.data,
        );
  }

  Widget? _buildChapterSubtitle(
      Chapter chapter, ChapterActivityDomain? activity) {
    final bool hasTimestamp =
        chapter.timestamp != null && formatTimestamp(chapter).isNotEmpty;
    final bool hasProgress = activity != null && activity.totalPages != 0;

    if (!hasTimestamp && !hasProgress) {
      return null;
    }

    return Row(
      children: <Widget>[
        if (hasTimestamp)
          Text(
            formatTimestamp(chapter),
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
        if (hasTimestamp && hasProgress)
          Text('  ·  ', style: TextStyle(color: AppColors.mainGrey)),
        if (hasProgress)
          Text(
            "${activity.readPages}/${activity.totalPages}",
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
      ],
    );
  }

  String formatTimestamp(Chapter e) {
    return int.tryParse(e.timestamp ?? '') != null
        ? DateFormat(chapterDateFormat).format(
            DateTime.fromMillisecondsSinceEpoch(int.tryParse(e.timestamp!)!))
        : e.timestamp ?? '';
  }
}
