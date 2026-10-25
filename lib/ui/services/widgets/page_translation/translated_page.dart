import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/ui/services/cubits/page_translation/page_translation_cubit.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_bubble_popup.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_bubble_sheet.dart';
import 'package:wakaranai/ui/services/widgets/page_translation/translation_typesetter.dart';

class TranslatedPage extends StatelessWidget {
  const TranslatedPage({
    super.key,
    required this.cubit,
    required this.path,
    required this.child,
  });

  final PageTranslationCubit? cubit;
  final String path;
  final Widget child;

  bool _shouldRebuild(
    PageTranslationState previous,
    PageTranslationState current,
  ) {
    return previous.active != current.active ||
        previous.entry(path) != current.entry(path) ||
        previous.hidden != current.hidden;
  }

  @override
  Widget build(BuildContext context) {
    final PageTranslationCubit? translation = cubit;
    if (translation == null) {
      return child;
    }

    return BlocBuilder<PageTranslationCubit, PageTranslationState>(
      bloc: translation,
      buildWhen: _shouldRebuild,
      builder: (BuildContext context, PageTranslationState state) {
        final PageTranslationResult? result = state.active
            ? state.entry(path)?.result
            : null;
        if (result == null || result.bubbles.isEmpty) {
          return Stack(children: <Widget>[child]);
        }

        final Set<int> hiddenBubbles = <int>{
          for (int i = 0; i < result.bubbles.length; i++)
            if (state.isHidden(path, i)) i,
        };
        return Stack(
          children: <Widget>[
            child,
            Positioned.fill(
              child: IgnorePointer(
                child: RepaintBoundary(
                  child: CustomPaint(
                    painter: TranslationOverlayPainter(
                      result: result,
                      hidden: hiddenBubbles,
                      style: context.select(
                        (PageTranslationSettingsCubit settings) =>
                            settings.state.overlay,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: _BubbleTapTargets(
                result: result,
                hiddenBubbles: hiddenBubbles,
                onToggle: (int index) => translation.toggleBubble(path, index),
                onRetranslate: (int index, String source) =>
                    translation.retranslateBubble(path, index, source),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BubbleTapTargets extends StatelessWidget {
  const _BubbleTapTargets({
    required this.result,
    required this.hiddenBubbles,
    required this.onToggle,
    required this.onRetranslate,
  });

  final PageTranslationResult result;
  final Set<int> hiddenBubbles;
  final ValueChanged<int> onToggle;
  final Future<String?> Function(int index, String source) onRetranslate;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double scaleX = constraints.maxWidth / result.width;
        final double scaleY = constraints.maxHeight / result.height;
        return Stack(
          children: <Widget>[
            for (int i = 0; i < result.bubbles.length; i++)
              _buildTarget(context, i, scaleX, scaleY),
          ],
        );
      },
    );
  }

  Widget _buildTarget(
    BuildContext context,
    int index,
    double scaleX,
    double scaleY,
  ) {
    final TranslatedBubble bubble = result.bubbles[index];
    final Rect bubbleArea = bubble.layoutBox.expandToInclude(bubble.textBox);
    void openSheet() {
      showTranslationBubbleSheet(
        context,
        bubble: bubble,
        hidden: hiddenBubbles.contains(index),
        onToggle: () => onToggle(index),
        onRetranslate: (String source) => onRetranslate(index, source),
      );
    }

    return Positioned.fromRect(
      rect: scaleRect(bubbleArea, scaleX, scaleY),
      child: Builder(
        builder: (BuildContext targetContext) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => showTranslationBubblePopup(
              context,
              bubbleArea: _globalRect(targetContext),
              bubble: bubble,
              onRetranslate: (String source) => onRetranslate(index, source),
              onEdit: openSheet,
            ),
            onLongPress: openSheet,
          );
        },
      ),
    );
  }

  Rect _globalRect(BuildContext targetContext) {
    final RenderBox box = targetContext.findRenderObject()! as RenderBox;
    return box.localToGlobal(Offset.zero) & box.size;
  }
}
