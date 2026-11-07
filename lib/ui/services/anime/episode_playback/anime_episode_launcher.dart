import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/api_clients/source_error.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/downloads/episode/downloaded_episode_lookup.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_session.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_player_result.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/video_sources_loading_dialog.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/source_error_view.dart';
import 'package:wakaranai/utils/source_error_description.dart';

class AnimeEpisodeLauncher {
  AnimeEpisodeLauncher({
    required this.client,
    required this.anime,
    required List<AnimeVideoGroup> groups,
    required this.groupIndex,
    Set<String> watchedEpisodeUids = const <String>{},
    this.onEpisodeOpened,
    this.downloadedEpisodes,
    this.configInfo,
    SettingsService? settingsService,
  })  : groups = List<AnimeVideoGroup>.unmodifiable(groups),
        _watchedEpisodeUids = <String>{...watchedEpisodeUids},
        _settingsService = settingsService ?? SettingsService();

  static bool _launchInFlight = false;

  final AnimeApiClient? client;
  final DownloadedEpisodeLookup? downloadedEpisodes;
  final ConfigInfo? configInfo;
  final AnimeConcreteView anime;
  final List<AnimeVideoGroup> groups;
  final int groupIndex;
  final void Function(AnimeVideo episode)? onEpisodeOpened;
  final Set<String> _watchedEpisodeUids;
  final SettingsService _settingsService;

  Future<EpisodePlaylist?> play(BuildContext context, AnimeVideo episode) async {
    if (_launchInFlight) {
      logger.d('Ignoring episode tap while another launch is in progress');
      return null;
    }
    _launchInFlight = true;
    try {
      return await _runSession(context, episode);
    } finally {
      _launchInFlight = false;
    }
  }

  Future<EpisodePlaylist> _runSession(
    BuildContext context,
    AnimeVideo episode,
  ) async {
    final VideoPlayerPreference preference =
        await _settingsService.getVideoPlayerPreference();
    late final EpisodePlaybackSession session;
    session = EpisodePlaybackSession(
      isActive: () => context.mounted,
      onEpisodeOpened: _markOpened,
      onSourceError: (EpisodePlaylist position, SourceError error) =>
          _handleSourceError(context, position, error),
      resolvePlan: (EpisodePlaylist position) =>
          _resolveWithDialog(context, position.current, preference),
      openNativePlayer: (EpisodePlaylist position, PlayableVideo video) =>
          _openNativePlayer(
        context,
        position,
        video,
        resolveInPlayer: (EpisodePlaylist target) {
          session.enterEpisode(target);
          return resolve(target.current, preference);
        },
      ),
      openWebPlayer: (
        EpisodePlaylist position, {
        required bool showFallbackNotice,
        SourceError? sourceError,
      }) =>
          _openWebPlayer(
        context,
        position,
        showFallbackNotice: showFallbackNotice,
        sourceError: sourceError,
      ),
    );
    return session.run(
      EpisodePlaylist(groups: groups, groupIndex: groupIndex, current: episode),
    );
  }

  String get _sourceName => configInfo?.name ?? '';

  SourceSignIn? get _sourceSignIn {
    final AnimeApiClient? apiClient = client;
    final ConfigInfo? info = configInfo;
    if (apiClient == null || info == null || info.protectorConfig == null) {
      return null;
    }
    return (BuildContext context, VoidCallback onSignedIn) => signInToSource(
          context,
          apiClient: apiClient,
          configInfo: info,
          onSignedIn: onSignedIn,
        );
  }

  SourceErrorDescription? _describe(SourceError? error) {
    return describeSourceError(
      error,
      sourceName: _sourceName,
      canSignIn: _sourceSignIn != null,
    );
  }

  Future<bool> _handleSourceError(
    BuildContext context,
    EpisodePlaylist position,
    SourceError error,
  ) async {
    final SourceErrorDescription? description = _describe(error);
    if (description == null || !context.mounted) {
      return false;
    }
    final SourceSignIn? signIn = _sourceSignIn;
    if (description.offersSignIn && signIn != null) {
      return _signInThenRetry(context, position, description, signIn);
    }
    if (description.offersRetry) {
      return _confirmSourceAction(
        context,
        position,
        description,
        S.of(context).source_error_retry_button,
      );
    }
    showSourceErrorSnackBar(context, description: description);
    return false;
  }

