import 'dart:async';

import 'package:capyscript/modules/waka_models/models/audio/audio_marker.dart';
import 'package:capyscript/modules/waka_models/models/audio/audio_track_source.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/audiobook_player/audiobook_player_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/chapter_activity_repository.dart';
import 'package:wakaranai/services/audiobooks/audio_progress.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const List<double> audioSpeedOptions = <double>[
  0.75,
  1.0,
  1.1,
  1.25,
  1.5,
  1.75,
  2.0,
  2.5,
  3.0,
];

const List<int> audioSleepMinuteOptions = <int>[5, 10, 15, 30, 45, 60, 90];

String formatAudioSpeed(double speed) {
  String text = speed.toStringAsFixed(2);
  while (text.endsWith('0')) {
    text = text.substring(0, text.length - 1);
  }
  if (text.endsWith('.')) {
    text = text.substring(0, text.length - 1);
  }
  return '$text×';
}

Future<void> showAudioSpeedSheet(BuildContext context) {
  final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
  final double current = player.state.speed;
  return showActionSheet(
    context,
    title: S.of(context).audio_player_speed,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final double speed in audioSpeedOptions)
            ActionSheetRow(
              label: formatAudioSpeed(speed),
              selected: speed == current,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(player.setSpeed(speed));
              },
            ),
        ],
      ),
    ),
  );
}

Future<void> showAudioSleepTimerSheet(BuildContext context) {
  final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
  final AudiobookSleepTimer timer = player.state.sleepTimer;
  return showActionSheet(
    context,
    title: S.of(context).audio_sleep_timer,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (timer.isActive)
            ActionSheetRow(
              icon: Icons.timer_off_outlined,
              label: S.of(context).audio_sleep_off,
              onTap: () {
                Navigator.of(sheetContext).pop();
                player.cancelSleepTimer();
              },
            ),
          for (final int minutes in audioSleepMinuteOptions)
            ActionSheetRow(
              icon: Icons.timer_outlined,
              label: S.of(context).audio_sleep_minutes(minutes),
              onTap: () {
                Navigator.of(sheetContext).pop();
                player.setSleepTimer(Duration(minutes: minutes));
              },
            ),
          ActionSheetRow(
            icon: Icons.last_page_rounded,
            label: S.of(context).audio_sleep_end_of_track,
            selected: timer.mode == AudiobookSleepMode.endOfTrack,
            onTap: () {
              Navigator.of(sheetContext).pop();
              player.sleepAtEndOfTrack();
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showAudioTracksSheet(BuildContext context) {
  final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
  final AudiobookSession? session = player.state.session;
  if (session == null) {
    return Future<void>.value();
  }
  final Future<List<ChapterActivityDomain>?> activities = context
      .read<ChapterActivityRepository>()
      .getAllActivitiesByConcreteId(session.concreteUid);
  return showActionSheet(
    context,
    title: S.of(context).audio_player_tracks,
    child: FutureBuilder<List<ChapterActivityDomain>?>(
      future: activities,
      builder: (
        BuildContext sheetContext,
        AsyncSnapshot<List<ChapterActivityDomain>?> snapshot,
      ) {
        final Map<String, ChapterActivityDomain> byUid =
            <String, ChapterActivityDomain>{
          for (final ChapterActivityDomain activity
              in snapshot.data ?? const <ChapterActivityDomain>[])
            activity.uid: activity,
        };
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (int index = 0; index < session.tracks.length; index++)
              _AudioTrackRow(
                index: index,
                track: session.tracks[index],
                activity: byUid[session.tracks[index].uid],
                current: index == player.state.trackIndex,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(player.jumpToTrack(index));
                },
              ),
          ],
        );
      },
    ),
  );
}

class _AudioTrackRow extends StatelessWidget {
  const _AudioTrackRow({
    required this.index,
    required this.track,
    required this.activity,
    required this.current,
    required this.onTap,
  });

  final int index;
  final Chapter track;
  final ChapterActivityDomain? activity;
  final bool current;
  final VoidCallback onTap;

  String? _subtitle(BuildContext context) {
    final ChapterActivityDomain? stored = activity;
    if (stored == null || stored.totalPages <= 0) {
      return null;
    }
    if (AudioProgress.isFinished(stored)) {
      return S.of(context).audio_track_finished;
    }
    return AudioProgress.progressLabel(stored);
  }

  @override
  Widget build(BuildContext context) {
    final String? subtitle = _subtitle(context);
    final Color titleColor = current ? AppColors.primary : AppColors.mainWhite;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 32,
              child: Text(
                '${index + 1}',
                style: medium(size: 13, color: AppColors.mainGrey),
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    track.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: medium(size: 15, color: titleColor),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: regular(size: 12, color: AppColors.mainGrey),
                    ),
                ],
              ),
            ),
            if (current)
              Icon(Icons.graphic_eq_rounded, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

Future<void> showAudioPlayerMoreSheet(BuildContext context) {
  final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
  final AudiobookPlayerState state = player.state;
  return showActionSheet(
    context,
    title: state.track?.title ?? S.of(context).audio_player_more,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          if (state.markers.isNotEmpty)
            ActionSheetRow(
              icon: Icons.bookmarks_outlined,
              label: S.of(context).audio_player_chapters,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(showAudioMarkersSheet(context));
              },
            ),
          if (state.sources.length > 1)
            ActionSheetRow(
              icon: Icons.high_quality_outlined,
              label: S.of(context).audio_player_source,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(showAudioSourcesSheet(context));
              },
            ),
          ActionSheetRow(
            icon: Icons.stop_circle_outlined,
            label: S.of(context).audio_player_stop,
            destructive: true,
            onTap: () {
              Navigator.of(sheetContext).pop();
              unawaited(player.stop());
              Navigator.of(context).maybePop();
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showAudioMarkersSheet(BuildContext context) {
  final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
  final List<AudioMarker> markers = player.state.markers;
  final AudioMarker? current = player.state.currentMarker;
  return showActionSheet(
    context,
    title: S.of(context).audio_player_chapters,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int index = 0; index < markers.length; index++)
            ActionSheetRow(
              label: _markerLabel(context, markers[index], index),
              selected: markers[index] == current,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(player.jumpToMarker(markers[index]));
              },
            ),
        ],
      ),
    ),
  );
}

