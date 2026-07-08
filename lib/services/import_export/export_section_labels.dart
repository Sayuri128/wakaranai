import 'package:wakaranai/data/domain/import_export/export_bundle.dart';
import 'package:wakaranai/generated/l10n.dart';

String exportSectionTitle(ExportSection section) {
  switch (section) {
    case ExportSection.history:
      return S.current.export_section_history;
    case ExportSection.library:
      return S.current.export_section_library;
    case ExportSection.categories:
      return S.current.export_section_categories;
    case ExportSection.sources:
      return S.current.export_section_sources;
    case ExportSection.settings:
      return S.current.export_section_settings;
  }
}

String exportSectionSubtitle(ExportSection section) {
  switch (section) {
    case ExportSection.history:
      return S.current.export_section_history_subtitle;
    case ExportSection.library:
      return S.current.export_section_library_subtitle;
    case ExportSection.categories:
      return S.current.export_section_categories_subtitle;
    case ExportSection.sources:
      return S.current.export_section_sources_subtitle;
    case ExportSection.settings:
      return S.current.export_section_settings_subtitle;
  }
}
