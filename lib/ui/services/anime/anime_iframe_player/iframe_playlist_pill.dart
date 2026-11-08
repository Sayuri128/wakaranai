import 'dart:async';

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/playlist_sheets.dart';
import 'package:wakaranai/utils/app_colors.dart';

const Duration _pillAutoHideDelay = Duration(seconds: 4);
const Duration _pillAnimationDuration = Duration(milliseconds: 200);

class IframePlaylistPill extends StatefulWidget {
  const IframePlaylistPill({
    super.key,
    required this.playlist,
    required this.watchedEpisodeUids,
    required this.onPlay,
  });

  final EpisodePlaylist playlist;
  final Set<String> watchedEpisodeUids;
  final ValueChanged<EpisodePlaylist> onPlay;

  @override
  State<IframePlaylistPill> createState() => _IframePlaylistPillState();
}

class _IframePlaylistPillState extends State<IframePlaylistPill> {
  bool _expanded = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _scheduleCollapse();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    super.dispose();
  }

  void _scheduleCollapse() {
    _hideTimer?.cancel();
    _hideTimer = Timer(_pillAutoHideDelay, () {
      if (mounted) {
        setState(() {
          _expanded = false;
        });
      }
    });
  }

  void _expand() {
    setState(() {
      _expanded = true;
    });
    _scheduleCollapse();
  }

  void _playEpisode(AnimeVideo? episode) {
    if (episode == null) {
      return;
    }
    widget.onPlay(widget.playlist.moveTo(episode));
  }

  Future<void> _openEpisodes() async {
    _hideTimer?.cancel();
    await showEpisodesSheet(
      context,
      playlist: widget.playlist,
      watchedEpisodeUids: widget.watchedEpisodeUids,
      onSelected: (AnimeVideo episode) {
        if (episode.uid != widget.playlist.current.uid) {
          _playEpisode(episode);
        }
      },
    );
    if (mounted) {
      _scheduleCollapse();
    }
  }

  Future<void> _openGroups() async {
    _hideTimer?.cancel();
    await showGroupsSheet(
      context,
      playlist: widget.playlist,
      onSelected: (int groupIndex) {
        final EpisodePlaylist? target =
            widget.playlist.switchGroup(groupIndex);
        if (target != null) {
          widget.onPlay(target);
        }
      },
    );
    if (mounted) {
      _scheduleCollapse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withValues(alpha: _expanded ? 0.6 : 0.35),
      shape: const StadiumBorder(),
      clipBehavior: Clip.antiAlias,
      child: AnimatedSize(
        duration: _pillAnimationDuration,
        alignment: Alignment.centerRight,
        child: _expanded ? _buildExpanded(context) : _buildCollapsed(context),
      ),
    );
  }

  Widget _buildCollapsed(BuildContext context) {
    return _buildButton(
      icon: Icons.playlist_play_rounded,
      tooltip: S.of(context).player_playlist,
      onPressed: _expand,
    );
  }

  Widget _buildExpanded(BuildContext context) {
    final S strings = S.of(context);
    final AnimeVideo? previous = widget.playlist.previous;
    final AnimeVideo? next = widget.playlist.next;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildButton(
          icon: Icons.skip_previous_rounded,
          tooltip: strings.player_previous_episode,
          onPressed: previous == null ? null : () => _playEpisode(previous),
        ),
        _buildButton(
          icon: Icons.format_list_numbered_rounded,
          tooltip: strings.player_episodes,
          onPressed: () => unawaited(_openEpisodes()),
        ),
        _buildButton(
          icon: Icons.skip_next_rounded,
          tooltip: strings.native_player_next_episode,
          onPressed: next == null ? null : () => _playEpisode(next),
        ),
        if (widget.playlist.hasSeveralGroups)
          _buildButton(
            icon: Icons.record_voice_over_rounded,
            tooltip: strings.player_dub_player,
            onPressed: () => unawaited(_openGroups()),
          ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 22,
      visualDensity: VisualDensity.compact,
      color: AppColors.onMedia,
      disabledColor: AppColors.onMedia.withValues(alpha: 0.3),
      icon: Icon(icon),
    );
  }
}
