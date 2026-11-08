import 'dart:async';

import 'package:capyscript/api_clients/audio_api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapter/chapter.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/chapters_group/chapters_group.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_concrete_view/manga_concrete_view.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/manga_gallery_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/audiobook_player/audiobook_player_cubit.dart';
import 'package:wakaranai/blocs/library_updates/library_updates_cubit.dart';
import 'package:wakaranai/data/domain/database/chapter_activity_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/audiobooks/audio_progress.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/ui/common/service_viewer/service_gallery_kind.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/services/audio/audio_service_viewer.dart';
import 'package:wakaranai/ui/services/audio/player/audio_player_page.dart';
import 'package:wakaranai/ui/services/concrete_viewer_page.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_button.dart';
import 'package:wakaranai/ui/services/continue_reading/continue_target.dart';
import 'package:wakaranai/ui/services/cubits/concrete_view/concrete_view_cubit.dart';
import 'package:wakaranai/ui/services/widgets/concrete_viewer_widgets.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

typedef AudioConcreteState = ConcreteViewInitialized<AudioApiClient,
    MangaConcreteView, MangaGalleryView>;

class AudioConcreteViewerData {
  final String uid;
  final Map<String, String> coverHeaders;
  final String? galleryCover;
  final Map<String, dynamic> galleryData;
  final AudioApiClient client;
  final ConfigInfo configInfo;
  final bool fromLibrary;
  final AutoContinueRequest? autoContinue;

  const AudioConcreteViewerData({
    required this.uid,
    required this.coverHeaders,
    required this.galleryCover,
    required this.galleryData,
    required this.client,
    required this.configInfo,
    this.fromLibrary = false,
    this.autoContinue,
  });

