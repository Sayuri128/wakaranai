import 'dart:async';
import 'dart:convert';

import 'package:capyscript/api_clients/manga_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/data/entities/download_table.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/concrete_viewer_mixin.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_viewer.dart';
import 'package:wakaranai/ui/services/widgets/chapter_download_button.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/ui/widgets/selection_action_bar.dart';
import 'package:wakaranai/ui/widgets/save_image_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
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

  const MangaConcreteViewerData({
    required this.uid,
    required this.coverHeaders,
    required this.galleryCover,
    required this.galleryData,
    required this.client,
    required this.configInfo,
    this.fromLibrary = false,
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
    );
  }
}

class MangaConcreteViewer extends StatelessWidget
    with
        ConcreteViewerMixin<MangaApiClient, MangaConcreteView,
            MangaGalleryView> {
  static const String chapterDateFormat = 'yyyy-MM-dd HH:mm';

  MangaConcreteViewer({super.key, required this.data});

  final GlobalKey _scaffoldKey = GlobalKey();

  final MangaConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    if (data.fromLibrary) {
      return WebBrowserWrapper<MangaApiClient>(
        configInfo: data.configInfo,
        apiClient: data.client,
        onInterceptorInitialized: () {
          _scaffoldKey.currentContext
              ?.read<
                  ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>>()
              .getConcrete(data.uid, data.galleryData);
        },
        builder: (BuildContext context, Completer<bool> completer) =>
            _wrapWithBrowserInterceptorCubit(
                child: _buildConcreteBody(false), completer: completer),
      );
    }
    return _buildConcreteBody(true);
  }

  Widget _buildFavoriteButton(
      BuildContext context, MangaConcreteView concreteView) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (BuildContext context, LibraryState libState) {
        final bool isFavorite = libState.entries
            .any((LibraryEntryDomain e) => e.uid == concreteView.uid);
        return ConcreteFavoriteButton(
          isFavorite: isFavorite,
          onTap: () => context.read<LibraryCubit>().toggleFavorite(
                LibraryEntryDomain(
                  id: 0,
                  uid: concreteView.uid,
                  extensionUid: data.configInfo.uid,
                  title: concreteView.title,
                  cover: concreteView.cover,
                  data: jsonEncode(data.galleryData),
                  createdAt: DateTime.now(),
                ),
              ),
        );
      },
    );
  }

  Widget _buildConcreteBody(bool init) {
    return ConcreteViewCubitWrapper<MangaApiClient, MangaConcreteView,
        MangaGalleryView>(
      client: data.client,
      configInfo: data.configInfo,
      init: (ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>
          cubit) {
        if (init) {
          cubit.getConcrete(data.uid, data.galleryData);
        }
      },
      builder: (BuildContext context,
              ConcreteViewState<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>
                  state) =>
          _buildBody(),
    );
  }

  Widget _wrapWithBrowserInterceptorCubit(
      {required Widget child, required Completer<bool> completer}) {
    if (data.configInfo.protectorConfig?.inAppBrowserInterceptor ?? false) {
      return BlocProvider<BrowserInterceptorCubit>(
        lazy: false,
        create: (BuildContext context) {
          final BrowserInterceptorCubit cubit = BrowserInterceptorCubit()
            ..init(
                url: data.configInfo.protectorConfig!.pingUrl,
                initCompleter: completer);
          data.client.passWebBrowserInterceptorController(controller: cubit);
          return cubit;
        },
        child: child,
      );
    } else {
      return child;
    }
  }

  Scaffold _buildBody() {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      body: BlocConsumer<
          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
              MangaGalleryView>,
          ConcreteViewState<MangaApiClient, MangaConcreteView,
              MangaGalleryView>>(
        listener: (BuildContext context,
            ConcreteViewState<MangaApiClient, MangaConcreteView,
                    MangaGalleryView>
                state) {},
        builder: (BuildContext context,
            ConcreteViewState<MangaApiClient, MangaConcreteView,
                    MangaGalleryView>
                state) {
          final bool initialized = state is ConcreteViewInitialized<
              MangaApiClient, MangaConcreteView, MangaGalleryView>;

          final MangaConcreteView? concreteView =
              initialized ? state.concreteView : null;
          final int currentGroupsIndex = initialized ? state.groupIndex : -1;

          final int groupSize = (initialized && currentGroupsIndex != -1)
              ? concreteView!.groups[currentGroupsIndex].elements.length
              : 0;

          return Stack(
            alignment: Alignment.center,
            children: <Widget>[
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.backgroundColor,
                onRefresh: () async {
                  await context
                      .read<
                          ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                              MangaGalleryView>>()
                      .getConcrete(data.uid, data.galleryData,
                          forceRemote: true);
                },
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(<Widget>[
                        if (data.galleryCover != null)
                          _buildCover(data.galleryCover!, context),
                        if (initialized) ...<Widget>[
                          if (data.galleryCover == null)
                            _buildCover(concreteView!.cover, context),
                          const SizedBox(height: 16),
                          _buildTitle(concreteView!),
                          if (state.offline) ...<Widget>[
                            const SizedBox(height: 16),
                            const ConcreteOfflineBanner(),
                          ],
                          if (concreteView.tags.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 16),
                            _buildTags(context, concreteView),
                          ],
                          if (concreteView.description.isNotEmpty) ...<Widget>[
                            const SizedBox(height: 20),
                            _buildDescription(context, concreteView),
                          ],
                          if (concreteView.groups.length > 1) ...<Widget>[
                            const SizedBox(height: 20),
                            ConcreteGroupSelector(
                              titles: concreteView.groups
                                  .map((ChaptersGroup g) => g.title)
                                  .toList(),
                              selectedIndex: currentGroupsIndex,
                              onSelected: (int index) => context
                                  .read<
                                      ConcreteViewCubit<MangaApiClient,
                                          MangaConcreteView, MangaGalleryView>>()
                                  .changeGroup(index),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ConcreteSectionHeader(
                            title: S
                                .current.concrete_viewer_chapters_section_title,
                            count: groupSize,
                          ),
                        ] else if (state is ConcreteViewError<MangaApiClient,
                            MangaConcreteView, MangaGalleryView>) ...<Widget>[
                          _buildErrorMessage(context, state)
                        ] else ...<Widget>[
                          ConcreteContentSkeleton(
                            showCover: data.galleryCover == null,
                          ),
                        ],
                      ]),
                    ),
                    if (initialized)
                      SliverList.builder(
                        itemCount: groupSize,
                        itemBuilder: (BuildContext context, int index) {
                          final Chapter chapter = concreteView!
                              .groups[currentGroupsIndex].elements[index];
                          return _buildChapter(
                            context: context,
                            chapter: chapter,
                            group: concreteView.groups[currentGroupsIndex],
                            configInfo: data.configInfo,
                            chapterActivityDomain:
                                state.chapterActivities[chapter.uid],
                            concreteViewInitialized: state,
                          );
                        },
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                          height: (initialized && state.selection.isNotEmpty
                                  ? 24 + kSelectionActionBarContentHeight
                                  : 24) +
                              MediaQuery.of(context).padding.bottom),
                    ),
                  ],
                ),
              ),
              const Positioned(
                top: 0,
                left: 0,
                child: ConcreteBackButton(),
              ),
              if (initialized && concreteView != null)
                Positioned(
                  top: 0,
                  right: 0,
                  child: _buildFavoriteButton(context, concreteView),
                ),
              if (initialized) getSelectionOverlay(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(
      BuildContext context,
      ConcreteViewError<MangaApiClient, MangaConcreteView, MangaGalleryView>
          state) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.6,
      child: ServiceViewerMessage(
        icon: Icons.error_outline_rounded,
        title: S.current.concrete_viewer_error_title,
        message: state.message,
        actions: <Widget>[
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.mainBlack,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            onPressed: () => context
                .read<
                    ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                        MangaGalleryView>>()
                .getConcrete(data.uid, data.galleryData, forceRemote: true),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.current.concrete_viewer_retry_button),
          ),
        ],
      ),
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

    return ConcreteListTile(
      title: chapter.title,
      selected: concreteViewInitialized.selection.contains(chapter.uid),
      dim: chapterActivityDomain?.isCompleted == true,
      progress: progress,
      trailing: _buildDownloadButton(context, chapter, concreteViewInitialized),
      subtitle: _buildChapterSubtitle(chapter, chapterActivityDomain),
      onLongPress: () {
        context
            .read<
                ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                    MangaGalleryView>>()
            .changeSelection(chapter.uid);
      },
      onTap: () {
        if (concreteViewInitialized.selection.isEmpty) {
          Navigator.of(context)
              .pushNamed(
            Routes.chapterViewer,
            arguments: ChapterViewerData(
                initialPage: chapterActivityDomain?.readPages ?? 1,
                apiClient: data.client,
                chapter: chapter,
                concreteView: concreteViewInitialized.concreteView,
                group: group,
                configInfo: configInfo),
          )
              .then((_) {
            context
                .read<
                    ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                        MangaGalleryView>>()
                .updateActivities();
          });
        } else {
          context
              .read<
                  ConcreteViewCubit<MangaApiClient, MangaConcreteView,
                      MangaGalleryView>>()
              .changeSelection(chapter.uid);
        }
      },
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
              _onDeleteDownload(context, download);
            }
          },
        );
      },
    );
  }

  void _onDeleteDownload(BuildContext context, DownloadDomain download) {
    final DownloadManagerCubit cubit = context.read<DownloadManagerCubit>();

    if (download.status != DownloadStatus.done) {
      cubit.deleteDownload(download);
      return;
    }

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
      if (confirmed == true) {
        cubit.deleteDownload(download);
      }
    });
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

  Widget _buildTitle(MangaConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(concreteView.title, style: semibold(size: 22)),
          if (concreteView.alternativeTitles.isNotEmpty) ...<Widget>[
            const SizedBox(height: 8),
            Text(
              concreteView.alternativeTitles.join(', '),
              style: regular(size: 14, color: AppColors.mainGrey),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTags(BuildContext context, MangaConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: concreteView.tags
            .map((String e) => ConcreteTagChip(label: e))
            .toList(),
      ),
    );
  }

  Widget _buildCover(String cover, BuildContext context) {
    return Hero(
      tag: Heroes.galleryViewToConcreteView(data.uid),
      flightShuttleBuilder: Heroes.crossfadeFlightShuttle,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onLongPress: () => showSaveImageSheet(
            context,
            url: cover,
            headers: data.coverHeaders,
          ),
          child: Stack(
            children: <Widget>[
              ImageWidget(
                uid: data.uid,
                url: cover,
                headers: data.coverHeaders,
              ),
              const Positioned.fill(child: ConcreteCoverScrim()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(
      BuildContext context, MangaConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpandableDescription(
        text: concreteView.description.replaceAll('\\n', '\n\n').trim(),
      ),
    );
  }
}
