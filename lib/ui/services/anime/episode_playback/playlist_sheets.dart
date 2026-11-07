import 'dart:math' as math;

import 'package:capyscript/modules/waka_models/models/anime/anime_concrete_view/anime_video/anime_video.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/anime/episode_playback/episode_playlist.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const double _episodeRowExtent = 52;
const double _sheetHeightFraction = 0.6;

Future<void> showEpisodesSheet(
  BuildContext context, {
  required EpisodePlaylist playlist,
  required Set<String> watchedEpisodeUids,
  required ValueChanged<AnimeVideo> onSelected,
}) {
  final String? groupTitle = playlist.group?.title.trim();
  final String title = playlist.hasSeveralGroups &&
          groupTitle != null &&
          groupTitle.isNotEmpty
      ? '${S.of(context).player_episodes} · $groupTitle'
      : S.of(context).player_episodes;
  return showActionSheet(
    context,
    title: title,
    child: _EpisodesList(
      playlist: playlist,
      watchedEpisodeUids: watchedEpisodeUids,
      onSelected: (AnimeVideo episode) {
        Navigator.of(context).pop();
        onSelected(episode);
      },
    ),
  );
}

Future<void> showGroupsSheet(
  BuildContext context, {
  required EpisodePlaylist playlist,
  required ValueChanged<int> onSelected,
}) {
  return showActionSheet(
    context,
    title: S.of(context).player_dub_player,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < playlist.groups.length; index++)
          ActionSheetRow(
            label: playlist.groups[index].title,
            selected: index == playlist.groupIndex,
            onTap: () {
              Navigator.of(context).pop();
              if (index != playlist.groupIndex) {
                onSelected(index);
              }
            },
          ),
      ],
    ),
  );
}

class _EpisodesList extends StatefulWidget {
  const _EpisodesList({
    required this.playlist,
    required this.watchedEpisodeUids,
    required this.onSelected,
  });

  final EpisodePlaylist playlist;
  final Set<String> watchedEpisodeUids;
  final ValueChanged<AnimeVideo> onSelected;

  @override
  State<_EpisodesList> createState() => _EpisodesListState();
}

class _EpisodesListState extends State<_EpisodesList> {
  ScrollController? _controller;

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  ScrollController _controllerFor(double viewportHeight) {
    final ScrollController? existing = _controller;
    if (existing != null) {
      return existing;
    }
    final ScrollController created = ScrollController(
      initialScrollOffset: _initialOffset(viewportHeight),
    );
    _controller = created;
    return created;
  }

  double _initialOffset(double viewportHeight) {
    final List<AnimeVideo> episodes = widget.playlist.episodes;
    final int currentIndex = episodes.indexWhere(
      (AnimeVideo episode) => episode.uid == widget.playlist.current.uid,
    );
    if (currentIndex < 0) {
      return 0;
    }
    final double centered = currentIndex * _episodeRowExtent -
        (viewportHeight - _episodeRowExtent) / 2;
    final double maxOffset =
        episodes.length * _episodeRowExtent - viewportHeight;
    return centered.clamp(0, math.max(0, maxOffset)).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final List<AnimeVideo> episodes = widget.playlist.episodes;
    final double available =
        MediaQuery.of(context).size.height * _sheetHeightFraction;
    final double height =
        math.min(episodes.length * _episodeRowExtent, available);
    return SizedBox(
      height: height,
      child: ListView.builder(
        controller: _controllerFor(height),
        itemExtent: _episodeRowExtent,
        itemCount: episodes.length,
        itemBuilder: (BuildContext context, int index) {
          return _buildRow(episodes[index]);
        },
      ),
    );
  }

  Widget _buildRow(AnimeVideo episode) {
    final bool current = episode.uid == widget.playlist.current.uid;
    final bool watched = widget.watchedEpisodeUids.contains(episode.uid);
    return InkWell(
      onTap: () => widget.onSelected(episode),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 34,
              child: current
                  ? Icon(
                      Icons.play_arrow_rounded,
                      size: 22,
                      color: AppColors.primary,
                    )
                  : null,
            ),
            Expanded(
              child: Text(
                episode.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: _rowStyle(current: current, watched: watched),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _rowStyle({required bool current, required bool watched}) {
    if (current) {
      return semibold(size: 15, color: AppColors.primary);
    }
    if (watched) {
      return medium(size: 15, color: AppColors.mainGrey);
    }
    return medium(size: 15, color: AppColors.mainWhite);
  }
}