  AudioConcreteViewerData copyWith({
    AudioApiClient? client,
    ConfigInfo? configInfo,
  }) {
    return AudioConcreteViewerData(
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

class AudioConcreteViewer extends ConcreteViewerPage<AudioApiClient,
    MangaConcreteView, MangaGalleryView> {
  static const String trackDateFormat = 'yyyy-MM-dd';

  AudioConcreteViewer({super.key, required this.data});

  final AudioConcreteViewerData data;

  @override
  AudioApiClient get client => data.client;

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
  String get elementsSectionTitle => S.current.audio_tracks_section_title;

  @override
  ServiceGalleryKind<AudioApiClient, MangaGalleryView> get galleryKind =>
      const AudioGalleryKind();

  @override
  AutoContinueRequest? get autoContinue => data.autoContinue;

  @override
  TrackerMediaType get trackerMediaType => TrackerMediaType.manga;

  @override
  int? trackerLocalProgress(AudioConcreteState state) {
    return null;
  }

  @override
  ConcreteContinueAction? continueAction(
    BuildContext context,
    AudioConcreteState state,
  ) {
    final AudiobookPlayerState player =
        context.read<AudiobookPlayerCubit>().state;
    final ConcreteContinueAction? nowPlaying =
        _nowPlayingAction(context, state, player);
    if (nowPlaying != null) {
      return nowPlaying;
    }
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

  ConcreteContinueAction? _nowPlayingAction(
    BuildContext context,
    AudioConcreteState state,
    AudiobookPlayerState player,
  ) {
    final AudiobookSession? session = player.session;
    final Chapter? track = player.track;
    if (session == null || track == null) {
      return null;
    }
    if (session.concreteUid != state.concreteView.uid) {
      return null;
    }
    return ConcreteContinueAction(
      kind: ContinueKind.resume,
      title: track.title,
      onTap: () => _openPlayer(context, const AudioPlayerData()),
    );
  }

  void _openContinueTarget(
    BuildContext context,
    AudioConcreteState state,
    ContinueTarget<Chapter> target,
  ) {
    if (target.groupIndex != state.groupIndex) {
      getConcreteViewCubit(context).changeGroup(target.groupIndex);
    }
    _openTrack(
      context,
      state,
      track: target.element,
      group: state.concreteView.groups[target.groupIndex],
    );
  }

  void _openTrack(
    BuildContext context,
    AudioConcreteState state, {
    required Chapter track,
    required ChaptersGroup group,
  }) {
    final List<Chapter> tracks = _listeningOrder(state, group);
    final int index =
        tracks.indexWhere((Chapter candidate) => candidate.uid == track.uid);
    if (index < 0) {
      return;
    }
    _openPlayer(
      context,
      AudioPlayerData(
        session: AudiobookSession(
          client: data.client,
          configInfo: data.configInfo,
          concreteUid: state.concreteView.uid,
          title: state.concreteView.title,
          tracks: tracks,
          cover: _coverOf(state),
          coverHeaders: data.coverHeaders,
        ),
        trackIndex: index,
      ),
    );
  }

  String? _coverOf(AudioConcreteState state) {
    final String cover = state.concreteView.cover;
    if (cover.isNotEmpty) {
      return cover;
    }
    return data.galleryCover;
  }

  void _openPlayer(BuildContext context, AudioPlayerData arguments) {
    unawaited(Navigator.of(context)
        .pushNamed(Routes.audioPlayer, arguments: arguments)
        .then((_) {
      if (context.mounted) {
        getConcreteViewCubit(context).updateActivities();
      }
    }));
  }

  List<Chapter> _listeningOrder(AudioConcreteState state, ChaptersGroup group) {
    if (state.order == ConcreteViewOrder.defReverse) {
      return group.elements.reversed.toList(growable: false);
    }
    return List<Chapter>.of(group.elements, growable: false);
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
    AudioConcreteState state,
    int index,
  ) {
    final ChaptersGroup group = state.concreteView.groups[state.groupIndex];
    final Chapter track = group.elements[index];
    final ChapterActivityDomain? activity = state.chapterActivities[track.uid];
    return BlocSelector<LibraryUpdatesCubit, LibraryUpdatesState, bool>(
      selector: (LibraryUpdatesState updates) => updates.isUnseen(track.uid),
      builder: (BuildContext tileContext, bool isNew) => ConcreteListTile(
        title: track.title,
        isNew: isNew,
        selected: state.selection.contains(track.uid),
        dim: AudioProgress.isFinished(activity),
        progress: _tileProgress(activity),
        trailing: _NowPlayingIndicator(
          concreteUid: state.concreteView.uid,
          trackUid: track.uid,
        ),
        subtitle: _buildTrackSubtitle(track, activity),
        onLongPress: () {
          getConcreteViewCubit(context).changeSelection(track.uid);
        },
        onTap: () {
          if (state.selection.isEmpty) {
            _openTrack(context, state, track: track, group: group);
          } else {
            getConcreteViewCubit(context).changeSelection(track.uid);
          }
        },
      ),
    );
  }

  double? _tileProgress(ChapterActivityDomain? activity) {
    if (activity == null) {
      return null;
    }
    return AudioProgress.fractionOf(activity);
  }

  Widget? _buildTrackSubtitle(
    Chapter track,
    ChapterActivityDomain? activity,
  ) {
    final String timestamp = formatTimestamp(track);
    final bool hasTimestamp = timestamp.isNotEmpty;
    final bool hasProgress = activity != null &&
        activity.totalPages > 0 &&
        !AudioProgress.isFinished(activity);

    if (!hasTimestamp && !hasProgress) {
      return null;
    }

    return Row(
      children: <Widget>[
        if (hasTimestamp)
          Text(
            timestamp,
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
        if (hasTimestamp && hasProgress)
          Text('  ·  ', style: TextStyle(color: AppColors.mainGrey)),
        if (hasProgress)
          Text(
            AudioProgress.progressLabel(activity),
            style: regular(color: AppColors.mainGrey, size: 12),
          ),
      ],
    );
  }

  String formatTimestamp(Chapter track) {
    final String? raw = track.timestamp;
    if (raw == null) {
      return '';
    }
    final int? millis = int.tryParse(raw);
    if (millis == null) {
      return raw;
    }
    return DateFormat(trackDateFormat)
        .format(DateTime.fromMillisecondsSinceEpoch(millis));
  }
}

class _NowPlayingIndicator extends StatelessWidget {
  const _NowPlayingIndicator({
    required this.concreteUid,
    required this.trackUid,
  });

  final String concreteUid;
  final String trackUid;

  @override
  Widget build(BuildContext context) {
    final bool current = context.select(
      (AudiobookPlayerCubit player) =>
          player.state.isPlayingTrack(concreteUid, trackUid),
    );
    if (!current) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Icon(Icons.graphic_eq_rounded, color: AppColors.primary, size: 22),
    );
  }
}
