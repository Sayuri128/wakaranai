import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_translation_result.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<void> showTranslationBubbleSheet(
  BuildContext context, {
  required TranslatedBubble bubble,
  required bool hidden,
  required VoidCallback onToggle,
  required Future<String?> Function(String source) onRetranslate,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _BubbleSheet(
      bubble: bubble,
      hidden: hidden,
      onToggle: onToggle,
      onRetranslate: onRetranslate,
    ),
  );
}

class _BubbleSheet extends StatefulWidget {
  const _BubbleSheet({
    required this.bubble,
    required this.hidden,
    required this.onToggle,
    required this.onRetranslate,
  });

  final TranslatedBubble bubble;
  final bool hidden;
  final VoidCallback onToggle;
  final Future<String?> Function(String source) onRetranslate;

  @override
  State<_BubbleSheet> createState() => _BubbleSheetState();
}

class _BubbleSheetState extends State<_BubbleSheet> {
  late final TextEditingController _source = TextEditingController(
    text: widget.bubble.source,
  );
  late String _translation = widget.bubble.translation;
  bool _retranslating = false;

  @override
  void dispose() {
    _source.dispose();
    super.dispose();
  }

  void _copyAndClose(String text) {
    Clipboard.setData(ClipboardData(text: text));
    Navigator.of(context).pop();
    SnackBars.showSnackBar(
      context: context,
      message: S.current.page_translation_copied,
    );
  }

  Future<void> _retranslate() async {
    final String source = _source.text.trim();
    if (source.isEmpty || _retranslating) {
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() => _retranslating = true);
    final String? translation = await widget.onRetranslate(source);
    if (!mounted) {
      return;
    }
    setState(() {
      _retranslating = false;
      _translation = translation ?? _translation;
    });
    if (translation == null) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.page_translation_retranslate_failed,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.overlay(0.18),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _TextBlock(
                label: S.current.page_translation_translation_label,
                text: _translation,
                emphasized: true,
              ),
              const SizedBox(height: 12),
              _buildSourceField(),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SheetButton(
                      icon: Icons.copy_rounded,
                      label: S.current.page_translation_copy_translation,
                      onTap: () => _copyAndClose(_translation),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SheetButton(
                      icon: Icons.copy_all_rounded,
                      label: S.current.page_translation_copy_original,
                      onTap: () => _copyAndClose(_source.text),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SheetButton(
                      icon: widget.hidden
                          ? Icons.translate_rounded
                          : Icons.visibility_rounded,
                      label: widget.hidden
                          ? S.current.page_translation_show_translation
                          : S.current.page_translation_show_original,
                      onTap: () {
                        widget.onToggle();
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SheetButton(
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
      ),
    );
  }

  Widget _buildSourceField() {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            S.current.page_translation_original_label,
            style: medium(size: 12, color: AppColors.mainGrey),
          ),
          TextField(
            controller: _source,
            minLines: 1,
            maxLines: 5,
            style: regular(size: 15),
            cursorColor: AppColors.primary,
            decoration: InputDecoration(
              isDense: true,
              border: InputBorder.none,
              helperText: S.current.page_translation_original_edit_hint,
              helperStyle: regular(size: 11, color: AppColors.mainGrey),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({
    required this.label,
    required this.text,
    this.emphasized = false,
  });

  final String label;
  final String text;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: medium(size: 12, color: AppColors.mainGrey)),
          const SizedBox(height: 6),
          SelectableText(
            text,
            style: emphasized ? medium(size: 16) : regular(size: 15),
          ),
        ],
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.primary = false,
    this.loading = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool primary;
  final bool loading;

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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (loading)
                SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              else
                Icon(icon, size: 18, color: foreground),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: semibold(size: 14, color: foreground),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
