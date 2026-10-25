import 'dart:math';

import 'package:flutter/material.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/translation_overlay_style.dart';

const double _lineHeight = 1.12;
const double _measureFontSize = 100;
const double _maxFontToWidthRatio = 0.6;
const int _fitSearchSteps = 9;
const double _overflowSlack = 0.5;
const double _lightFillLuminance = 0.4;
const Color _darkText = Color(0xFF111111);
const double _erasePadding = 2;
const double _eraseCornerRadius = 4;
const double _bubbleInset = 0.06;
const double _labelPadding = 0.3;

TextStyle _translationStyle(
  double fontSize,
  Color color,
  TranslationFont font,
) {
  return TextStyle(
    fontFamily: font.family,
    fontWeight: font.weight,
    fontSize: fontSize,
    height: _lineHeight,
    color: color,
  );
}

double _widestWordWidth(String text, Color color, TranslationFont font) {
  double widest = 0;
  for (final String word in text.split(RegExp(r'\s+'))) {
    if (word.isEmpty) {
      continue;
    }
    final TextPainter painter = TextPainter(
      text: TextSpan(
        text: word,
        style: _translationStyle(_measureFontSize, color, font),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    widest = max(widest, painter.width);
    painter.dispose();
  }
  return widest;
}

TextPainter fitTranslation(
  String text,
  Size area, {
  required Color color,
  TranslationOverlayStyle style = const TranslationOverlayStyle(),
  double minSize = 4,
}) {
  final double scale = style.textSize.scale;
  final TranslationFont font = style.font;
  final Size box = scale > 1 ? area * scale : area;

  TextPainter layoutAt(double fontSize) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: _translationStyle(fontSize, color, font),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: max(1, box.width));
  }

  bool fitsInBox(TextPainter painter) {
    if (painter.height > box.height) {
      return false;
    }
    return painter.computeLineMetrics().every(
      (LineMetrics line) => line.width <= box.width + _overflowSlack,
    );
  }

  final double widestWord = _widestWordWidth(text, color, font);
  final double largestUnbrokenSize = widestWord == 0
      ? double.infinity
      : box.width * _measureFontSize / widestWord;

  final double sizeCap = min(
    box.height / _lineHeight,
    box.width * _maxFontToWidthRatio,
  );
  double smallest = minSize;
  double largest = max(minSize, min(sizeCap, largestUnbrokenSize));

  TextPainter best = layoutAt(smallest);
  if (!fitsInBox(best) || smallest > largestUnbrokenSize) {
    return best;
  }
  for (int step = 0; step < _fitSearchSteps; step++) {
    final double middle = (smallest + largest) / 2;
    final TextPainter candidate = layoutAt(middle);
    if (middle <= largestUnbrokenSize && fitsInBox(candidate)) {
      best.dispose();
      best = candidate;
      smallest = middle;
    } else {
      candidate.dispose();
      largest = middle;
    }
  }

  if (scale >= 1) {
    return best;
  }
  best.dispose();
  return layoutAt(max(minSize, smallest * scale));
}

Color translationTextColor(Color fill) {
  if (fill.computeLuminance() > _lightFillLuminance) {
    return _darkText;
  }
  return Colors.white;
}

Rect scaleRect(Rect rect, double scaleX, double scaleY) => Rect.fromLTRB(
  rect.left * scaleX,
  rect.top * scaleY,
  rect.right * scaleX,
  rect.bottom * scaleY,
);

class TranslationOverlayPainter extends CustomPainter {
  TranslationOverlayPainter({
    required this.result,
    required this.hidden,
    this.style = const TranslationOverlayStyle(),
  });

  final PageTranslationResult result;
  final Set<int> hidden;
  final TranslationOverlayStyle style;

  @override
  void paint(Canvas canvas, Size size) {
    final double scaleX = size.width / result.width;
    final double scaleY = size.height / result.height;

    for (int i = 0; i < result.bubbles.length; i++) {
      final TranslatedBubble bubble = result.bubbles[i];
      if (hidden.contains(i) || bubble.translation.isEmpty) {
        continue;
      }

      final Rect textRect = scaleRect(bubble.textBox, scaleX, scaleY);
      final Rect layoutRect = scaleRect(bubble.layoutBox, scaleX, scaleY);
      if (bubble.erase) {
        _paintOverErasedText(canvas, bubble, textRect, layoutRect, scaleX);
      } else {
        _paintLabel(canvas, bubble, layoutRect);
      }
    }
  }

  void _paintOverErasedText(
    Canvas canvas,
    TranslatedBubble bubble,
    Rect textRect,
    Rect layoutRect,
    double scale,
  ) {
    final Color fill = Color(bubble.fillColor);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        textRect.inflate(_erasePadding * scale),
        Radius.circular(_eraseCornerRadius * scale),
      ),
      Paint()..color = fill,
    );

    final double inset =
        min(layoutRect.width, layoutRect.height) * _bubbleInset;
    final Rect textArea = layoutRect.deflate(inset);
    final TextPainter painter = fitTranslation(
      bubble.translation,
      textArea.size,
      color: translationTextColor(fill),
      style: style,
    );
    painter.paint(canvas, _centered(painter, textArea.center));
    painter.dispose();
  }

  void _paintLabel(Canvas canvas, TranslatedBubble bubble, Rect layoutRect) {
    final TextPainter painter = fitTranslation(
      bubble.translation,
      layoutRect.size,
      color: _darkText,
      style: style,
    );
    final double padding = painter.preferredLineHeight * _labelPadding;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: layoutRect.center,
          width: painter.width + padding * 2,
          height: painter.height + padding * 2,
        ),
        Radius.circular(padding),
      ),
      Paint()..color = Colors.white.withValues(alpha: style.labelOpacity),
    );
    painter.paint(canvas, _centered(painter, layoutRect.center));
    painter.dispose();
  }

  Offset _centered(TextPainter painter, Offset center) =>
      center - Offset(painter.width / 2, painter.height / 2);

  @override
  bool shouldRepaint(TranslationOverlayPainter oldDelegate) {
    if (!identical(oldDelegate.result, result) || oldDelegate.style != style) {
      return true;
    }
    return oldDelegate.hidden.length != hidden.length ||
        !oldDelegate.hidden.containsAll(hidden);
  }
}
