import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video_group/anime_video_group.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
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

class AnimeEpisodeLauncher {
  AnimeEpisodeLauncher({
    required this.client,
    required this.anime,
    required List<AnimeVideoGroup> groups,
    required this.groupIndex,
    Set<String> watchedEpisodeUids = const <String>{},
    this.onEpisodeOpened,
    SettingsService? settingsService,
  })  : groups = List<AnimeVideoGroup>.unmodifiable(groups),
        _watchedEpisodeUids = <String>{...watchedEpisodeUids},
        _settingsService = settingsService ?? SettingsService();

  static bool _launchInFlight = false;

  final AnimeApiClient client;
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
      resolvePlan: (EpisodePlaylist position) =>
          _resolveWithDialog(context, position.current, preference),
      openNativePlayer: (EpisodePlaylist position, PlayableVideo video) =>
          _openNativePlayer(
        context,
        position,
        video,
        resolveInPlayer: (EpisodePlaylist target) {
          session.enterEpisode(target);
          return _resolve(target.current, preference);
        },
      ),
      openWebPlayer: (
        EpisodePlaylist position, {
        required bool showFallbackNotice,
      }) =>
          _openWebPlayer(
        context,
        position,
        showFallbackNotice: showFallbackNotice,
      ),
    );
    return session.run(
      EpisodePlaylist(groups: groups, groupIndex: groupIndex, current: episode),
    );
  }

  void _markOpened(AnimeVideo episode) {
    _watchedEpisodeUids.add(episode.uid);
    onEpisodeOpened?.call(episode);
  }

  Future<EpisodePlaybackPlan> _resolve(
    AnimeVideo episode,
    VideoPlayerPreference preference, {
    void Function()? onFetchingSources,
  }) {
    return resolveEpisodePlayback(
      episode: episode,
      provider: AnimeApiClientVideoSourceProvider(client),
      preference: preference,
      onFetchingSources: onFetchingSources,
    );
  }

  Future<EpisodePlaybackPlan?> _resolveWithDialog(
    BuildContext context,
    AnimeVideo episode,
    VideoPlayerPreference preference,
  ) async {
    VideoSourcesLoadingHandle? loadingHandle;
    final EpisodePlaybackPlan plan = await _resolve(
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
      ),
    );
  }

  Future<EpisodePlayerResult?> _openWebPlayer(
    BuildContext context,
    EpisodePlaylist position, {
    required bool showFallbackNotice,
  }) async {
    final Object? result = await Navigator.of(context).pushNamed(
      Routes.iframeAnimePlayer,
      arguments: AnimeIframePlayerData(
        anime: anime,
        video: position.current,
        notice: showFallbackNotice
            ? S.of(context).episode_playback_fallback_notice
            : null,
        playlist: position,
        watchedEpisodeUids: Set<String>.unmodifiable(_watchedEpisodeUids),
      ),
    );
    if (result is EpisodePlayerResult) {
      return result;
    }
    return null;
  }
}
