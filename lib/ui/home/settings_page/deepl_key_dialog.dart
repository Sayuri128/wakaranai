import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

const String _deepLSignUpUrl = 'https://www.deepl.com/pro-api';

Future<bool> showDeepLKeyDialog(BuildContext context) async {
  final String? currentKey = await DeepLApiKeyStore.read();
  if (!context.mounted) {
    return false;
  }
  final bool? saved = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) =>
        _DeepLKeyDialog(currentKey: currentKey),
  );
  return saved ?? false;
}

class _DeepLKeyDialog extends StatefulWidget {
  const _DeepLKeyDialog({required this.currentKey});

  final String? currentKey;

  @override
  State<_DeepLKeyDialog> createState() => _DeepLKeyDialogState();
}

class _DeepLKeyDialogState extends State<_DeepLKeyDialog> {
  late final TextEditingController _key = TextEditingController(
    text: widget.currentKey ?? '',
  );
  bool _checking = false;
  String? _error;

  @override
  void dispose() {
    _key.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final String apiKey = _key.text.trim();
    if (apiKey.isEmpty || _checking) {
      return;
    }
    setState(() {
      _checking = true;
      _error = null;
    });
    final String? error = await _validate(apiKey);
    if (!mounted) {
      return;
    }
    if (error != null) {
      setState(() {
        _checking = false;
        _error = error;
      });
      return;
    }
    await DeepLApiKeyStore.write(apiKey);
    if (mounted) {
      Navigator.of(context).pop(true);
    }
  }

  Future<String?> _validate(String apiKey) async {
    try {
      await DeepLClient(apiKey).usage();
      return null;
    } on DeepLException catch (e) {
      if (e.error == DeepLError.network) {
        return S.current.deepl_key_network;
      }
      return S.current.deepl_key_invalid;
    }
  }

  Future<void> _remove() async {
    await DeepLApiKeyStore.delete();
    if (mounted) {
      Navigator.of(context).pop(false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.dialogSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(S.current.deepl_key_title, style: semibold(size: 18)),
            const SizedBox(height: 8),
            Text(
              S.current.deepl_key_dialog_message,
              style: regular(size: 14, color: AppColors.mainGrey),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: EdgeInsets.zero,
                ),
                onPressed: () => launchUrl(
                  Uri.parse(_deepLSignUpUrl),
                  mode: LaunchMode.externalApplication,
                ),
                icon: const Icon(Icons.open_in_new_rounded, size: 16),
                label: Text(S.current.deepl_key_get),
              ),
            ),
            _buildKeyField(),
            if (_error != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(_error!, style: regular(size: 13, color: AppColors.red)),
            ],
            const SizedBox(height: 16),
            _buildButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildKeyField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: _key,
        autocorrect: false,
        enableSuggestions: false,
        style: regular(size: 14),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: S.current.deepl_key_hint,
          hintStyle: regular(size: 14, color: AppColors.mainGrey),
        ),
        onSubmitted: (_) => _save(),
      ),
    );
  }

  Widget _buildButtons() {
    return Row(
      children: <Widget>[
        if (widget.currentKey != null)
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.red),
            onPressed: _checking ? null : _remove,
            child: Text(S.current.deepl_key_remove),
          ),
        const Spacer(),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: AppColors.mainGrey),
          onPressed: _checking ? null : () => Navigator.of(context).pop(false),
          child: Text(S.current.deepl_key_cancel),
        ),
        const SizedBox(width: 8),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.mainBlack,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: _checking ? null : _save,
          child: _checking
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.mainBlack,
                  ),
                )
              : Text(S.current.deepl_key_save),
        ),
      ],
    );
  }
}
