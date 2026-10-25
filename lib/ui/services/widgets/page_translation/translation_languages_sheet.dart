import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/page_language.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Widget _dragHandle() {
  return Center(
    child: Container(
      width: 40,
      height: 4,
      margin: const EdgeInsets.only(top: 12, bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.18),
        borderRadius: BorderRadius.circular(2),
      ),
    ),
  );
}

Future<PageLanguage?> showLanguagePicker(
  BuildContext context, {
  required String title,
  required List<PageLanguage> options,
  required PageLanguage current,
}) {
  return showModalBottomSheet<PageLanguage>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _dragHandle(),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: Text(title, style: semibold(size: 18)),
              ),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: <Widget>[
                    for (final PageLanguage language in options)
                      _LanguageOption(
                        language: language,
                        selected: language == current,
                        onTap: () => Navigator.of(sheetContext).pop(language),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      );
    },
  );
}

Future<TitleLanguages?> showTranslationLanguagesSheet(
  BuildContext context, {
  required TitleLanguages initial,
  required String confirmLabel,
}) {
  return showModalBottomSheet<TitleLanguages>(
    context: context,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _TranslationLanguagesSheet(
      initial: initial,
      confirmLabel: confirmLabel,
    ),
  );
}

class _TranslationLanguagesSheet extends StatefulWidget {
  const _TranslationLanguagesSheet({
    required this.initial,
    required this.confirmLabel,
  });

  final TitleLanguages initial;
  final String confirmLabel;

  @override
  State<_TranslationLanguagesSheet> createState() =>
      _TranslationLanguagesSheetState();
}

class _TranslationLanguagesSheetState
    extends State<_TranslationLanguagesSheet> {
  late PageLanguage _source = widget.initial.source;
  late PageLanguage _target = widget.initial.target;

  Future<void> _pickSource() async {
    final PageLanguage? picked = await showLanguagePicker(
      context,
      title: S.current.page_translation_languages_from,
      options: PageLanguage.sources,
      current: _source,
    );
    if (picked != null && mounted) {
      setState(() => _source = picked);
    }
  }

  Future<void> _pickTarget() async {
    final PageLanguage? picked = await showLanguagePicker(
      context,
      title: S.current.page_translation_languages_to,
      options: PageLanguage.targets,
      current: _target,
    );
    if (picked != null && mounted) {
      setState(() => _target = picked);
    }
  }

  void _confirm() {
    Navigator.of(
      context,
    ).pop(widget.initial.copyWith(source: _source, target: _target));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _dragHandle(),
            const SizedBox(height: 8),
            Text(
              S.current.page_translation_languages_title,
              style: semibold(size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              S.current.page_translation_languages_subtitle,
              style: regular(size: 13, color: AppColors.mainGrey),
            ),
            const SizedBox(height: 16),
            _LanguageRow(
              label: S.current.page_translation_languages_from,
              value: _source.name,
              onTap: _pickSource,
            ),
            const SizedBox(height: 8),
            _LanguageRow(
              label: S.current.page_translation_languages_to,
              value: _target.name,
              onTap: _pickTarget,
            ),
            const SizedBox(height: 20),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.mainBlack,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _confirm,
              child: Text(
                widget.confirmLabel,
                style: semibold(size: 15, color: AppColors.mainBlack),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  label,
                  style: medium(size: 14, color: AppColors.mainGrey),
                ),
              ),
              Text(value, style: semibold(size: 15)),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.language,
    required this.selected,
    required this.onTap,
  });

  final PageLanguage language;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: <Widget>[
            Expanded(
              child: Text(
                language.name,
                style: medium(
                  size: 15,
                  color: selected ? AppColors.primary : AppColors.mainWhite,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_rounded, color: AppColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
