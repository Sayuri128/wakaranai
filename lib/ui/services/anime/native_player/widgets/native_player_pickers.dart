import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_fit_mode.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_speed_sheet.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

String streamQualityLabel(List<PlayableStream> streams, int index) {
  final String? quality = streams[index].quality?.trim();
  if (quality != null && quality.isNotEmpty) {
    return quality;
  }
  return S.current.native_player_quality_fallback(index + 1);
}

String subtitleLabel(List<PlayableSubtitle> subtitles, int index) {
  final PlayableSubtitle subtitle = subtitles[index];
  final String? label = subtitle.label?.trim();
  if (label != null && label.isNotEmpty) {
    return label;
  }
  final String? language = subtitle.language?.trim();
  if (language != null && language.isNotEmpty) {
    return language;
  }
  return S.current.native_player_subtitle_fallback(index + 1);
}

String speedMultiplierLabel(double speed) {
  final double rounded = double.parse(speed.toStringAsFixed(2));
  if (rounded == rounded.roundToDouble()) {
    return '${rounded.toStringAsFixed(0)}×';
  }
  String number = rounded.toStringAsFixed(2);
  if (number.endsWith('0')) {
    number = number.substring(0, number.length - 1);
  }
  return '$number×';
}

String playbackSpeedLabel(double speed) {
  if (speed == 1.0) {
    return S.current.native_player_speed_normal;
  }
  return speedMultiplierLabel(speed);
}

Future<void> showQualityPicker(
  BuildContext context, {
  required List<PlayableStream> streams,
  required int selectedIndex,
  required ValueChanged<int> onSelected,
}) {
  return showActionSheet(
    context,
    title: S.of(context).native_player_quality,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        for (int index = 0; index < streams.length; index++)
          _buildRow(
            context,
            label: streamQualityLabel(streams, index),
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          ),
      ],
    ),
  );
}

Future<void> showSpeedPicker(
  BuildContext context, {
  required double selectedSpeed,
  required ValueChanged<double> onSelected,
}) {
  return showActionSheet(
    context,
    title: S.of(context).native_player_speed,
    child: NativePlayerSpeedSheet(
      initialSpeed: selectedSpeed,
      onSelected: onSelected,
    ),
  );
}

Future<void> showSubtitlePicker(
  BuildContext context, {
  required List<PlayableSubtitle> subtitles,
  required int? selectedIndex,
  required ValueChanged<int?> onSelected,
}) {
  return showActionSheet(
    context,
    title: S.of(context).native_player_subtitles,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        _buildRow(
          context,
          label: S.of(context).native_player_subtitles_off,
          selected: selectedIndex == null,
          onTap: () => onSelected(null),
        ),
        for (int index = 0; index < subtitles.length; index++)
          _buildRow(
            context,
            label: subtitleLabel(subtitles, index),
            selected: index == selectedIndex,
            onTap: () => onSelected(index),
          ),
      ],
    ),
  );
}

Future<void> showPlayerMoreSheet(
  BuildContext context, {
  required PlayerFitMode fitMode,
  required ValueChanged<PlayerFitMode> onFitModeSelected,
  required VoidCallback onOpenWebPlayer,
}) {
  final S strings = S.of(context);
  return showActionSheet(
    context,
    title: strings.native_player_more,
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSectionHeader(strings.native_player_fit_mode),
        for (final PlayerFitMode mode in PlayerFitMode.values)
          _buildRow(
            context,
            label: fitModeLabel(mode),
            icon: fitModeIcon(mode),
            selected: mode == fitMode,
            onTap: () => onFitModeSelected(mode),
          ),
        Divider(height: 16, color: AppColors.overlay(0.08)),
        _buildRow(
          context,
          label: strings.native_player_open_web_player,
          icon: Icons.public_rounded,
          selected: false,
          onTap: onOpenWebPlayer,
        ),
      ],
    ),
  );
}

Widget _buildSectionHeader(String label) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
    child: Text(label, style: semibold(size: 13, color: AppColors.mainGrey)),
  );
}

Widget _buildRow(
  BuildContext context, {
  IconData? icon,
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return ActionSheetRow(
    label: label,
    icon: icon,
    selected: selected,
    onTap: () {
      Navigator.of(context).pop();
      onTap();
    },
  );
}
