import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/services/anime/native_player/widgets/native_player_speed_sheet.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';

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

Widget _buildRow(
  BuildContext context, {
  required String label,
  required bool selected,
  required VoidCallback onTap,
}) {
  return ActionSheetRow(
    label: label,
    selected: selected,
    onTap: () {
      Navigator.of(context).pop();
      onTap();
    },
  );
}
