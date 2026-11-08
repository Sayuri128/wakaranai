import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const double _popupMaxWidth = 340;
const double _screenMargin = 12;
const double _bubbleGap = 8;

Future<void> showTranslationBubblePopup(
  BuildContext context, {
  required Rect bubbleArea,
  required TranslatedBubble bubble,
  required Future<String?> Function(String source) onRetranslate,
  required VoidCallback onEdit,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black.withValues(alpha: 0.25),
    transitionDuration: const Duration(milliseconds: 150),
    pageBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
        ) {
          return SafeArea(
            child: CustomSingleChildLayout(
              delegate: _NextToBubble(bubbleArea),
              child: _BubblePopup(
                bubble: bubble,
                onRetranslate: onRetranslate,
                onEdit: onEdit,
                messengerContext: context,
              ),
            ),
          );
        },
    transitionBuilder:
        (
          BuildContext dialogContext,
          Animation<double> animation,
          Animation<double> secondaryAnimation,
          Widget child,
        ) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1).animate(animation),
              child: child,
            ),
          );
        },
  );
}

class _NextToBubble extends SingleChildLayoutDelegate {
  _NextToBubble(this.bubbleArea);

  final Rect bubbleArea;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final double width = min(
      _popupMaxWidth,
      constraints.maxWidth - _screenMargin * 2,
    );
    return BoxConstraints(
      minWidth: width,
      maxWidth: width,
      maxHeight: constraints.maxHeight - _screenMargin * 2,
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final double left = (bubbleArea.center.dx - childSize.width / 2).clamp(
      _screenMargin,
      size.width - childSize.width - _screenMargin,
    );

    final double below = bubbleArea.bottom + _bubbleGap;
    final double above = bubbleArea.top - _bubbleGap - childSize.height;
    final bool fitsBelow =
        below + childSize.height <= size.height - _screenMargin;
    final bool fitsAbove = above >= _screenMargin;

    double top;
    if (fitsBelow) {
      top = below;
    } else if (fitsAbove) {
      top = above;
    } else {
      top = (size.height - childSize.height) / 2;
    }
    top = top.clamp(
      _screenMargin,
      max(_screenMargin, size.height - childSize.height - _screenMargin),
    );
    return Offset(left, top);
  }

  @override
  bool shouldRelayout(_NextToBubble oldDelegate) {
    return oldDelegate.bubbleArea != bubbleArea;
  }
}

class _BubblePopup extends StatefulWidget {
  const _BubblePopup({
    required this.bubble,
    required this.onRetranslate,
    required this.onEdit,
    required this.messengerContext,
  });

  final TranslatedBubble bubble;
  final Future<String?> Function(String source) onRetranslate;
  final VoidCallback onEdit;
  final BuildContext messengerContext;

  @override
  State<_BubblePopup> createState() => _BubblePopupState();
}

class _BubblePopupState extends State<_BubblePopup> {
  late String _translation = widget.bubble.translation;
  bool _retranslating = false;

  void _copy() {
    Clipboard.setData(ClipboardData(text: _translation));
    Navigator.of(context).pop();
    SnackBars.showSnackBar(
      context: widget.messengerContext,
      message: S.current.page_translation_copied,
    );
  }

  Future<void> _retranslate() async {
    if (_retranslating) {
      return;
    }
    setState(() => _retranslating = true);
    final String? translation = await widget.onRetranslate(
      widget.bubble.source,
    );
    if (!mounted) {
      return;
    }
    setState(() {
      _retranslating = false;
      _translation = translation ?? _translation;
    });
    if (translation == null) {
      SnackBars.showSnackBar(
        context: widget.messengerContext,
        message: S.current.page_translation_retranslate_failed,
      );
    }
  }

  void _edit() {
    Navigator.of(context).pop();
    widget.onEdit();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.dialogSurface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text(
                      widget.bubble.source,
                      style: regular(size: 13, color: AppColors.mainGrey),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Icon(
                        Icons.arrow_downward_rounded,
                        size: 16,
                        color: AppColors.mainGrey,
                      ),
                    ),
                    Text(_translation, style: medium(size: 16)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: <Widget>[
                Expanded(
                  child: _PopupAction(
                    icon: Icons.edit_rounded,
                    label: S.current.page_translation_edit,
                    onTap: _edit,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _PopupAction(
                    icon: Icons.copy_rounded,
                    label: S.current.page_translation_copy,
                    onTap: _copy,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _PopupAction(
                    icon: Icons.refresh_rounded,
                    label: S.current.page_translation_retranslate,
                    primary: true,
                    loading: _retranslating,
                    onTap: _retranslate,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PopupAction extends StatelessWidget {
  const _PopupAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.loading = false,
    this.primary = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool loading;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final Color foreground = primary
        ? AppColors.mainBlack
        : AppColors.mainWhite;
    return Material(
      color: primary ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: loading ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(width: 20, height: 20, child: _buildIcon(foreground)),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: semibold(size: 12, color: foreground),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(Color color) {
    if (loading) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: CircularProgressIndicator(strokeWidth: 2, color: color),
      );
    }
    return Icon(icon, size: 20, color: color);
  }
}
