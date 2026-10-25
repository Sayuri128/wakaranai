import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/download_rate.dart';

const int _bytesPerMegabyte = 1000 * 1000;

String withDownloadEstimate(String progressLabel, DownloadEstimate? estimate) {
  if (estimate == null) {
    return progressLabel;
  }
  final String speed = S.current.download_speed_megabytes(
    (estimate.bytesPerSecond / _bytesPerMegabyte).toStringAsFixed(1),
  );
  final String timeLeft = S.current.download_time_left(
    _formatRemaining(estimate.remaining),
  );
  return '$progressLabel · $speed · $timeLeft';
}

String _formatRemaining(Duration remaining) {
  if (remaining.inHours > 0) {
    return S.current.duration_hours_minutes(
      remaining.inHours,
      remaining.inMinutes.remainder(Duration.minutesPerHour),
    );
  }
  if (remaining.inMinutes > 0) {
    return S.current.duration_minutes(remaining.inMinutes + 1);
  }
  return S.current.duration_seconds(remaining.inSeconds);
}
