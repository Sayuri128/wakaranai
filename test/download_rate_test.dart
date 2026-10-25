import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/utils/download_rate.dart';

void main() {
  test('speed and time left come from the recent samples', () {
    DateTime now = DateTime(2026, 10, 26, 12);
    final DownloadRate rate = DownloadRate(
      totalBytes: 1000 * 1000 * 1000,
      clock: () => now,
    );

    rate.record(0);
    expect(rate.estimate, isNull);

    now = now.add(const Duration(seconds: 10));
    rate.record(100 * 1000 * 1000);

    final DownloadEstimate estimate = rate.estimate!;
    expect(estimate.bytesPerSecond, 10 * 1000 * 1000);
    expect(estimate.remaining, const Duration(seconds: 90));
  });

  test('old samples fall out of the window', () {
    DateTime now = DateTime(2026, 10, 26, 12);
    final DownloadRate rate = DownloadRate(
      totalBytes: 1000,
      clock: () => now,
      window: const Duration(seconds: 20),
    );

    rate.record(0);
    now = now.add(const Duration(seconds: 60));
    rate.record(100);
    now = now.add(const Duration(seconds: 10));
    rate.record(600);

    expect(rate.estimate!.bytesPerSecond, 50);
  });
}
