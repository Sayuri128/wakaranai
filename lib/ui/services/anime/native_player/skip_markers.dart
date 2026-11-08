import 'package:wakaranai/data/domain/playable_video.dart';

const Set<PlayableSkipType> kAutoSkippableTypes = <PlayableSkipType>{
  PlayableSkipType.intro,
  PlayableSkipType.outro,
};

List<PlayableSkipMarker> normalizeSkipMarkers(
  Iterable<PlayableSkipMarker> markers,
) {
  final List<PlayableSkipMarker> valid = <PlayableSkipMarker>[];
  for (final PlayableSkipMarker marker in markers) {
    final PlayableSkipMarker? normalized = _normalizedMarker(marker);
    if (normalized != null && !valid.contains(normalized)) {
      valid.add(normalized);
    }
  }
  valid.sort(_compareMarkers);
  return List<PlayableSkipMarker>.unmodifiable(valid);
}

PlayableSkipMarker? _normalizedMarker(PlayableSkipMarker marker) {
  final Duration start =
      marker.start < Duration.zero ? Duration.zero : marker.start;
  if (marker.end <= start) {
    return null;
  }
  if (start == marker.start) {
    return marker;
  }
  return PlayableSkipMarker(type: marker.type, start: start, end: marker.end);
}

int _compareMarkers(PlayableSkipMarker first, PlayableSkipMarker second) {
  final int byStart = first.start.compareTo(second.start);
  if (byStart != 0) {
    return byStart;
  }
  return first.end.compareTo(second.end);
}

Duration? skipMarkerOffset(num seconds) {
  if (!seconds.isFinite) {
    return null;
  }
  return Duration(milliseconds: (seconds * 1000).round());
}

PlayableSkipMarker? activeSkipMarker(
  List<PlayableSkipMarker> markers,
  Duration position,
) {
  return _furthestReaching(
    markers.where((PlayableSkipMarker marker) => marker.contains(position)),
  );
}

PlayableSkipMarker? _furthestReaching(Iterable<PlayableSkipMarker> markers) {
  PlayableSkipMarker? best;
  for (final PlayableSkipMarker marker in markers) {
    if (best == null || marker.end > best.end) {
      best = marker;
    }
  }
  return best;
}

class SkipMarkerTracker {
  final Set<PlayableSkipMarker> _handled = <PlayableSkipMarker>{};

  bool isHandled(PlayableSkipMarker marker) => _handled.contains(marker);

  void reset() {
    _handled.clear();
  }

  void markHandled(PlayableSkipMarker marker) {
    _handled.add(marker);
  }

  void noteUserSeek(List<PlayableSkipMarker> markers, Duration position) {
    for (final PlayableSkipMarker marker in markers) {
      if (marker.contains(position)) {
        _handled.add(marker);
      }
    }
  }

  PlayableSkipMarker? takeAutoSkip(
    List<PlayableSkipMarker> markers,
    Duration position,
  ) {
    final List<PlayableSkipMarker> pending = markers
        .where(
          (PlayableSkipMarker marker) =>
              kAutoSkippableTypes.contains(marker.type) &&
              marker.contains(position) &&
              !_handled.contains(marker),
        )
        .toList(growable: false);
    if (pending.isEmpty) {
      return null;
    }
    _handled.addAll(pending);
    return _furthestReaching(pending);
  }
}
