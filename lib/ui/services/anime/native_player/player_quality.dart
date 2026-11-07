import 'package:equatable/equatable.dart';
import 'package:video_player/video_player.dart';

const String kAutoQualityLabel = 'Auto';

final RegExp _heightPattern = RegExp(r'(\d{3,4})\s*p\b', caseSensitive: false);

class PlayerRendition extends Equatable {
  const PlayerRendition(this.track);

  final VideoTrack track;

  String get id => track.id;

  int? get height => track.height;

  int? get bitrate => track.bitrate;

  String? get trackLabel {
    final String? label = track.label?.trim();
    if (label == null || label.isEmpty) {
      return null;
    }
    return label;
  }

  String get preferenceLabel {
    final int? renditionHeight = height;
    if (renditionHeight != null) {
      return '${renditionHeight}p';
    }
    final String? label = trackLabel;
    if (label != null) {
      return label;
    }
    final int? renditionBitrate = bitrate;
    if (renditionBitrate != null) {
      return formatBitrate(renditionBitrate);
    }
    return id;
  }

  @override
  List<Object?> get props => <Object?>[id, height, bitrate, track.width, trackLabel];
}

List<PlayerRendition> distinctRenditions(List<VideoTrack> tracks) {
  final Map<String, PlayerRendition> byKey = <String, PlayerRendition>{};
  for (final VideoTrack track in tracks) {
    byKey.putIfAbsent(_renditionKey(track), () => PlayerRendition(track));
  }
  final List<PlayerRendition> renditions = byKey.values.toList();
  renditions.sort(_compareRenditions);
  return renditions;
}

String _renditionKey(VideoTrack track) {
  if (track.height == null && track.bitrate == null) {
    return 'track:${track.label ?? track.id}';
  }
  return '${track.height}:${track.bitrate}';
}

int _compareRenditions(PlayerRendition first, PlayerRendition second) {
  final int byHeight = (second.height ?? 0).compareTo(first.height ?? 0);
  if (byHeight != 0) {
    return byHeight;
  }
  return (second.bitrate ?? 0).compareTo(first.bitrate ?? 0);
}

String formatBitrate(int bitsPerSecond) {
  if (bitsPerSecond >= 1000000) {
    return '${(bitsPerSecond / 1000000).toStringAsFixed(1)} Mbps';
  }
  return '${(bitsPerSecond / 1000).round()} kbps';
}

String renditionLabel(PlayerRendition rendition, List<PlayerRendition> all) {
  final String base = rendition.preferenceLabel;
  final int? bitrate = rendition.bitrate;
  if (rendition.height == null || bitrate == null) {
    return base;
  }
  final bool sharesHeight = all.any(
    (PlayerRendition other) =>
        other.id != rendition.id && other.height == rendition.height,
  );
  if (!sharesHeight) {
    return base;
  }
  return '$base · ${formatBitrate(bitrate)}';
}

bool isAutoQualityLabel(String? label) {
  return label?.trim().toLowerCase() == kAutoQualityLabel.toLowerCase();
}

int? qualityHeightOf(String label) {
  final RegExpMatch? match = _heightPattern.firstMatch(label);
  if (match == null) {
    return null;
  }
  return int.tryParse(match.group(1)!);
}

PlayerRendition? matchRendition(
  List<PlayerRendition> renditions,
  String wanted,
) {
  final String normalized = wanted.trim().toLowerCase();
  if (normalized.isEmpty) {
    return null;
  }
  for (final PlayerRendition rendition in renditions) {
    final bool sameLabel =
        rendition.preferenceLabel.toLowerCase() == normalized ||
            rendition.trackLabel?.toLowerCase() == normalized;
    if (sameLabel) {
      return rendition;
    }
  }
  final int? wantedHeight = qualityHeightOf(normalized);
  if (wantedHeight == null) {
    return null;
  }
  return _closestLowerRendition(renditions, wantedHeight);
}

