import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/image_saver/image_saver.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

/// Shows a themed action sheet offering to save the given image. Trigger it
/// from an image's long-press handler.
Future<void> showSaveImageSheet(
  BuildContext context, {
  required String url,
  Map<String, String> headers = const <String, String>{},
}) {
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                decoration: BoxDecoration(
                  color: AppColors.overlay(0.18),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
              child: Text(
                S.current.save_image_sheet_title,
                style: semibold(size: 18),
              ),
            ),
            _SaveOption(
              icon: Icons.save_alt_rounded,
              label: S.current.save_image_save_button,
              onTap: () {
                Navigator.of(sheetContext).pop();
                ImageSaver.save(context, url: url, headers: headers);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

class _SaveOption extends StatelessWidget {
  const _SaveOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: <Widget>[
            Icon(icon, color: AppColors.mainWhite, size: 22),
            const SizedBox(width: 14),
            Text(label, style: medium(size: 15)),
          ],
        ),
      ),
    );
  }
}
