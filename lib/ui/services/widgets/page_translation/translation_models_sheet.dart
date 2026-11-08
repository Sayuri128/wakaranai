import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakaranai/services/page_translation/page_language_names.dart';

Future<bool> showTranslationModelsSheet(
  BuildContext context, {
  required TitleLanguages languages,
  required bool wifiOnly,
  OnDeviceModel? gemma,
}) async {
  final String title;
  final String message;
  if (gemma != null) {
    title = S.current.page_translation_ai_model_title;
    message = S.current.page_translation_ai_model_message(
      gemma.displayName,
      gemma.sizeLabel,
    );
  } else {
    title = S.current.page_translation_models_title;
    message = S.current.page_translation_models_message(
      pageLanguageName(languages.source),
      pageLanguageName(languages.target),
    );
  }
  final bool showWifiNote = wifiOnly && gemma == null;

  final bool? confirmed = await showModalBottomSheet<bool>(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
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
              Text(title, style: semibold(size: 18)),
              const SizedBox(height: 10),
              Text(
                message,
                style: regular(size: 14, color: AppColors.mainGrey),
              ),
              if (showWifiNote) ...<Widget>[
                const SizedBox(height: 8),
                Text(
                  S.current.page_translation_models_wifi_note,
                  style: regular(size: 12, color: AppColors.mainGrey),
                ),
              ],
              const SizedBox(height: 20),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _SheetActionButton(
                      label: S.current.page_translation_models_cancel,
                      background: AppColors.overlay(0.06),
                      foreground: AppColors.mainWhite,
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetActionButton(
                      label: S.current.page_translation_models_download,
                      background: AppColors.primary,
                      foreground: AppColors.mainBlack,
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
  return confirmed ?? false;
}

class _SheetActionButton extends StatelessWidget {
  const _SheetActionButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onPressed,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: background,
        foregroundColor: foreground,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onPressed,
      child: Text(label, style: semibold(size: 15, color: foreground)),
    );
  }
}
