import 'dart:ui';

class TranslatedBubble {
  const TranslatedBubble({
    required this.textBox,
    required this.layoutBox,
    required this.fillColor,
    required this.erase,
    required this.source,
    required this.translation,
  });

  final Rect textBox;
  final Rect layoutBox;
  final int fillColor;
  final bool erase;
  final String source;
  final String translation;

  TranslatedBubble copyWith({String? source, String? translation}) {
    return TranslatedBubble(
      textBox: textBox,
      layoutBox: layoutBox,
      fillColor: fillColor,
      erase: erase,
      source: source ?? this.source,
      translation: translation ?? this.translation,
    );
  }

  factory TranslatedBubble.fromJson(Map<String, dynamic> json) {
    return TranslatedBubble(
      textBox: _rectFromJson(json['textBox'] as List<dynamic>),
      layoutBox: _rectFromJson(json['layoutBox'] as List<dynamic>),
      fillColor: json['fillColor'] as int,
      erase: json['erase'] as bool,
      source: json['source'] as String,
      translation: json['translation'] as String,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'textBox': _rectToJson(textBox),
    'layoutBox': _rectToJson(layoutBox),
    'fillColor': fillColor,
    'erase': erase,
    'source': source,
    'translation': translation,
  };
}

class PageTranslationResult {
  const PageTranslationResult({
    required this.width,
    required this.height,
    required this.bubbles,
  });

  final int width;
  final int height;
  final List<TranslatedBubble> bubbles;

  factory PageTranslationResult.fromJson(Map<String, dynamic> json) {
    return PageTranslationResult(
      width: json['width'] as int,
      height: json['height'] as int,
      bubbles: (json['bubbles'] as List<dynamic>)
          .map(
            (dynamic bubble) =>
                TranslatedBubble.fromJson(bubble as Map<String, dynamic>),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'width': width,
    'height': height,
    'bubbles': bubbles
        .map((TranslatedBubble bubble) => bubble.toJson())
        .toList(),
  };
}

Rect _rectFromJson(List<dynamic> values) => Rect.fromLTRB(
  (values[0] as num).toDouble(),
  (values[1] as num).toDouble(),
  (values[2] as num).toDouble(),
  (values[3] as num).toDouble(),
);

List<double> _rectToJson(Rect rect) => <double>[
  rect.left,
  rect.top,
  rect.right,
  rect.bottom,
];
