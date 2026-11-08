import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';

String trackerStatusLabel(TrackerStatus status, TrackerMediaType type) {
  final bool manga = type == TrackerMediaType.manga;
  switch (status) {
    case TrackerStatus.planning:
      return S.current.tracker_status_planning;
    case TrackerStatus.current:
      if (manga) {
        return S.current.tracker_status_reading;
      }
      return S.current.tracker_status_watching;
    case TrackerStatus.completed:
      return S.current.tracker_status_completed;
    case TrackerStatus.paused:
      return S.current.tracker_status_paused;
    case TrackerStatus.dropped:
      return S.current.tracker_status_dropped;
    case TrackerStatus.repeating:
      if (manga) {
        return S.current.tracker_status_rereading;
      }
      return S.current.tracker_status_rewatching;
  }
}

String trackerProgressLabel(int progress, int? total) {
  if (total == null || total <= 0) {
    return '$progress';
  }
  return '$progress / $total';
}

IconData trackerStatusIcon(TrackerStatus status, TrackerMediaType type) {
  switch (status) {
    case TrackerStatus.planning:
      return Icons.schedule_rounded;
    case TrackerStatus.current:
      if (type == TrackerMediaType.manga) {
        return Icons.auto_stories_rounded;
      }
      return Icons.play_arrow_rounded;
    case TrackerStatus.completed:
      return Icons.check_circle_rounded;
    case TrackerStatus.paused:
      return Icons.pause_rounded;
    case TrackerStatus.dropped:
      return Icons.cancel_rounded;
    case TrackerStatus.repeating:
      return Icons.replay_rounded;
  }
}
