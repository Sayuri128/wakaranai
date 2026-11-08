import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/audiobook_player/audiobook_player_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/services/audio/player/audio_player_controls.dart';
import 'package:wakaranai/ui/widgets/image_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/source_error_description.dart';
import 'package:wakaranai/utils/text_styles.dart';

class AudioPlayerData {
  const AudioPlayerData({
    this.session,
    this.trackIndex = 0,
    this.startAt,
  });

  final AudiobookSession? session;
  final int trackIndex;
  final Duration? startAt;
}

class AudioPlayerPage extends StatefulWidget {
  const AudioPlayerPage({super.key, required this.data});

  final AudioPlayerData data;

  @override
  State<AudioPlayerPage> createState() => _AudioPlayerPageState();
}

class _AudioPlayerPageState extends State<AudioPlayerPage> {
  @override
  void initState() {
    super.initState();
    final AudiobookSession? session = widget.data.session;
    if (session != null) {
      unawaited(context.read<AudiobookPlayerCubit>().open(
            session,
            trackIndex: widget.data.trackIndex,
            startAt: widget.data.startAt,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: BlocBuilder<AudiobookPlayerCubit, AudiobookPlayerState>(
          builder: (BuildContext context, AudiobookPlayerState state) {
            if (!state.hasSession) {
              return _buildIdle(context);
            }
            return _buildPlayer(context, state);
          },
        ),
      ),
    );
  }

  Widget _buildIdle(BuildContext context) {
    return Column(
      children: <Widget>[
        Expanded(
          child: ServiceViewerMessage(
            icon: Icons.headphones_rounded,
            title: S.of(context).audio_player_idle_title,
            message: S.of(context).audio_player_idle_message,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AudioPlayerIconButton(
              icon: Icons.keyboard_arrow_down_rounded,
              tooltip: S.of(context).audio_player_close,
              onTap: () => Navigator.of(context).maybePop(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayer(BuildContext context, AudiobookPlayerState state) {
    return Column(
      children: <Widget>[
        Expanded(child: _AudioPlayerArtwork(state: state)),
        if (state.status == AudiobookStatus.error)
          _AudioPlayerErrorLine(state: state),
        AudioPlayerSeekBar(state: state),
        const SizedBox(height: 8),
        AudioPlayerTransport(state: state),
        const SizedBox(height: 16),
        AudioPlayerBottomBar(state: state),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _AudioPlayerArtwork extends StatelessWidget {
  const _AudioPlayerArtwork({required this.state});

  final AudiobookPlayerState state;

  @override
  Widget build(BuildContext context) {
    final AudiobookSession session = state.session!;
    final String trackTitle = state.track?.title ?? '';
    final String? markerTitle = state.currentMarker?.title;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Center(
              child: AspectRatio(
                aspectRatio: 1,
                child: _buildCover(session),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            trackTitle,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: semibold(size: 20),
          ),
          const SizedBox(height: 6),
          Text(
            session.title,
            maxLines: 1,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: regular(size: 14, color: AppColors.mainGrey),
          ),
          if (markerTitle != null && markerTitle.isNotEmpty) ...<Widget>[
            const SizedBox(height: 6),
            Text(
              markerTitle,
              maxLines: 1,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: medium(size: 13, color: AppColors.primary),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCover(AudiobookSession session) {
    final String? cover = session.cover;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: ColoredBox(
        color: AppColors.overlay(0.06),
        child: cover == null || cover.isEmpty
            ? Center(
                child: Icon(
                  Icons.headphones_rounded,
                  size: 72,
                  color: AppColors.mainGrey,
                ),
              )
            : ImageWidget(
                uid: session.concreteUid,
                url: cover,
                headers: session.coverHeaders,
              ),
      ),
    );
  }
}

class _AudioPlayerErrorLine extends StatelessWidget {
  const _AudioPlayerErrorLine({required this.state});

  final AudiobookPlayerState state;

  String _messageOf(BuildContext context) {
    final Object? error = state.error;
    if (error is AudiobookNoSourceException) {
      return S.of(context).audio_player_no_sources;
    }
    final SourceErrorDescription? description = describeSourceError(
      error,
      sourceName: state.session?.configInfo.name ?? '',
      canSignIn: false,
    );
    if (description != null) {
      return description.title;
    }
    return S.of(context).audio_player_error;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: AppColors.red.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
          child: Row(
            children: <Widget>[
              Icon(Icons.error_outline_rounded, color: AppColors.red),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _messageOf(context),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: regular(size: 13),
                ),
              ),
              TextButton(
                onPressed: () => unawaited(
                  context.read<AudiobookPlayerCubit>().retry(),
                ),
                child: Text(
                  S.of(context).audio_player_retry,
                  style: semibold(size: 14, color: AppColors.primary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
