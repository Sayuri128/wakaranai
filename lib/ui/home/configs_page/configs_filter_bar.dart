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
    required this.filter,
    required this.onChanged,
  });

  final List<String> kinds;
  final List<String> languages;
  final List<String> pricings;
  final ConfigsFilter filter;
  final ValueChanged<ConfigsFilter> onChanged;

  bool get isUseful =>
      kinds.length > 1 || languages.length > 1 || pricings.length > 1;

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
              label: S.of(context).configs_filter_all_prices,
              selected: filter.pricing == null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onChanged(filter.withPricing(null));
              },
            ),
            for (final String pricing in pricings)
              ActionSheetRow(
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
              label: S.of(context).configs_filter_all_languages,
              selected: filter.language == null,
              onTap: () {
                Navigator.of(sheetContext).pop();
                onChanged(filter.withLanguage(null));
              },
            ),
            for (final String language in languages)
              ActionSheetRow(
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
