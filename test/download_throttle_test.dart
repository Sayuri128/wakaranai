import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/blocs/downloads/download_throttle.dart';

void main() {
  test('an untouched extension downloads without any delay', () {
    final DownloadThrottle throttle = DownloadThrottle();

    expect(throttle.pageDelay('hentailib'), Duration.zero);
    expect(throttle.chapterDelay('hentailib'), Duration.zero);
  });

  test('each rate limit doubles the page delay up to a ceiling', () {
    final DownloadThrottle throttle = DownloadThrottle();

    throttle.rateLimited('hentailib');
    expect(throttle.pageDelay('hentailib'), DownloadThrottle.minimumPageDelay);

    throttle.rateLimited('hentailib');
    expect(throttle.pageDelay('hentailib'), const Duration(seconds: 1));

    for (int i = 0; i < 10; i++) {
      throttle.rateLimited('hentailib');
    }
    expect(throttle.pageDelay('hentailib'), DownloadThrottle.maximumPageDelay);
  });

  test('slowing one extension leaves the others alone', () {
    final DownloadThrottle throttle = DownloadThrottle();

    throttle.rateLimited('hentailib');

    expect(throttle.pageDelay('mangadex'), Duration.zero);
    expect(throttle.chapterDelay('hentailib'), const Duration(seconds: 2));
  });

  test('configured delays apply until learned delays grow past them', () {
    final DownloadThrottle throttle = DownloadThrottle()
      ..configure(
        'hentailib',
        pageDelay: const Duration(milliseconds: 750),
        chapterDelay: const Duration(seconds: 3),
      );

    expect(throttle.pageDelay('hentailib'), const Duration(milliseconds: 750));
    expect(throttle.chapterDelay('hentailib'), const Duration(seconds: 3));

    throttle
      ..rateLimited('hentailib')
      ..rateLimited('hentailib');

    expect(throttle.pageDelay('hentailib'), const Duration(seconds: 1));
    expect(throttle.chapterDelay('hentailib'), const Duration(seconds: 4));
  });

  test('retry waits back off exponentially without a server hint', () {
    final DownloadThrottle throttle = DownloadThrottle();

    expect(throttle.retryWait(1), const Duration(seconds: 2));
    expect(throttle.retryWait(2), const Duration(seconds: 4));
    expect(throttle.retryWait(3), const Duration(seconds: 8));
    expect(throttle.retryWait(10), DownloadThrottle.maximumRetryWait);
  });

  test('retry waits follow Retry-After in seconds or as a date', () {
    final DateTime now = DateTime.utc(2026, 11, 7, 12);
    final DownloadThrottle throttle = DownloadThrottle(now: () => now);

    expect(
      throttle.retryWait(1, retryAfterHeader: '7'),
      const Duration(seconds: 7),
    );
    expect(
      throttle.retryWait(
        1,
        retryAfterHeader:
            HttpDate.format(now.add(const Duration(seconds: 15))),
      ),
      const Duration(seconds: 15),
    );
    expect(
      throttle.retryWait(1, retryAfterHeader: '3600'),
      DownloadThrottle.maximumRetryWait,
    );
    expect(
      throttle.retryWait(2, retryAfterHeader: 'soon'),
      const Duration(seconds: 4),
    );
  });
}
