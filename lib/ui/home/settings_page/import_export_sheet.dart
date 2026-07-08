import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/import_export/export_section_labels.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

Future<Set<ExportSection>?> showImportExportSheet(
  BuildContext context, {
  required Set<ExportSection> available,
  required String title,
  required String confirmLabel,
}) {
  return showModalBottomSheet<Set<ExportSection>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) => _ImportExportSheet(
      available: available,
      title: title,
      confirmLabel: confirmLabel,
    ),
  );
}

IconData _sectionIcon(ExportSection section) {
  switch (section) {
    case ExportSection.history:
      return Icons.history_rounded;
    case ExportSection.library:
      return Icons.collections_bookmark_rounded;
    case ExportSection.categories:
      return Icons.folder_outlined;
    case ExportSection.sources:
      return Icons.extension_rounded;
    case ExportSection.settings:
      return Icons.settings_rounded;
  }
}

class _ImportExportSheet extends StatefulWidget {
  const _ImportExportSheet({
    required this.available,
    required this.title,
    required this.confirmLabel,
  });

  final Set<ExportSection> available;
  final String title;
  final String confirmLabel;

  @override
  State<_ImportExportSheet> createState() => _ImportExportSheetState();
}

class _ImportExportSheetState extends State<_ImportExportSheet> {
  late final List<ExportSection> _sections = ExportSection.values
      .where((ExportSection s) => widget.available.contains(s))
      .toList();

  late Set<ExportSection> _selected = <ExportSection>{..._sections};

  bool get _allSelected => _selected.length == _sections.length;

  void _toggle(ExportSection section) {
    setState(() {
      if (_selected.contains(section)) {
        _selected.remove(section);
      } else {
        _selected.add(section);
      }
    });
  }

  void _toggleAll() {
    setState(() {
      _selected = _allSelected ? <ExportSection>{} : <ExportSection>{..._sections};
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.overlay(0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(widget.title, style: semibold(size: 18)),
                  ),
                  TextButton(
                    onPressed: _toggleAll,
                    child: Text(
                      S.current.settings_export_select_all,
                      style: medium(
                        size: 13,
                        color: _allSelected
                            ? AppColors.primary
                            : AppColors.mainGrey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _sections.length,
                itemBuilder: (BuildContext context, int index) {
                  final ExportSection section = _sections[index];
                  return _SectionRow(
                    section: section,
                    selected: _selected.contains(section),
                    onTap: () => _toggle(section),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.mainBlack,
                    disabledBackgroundColor: AppColors.overlay(0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: _selected.isEmpty
                      ? null
                      : () => Navigator.of(context).pop(_selected),
                  child: Text(
                    widget.confirmLabel,
                    style: semibold(
                      size: 15,
                      color: _selected.isEmpty
                          ? AppColors.mainGrey
                          : AppColors.mainBlack,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({
    required this.section,
    required this.selected,
    required this.onTap,
  });

  final ExportSection section;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? AppColors.primary.withValues(alpha: 0.14)
            : AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Icon(
                  _sectionIcon(section),
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.mainGrey,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        exportSectionTitle(section),
                        style: medium(
                          size: 15,
                          color: selected
                              ? AppColors.primary
                              : AppColors.mainWhite,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exportSectionSubtitle(section),
                        style: regular(size: 12, color: AppColors.mainGrey),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.circle_outlined,
                  size: 22,
                  color: selected ? AppColors.primary : AppColors.mainGrey,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
