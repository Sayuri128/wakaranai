import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

class BubbleLayout {
  const BubbleLayout({
    required this.textBox,
    required this.layoutBox,
    required this.fillColor,
    required this.erase,
  });

  final Rect textBox;
  final Rect layoutBox;
  final int fillColor;
  final bool erase;
}

class PagePixels {
  const PagePixels({
    required this.rgba,
    required this.width,
    required this.height,
  });

  final Uint8List rgba;
  final int width;
  final int height;
}

class BubbleAnalysisRequest {
  const BubbleAnalysisRequest({required this.pixels, required this.boxes});

  final PagePixels pixels;
  final List<Rect> boxes;
}

const int _colorTolerance = 48;
const double _backgroundShare = 0.85;
const int _borderGap = 4;
const double _maxGrowth = 1.5;
const double _openSideGrowth = 0.25;
const double _labelPadding = 0.04;
const double _borderLineShare = 0.6;

List<BubbleLayout> analyzeBubbles(BubbleAnalysisRequest request) {
  final _PageImage image = _PageImage(request.pixels);
  return request.boxes.map(image.analyze).toList();
}

bool hasBorderBetween(PagePixels pixels, Rect a, Rect b) {
  return _PageImage(pixels).hasBorderBetween(a, b);
}

typedef _Rgb = ({int red, int green, int blue});

const Point<int> _leftward = Point<int>(-1, 0);
const Point<int> _rightward = Point<int>(1, 0);
const Point<int> _upward = Point<int>(0, -1);
const Point<int> _downward = Point<int>(0, 1);

class _PageImage {
  _PageImage(this.pixels)
    : bounds = Rect.fromLTWH(
        0,
        0,
        pixels.width.toDouble(),
        pixels.height.toDouble(),
      );

  final PagePixels pixels;
  final Rect bounds;

  BubbleLayout analyze(Rect box) {
    final Rect text = box.intersect(bounds);
    if (text.width < 1 || text.height < 1) {
      return BubbleLayout(
        textBox: box,
        layoutBox: box,
        fillColor: 0xFFFFFFFF,
        erase: false,
      );
    }

    final List<_Rgb> border = _pixelsAround(
      text.inflate(_borderGap.toDouble()),
    );
    final _Rgb background = _medianColor(border);
    final int matching = border
        .where((_Rgb color) => _matches(color, background))
        .length;
    final bool insideBubble =
        border.isNotEmpty && matching >= border.length * _backgroundShare;

    if (!insideBubble) {
      final double padding = max(text.width, text.height) * _labelPadding;
      return BubbleLayout(
        textBox: text,
        layoutBox: text.inflate(padding).intersect(bounds),
        fillColor: _toArgb(background),
        erase: false,
      );
    }

    return BubbleLayout(
      textBox: text,
      layoutBox: _bubbleInterior(text, background),
      fillColor: _toArgb(background),
      erase: true,
    );
  }

  bool hasBorderBetween(Rect a, Rect b) {
    final bool overlapX = a.left < b.right && b.left < a.right;
    final bool overlapY = a.top < b.bottom && b.top < a.bottom;
    if (overlapX && overlapY) {
      return false;
    }
    if (!overlapX && !overlapY) {
      return true;
    }

    final _Rgb background = _medianColor(
      _pixelsAround(a.inflate(_borderGap.toDouble())),
    );
    if (overlapX) {
      return _hasHorizontalLine(_gapBetweenStacked(a, b), background);
    }
    return _hasVerticalLine(_gapBetweenSideBySide(a, b), background);
  }

  Rect _gapBetweenStacked(Rect a, Rect b) {
    final Rect upper = a.top < b.top ? a : b;
    final Rect lower = identical(upper, a) ? b : a;
    return Rect.fromLTRB(
      max(a.left, b.left),
      upper.bottom,
      min(a.right, b.right),
      lower.top,
    ).intersect(bounds);
  }

  Rect _gapBetweenSideBySide(Rect a, Rect b) {
    final Rect leftBox = a.left < b.left ? a : b;
    final Rect rightBox = identical(leftBox, a) ? b : a;
    return Rect.fromLTRB(
      leftBox.right,
      max(a.top, b.top),
      rightBox.left,
      min(a.bottom, b.bottom),
    ).intersect(bounds);
  }

  bool _hasHorizontalLine(Rect gap, _Rgb background) {
    for (int y = gap.top.floor(); y < gap.bottom; y++) {
      if (_isBorderLine(_row(y, gap), background)) {
        return true;
      }
    }
    return false;
  }

  bool _hasVerticalLine(Rect gap, _Rgb background) {
    for (int x = gap.left.floor(); x < gap.right; x++) {
      if (_isBorderLine(_column(x, gap), background)) {
        return true;
      }
    }
    return false;
  }

