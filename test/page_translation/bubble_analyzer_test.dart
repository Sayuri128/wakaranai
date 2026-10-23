import 'dart:typed_data';
import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:wakaranai/services/page_translation/bubble_analyzer.dart';

class _Canvas {
  _Canvas(this.width, this.height) : rgba = Uint8List(width * height * 4);

  final int width;
  final int height;
  final Uint8List rgba;

  PagePixels get pixels => PagePixels(rgba: rgba, width: width, height: height);

  void set(int x, int y, int value) {
    final int offset = (y * width + x) * 4;
    rgba[offset] = value;
    rgba[offset + 1] = value;
    rgba[offset + 2] = value;
    rgba[offset + 3] = 255;
  }

  void fill(int Function(int x, int y) value) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        set(x, y, value(x, y));
      }
    }
  }

  void ellipse(
    Offset center,
    double radiusX,
    double radiusY,
    int inside,
    int outline,
  ) {
    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final double dx = (x - center.dx) / radiusX;
        final double dy = (y - center.dy) / radiusY;
        final double distance = dx * dx + dy * dy;
        if (distance <= 1) {
          set(x, y, inside);
        }
        if (distance > 0.9 && distance <= 1.1) {
          set(x, y, outline);
        }
      }
    }
  }

  void glyphs(Rect area) {
    for (int y = area.top.toInt(); y < area.bottom; y++) {
      for (int x = area.left.toInt(); x < area.right; x++) {
        if ((x ~/ 4).isEven && (y ~/ 6).isEven) {
          set(x, y, 0);
        }
      }
    }
  }
}

int _noise(int x, int y) {
  final bool dark = (x * 7 + y * 13) % 5 < 2;
  return dark ? 30 : 210;
}

void main() {
  test('text in a white bubble is erased and laid out across the bubble', () {
    final _Canvas canvas = _Canvas(400, 400);
    canvas.fill(_noise);
    canvas.ellipse(const Offset(200, 200), 140, 100, 255, 0);
    const Rect text = Rect.fromLTRB(170, 150, 230, 250);
    canvas.glyphs(text);

    final List<BubbleLayout> layouts = analyzeBubbles(
      BubbleAnalysisRequest(pixels: canvas.pixels, boxes: <Rect>[text]),
    );

    final BubbleLayout layout = layouts.single;
    expect(layout.erase, isTrue);
    expect(layout.fillColor & 0xFFFFFF, 0xFFFFFF);
    expect(layout.layoutBox.width, greaterThan(text.width * 2));
    expect(layout.layoutBox.left, greaterThan(200 - 140));
    expect(layout.layoutBox.right, lessThan(200 + 140));
    expect(layout.layoutBox.top, greaterThan(200 - 100));
    expect(layout.layoutBox.bottom, lessThan(200 + 100));
    expect(layout.layoutBox.contains(text.center), isTrue);
    for (final Offset corner in <Offset>[
      layout.layoutBox.topLeft,
      layout.layoutBox.topRight,
      layout.layoutBox.bottomLeft,
      layout.layoutBox.bottomRight,
    ]) {
      final double dx = (corner.dx - 200) / 140;
      final double dy = (corner.dy - 200) / 100;
      expect(dx * dx + dy * dy, lessThanOrEqualTo(1.0));
    }
  });

  test('text over busy artwork is not erased', () {
    final _Canvas canvas = _Canvas(300, 300);
    canvas.fill(_noise);
    const Rect text = Rect.fromLTRB(100, 100, 200, 140);
    canvas.glyphs(text);

    final BubbleLayout layout = analyzeBubbles(
      BubbleAnalysisRequest(pixels: canvas.pixels, boxes: <Rect>[text]),
    ).single;

    expect(layout.erase, isFalse);
    expect(layout.layoutBox.contains(text.center), isTrue);
  });

  test('text on an open white page does not spread over the whole page', () {
    final _Canvas canvas = _Canvas(600, 600);
    canvas.fill((int x, int y) => 255);
    const Rect text = Rect.fromLTRB(280, 280, 320, 330);
    canvas.glyphs(text);

    final BubbleLayout layout = analyzeBubbles(
      BubbleAnalysisRequest(pixels: canvas.pixels, boxes: <Rect>[text]),
    ).single;

    expect(layout.erase, isTrue);
    expect(layout.layoutBox.width, lessThan(text.width * 2));
    expect(layout.layoutBox.height, lessThan(text.height * 2));
  });

  test('an outline between two bubbles separates their text', () {
    final _Canvas canvas = _Canvas(300, 400);
    canvas.fill((int x, int y) => 255);
    canvas.ellipse(const Offset(150, 100), 110, 80, 255, 0);
    canvas.ellipse(const Offset(150, 290), 110, 80, 255, 0);
    const Rect upper = Rect.fromLTRB(110, 120, 190, 150);
    const Rect lower = Rect.fromLTRB(110, 235, 190, 265);
    const Rect sameBubble = Rect.fromLTRB(110, 80, 190, 110);

    expect(hasBorderBetween(canvas.pixels, upper, lower), isTrue);
    expect(hasBorderBetween(canvas.pixels, sameBubble, upper), isFalse);
  });
}
