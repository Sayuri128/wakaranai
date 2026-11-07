import 'package:collection/collection.dart';
import 'package:wakaranai/data/domain/playable_video.dart';
import 'package:wakaranai/repositories/shared_pref/player_preferences.dart';
import 'package:wakaranai/services/downloads/episode/hls_playlist.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_quality.dart';
import 'package:wakaranai/ui/services/anime/native_player/player_track_selection.dart';

int? wantedHeightFor(QualityPreference preference) {
  final String? renditionLabel = preference.renditionLabel;
  if (renditionLabel != null && isAutoQualityLabel(renditionLabel)) {
    return null;
  }
  return _heightOfLabel(renditionLabel) ??
      _heightOfLabel(preference.streamLabel);
}

int? _heightOfLabel(String? label) {
  if (label == null || isAutoQualityLabel(label)) {
    return null;
  }
  return qualityHeightOf(label);
}

HlsVariant pickHlsVariant(List<HlsVariant> variants, int? wantedHeight) {
  if (variants.isEmpty) {
    throw ArgumentError.value(variants, 'variants', 'must not be empty');
  }
  final List<HlsVariant> withHeight =
      variants.where((HlsVariant variant) => variant.height != null).toList()
        ..sort(_compareByHeightThenBandwidth);
  if (withHeight.isEmpty) {
    return variants.reduce(_higherBandwidth);
  }
  if (wantedHeight == null) {
    return withHeight.last;
  }
  final HlsVariant? closestLower = withHeight.lastWhereOrNull(
    (HlsVariant variant) => variant.height! <= wantedHeight,
  );
  if (closestLower != null) {
    return closestLower;
  }
  final int lowestHeight = withHeight.first.height!;
  return withHeight.lastWhere(
    (HlsVariant variant) => variant.height == lowestHeight,
  );
}

int _compareByHeightThenBandwidth(HlsVariant first, HlsVariant second) {
  final int byHeight = (first.height ?? 0).compareTo(second.height ?? 0);
  if (byHeight != 0) {
    return byHeight;
  }
  return _bandwidthOf(first).compareTo(_bandwidthOf(second));
}

HlsVariant _higherBandwidth(HlsVariant first, HlsVariant second) {
  if (_bandwidthOf(second) > _bandwidthOf(first)) {
    return second;
  }
  return first;
}

int _bandwidthOf(HlsVariant variant) {
  return variant.bandwidth ?? variant.averageBandwidth ?? 0;
}

HlsAudioRendition? pickAudioRendition(
  HlsMasterPlaylist master,
  HlsVariant variant,
) {
  final String? groupId = variant.audioGroupId;
  if (groupId == null) {
    return null;
  }
  final List<HlsAudioRendition> withUri = master
      .audioGroup(groupId)
      .where((HlsAudioRendition rendition) => rendition.uri != null)
      .toList(growable: false);
  if (withUri.isEmpty) {
    return null;
  }
  return withUri.firstWhereOrNull(
        (HlsAudioRendition rendition) => rendition.isDefault,
      ) ??
      withUri.first;
}

List<int> downloadableStreamOrder(
  List<PlayableStream> streams,
  String? streamLabel,
) {
  if (streams.isEmpty) {
    return const <int>[];
  }
  final int preferred = preferredStreamIndex(streams, streamLabel);
  final List<int> order = <int>[
    preferred,
    for (int index = 0; index < streams.length; index++)
      if (index != preferred) index,
  ];
  return order
      .where(
        (int index) =>
            resolveStreamFormat(streams[index]) != PlayableStreamFormat.dash,
      )
      .toList(growable: false);
}

String? variantQualityLabel(HlsVariant variant) {
  final int? height = variant.height;
  if (height == null) {
    return null;
  }
  return '${height}p';
}
