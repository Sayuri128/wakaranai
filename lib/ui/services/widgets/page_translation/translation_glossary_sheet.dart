import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/glossary.dart';
import 'package:wakaranai/services/page_translation/title_languages.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class GlossaryEdit {
  const GlossaryEdit({required this.glossary, required this.retranslate});

  final List<GlossaryEntry> glossary;
  final bool retranslate;
}

Future<GlossaryEdit?> showTranslationGlossarySheet(
  BuildContext context, {
  required TitleLanguages languages,
  required bool engineSupportsGlossary,
}) {
  return showModalBottomSheet<GlossaryEdit>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _GlossarySheet(
      languages: languages,
      engineSupportsGlossary: engineSupportsGlossary,
    ),
  );
}

class _EntryControllers {
  _EntryControllers(GlossaryEntry entry)
    : source = TextEditingController(text: entry.source),
      target = TextEditingController(text: entry.target);

  final TextEditingController source;
  final TextEditingController target;

  GlossaryEntry toEntry() {
    return GlossaryEntry(
      source: source.text.trim(),
      target: target.text.trim(),
    );
  }

  void dispose() {
    source.dispose();
    target.dispose();
  }
}

class _GlossarySheet extends StatefulWidget {
  const _GlossarySheet({
    required this.languages,
    required this.engineSupportsGlossary,
  });

  final TitleLanguages languages;
  final bool engineSupportsGlossary;

  @override
  State<_GlossarySheet> createState() => _GlossarySheetState();
}

class _GlossarySheetState extends State<_GlossarySheet> {
  late final List<_EntryControllers> _entries = <_EntryControllers>[
    for (final GlossaryEntry entry in widget.languages.glossary)
      _EntryControllers(entry),
  ];

  @override
  void initState() {
    super.initState();
    if (_entries.isEmpty) {
      _entries.add(_EntryControllers(_emptyEntry));
    }
  }

  static const GlossaryEntry _emptyEntry = GlossaryEntry(
    source: '',
    target: '',
  );

  @override
  void dispose() {
    for (final _EntryControllers entry in _entries) {
      entry.dispose();
    }
    super.dispose();
  }

  void _addEntry() {
    setState(() => _entries.add(_EntryControllers(_emptyEntry)));
  }

  void _removeEntry(int index) {
    setState(() => _entries.removeAt(index).dispose());
  }

  void _finish({required bool retranslate}) {
    final List<GlossaryEntry> glossary = <GlossaryEntry>[
      for (final _EntryControllers controllers in _entries)
        if (controllers.toEntry().isComplete) controllers.toEntry(),
    ];
    Navigator.of(
      context,
    ).pop(GlossaryEdit(glossary: glossary, retranslate: retranslate));
  }

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.85;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: maxHeight),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _buildHandle(),
                Text(
                  S.current.page_translation_glossary_title,
                  style: semibold(size: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.engineSupportsGlossary
                      ? S.current.page_translation_glossary_subtitle
                      : S.current.page_translation_glossary_unsupported,
                  style: regular(
                    size: 13,
                    color: widget.engineSupportsGlossary
                        ? AppColors.mainGrey
                        : AppColors.red,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(child: _buildEntryList()),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                    onPressed: _addEntry,
                    icon: const Icon(Icons.add_rounded),
                    label: Text(S.current.page_translation_glossary_add),
                  ),
                ),
                const SizedBox(height: 8),
                _buildActions(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(top: 12, bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.overlay(0.18),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildEntryList() {
    return ListView.separated(
      shrinkWrap: true,
      itemCount: _entries.length,
      separatorBuilder: (BuildContext context, int index) =>
          const SizedBox(height: 8),
      itemBuilder: (BuildContext context, int index) {
        final _EntryControllers entry = _entries[index];
        return Row(
          children: <Widget>[
            Expanded(
              child: _GlossaryField(
                controller: entry.source,
                hint: widget.languages.source.name,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: AppColors.mainGrey,
              ),
            ),
            Expanded(
              child: _GlossaryField(
                controller: entry.target,
                hint: widget.languages.target.name,
              ),
            ),
            IconButton(
              icon: Icon(Icons.close_rounded, color: AppColors.mainGrey),
              onPressed: () => _removeEntry(index),
            ),
          ],
        );
      },
    );
  }

  Widget _buildActions() {
    return Row(
      children: <Widget>[
        Expanded(
          child: _ActionButton(
            label: S.current.page_translation_glossary_save_retranslate,
            onTap: () => _finish(retranslate: true),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _ActionButton(
            label: S.current.page_translation_glossary_save,
            primary: true,
            onTap: () => _finish(retranslate: false),
          ),
        ),
      ],
    );
  }
}

class _GlossaryField extends StatelessWidget {
  const _GlossaryField({required this.controller, required this.hint});

  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: regular(size: 14),
        cursorColor: AppColors.primary,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(
          isDense: true,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          hintText: hint,
          hintStyle: regular(size: 14, color: AppColors.mainGrey),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.onTap,
    this.primary = false,
  });

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
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: semibold(size: 14, color: foreground),
          ),
        ),
      ),
    );
  }
}
