import 'package:capyscript/api_clients/anime_api_client.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/settings_service/settings_service.dart';
import 'package:wakaranai/services/settings_service/video_player_preference.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/anime/anime_iframe_player/anime_iframe_player.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playback_resolver.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/video_sources_loading_dialog.dart';
import 'package:wakaranai/ui/services/anime/native_player/native_player.dart';

AnimeVideo? nextEpisodeAfter(List<AnimeVideo> episodes, String uid) {
  final int index = episodes.indexWhere((AnimeVideo video) => video.uid == uid);
  if (index < 0 || index + 1 >= episodes.length) {
    return null;
  }
  return episodes[index + 1];
}

class AnimeEpisodeLauncher {
  AnimeEpisodeLauncher({
    required this.client,
    required this.anime,
    required List<AnimeVideo> episodes,
    this.onEpisodeOpened,
    SettingsService? settingsService,
  })  : episodes = List<AnimeVideo>.unmodifiable(episodes),
        _settingsService = settingsService ?? SettingsService();

  static bool _launchInFlight = false;

  final AnimeApiClient client;
  final AnimeConcreteView anime;
  final List<AnimeVideo> episodes;
  final void Function(AnimeVideo episode)? onEpisodeOpened;
  final SettingsService _settingsService;

  Future<void> play(BuildContext context, AnimeVideo episode) async {
    if (_launchInFlight) {
      logger.d('Ignoring episode tap while another launch is in progress');
      return;
    }
    _launchInFlight = true;
    try {
      await _playFrom(context, episode);
    } finally {
      _launchInFlight = false;
    }
  }

  Future<void> _playFrom(BuildContext context, AnimeVideo firstEpisode) async {
    final VideoPlayerPreference preference =
        await _settingsService.getVideoPlayerPreference();
    AnimeVideo? episode = firstEpisode;
    while (episode != null && context.mounted) {
      onEpisodeOpened?.call(episode);
      episode = await _playEpisode(context, episode, preference);
    }
  }

  Future<AnimeVideo?> _playEpisode(
    BuildContext context,
    AnimeVideo episode,
    VideoPlayerPreference preference,
  ) async {
    final EpisodePlaybackPlan? plan =
        await _resolvePlan(context, episode, preference);
    if (plan == null || !context.mounted) {
      return null;
    }
    switch (plan) {
      case WebPlaybackPlan():
        await _openWebPlayer(
          context,
          episode,
          notice: plan.shouldNotifyUser
              ? S.of(context).episode_playback_fallback_notice
              : null,
        );
        return null;
      case NativePlaybackPlan():
        return _openNativePlayer(context, episode, plan);
    }
  }

  Future<AnimeVideo?> _openNativePlayer(
    BuildContext context,
    AnimeVideo episode,
    NativePlaybackPlan plan,
  ) async {
    final AnimeVideo? nextEpisode = nextEpisodeAfter(episodes, episode.uid);
    final NativePlayerResult? result = await openNativePlayer(
      context,
      NativePlayerData(
        video: plan.video,
        episode: episode,
        anime: anime,
        hasNextEpisode: nextEpisode != null,
      ),
    );
    if (!context.mounted) {
      return null;
    }
    if (result == NativePlayerResult.openInWebPlayer) {
      await _openWebPlayer(context, episode);
      return null;
    }
    if (result == NativePlayerResult.nextEpisode) {
      return nextEpisode;
    }
    return null;
  }

  Future<EpisodePlaybackPlan?> _resolvePlan(
    BuildContext context,
    AnimeVideo episode,
    VideoPlayerPreference preference,
  ) async {
    VideoSourcesLoadingHandle? loadingHandle;
    final EpisodePlaybackPlan plan = await resolveEpisodePlayback(
      episode: episode,
      provider: AnimeApiClientVideoSourceProvider(client),
      preference: preference,
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

  Future<void> _openWebPlayer(
    BuildContext context,
    AnimeVideo episode, {
    String? notice,
  }) {
    return Navigator.of(context).pushNamed(
      Routes.iframeAnimePlayer,
      arguments: AnimeIframePlayerData(
        anime: anime,
        video: episode,
        notice: notice,
      ),
    );
  }
}
