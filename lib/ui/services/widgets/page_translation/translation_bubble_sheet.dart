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
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      void copyAndClose(String text) {
        Clipboard.setData(ClipboardData(text: text));
        Navigator.of(sheetContext).pop();
        SnackBars.showSnackBar(
          context: context,
          message: S.current.page_translation_copied,
        );
      }

      return SafeArea(
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
                text: bubble.translation,
                emphasized: true,
              ),
              const SizedBox(height: 12),
              _TextBlock(
                label: S.current.page_translation_original_label,
                text: bubble.source,
              ),
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SheetButton(
                      icon: Icons.copy_rounded,
                      label: S.current.page_translation_copy_translation,
                      onTap: () => copyAndClose(bubble.translation),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SheetButton(
                      icon: Icons.copy_all_rounded,
                      label: S.current.page_translation_copy_original,
                      onTap: () => copyAndClose(bubble.source),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _SheetButton(
                icon: hidden
                    ? Icons.translate_rounded
                    : Icons.visibility_rounded,
                label: hidden
                    ? S.current.page_translation_show_translation
                    : S.current.page_translation_show_original,
                primary: true,
                onTap: () {
                  onToggle();
                  Navigator.of(sheetContext).pop();
                },
              ),
            ],
          ),
        ),
      );
    },
  );
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
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
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
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
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