  List<_Rgb> _row(int y, Rect area) {
    return <_Rgb>[
      for (int x = area.left.floor(); x < area.right; x++) _pixel(x, y),
    ];
  }

  List<_Rgb> _column(int x, Rect area) {
    return <_Rgb>[
      for (int y = area.top.floor(); y < area.bottom; y++) _pixel(x, y),
    ];
  }

  bool _isBorderLine(List<_Rgb> line, _Rgb background) {
    if (line.isEmpty) {
      return false;
    }
    final int different = line
        .where((_Rgb color) => !_matches(color, background))
        .length;
    return different > line.length * _borderLineShare;
  }

  Rect _bubbleInterior(Rect text, _Rgb background) {
    final double longestSide = max(text.width, text.height);
    final int limit = (longestSide * _maxGrowth).round();
    final int openLimit = (longestSide * _openSideGrowth).round();

    int growth(List<Point<int>> starts, Point<int> step) {
      int smallest = limit;
      for (final Point<int> start in starts) {
        final int free = _freeDistance(start, step, background, limit);
        smallest = min(smallest, free);
      }
      if (smallest == limit) {
        return openLimit;
      }
      return smallest;
    }

    final int left = text.left.floor();
    final int right = text.right.ceil() - 1;
    final int top = text.top.floor();
    final int bottom = text.bottom.ceil() - 1;

    final List<int> rows = <int>[top, (top + bottom) ~/ 2, bottom];
    final int newLeft = left - growth(_pointsInColumn(left, rows), _leftward);
    final int newRight =
        right + growth(_pointsInColumn(right, rows), _rightward);

    final List<int> columns = <int>[newLeft, (left + right) ~/ 2, newRight];
    final int newTop = top - growth(_pointsInRow(top, columns), _upward);
    final int newBottom =
        bottom + growth(_pointsInRow(bottom, columns), _downward);

    final Rect interior = Rect.fromLTRB(
      newLeft.toDouble(),
      newTop.toDouble(),
      (newRight + 1).toDouble(),
      (newBottom + 1).toDouble(),
    );
    return interior.expandToInclude(text).intersect(bounds);
  }

  List<Point<int>> _pointsInColumn(int x, List<int> ys) {
    return <Point<int>>[for (final int y in ys) Point<int>(x, y)];
  }

  List<Point<int>> _pointsInRow(int y, List<int> xs) {
    return <Point<int>>[for (final int x in xs) Point<int>(x, y)];
  }

  int _freeDistance(
    Point<int> start,
    Point<int> step,
    _Rgb background,
    int limit,
  ) {
    for (int distance = 0; distance < limit; distance++) {
      final int x = start.x + step.x * (distance + 1);
      final int y = start.y + step.y * (distance + 1);
      if (x < 0 || y < 0 || x >= pixels.width || y >= pixels.height) {
        return distance;
      }
      final bool pastGap = distance >= _borderGap;
      if (pastGap && !_matches(_pixel(x, y), background)) {
        return distance;
      }
    }
    return limit;
  }

  List<_Rgb> _pixelsAround(Rect rect) {
    final Rect clamped = rect.intersect(bounds);
    final int left = clamped.left.floor();
    final int top = clamped.top.floor();
    final int right = min(pixels.width - 1, clamped.right.floor());
    final int bottom = min(pixels.height - 1, clamped.bottom.floor());
    if (right <= left || bottom <= top) {
      return const <_Rgb>[];
    }

    final List<_Rgb> samples = <_Rgb>[];
    for (int x = left; x <= right; x += 2) {
      samples.add(_pixel(x, top));
      samples.add(_pixel(x, bottom));
    }
    for (int y = top; y <= bottom; y += 2) {
      samples.add(_pixel(left, y));
      samples.add(_pixel(right, y));
    }
    return samples;
  }

  _Rgb _pixel(int x, int y) {
    final int offset = (y * pixels.width + x) * 4;
    return (
      red: pixels.rgba[offset],
      green: pixels.rgba[offset + 1],
      blue: pixels.rgba[offset + 2],
    );
  }
}

bool _matches(_Rgb a, _Rgb b) {
  return (a.red - b.red).abs() <= _colorTolerance &&
      (a.green - b.green).abs() <= _colorTolerance &&
      (a.blue - b.blue).abs() <= _colorTolerance;
}

_Rgb _medianColor(List<_Rgb> colors) {
  if (colors.isEmpty) {
    return (red: 255, green: 255, blue: 255);
  }

  int median(int Function(_Rgb color) channel) {
    final List<int> values = colors.map(channel).toList();
    values.sort();
    return values[values.length ~/ 2];
  }

  return (
    red: median((_Rgb color) => color.red),
    green: median((_Rgb color) => color.green),
    blue: median((_Rgb color) => color.blue),
  );
}

int _toArgb(_Rgb color) {
  return 0xFF000000 | (color.red << 16) | (color.green << 8) | color.blue;
}
