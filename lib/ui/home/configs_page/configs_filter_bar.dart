import 'dart:async';

import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_page/configs_filter.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigsFilterBar extends StatelessWidget {
  const ConfigsFilterBar({
    super.key,
    required this.kinds,
    required this.languages,
    required this.pricings,
    required this.sourceTypes,
    required this.filter,
    required this.onChanged,
  });

  final List<String> kinds;
  final List<String> languages;
  final List<String> pricings;
  final List<String> sourceTypes;
  final ConfigsFilter filter;
  final ValueChanged<ConfigsFilter> onChanged;

  bool get isUseful =>
      kinds.length > 1 ||
      languages.length > 1 ||
      pricings.length > 1 ||
      sourceTypes.length > 1;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        children: <Widget>[
          if (languages.length > 1) ...<Widget>[
            _Pill(
              icon: Icons.translate_rounded,
              label: filter.language ?? S.of(context).configs_filter_all_languages,
              selected: filter.language != null,
              trailingIcon: Icons.arrow_drop_down_rounded,
              onTap: () => _pickLanguage(context),
            ),
            const SizedBox(width: 8),
          ],
          if (sourceTypes.length > 1) ...<Widget>[
            _Pill(
              icon: Icons.category_rounded,
              label: _sourceTypePillLabel(context),
              selected: filter.sourceType != null,
              trailingIcon: Icons.arrow_drop_down_rounded,
              onTap: () => _pickSourceType(context),
            ),
            const SizedBox(width: 8),
          ],
          if (pricings.length > 1) ...<Widget>[
            _Pill(
              icon: Icons.payments_outlined,
              label: _pricingPillLabel(context),
              selected: filter.pricing != null,
              trailingIcon: Icons.arrow_drop_down_rounded,
              onTap: () => _pickPricing(context),
            ),
            const SizedBox(width: 8),
          ],
          if (kinds.length > 1) ...<Widget>[
            _Pill(
              label: S.of(context).configs_filter_all_kinds,
              selected: filter.kind == null,
              onTap: () => onChanged(filter.withKind(null)),
            ),
            for (final String kind in kinds) ...<Widget>[
              const SizedBox(width: 8),
              _Pill(
                label: contentKindLabel(kind),
                selected: filter.kind == kind,
                onTap: () => onChanged(
                  filter.withKind(filter.kind == kind ? null : kind),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  String _sourceTypePillLabel(BuildContext context) {
    final String? selected = filter.sourceType;
    if (selected == null) {
      return S.of(context).configs_filter_all_types;
    }
    return sourceTypeLabel(selected);
  }

  void _pickSourceType(BuildContext context) {
    unawaited(showActionSheet(
      context,
      title: S.of(context).configs_filter_type_title,
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ActionSheetRow(
              icon: Icons.all_inclusive_rounded,
              label: S.of(context).configs_filter_all_types,
              selected: filter.sourceType == null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onChanged(filter.withSourceType(null));
              },
            ),
            for (final String sourceType in sourceTypes)
              ActionSheetRow(
                icon: sourceTypeIcon(sourceType),
                label: sourceTypeLabel(sourceType),
                selected: filter.sourceType == sourceType,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onChanged(filter.withSourceType(sourceType));
                },
              ),
          ],
        ),
      ),
    ));
  }

  String _pricingPillLabel(BuildContext context) {
    final String? selected = filter.pricing;
    if (selected == null) {
      return S.of(context).configs_filter_all_prices;
    }
    return pricingLabel(selected);
  }

  void _pickPricing(BuildContext context) {
    unawaited(showActionSheet(
      context,
      title: S.of(context).configs_filter_price_title,
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ActionSheetRow(
              icon: Icons.all_inclusive_rounded,
              label: S.of(context).configs_filter_all_prices,
              selected: filter.pricing == null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onChanged(filter.withPricing(null));
              },
            ),
            for (final String pricing in pricings)
              ActionSheetRow(
                icon: pricingIcon(pricing),
                label: pricingLabel(pricing),
                selected: filter.pricing == pricing,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onChanged(filter.withPricing(pricing));
                },
              ),
          ],
        ),
      ),
    ));
  }

  void _pickLanguage(BuildContext context) {
    unawaited(showActionSheet(
      context,
      title: S.of(context).configs_filter_language_title,
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ActionSheetRow(
              leading: _LanguageMark(
                selected: filter.language == null,
                icon: Icons.language_rounded,
              ),
              label: S.of(context).configs_filter_all_languages,
              selected: filter.language == null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onChanged(filter.withLanguage(null));
              },
            ),
            for (final String language in languages)
              ActionSheetRow(
                leading: _languageMarkFor(language, filter.language == language),
                label: language,
                selected: filter.language == language,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  onChanged(filter.withLanguage(language));
                },
              ),
          ],
        ),
      ),
    ));
  }
}

Widget _languageMarkFor(String language, bool selected) {
  if (isMultiLanguage(language)) {
    return _LanguageMark(
      selected: selected,
      icon: Icons.public_rounded,
      language: language,
    );
  }
  return _LanguageMark(selected: selected, language: language);
}

class _LanguageMark extends StatelessWidget {
  const _LanguageMark({
    required this.selected,
    this.icon,
    this.language,
  });

  final bool selected;
  final IconData? icon;
  final String? language;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 30,
      child: Center(child: _buildMark()),
    );
  }

  Widget _buildMark() {
    final Color color = selected ? AppColors.primary : AppColors.mainWhite;
    final IconData? markIcon = icon;
    if (markIcon != null) {
      return Icon(markIcon, size: 20, color: color);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.08),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        languageCode(language ?? ''),
        style: semibold(size: 11, color: color),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.trailingIcon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final IconData? trailingIcon;

  @override
  Widget build(BuildContext context) {
    final Color foreground = selected ? AppColors.mainBlack : AppColors.mainWhite;
    return Material(
      color: selected ? AppColors.primary : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 16, color: foreground),
                const SizedBox(width: 6),
              ],
              Text(label, style: medium(size: 13, color: foreground)),
              if (trailingIcon != null)
                Icon(trailingIcon, size: 18, color: foreground),
            ],
          ),
        ),
      ),
    );
  }
}
