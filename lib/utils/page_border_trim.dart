import 'dart:async';
import 'dart:collection';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' as ui;

class PageTrim {
  const PageTrim(this.left, this.top, this.right, this.bottom);

  static const PageTrim none = PageTrim(0, 0, 1, 1);

  final double left;
  final double top;
  final double right;
  final double bottom;

  bool get isNone => left <= 0 && top <= 0 && right >= 1 && bottom >= 1;

  ui.Rect sourceRect(ui.Image image) {
    return ui.Rect.fromLTRB(
      left * image.width,
      top * image.height,
      right * image.width,
      bottom * image.height,
    );
  }

  ui.Size trimmedSize(ui.Size size) {
    return ui.Size(
      size.width * (right - left),
      size.height * (bottom - top),
    );
  }
}

class PageBorderTrimmer {
  PageBorderTrimmer._();

  static const int _sampleWidth = 160;
  static const int _maxCached = 256;
  static const int _tolerance = 28;
  static const double _margin = 0.008;
  static const double _minKeptFraction = 0.55;

  static final LinkedHashMap<String, PageTrim> _cache =
      LinkedHashMap<String, PageTrim>();
  static final Map<String, Future<PageTrim>> _pending =
      <String, Future<PageTrim>>{};

  static PageTrim? cached(String path) => _cache[path];

  static Future<PageTrim> trimFor(String path, ui.Image image) {
    final PageTrim? known = _cache[path];
    if (known != null) {
      return Future<PageTrim>.value(known);
    }
    return _pending.putIfAbsent(path, () async {
      try {
        final PageTrim trim = await _analyze(image);
        _remember(path, trim);
        return trim;
      } catch (_) {
        return PageTrim.none;
      } finally {
        unawaited(_pending.remove(path));
      }
    });
  }

  static void _remember(String path, PageTrim trim) {
    _cache.remove(path);
    _cache[path] = trim;
    while (_cache.length > _maxCached) {
      _cache.remove(_cache.keys.first);
    }
  }

  static Future<PageTrim> _analyze(ui.Image image) async {
    final int width = min(_sampleWidth, image.width);
    final int height = max(1, (image.height * width / image.width).round());
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final ui.Canvas canvas = ui.Canvas(recorder);
    canvas.drawImageRect(
      image,
      ui.Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      ui.Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()),
      ui.Paint()..filterQuality = ui.FilterQuality.low,
    );
    final ui.Image sample =
        await recorder.endRecording().toImage(width, height);
    try {
      final ByteData? data =
          await sample.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (data == null) {
        return PageTrim.none;
      }
      return computeTrim(data.buffer.asUint8List(), width, height);
    } finally {
      sample.dispose();
    }
  }

  static PageTrim computeTrim(Uint8List rgba, int width, int height) {
    final int? background = _uniformBackground(rgba, width, height);
    if (background == null) {
      return PageTrim.none;
    }
    bool rowBlank(int y) {
      for (int x = 0; x < width; x++) {
        if (!_near(rgba, (y * width + x) * 4, background)) {
          return false;
        }
      }
      return true;
    }

    bool columnBlank(int x, int top, int bottom) {
      for (int y = top; y <= bottom; y++) {
        if (!_near(rgba, (y * width + x) * 4, background)) {
          return false;
        }
      }
      return true;
    }

    int top = 0;
    while (top < height && rowBlank(top)) {
      top++;
    }
    if (top >= height) {
      return PageTrim.none;
    }
    int bottom = height - 1;
    while (bottom > top && rowBlank(bottom)) {
      bottom--;
    }
    int left = 0;
    while (left < width && columnBlank(left, top, bottom)) {
      left++;
    }
    int right = width - 1;
    while (right > left && columnBlank(right, top, bottom)) {
      right--;
    }
    final PageTrim trim = PageTrim(
      max(0.0, left / width - _margin),
      max(0.0, top / height - _margin),
      min(1.0, (right + 1) / width + _margin),
      min(1.0, (bottom + 1) / height + _margin),
    );
    final double kept = (trim.right - trim.left) * (trim.bottom - trim.top);
    if (kept < _minKeptFraction) {
      return PageTrim.none;
    }
    return trim;
  }

  static int? _uniformBackground(Uint8List rgba, int width, int height) {
    final List<int> corners = <int>[
      0,
      (width - 1) * 4,
      ((height - 1) * width) * 4,
      ((height - 1) * width + width - 1) * 4,
    ];
    final int reference = _luma(rgba, corners.first);
    for (final int offset in corners) {
      if ((_luma(rgba, offset) - reference).abs() > _tolerance) {
        return null;
      }
    }
    final bool white = reference >= 215;
    final bool black = reference <= 40;
    if (!white && !black) {
      return null;
    }
    return reference;
  }

  static int _luma(Uint8List rgba, int offset) {
    return (rgba[offset] * 299 + rgba[offset + 1] * 587 + rgba[offset + 2] * 114) ~/
        1000;
  }

  static bool _near(Uint8List rgba, int offset, int background) {
    return (_luma(rgba, offset) - background).abs() <= _tolerance;
  }
}
