import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/services/page_translation/translation_overlay_style.dart';
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_bubble_popup.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_bubble_sheet.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_typesetter.dart';

class TranslatedPage extends StatefulWidget {
  const TranslatedPage({
    super.key,
    required this.cubit,
    required this.path,
    required this.child,
  });

  final PageTranslationCubit? cubit;
  final String path;
  final Widget child;

  @override
  State<TranslatedPage> createState() => TranslatedPageState();
}

class TranslatedPageState extends State<TranslatedPage> {
  bool openBubbleAt(Offset globalPosition, {bool longPress = false}) {
    final PageTranslationCubit? translation = widget.cubit;
    final PageTranslationResult? result = _visibleResult();
    final RenderObject? renderObject = context.findRenderObject();
    if (translation == null ||
        result == null ||
        renderObject is! RenderBox ||
        !renderObject.attached) {
      return false;
    }

    final TranslationOverlayStyle style = context
        .read<PageTranslationSettingsCubit>()
        .state
        .overlay;
    final List<Rect> areas = bubbleScreenAreas(result, style, renderObject);
    final int? index = bubbleIndexAt(result, areas, globalPosition);
    if (kDebugMode) {
      logger.d(
        '[bubble-tap] ${widget.path.split('/').last} at '
        '(${globalPosition.dx.round()}, ${globalPosition.dy.round()}) '
        'bubble=$index of ${areas.length}',
      );
    }
    if (index == null) {
      return false;
    }

    if (longPress) {
      _openSheet(translation, result, index);
    } else {
      _openPopup(translation, result, index, areas[index]);
    }
    return true;
  }

  PageTranslationResult? _visibleResult() {
    final PageTranslationState? state = widget.cubit?.state;
    if (state == null || !state.active) {
      return null;
    }
    final PageTranslationResult? result = state.entry(widget.path)?.result;
    if (result == null || result.bubbles.isEmpty) {
      return null;
    }
    return result;
  }

  void _openPopup(
    PageTranslationCubit translation,
    PageTranslationResult result,
    int index,
    Rect screenArea,
  ) {
    showTranslationBubblePopup(
      context,
      bubbleArea: screenArea,
      bubble: result.bubbles[index],
      onRetranslate: (String source) =>
          translation.retranslateBubble(widget.path, index, source),
      onEdit: () => _openSheet(translation, result, index),
    );
  }

  void _openSheet(
    PageTranslationCubit translation,
    PageTranslationResult result,
    int index,
  ) {
    showTranslationBubbleSheet(
      context,
      bubble: result.bubbles[index],
      hidden: translation.state.isHidden(widget.path, index),
      onToggle: () => translation.toggleBubble(widget.path, index),
      onRetranslate: (String source) =>
          translation.retranslateBubble(widget.path, index, source),
    );
  }

  bool _shouldRebuild(
    PageTranslationState previous,
    PageTranslationState current,
  ) {
    return previous.active != current.active ||
        previous.entry(widget.path) != current.entry(widget.path) ||
        previous.hidden != current.hidden;
  }

  @override
  Widget build(BuildContext context) {
    final PageTranslationCubit? translation = widget.cubit;
    if (translation == null) {
      return widget.child;
    }

    return BlocBuilder<PageTranslationCubit, PageTranslationState>(
      bloc: translation,
      buildWhen: _shouldRebuild,
      builder: (BuildContext context, PageTranslationState state) {
        final PageTranslationResult? result = state.active
            ? state.entry(widget.path)?.result
            : null;
        if (result == null || result.bubbles.isEmpty) {
          return Stack(children: <Widget>[widget.child]);
        }

        final TranslationOverlayStyle style = context.select(
          (PageTranslationSettingsCubit settings) => settings.state.overlay,
        );
        final Set<int> hiddenBubbles = <int>{
          for (int i = 0; i < result.bubbles.length; i++)
            if (state.isHidden(widget.path, i)) i,
        };
        return Stack(
          children: <Widget>[
            widget.child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: TranslationOverlayPainter(
                      result: result,
                      hidden: hiddenBubbles,
                      style: style,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

const double _touchMargin = 14;

Rect bubbleTapArea(TranslatedBubble bubble, TranslationOverlayStyle style) {
  final Rect area = bubble.layoutBox.expandToInclude(bubble.textBox);
  final double overflow = max(0, style.textSize.scale - 1) / 2;
  return Rect.fromCenter(
    center: area.center,
    width: area.width * (1 + overflow * 2),
    height: area.height * (1 + overflow * 2),
  );
}

List<Rect> bubbleScreenAreas(
  PageTranslationResult result,
  TranslationOverlayStyle style,
  RenderBox page,
) {
  final double scaleX = page.size.width / result.width;
  final double scaleY = page.size.height / result.height;
  return <Rect>[
    for (final TranslatedBubble bubble in result.bubbles)
      _toScreen(
        scaleRect(bubbleTapArea(bubble, style), scaleX, scaleY),
        page,
      ).inflate(_touchMargin),
  ];
}

Rect _toScreen(Rect local, RenderBox page) {
  return Rect.fromPoints(
    page.localToGlobal(local.topLeft),
    page.localToGlobal(local.bottomRight),
  );
}

int? bubbleIndexAt(
  PageTranslationResult result,
  List<Rect> areas,
  Offset position,
) {
  double areaOf(int index) {
    final Rect box = result.bubbles[index].layoutBox;
    return box.width * box.height;
  }

  final List<int> smallestFirst = List<int>.generate(
    result.bubbles.length,
    (int index) => index,
  )..sort((int a, int b) => areaOf(a).compareTo(areaOf(b)));
  for (final int index in smallestFirst) {
    if (areas[index].contains(position)) {
      return index;
    }
  }
  return null;
}
