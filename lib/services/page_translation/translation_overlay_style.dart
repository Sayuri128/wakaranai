import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:equatable/equatable.dart';

enum TranslationTextSize {
  small('small', 0.85),
  normal('normal', 1),
  large('large', 1.15);

  const TranslationTextSize(this.id, this.scale);

  final String id;
  final double scale;

  static TranslationTextSize byId(String? id) {
    return values.firstWhereOrNull(
          (TranslationTextSize size) => size.id == id,
        ) ??
        normal;
  }
}

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
    this.textSize = TranslationTextSize.normal,
    this.font = TranslationFont.system,
    this.labelOpacity = defaultLabelOpacity,
  });

  static const double defaultLabelOpacity = 0.9;
  static const double minLabelOpacity = 0.5;
  static const double maxLabelOpacity = 1;

  final TranslationTextSize textSize;
  final TranslationFont font;
  final double labelOpacity;

  TranslationOverlayStyle copyWith({
    TranslationTextSize? textSize,
    TranslationFont? font,
    double? labelOpacity,
  }) {
    return TranslationOverlayStyle(
      textSize: textSize ?? this.textSize,
      font: font ?? this.font,
      labelOpacity: labelOpacity ?? this.labelOpacity,
    );
  }

  @override
  List<Object?> get props => <Object?>[textSize, font, labelOpacity];
}