PlayerRendition? _closestLowerRendition(
  List<PlayerRendition> renditions,
  int wantedHeight,
) {
  final List<PlayerRendition> withHeight = renditions
      .where((PlayerRendition rendition) => rendition.height != null)
      .toList();
  if (withHeight.isEmpty) {
    return null;
  }
  for (final PlayerRendition rendition in withHeight) {
    if (rendition.height! <= wantedHeight) {
      return rendition;
    }
  }
  return withHeight.last;
}

enum QualityOptionKind { stream, auto, rendition }

class QualityOption extends Equatable {
  const QualityOption.stream({required this.streamIndex, required this.label})
      : kind = QualityOptionKind.stream,
        rendition = null;

  const QualityOption.auto({required this.streamIndex, required this.label})
      : kind = QualityOptionKind.auto,
        rendition = null;

  const QualityOption.rendition({
    required this.streamIndex,
    required PlayerRendition this.rendition,
    required this.label,
  }) : kind = QualityOptionKind.rendition;

  final QualityOptionKind kind;
  final int streamIndex;
  final PlayerRendition? rendition;
  final String label;

  bool isSelected({
    required int currentStreamIndex,
    required String? selectedRenditionId,
  }) {
    if (streamIndex != currentStreamIndex) {
      return false;
    }
    switch (kind) {
      case QualityOptionKind.stream:
        return true;
      case QualityOptionKind.auto:
        return selectedRenditionId == null;
      case QualityOptionKind.rendition:
        return rendition?.id == selectedRenditionId;
    }
  }

  @override
  List<Object?> get props => <Object?>[kind, streamIndex, rendition, label];
}

class QualityGroup extends Equatable {
  const QualityGroup({
    required this.streamIndex,
    required this.label,
    this.options = const <QualityOption>[],
  });

  final int streamIndex;
  final String label;
  final List<QualityOption> options;

  List<QualityOption> get selectableOptions {
    if (options.isNotEmpty) {
      return options;
    }
    return <QualityOption>[
      QualityOption.stream(streamIndex: streamIndex, label: label),
    ];
  }

  @override
  List<Object?> get props => <Object?>[streamIndex, label, options];
}

List<QualityGroup> buildQualityGroups({
  required List<String> streamLabels,
  required int currentStreamIndex,
  required List<PlayerRendition> renditions,
  required String autoLabel,
}) {
  return <QualityGroup>[
    for (int index = 0; index < streamLabels.length; index++)
      QualityGroup(
        streamIndex: index,
        label: streamLabels[index],
        options: index == currentStreamIndex
            ? _renditionOptions(index, renditions, autoLabel)
            : const <QualityOption>[],
      ),
  ];
}

List<QualityOption> _renditionOptions(
  int streamIndex,
  List<PlayerRendition> renditions,
  String autoLabel,
) {
  if (renditions.length < 2) {
    return const <QualityOption>[];
  }
  return <QualityOption>[
    QualityOption.auto(streamIndex: streamIndex, label: autoLabel),
    for (final PlayerRendition rendition in renditions)
      QualityOption.rendition(
        streamIndex: streamIndex,
        rendition: rendition,
        label: renditionLabel(rendition, renditions),
      ),
  ];
}

int selectableQualityCount(List<QualityGroup> groups) {
  int count = 0;
  for (final QualityGroup group in groups) {
    count += group.selectableOptions.length;
  }
  return count;
}

String? currentQualityLabel(
  List<QualityGroup> groups, {
  required int currentStreamIndex,
  required String? selectedRenditionId,
}) {
  for (final QualityGroup group in groups) {
    for (final QualityOption option in group.selectableOptions) {
      final bool selected = option.isSelected(
        currentStreamIndex: currentStreamIndex,
        selectedRenditionId: selectedRenditionId,
      );
      if (selected) {
        return option.rendition?.preferenceLabel ?? option.label;
      }
    }
  }
  return null;
}
