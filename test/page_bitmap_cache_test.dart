import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/utils/page_bitmap.dart';
import 'package:wakaranai/utils/page_bitmap_cache.dart';

const int _side = 64;
const int _bytesPerPage = _side * _side * 4;

Future<PageBitmap> _makeBitmap() async {
  final ui.Image image = await rawImage(
    Uint8List(_bytesPerPage),
    _side,
    _side,
  );
  return PageBitmap(image, _side, _side);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('a second acquire reuses the decoded bitmap', () async {
    int loads = 0;
    final PageBitmapCache cache = PageBitmapCache(
      loader: (String path, Map<String, String> headers) async {
        loads++;
        return _makeBitmap();
      },
    );

    final PageBitmap first = await cache.acquire('a', const {}).bitmap;
    final PageBitmap second = await cache.acquire('a', const {}).bitmap;

    expect(loads, 1);
    expect(identical(first, second), isTrue);
  });

  test('idle pages are evicted once the budget is exceeded', () async {
    final PageBitmapCache cache = PageBitmapCache(
      maxBytes: _bytesPerPage * 2,
      loader: (String path, Map<String, String> headers) => _makeBitmap(),
    );

    for (final String path in <String>['a', 'b', 'c', 'd']) {
      final PageBitmapLease lease = cache.acquire(path, const {});
      await lease.bitmap;
      lease.release();
    }

    expect(cache.residentBytes, lessThanOrEqualTo(_bytesPerPage * 2));
    expect(cache.residentCount, lessThanOrEqualTo(2));
  });

  test('a page still held is never evicted', () async {
    final PageBitmapCache cache = PageBitmapCache(
      maxBytes: _bytesPerPage,
      loader: (String path, Map<String, String> headers) => _makeBitmap(),
    );

    final PageBitmapLease heldLease = cache.acquire('held', const {});
    final PageBitmap held = await heldLease.bitmap;

    for (final String path in <String>['a', 'b', 'c']) {
      final PageBitmapLease lease = cache.acquire(path, const {});
      await lease.bitmap;
      lease.release();
    }

    expect(cache.residentCount, 1);
    expect(
        identical(await cache.acquire('held', const {}).bitmap, held), isTrue);
  });

  test('a resolved size outlives the evicted pixels', () async {
    final PageBitmapCache cache = PageBitmapCache(
      maxBytes: _bytesPerPage,
      loader: (String path, Map<String, String> headers) => _makeBitmap(),
    );

    for (final String path in <String>['a', 'b']) {
      final PageBitmapLease lease = cache.acquire(path, const {});
      await lease.bitmap;
      lease.release();
    }

    expect(cache.residentCount, 1);
    expect(cache.knownSize('a'), const ui.Size(64, 64));
  });

  test('a failed load is not cached, so a retry loads again', () async {
    int attempts = 0;
    final PageBitmapCache cache = PageBitmapCache(
      loader: (String path, Map<String, String> headers) async {
        attempts++;
        if (attempts == 1) throw Exception('boom');
        return _makeBitmap();
      },
    );

    final PageBitmapLease failed = cache.acquire('a', const {});
    await expectLater(failed.bitmap, throwsException);
    failed.release();

    await expectLater(cache.acquire('a', const {}).bitmap, completes);
    expect(attempts, 2);
  });

  test('a stale release does not drop a newer entry for the same page',
      () async {
    int attempts = 0;
    final PageBitmapCache cache = PageBitmapCache(
      maxBytes: _bytesPerPage,
      loader: (String path, Map<String, String> headers) async {
        attempts++;
        if (attempts == 1) throw Exception('boom');
        return _makeBitmap();
      },
    );

    final PageBitmapLease failed = cache.acquire('a', const {});
    await expectLater(failed.bitmap, throwsException);

    final PageBitmapLease live = cache.acquire('a', const {});
    final PageBitmap bitmap = await live.bitmap;

    failed.release();

    final PageBitmapLease other = cache.acquire('b', const {});
    await other.bitmap;
    other.release();

    expect(bitmap.image.debugDisposed, isFalse);
    expect(identical(await cache.acquire('a', const {}).bitmap, bitmap),
        isTrue);
  });
}
