import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/widgets/outlined_text_form_field.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<String?> showDebugStreamUrlDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (BuildContext dialogContext) => const DebugStreamUrlDialog(),
  );
}

class DebugStreamUrlDialog extends StatefulWidget {
  const DebugStreamUrlDialog({super.key});

  @override
  State<DebugStreamUrlDialog> createState() => _DebugStreamUrlDialogState();
}

class _DebugStreamUrlDialogState extends State<DebugStreamUrlDialog> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _submit() {
    final String url = _urlController.text.trim();
    if (url.isEmpty) {
      return;
    }
    Navigator.of(context).pop(url);
  }

  @override
  Widget build(BuildContext context) {
    final S strings = S.of(context);
    return Dialog(
      backgroundColor: AppColors.dialogSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              strings.native_player_debug_url_title,
              style: semibold(size: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedTextFormField(
              controller: _urlController,
              title: strings.native_player_debug_url_label,
              hint: strings.native_player_debug_url_hint,
            ),
            const SizedBox(height: 20),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildButton(
                    label: strings.common_cancel,
                    background: AppColors.overlay(0.06),
                    foreground: AppColors.mainWhite,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildButton(
                    label: strings.native_player_debug_play,
                    background: AppColors.primary,
                    foreground: AppColors.mainBlack,
                    onPressed: _submit,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required Color background,
    required Color foreground,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 48,
      child: TextButton(
        style: TextButton.styleFrom(
          backgroundColor: background,
          foregroundColor: foreground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(label, style: semibold(size: 15, color: foreground)),
      ),
    );
  }
}
