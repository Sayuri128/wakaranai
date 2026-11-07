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