String _markerLabel(BuildContext context, AudioMarker marker, int index) {
  final String start = AudioProgress.formatClock(
    Duration(milliseconds: (marker.start * 1000).round()),
  );
  final String title = marker.title.isEmpty
      ? S.of(context).audio_player_chapter_number(index + 1)
      : marker.title;
  return '$start  $title';
}

Future<void> showAudioSourcesSheet(BuildContext context) {
  final AudiobookPlayerCubit player = context.read<AudiobookPlayerCubit>();
  final List<AudioTrackSource> sources = player.state.sources;
  final int selected = player.state.sourceIndex;
  return showActionSheet(
    context,
    title: S.of(context).audio_player_source,
    child: Builder(
      builder: (BuildContext sheetContext) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int index = 0; index < sources.length; index++)
            ActionSheetRow(
              label: _sourceLabel(context, sources[index], index),
              selected: index == selected,
              onTap: () {
                Navigator.of(sheetContext).pop();
                unawaited(player.selectSource(index));
              },
            ),
        ],
      ),
    ),
  );
}

String _sourceLabel(BuildContext context, AudioTrackSource source, int index) {
  final List<String> parts = <String>[
    if (source.quality != null) source.quality!,
    if (source.format != null) source.format!.toUpperCase(),
  ];
  if (parts.isEmpty) {
    return S.of(context).audio_player_source_number(index + 1);
  }
  return parts.join(' · ');
}
