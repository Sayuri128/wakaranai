import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_gallery_view/anime_gallery_view.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/data/domain/database/concrete_data_domain.dart';
import 'package:wakaranai/data/domain/database/download_domain.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/database/download_repository.dart';
import 'package:wakaranai/services/downloads/episode/downloaded_episode_lookup.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/anime_episode_launcher.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/debug_stream_url_dialog.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/anime_episode_activity_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/services/concrete_viewer_page.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_button.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/widgets/chapter_download_button.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/selection_action_bar.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AnimeConcreteViewerData {
  final String uid;
  final Map<String, dynamic> galleryData;

  // used for hero animation
  final String? galleryCover;
  final AnimeApiClient client;
  final ConfigInfo configInfo;
  final bool fromLibrary;
  final AutoContinueRequest? autoContinue;

  const AnimeConcreteViewerData(
      {required this.uid,
      required this.galleryData,
      required this.galleryCover,
      required this.client,
      required this.configInfo,
      this.fromLibrary = false,
      this.autoContinue});

  AnimeConcreteViewerData copyWith({
    AnimeApiClient? client,
    ConfigInfo? configInfo,
  }) {
    return AnimeConcreteViewerData(
      uid: uid,
      galleryData: galleryData,
      galleryCover: galleryCover,
      client: client ?? this.client,
      configInfo: configInfo ?? this.configInfo,
      fromLibrary: fromLibrary,
      autoContinue: autoContinue,
    );
  }
}

