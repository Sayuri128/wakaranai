import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/browser_interceptor/browser_interceptor_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/concrete_view_cubit_wrapper.dart';
import 'package:wakaranai/ui/home/web_browser_wrapper.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/services/concrete_viewer_mixin.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/save_image_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/heroes.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AnimeConcreteViewerData {
  final String uid;
  final Map<String, dynamic> galleryData;

  // used for hero animation
  final String? galleryCover;
  final AnimeApiClient client;
  final ConfigInfo configInfo;
  final bool fromLibrary;

  const AnimeConcreteViewerData(
      {required this.uid,
      required this.galleryData,
      required this.galleryCover,
      required this.client,
      required this.configInfo,
      this.fromLibrary = false});
}

class AnimeConcreteViewer extends StatelessWidget
    with
        ConcreteViewerMixin<AnimeApiClient, AnimeConcreteView,
            AnimeGalleryView> {
  AnimeConcreteViewer({super.key, required this.data});

  final GlobalKey _scaffoldKey = GlobalKey();

  final AnimeConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    if (data.fromLibrary) {
      return WebBrowserWrapper(
        configInfo: data.configInfo,
        apiClient: data.client,
        onInterceptorInitialized: () {
          _scaffoldKey.currentContext
              ?.read<
                  ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                      AnimeGalleryView>>()
              .getConcrete(data.uid, data.galleryData);
        },
        builder: (BuildContext context, Completer<bool> completer) =>
            _wrapWithBrowserInterceptorCubit(
                child: _buildConcreteBody(init: false), completer: completer),
      );
    } else {
      return _buildConcreteBody(init: true);
    }
  }

  Widget _buildFavoriteButton(
      BuildContext context, AnimeConcreteView concreteView) {
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

  Widget _buildConcreteBody({required bool init}) {
    return ConcreteViewCubitWrapper<AnimeApiClient, AnimeConcreteView,
        AnimeGalleryView>(
      client: data.client,
      configInfo: data.configInfo,
      init: (ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>
          cubit) {
        if (init) {
          cubit.getConcrete(data.uid, data.galleryData);
        }
      },
      builder: (BuildContext context,
              ConcreteViewState<AnimeApiClient, AnimeConcreteView,
                      AnimeGalleryView>
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
      body: BlocBuilder<
          ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>,
          ConcreteViewState<AnimeApiClient, AnimeConcreteView,
              AnimeGalleryView>>(
        builder: (BuildContext context,
            ConcreteViewState<AnimeApiClient, AnimeConcreteView,
                    AnimeGalleryView>
                state) {
          final bool initialized = state is ConcreteViewInitialized<
              AnimeApiClient, AnimeConcreteView, AnimeGalleryView>;

          final AnimeConcreteView? concreteView =
              initialized ? state.concreteView : null;
          final int currentGroupIndex = initialized ? state.groupIndex : -1;

          final int groupSize = (initialized && currentGroupIndex != -1)
              ? concreteView!.groups[currentGroupIndex].elements.length
              : 0;

          return Stack(
            children: <Widget>[
              RefreshIndicator(
                color: AppColors.primary,
                backgroundColor: AppColors.backgroundColor,
                onRefresh: () async {
                  await context
                      .read<
                          ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                              AnimeGalleryView>>()
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
                                  .map((AnimeVideoGroup g) => g.title)
                                  .toList(),
                              selectedIndex: currentGroupIndex,
                              onSelected: (int index) => context
                                  .read<
                                      ConcreteViewCubit<AnimeApiClient,
                                          AnimeConcreteView, AnimeGalleryView>>()
                                  .changeGroup(index),
                            ),
                          ],
                          const SizedBox(height: 20),
                          ConcreteSectionHeader(
                            title: S
                                .current.concrete_viewer_episodes_section_title,
                            count: groupSize,
                          ),
                        ] else if (state is ConcreteViewError<AnimeApiClient,
                            AnimeConcreteView, AnimeGalleryView>) ...<Widget>[
                          _buildErrorMessage(context, state),
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
                          final AnimeVideo animeVideo = concreteView!
                              .groups[currentGroupIndex].elements[index];
                          return _buildEpisode(
                            context: context,
                            animeVideo: animeVideo,
                            concreteView: concreteView,
                            activity:
                                state.animeEpisodeActivities[animeVideo.uid],
                            state: state,
                          );
                        },
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(
                          height: 24 + MediaQuery.of(context).padding.bottom),
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
      ConcreteViewError<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
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
                    ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                        AnimeGalleryView>>()
                .getConcrete(data.uid, data.galleryData, forceRemote: true),
            icon: const Icon(Icons.refresh_rounded),
            label: Text(S.current.concrete_viewer_retry_button),
          ),
        ],
      ),
    );
  }

  Widget _buildEpisode({
    required BuildContext context,
    required AnimeVideo animeVideo,
    required AnimeConcreteView concreteView,
    required AnimeEpisodeActivityDomain? activity,
    required ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView,
            AnimeGalleryView>
        state,
  }) {
    return ConcreteListTile(
      title: animeVideo.title,
      selected: state.selection.contains(animeVideo.uid),
      dim: activity != null,
      subtitle: _buildEpisodeSubtitle(animeVideo, activity),
      onLongPress: () {
        getConcreteViewCubit(context).changeSelection(animeVideo.uid);
      },
      onTap: () {
        if (state.selection.isEmpty) {
          Navigator.of(context)
              .pushNamed(
            Routes.iframeAnimePlayer,
            arguments: AnimeIframePlayerData(
              anime: concreteView,
              video: animeVideo,
            ),
          )
              .then((_) {
            context
                .read<
                    ConcreteViewCubit<AnimeApiClient, AnimeConcreteView,
                        AnimeGalleryView>>()
                .updateActivities();
          });
        } else {
          getConcreteViewCubit(context).changeSelection(animeVideo.uid);
        }
      },
    );
  }

  Widget? _buildEpisodeSubtitle(
      AnimeVideo animeVideo, AnimeEpisodeActivityDomain? activity) {
    final bool hasTimestamp = animeVideo.timestamp != null &&
        (animeVideo.timestamp?.isNotEmpty ?? false);

    if (!hasTimestamp && activity == null) {
      return null;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (hasTimestamp)
          Text(
            int.tryParse(animeVideo.timestamp ?? '') != null
                ? DateFormat(animeVideo.timestamp).format(
                    DateTime.fromMillisecondsSinceEpoch(
                        int.tryParse(animeVideo.timestamp!)!))
                : animeVideo.timestamp ?? '',
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
        if (activity != null) ...<Widget>[
          if (hasTimestamp) const SizedBox(height: 4),
          Text(
            S.current.anime_concrete_viewer_watched_at_title(
                DateFormat('yyyy-MM-dd HH:mm').format(activity.createdAt)),
            style: regular(color: AppColors.primary, size: 12),
          ),
        ],
      ],
    );
  }

  Widget _buildTitle(AnimeConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(concreteView.title, style: semibold(size: 22)),
    );
  }

  Widget _buildTags(BuildContext context, AnimeConcreteView concreteView) {
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
          onLongPress: () => showSaveImageSheet(context, url: cover),
          child: Stack(
            children: <Widget>[
              CachedNetworkImage(
                imageUrl: cover,
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.cover,
                progressIndicatorBuilder: (BuildContext context, String url,
                        DownloadProgress progress) =>
                    SizedBox(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width,
                  child: Center(
                    child: CircularProgressIndicator(
                        color: AppColors.primary, value: progress.progress),
                  ),
                ),
              ),
              const Positioned.fill(child: ConcreteCoverScrim()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescription(
      BuildContext context, AnimeConcreteView concreteView) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ExpandableDescription(
        text: concreteView.description.replaceAll('\\n', '\n\n').trim(),
      ),
    );
  }
}
