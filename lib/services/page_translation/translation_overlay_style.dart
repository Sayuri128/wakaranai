import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum TranslationFont {
  system('system', null, FontWeight.w600),
  comic('comic', 'Pangolin', FontWeight.w400);

  const TranslationFont(this.id, this.family, this.weight);

  final String id;
  final String? family;
  final FontWeight weight;

  static TranslationFont byId(String? id) {
    return values.firstWhereOrNull((TranslationFont font) => font.id == id) ??
        system;
  }
}

class TranslationOverlayStyle extends Equatable {
  const TranslationOverlayStyle({
    this.maxTextPixels,
    this.font = TranslationFont.system,
    this.labelOpacity = defaultLabelOpacity,
  });

  static const double minTextPixelsLimit = 8;
  static const double maxTextPixelsLimit = 32;
  static const double defaultLabelOpacity = 0.9;
  static const double minLabelOpacity = 0.5;
  static const double maxLabelOpacity = 1;

  final double? maxTextPixels;
  final TranslationFont font;
  final double labelOpacity;

  TranslationOverlayStyle copyWith({
    TranslationFont? font,
    double? labelOpacity,
  }) {
    return TranslationOverlayStyle(
      maxTextPixels: maxTextPixels,
      font: font ?? this.font,
      labelOpacity: labelOpacity ?? this.labelOpacity,
    );
  }

  TranslationOverlayStyle withMaxTextPixels(double? pixels) {
    return TranslationOverlayStyle(
      maxTextPixels: pixels,
      font: font,
      labelOpacity: labelOpacity,
    );
  }

  @override
  List<Object?> get props => <Object?>[maxTextPixels, font, labelOpacity];
}