class AnimeConcreteViewer extends ConcreteViewerPage<AnimeApiClient,
    AnimeConcreteView, AnimeGalleryView> {
  AnimeConcreteViewer({super.key, required this.data});

  final AnimeConcreteViewerData data;

  @override
  AnimeApiClient get client => data.client;

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
  Map<String, String> get coverHeaders => const <String, String>{};

  @override
  bool get showsAlternativeTitles => false;

  @override
  AutoContinueRequest? get autoContinue => data.autoContinue;

  @override
  ConcreteContinueAction? continueAction(
    BuildContext context,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView,
            AnimeGalleryView>
        state,
  ) {
    final ContinueTarget<AnimeVideo>? target = resolveEpisodeContinue(
      groups: state.concreteView.groups,
      preferredGroup: state.groupIndex,
      activities: state.animeEpisodeActivities,
    );
    if (target == null) {
      return null;
    }
    return ConcreteContinueAction(
      kind: target.kind,
      title: target.element.title,
      onTap: () {
        if (target.groupIndex != state.groupIndex) {
          getConcreteViewCubit(context).changeGroup(target.groupIndex);
        }
        unawaited(_playEpisode(
          context,
          state,
          target.element,
          groupIndex: target.groupIndex,
        ));
      },
    );
  }

  @override
  String get elementsSectionTitle =>
      S.current.concrete_viewer_episodes_section_title;

  @override
  Widget buildCoverImage(BuildContext context, String cover) {
    return CachedNetworkImage(
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
    );
  }

  @override
  Widget buildElementTile(
    BuildContext context,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView,
            AnimeGalleryView>
        state,
    int index,
  ) {
    final AnimeVideo animeVideo =
        state.concreteView.groups[state.groupIndex].elements[index];
    return _buildEpisode(
      context: context,
      animeVideo: animeVideo,
      concreteView: state.concreteView,
      activity: state.animeEpisodeActivities[animeVideo.uid],
      state: state,
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
    return BlocSelector<LibraryUpdatesCubit, LibraryUpdatesState, bool>(
      selector: (LibraryUpdatesState updates) => updates.isUnseen(animeVideo.uid),
      builder: (BuildContext tileContext, bool isNew) => ConcreteListTile(
      title: animeVideo.title,
      isNew: isNew,
      selected: state.selection.contains(animeVideo.uid),
      dim: activity != null,
      trailing: _buildDownloadButton(context, animeVideo, state),
      subtitle: _buildEpisodeSubtitle(animeVideo, activity),
      onLongPress: () {
        getConcreteViewCubit(context).changeSelection(animeVideo.uid);
      },
      onTap: () {
        if (state.selection.isEmpty) {
          unawaited(_playEpisode(context, state, animeVideo));
        } else {
          getConcreteViewCubit(context).changeSelection(animeVideo.uid);
        }
      },
    ),
    );
  }

  Widget? _buildDownloadButton(
    BuildContext context,
    AnimeVideo episode,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        state,
  ) {
    final ConcreteDataDomain? domain = state.domain;
    if (domain == null) {
      return null;
    }
    return BlocBuilder<DownloadManagerCubit, DownloadManagerState>(
      builder: (BuildContext context, DownloadManagerState downloads) {
        final DownloadDomain? download = downloads.forChapter(episode.uid);
        return ChapterDownloadButton(
          download: download,
          onDownload: () => _enqueueEpisode(context, episode, state, domain),
          onRetry: () {
            if (download != null) {
              unawaited(
                context.read<DownloadManagerCubit>().retryDownload(download),
              );
            }
          },
          onDelete: () {
            if (download != null) {
              deleteDownloadWithConfirmation(context, download);
            }
          },
          onResume: () => unawaited(
            context.read<DownloadManagerCubit>().resumeDownload(episode.uid),
          ),
        );
      },
    );
  }

  void _enqueueEpisode(
    BuildContext context,
    AnimeVideo episode,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        state,
    ConcreteDataDomain domain,
  ) {
    unawaited(context.read<DownloadManagerCubit>().enqueueEpisode(
          extensionUid: data.configInfo.uid,
          concreteUid: state.concreteView.uid,
          concreteId: domain.id,
          concreteTitle: state.concreteView.title,
          concreteCover: state.concreteView.cover,
          episode: episode,
        ));
  }

  Future<void> _playEpisode(
    BuildContext context,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        state,
    AnimeVideo episode, {
    int? groupIndex,
  }) async {
    final ConcreteViewCubit<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        cubit = getConcreteViewCubit(context);
    final LibraryUpdatesCubit libraryUpdatesCubit =
        context.read<LibraryUpdatesCubit>();
    final AnimeEpisodeLauncher launcher = AnimeEpisodeLauncher(
      client: state.apiClient,
      configInfo: state.configInfo,
      anime: state.concreteView,
      groups: state.concreteView.groups,
      groupIndex: groupIndex ?? state.groupIndex,
      watchedEpisodeUids: state.animeEpisodeActivities.keys.toSet(),
      downloadedEpisodes: RepositoryDownloadedEpisodeLookup(
        context.read<DownloadRepository>(),
      ),
      onEpisodeOpened: (AnimeVideo openedEpisode) {
        unawaited(libraryUpdatesCubit.markSeenIfNew(openedEpisode.uid));
      },
    );
    final EpisodePlaylist? lastPosition = await launcher.play(context, episode);
    if (cubit.isClosed) {
      return;
    }
    cubit.updateActivities();
    _followPlayerGroup(cubit, state.concreteView, lastPosition);
  }

  void _followPlayerGroup(
    ConcreteViewCubit<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        cubit,
    AnimeConcreteView playedView,
    EpisodePlaylist? lastPosition,
  ) {
    final ConcreteViewState<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        current = cubit.state;
    if (lastPosition == null ||
        current is! ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView,
            AnimeGalleryView>) {
      return;
    }
    final bool sameView = identical(current.concreteView, playedView);
    final bool groupChanged = lastPosition.groupIndex != current.groupIndex;
    if (sameView && groupChanged) {
      cubit.changeGroup(lastPosition.groupIndex);
    }
  }

  @override
  List<SelectionAction> extraSelectionActions(
    BuildContext context,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        state,
  ) {
    if (!kDebugMode || state.selection.length != 1) {
      return const <SelectionAction>[];
    }
    return <SelectionAction>[
      SelectionAction(
        icon: Icons.play_circle_outline_rounded,
        label: S.of(context).native_player_debug_action,
        onTap: () => unawaited(_playSelectedInNativePlayer(context, state)),
      ),
    ];
  }

  Future<void> _playSelectedInNativePlayer(
    BuildContext context,
    ConcreteViewInitialized<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        state,
  ) async {
    final String selectedUid = state.selection.first;
    final AnimeVideo? episode = state
        .concreteView.groups[state.groupIndex].elements
        .firstWhereOrNull((AnimeVideo video) => video.uid == selectedUid);
    if (episode == null) {
      return;
    }
    final ConcreteViewCubit<AnimeApiClient, AnimeConcreteView, AnimeGalleryView>
        cubit = getConcreteViewCubit(context);
    final String? streamUrl = await showDebugStreamUrlDialog(context);
    if (streamUrl == null || !context.mounted) {
      return;
    }
    cubit.clearSelection();
    final EpisodePlayerResult? result = await openNativePlayer(
      context,
      NativePlayerData(
        video: PlayableVideo(
          streams: <PlayableStream>[PlayableStream(url: streamUrl)],
        ),
        anime: state.concreteView,
        playlist: EpisodePlaylist(
          groups: state.concreteView.groups,
          groupIndex: state.groupIndex,
          current: episode,
        ),
      ),
    );
    if (result is OpenInWebPlayer && context.mounted) {
      await Navigator.of(context).pushNamed(
        Routes.iframeAnimePlayer,
        arguments: AnimeIframePlayerData(
          anime: state.concreteView,
          video: episode,
        ),
      );
    }
    cubit.updateActivities();
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
}
