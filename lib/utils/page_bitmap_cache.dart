import 'dart:async';
import 'dart:collection';

import 'package:flutter/widgets.dart';
import 'package:wakaranai/utils/page_bitmap.dart';

typedef PageBitmapLoader = Future<PageBitmap> Function(
    String path, Map<String, String> headers);

class _PageCacheEntry {
  _PageCacheEntry(this.future);

  final Future<PageBitmap> future;
  PageBitmap? bitmap;
  int refs = 0;

  int get bytes => bitmap == null ? 0 : bitmap!.width * bitmap!.height * 4;

  void disposeBitmap() {
    bitmap?.dispose();
    bitmap = null;
  }
}

/// A claim on one cached page. The bitmap behind it stays alive until
/// [release] is called, so a lease must be released exactly once by whoever
/// took it. Holding the lease rather than the path keeps a stale release from
/// dropping a newer entry's reference.
class PageBitmapLease {
  PageBitmapLease._(this._cache, this._entry, this.path);

  final PageBitmapCache _cache;
  final _PageCacheEntry _entry;
  final String path;
  bool _released = false;

  Future<PageBitmap> get bitmap => _entry.future;

  void release() {
    if (_released) return;
    _released = true;
    _cache._release(path, _entry);
  }
}

/// Keeps decoded pages alive between builds so scrolling back does not decode
/// again, while capping how many full-resolution bitmaps are resident at once.
///
/// Entries are reference counted: a page still leased is never disposed, so
/// [maxBytes] is a ceiling on idle pages rather than a hard limit. Resolved
/// sizes outlive their pixels so a rebuilt placeholder can reserve the right
/// height and keep the scroll offset stable.
class PageBitmapCache {
  PageBitmapCache({
    PageBitmapLoader? loader,
    this.maxBytes = defaultMaxBytes,
  }) : _loader = loader ?? loadPageBitmap;

  static final PageBitmapCache instance = PageBitmapCache();

  static const int defaultMaxBytes = 100 << 20;

  final PageBitmapLoader _loader;
  final int maxBytes;

  final LinkedHashMap<String, _PageCacheEntry> _entries =
      LinkedHashMap<String, _PageCacheEntry>();
  final Map<String, Size> _sizes = <String, Size>{};

  int _bytes = 0;

  int get residentBytes => _bytes;

  int get residentCount => _entries.length;

  Size? knownSize(String path) => _sizes[path];

  PageBitmapLease acquire(String path, Map<String, String> headers) {
    _PageCacheEntry? entry = _entries.remove(path);
    entry ??= _load(path, headers);
    _entries[path] = entry;
    entry.refs++;
    return PageBitmapLease._(this, entry, path);
  }

  void prefetch(String path, Map<String, String> headers) {
    if (_entries.containsKey(path)) return;
    final PageBitmapLease lease = acquire(path, headers);
    unawaited(lease.bitmap.then(
      (_) => lease.release(),
      onError: (Object _) => lease.release(),
    ));
  }

  Future<void> evict(String path) async {
    final _PageCacheEntry? entry = _entries.remove(path);
    if (entry != null) {
      _bytes -= entry.bytes;
      if (entry.refs == 0) {
        entry.disposeBitmap();
      }
    }
    _sizes.remove(path);
    await evictPageSource(path);
  }

  void _release(String path, _PageCacheEntry entry) {
    if (entry.refs > 0) entry.refs--;
    if (entry.refs > 0) return;

    if (!identical(_entries[path], entry)) {
      entry.disposeBitmap();
      return;
    }
    _trim();
  }

  _PageCacheEntry _load(String path, Map<String, String> headers) {
    late final _PageCacheEntry entry;
    final Future<PageBitmap> future = _loader(path, headers).then(
      (PageBitmap bitmap) {
        if (!identical(_entries[path], entry)) {
          if (entry.refs == 0) bitmap.dispose();
          return bitmap;
        }
        entry.bitmap = bitmap;
        _sizes[path] = bitmap.size;
        _bytes += entry.bytes;
        _trim();
        return bitmap;
      },
      onError: (Object error, StackTrace stack) {
        if (identical(_entries[path], entry)) {
          _entries.remove(path);
        }
        throw error;
      },
    );
    entry = _PageCacheEntry(future);
    return entry;
  }

  void _trim() {
    if (_bytes <= maxBytes) return;

    for (final String key in _entries.keys.toList()) {
      if (_bytes <= maxBytes) break;
      final _PageCacheEntry entry = _entries[key]!;
      if (entry.refs > 0 || entry.bitmap == null) continue;
      _bytes -= entry.bytes;
      entry.disposeBitmap();
      _entries.remove(key);
    }
  }
}
