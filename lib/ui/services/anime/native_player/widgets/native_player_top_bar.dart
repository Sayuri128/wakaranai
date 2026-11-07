import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_pickers.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const int _maxInlineQualityLabelLength = 6;

class NativePlayerTopBar extends StatelessWidget {
  const NativePlayerTopBar({
    super.key,
    required this.title,
    required this.onBack,
    required this.playbackSpeed,
    required this.onSpeed,
    required this.onMore,
    this.subtitle,
    this.onEpisodes,
    this.onGroups,
    this.onSubtitles,
    this.subtitlesActive = false,
    this.onQuality,
    this.qualityLabel,
  });

  final String title;
  final String? subtitle;
  final VoidCallback onBack;
  final VoidCallback? onEpisodes;
  final VoidCallback? onGroups;
  final VoidCallback? onSubtitles;
  final bool subtitlesActive;
  final VoidCallback? onQuality;
  final String? qualityLabel;
  final double playbackSpeed;
  final VoidCallback onSpeed;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Positioned.fill(child: IgnorePointer(child: _buildGradient())),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 4, 8, 20),
            child: _buildRow(S.of(context)),
          ),
        ),
      ],
    );
  }

  Widget _buildGradient() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
    );
  }

  Widget _buildRow(S strings) {
    return Row(
      children: <Widget>[
        _buildIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: strings.common_go_back,
          onPressed: onBack,
        ),
        const SizedBox(width: 4),
        Expanded(child: IgnorePointer(child: _buildTitles())),
        ..._buildActions(strings),
      ],
    );
  }

  Widget _buildTitles() {
    final String? currentSubtitle = subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: semibold(size: 16, color: AppColors.onMedia),
        ),
        if (currentSubtitle != null && currentSubtitle.isNotEmpty) ...<Widget>[
          const SizedBox(height: 2),
          Text(
            currentSubtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: regular(
              size: 13,
              color: AppColors.onMedia.withValues(alpha: 0.75),
            ),
          ),
        ],
      ],
    );
  }

  List<Widget> _buildActions(S strings) {
    return <Widget>[
      if (onEpisodes != null)
        _buildIconButton(
          icon: Icons.format_list_numbered_rounded,
          tooltip: strings.player_episodes,
          onPressed: onEpisodes,
        ),
      if (onGroups != null)
        _buildIconButton(
          icon: Icons.record_voice_over_rounded,
          tooltip: strings.player_dub_player,
          onPressed: onGroups,
        ),
      if (onSubtitles != null)
        _buildIconButton(
          icon: subtitlesActive
              ? Icons.closed_caption_rounded
              : Icons.closed_caption_off_outlined,
          tooltip: strings.native_player_subtitles,
          onPressed: onSubtitles,
          highlighted: subtitlesActive,
        ),
      if (onQuality != null) _buildQualityButton(strings),
      _buildSpeedButton(strings),
      _buildIconButton(
        icon: Icons.more_vert_rounded,
        tooltip: strings.native_player_more,
        onPressed: onMore,
      ),
    ];
  }

  Widget _buildQualityButton(S strings) {
    final String? label = qualityLabel;
    if (label == null || label.length > _maxInlineQualityLabelLength) {
      return _buildIconButton(
        icon: Icons.high_quality_rounded,
        tooltip: strings.native_player_quality,
        onPressed: onQuality,
      );
    }
    return _buildLabelButton(
      label: label,
      tooltip: strings.native_player_quality,
      onPressed: onQuality!,
      outlined: true,
    );
  }

  Widget _buildSpeedButton(S strings) {
    if (playbackSpeed == 1.0) {
      return _buildIconButton(
        icon: Icons.speed_rounded,
        tooltip: strings.native_player_speed,
        onPressed: onSpeed,
      );
    }
    return _buildLabelButton(
      label: speedMultiplierLabel(playbackSpeed),
      tooltip: strings.native_player_speed,
      onPressed: onSpeed,
      highlighted: true,
    );
  }

  Widget _buildLabelButton({
    required String label,
    required String tooltip,
    required VoidCallback onPressed,
    bool outlined = false,
    bool highlighted = false,
  }) {
    final Color color = highlighted ? AppColors.primary : AppColors.onMedia;
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onPressed,
        radius: 24,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                border: outlined
                    ? Border.all(color: color.withValues(alpha: 0.7), width: 1.5)
                    : null,
              ),
              child: Text(label, style: semibold(size: 13, color: color)),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback? onPressed,
    bool highlighted = false,
  }) {
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      iconSize: 24,
      color: highlighted ? AppColors.primary : AppColors.onMedia,
      icon: Icon(icon),
    );
  }
}
