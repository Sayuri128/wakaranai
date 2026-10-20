import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<bool> showTranslationModelsSheet(
  BuildContext context, {
  required TitleLanguages languages,
  required bool wifiOnly,
}) async {
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
              Text(
                S.current.page_translation_models_title,
                style: semibold(size: 18),
              ),
              const SizedBox(height: 10),
              Text(
                S.current.page_translation_models_message(
                  languages.source.name,
                  languages.target.name,
                ),
                style: regular(size: 14, color: AppColors.mainGrey),
              ),
              if (wifiOnly) ...<Widget>[
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
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.overlay(0.06),
                        foregroundColor: AppColors.mainWhite,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      child: Text(
                        S.current.page_translation_models_cancel,
                        style: semibold(size: 15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.mainBlack,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      child: Text(
                        S.current.page_translation_models_download,
                        style: semibold(size: 15, color: AppColors.mainBlack),
                      ),
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