  Future<bool> _signInThenRetry(
    BuildContext context,
    EpisodePlaylist position,
    SourceErrorDescription description,
    SourceSignIn signIn,
  ) async {
    final bool wantsSignIn = await _confirmSourceAction(
      context,
      position,
      description,
      S.of(context).source_error_sign_in_button,
    );
    if (!wantsSignIn || !context.mounted) {
      return false;
    }
    bool signedIn = false;
    await signIn(context, () => signedIn = true);
    return signedIn;
  }

  Future<bool> _confirmSourceAction(
    BuildContext context,
    EpisodePlaylist position,
    SourceErrorDescription description,
    String actionLabel,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        title: description.title,
        message: description.detail ?? position.current.title,
        yesText: actionLabel,
        noText: S.of(dialogContext).common_cancel,
        icon: description.icon,
      ),
    );
    return confirmed == true;
  }

  void _markOpened(AnimeVideo episode) {
    _watchedEpisodeUids.add(episode.uid);
    onEpisodeOpened?.call(episode);
  }

  Future<EpisodePlaybackPlan> resolve(
    AnimeVideo episode,
    VideoPlayerPreference preference, {
    void Function()? onFetchingSources,
  }) {
    return resolveEpisodePlayback(
      episode: episode,
      provider: _videoSourceProvider(),
      preference: preference,
      downloadedEpisodes: downloadedEpisodes,
      onFetchingSources: onFetchingSources,
    );
  }

  VideoSourceProvider? _videoSourceProvider() {
    final AnimeApiClient? apiClient = client;
    if (apiClient == null) {
      return null;
    }
    return AnimeApiClientVideoSourceProvider(apiClient);
  }

  Future<EpisodePlaybackPlan?> _resolveWithDialog(
    BuildContext context,
    AnimeVideo episode,
    VideoPlayerPreference preference,
  ) async {
    VideoSourcesLoadingHandle? loadingHandle;
    final EpisodePlaybackPlan plan = await resolve(
      episode,
      preference,
      onFetchingSources: () {
        if (context.mounted) {
          loadingHandle = showVideoSourcesLoading(context);
        }
      },
    );
    final VideoSourcesLoadingHandle? shownHandle = loadingHandle;
    if (shownHandle == null) {
      return plan;
    }
    if (shownHandle.cancelledByUser) {
      logger.i('Video source lookup for ${episode.uid} was cancelled');
      return null;
    }
    shownHandle.close();
    return plan;
  }

  Future<EpisodePlayerResult?> _openNativePlayer(
    BuildContext context,
    EpisodePlaylist position,
    PlayableVideo video, {
    required EpisodeResolver resolveInPlayer,
  }) {
    return openNativePlayer(
      context,
      NativePlayerData(
        video: video,
        anime: anime,
        playlist: position,
        resolveEpisode: resolveInPlayer,
        watchedEpisodeUids: Set<String>.unmodifiable(_watchedEpisodeUids),
        canStream: client != null,
        sourceName: _sourceName,
        signIn: _sourceSignIn,
      ),
    );
  }

  Future<EpisodePlayerResult?> _openWebPlayer(
    BuildContext context,
    EpisodePlaylist position, {
    required bool showFallbackNotice,
    SourceError? sourceError,
  }) async {
    final Object? result = await Navigator.of(context).pushNamed(
      Routes.iframeAnimePlayer,
      arguments: AnimeIframePlayerData(
        anime: anime,
        video: position.current,
        notice: _webPlayerNotice(
          context,
          showFallbackNotice: showFallbackNotice,
          sourceError: sourceError,
        ),
        playlist: position,
        watchedEpisodeUids: Set<String>.unmodifiable(_watchedEpisodeUids),
      ),
    );
    if (result is EpisodePlayerResult) {
      return result;
    }
    return null;
  }

  String? _webPlayerNotice(
    BuildContext context, {
    required bool showFallbackNotice,
    SourceError? sourceError,
  }) {
    final SourceErrorDescription? description = _describe(sourceError);
    if (description != null) {
      return description.summary;
    }
    if (showFallbackNotice) {
      return S.of(context).episode_playback_fallback_notice;
    }
    return null;
  }
}
