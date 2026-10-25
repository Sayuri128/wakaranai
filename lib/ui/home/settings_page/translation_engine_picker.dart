import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_variant.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class TranslationEngineOption {
  const TranslationEngineOption({
    required this.id,
    required this.icon,
    required this.title,
    required this.description,
    required this.tags,
    this.gemma,
  });

  final String id;
  final IconData icon;
  final String title;
  final String description;
  final List<String> tags;
  final GemmaVariant? gemma;

  static List<TranslationEngineOption> all() {
    return <TranslationEngineOption>[
      TranslationEngineOption(
        id: PageTranslationEngines.translators.first.id,
        icon: Icons.bolt_rounded,
        title: S.current.translation_engine_mlkit,
        description: S.current.translation_engine_mlkit_subtitle,
        tags: <String>[
          S.current.engine_tag_offline,
          S.current.engine_tag_fast,
          S.current.engine_tag_literal,
        ],
      ),
      for (final GemmaVariant variant in GemmaVariant.values)
        TranslationEngineOption(
          id: variant.engineId,
          icon: Icons.auto_awesome_rounded,
          title: _gemmaTitle(variant),
          description: _gemmaDescription(variant),
          gemma: variant,
          tags: <String>[
            S.current.engine_tag_offline,
            _gemmaSpeedTag(variant),
            S.current.engine_tag_natural,
            S.current.engine_tag_size(variant.sizeLabel),
          ],
        ),
      TranslationEngineOption(
        id: deepLEngineId,
        icon: Icons.cloud_outlined,
        title: S.current.translation_engine_deepl,
        description: S.current.translation_engine_deepl_subtitle,
        tags: <String>[
          S.current.engine_tag_online,
          S.current.engine_tag_fast,
          S.current.engine_tag_best,
        ],
      ),
    ];
  }

  static TranslationEngineOption byId(String id) {
    final List<TranslationEngineOption> options = all();
    return options.firstWhere(
      (TranslationEngineOption option) => option.id == id,
      orElse: () => options.first,
    );
  }

  static String _gemmaTitle(GemmaVariant variant) {
    return switch (variant) {
      GemmaVariant.e2b => S.current.translation_engine_gemma,
      GemmaVariant.e4b => S.current.translation_engine_gemma_e4b,
    };
  }

  static String _gemmaDescription(GemmaVariant variant) {
    return switch (variant) {
      GemmaVariant.e2b => S.current.translation_engine_gemma_subtitle,
      GemmaVariant.e4b => S.current.translation_engine_gemma_e4b_subtitle,
    };
  }

  static String _gemmaSpeedTag(GemmaVariant variant) {
    return switch (variant) {
      GemmaVariant.e2b => S.current.engine_tag_medium_speed,
      GemmaVariant.e4b => S.current.engine_tag_slow,
    };
  }
}

Future<String?> showTranslationEnginePicker(
  BuildContext context, {
  required String selectedId,
  required String? Function(GemmaVariant variant) unavailableReason,
  required VoidCallback onShowGemmaInfo,
}) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return BlocProvider<GemmaModelCubit>.value(
        value: context.read<GemmaModelCubit>(),
        child: _EnginePickerSheet(
          selectedId: selectedId,
          unavailableReason: unavailableReason,
          onShowGemmaInfo: onShowGemmaInfo,
        ),
      );
    },
  );
}

class _EnginePickerSheet extends StatelessWidget {
  const _EnginePickerSheet({
    required this.selectedId,
    required this.unavailableReason,
    required this.onShowGemmaInfo,
  });

  final String selectedId;
  final String? Function(GemmaVariant variant) unavailableReason;
  final VoidCallback onShowGemmaInfo;

  @override
  Widget build(BuildContext context) {
    final double maxHeight = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
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
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 12),
              child: Text(
                S.current.translation_engine_section,
                style: semibold(size: 18),
              ),
            ),
            for (final TranslationEngineOption option
                in TranslationEngineOption.all())
              _EngineCard(
                option: option,
                selected: option.id == selectedId,
                unavailableReason: _reasonFor(option),
                onTap: () => Navigator.of(context).pop(option.id),
                onInfo: option.gemma == null ? null : onShowGemmaInfo,
              ),
          ],
        ),
      ),
    );
  }

  String? _reasonFor(TranslationEngineOption option) {
    final GemmaVariant? variant = option.gemma;
    if (variant == null) {
      return null;
    }
    return unavailableReason(variant);
  }
}

class _EngineCard extends StatelessWidget {
  const _EngineCard({
    required this.option,
    required this.selected,
    required this.unavailableReason,
    required this.onTap,
    required this.onInfo,
  });

  final TranslationEngineOption option;
  final bool selected;
  final String? unavailableReason;
  final VoidCallback onTap;
  final VoidCallback? onInfo;

  @override
  Widget build(BuildContext context) {
    final bool available = unavailableReason == null;
    final Color fill = selected
        ? AppColors.primary.withValues(alpha: 0.14)
        : AppColors.overlay(0.04);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Opacity(
        opacity: available ? 1 : 0.45,
        child: Material(
          color: fill,
          borderRadius: BorderRadius.circular(14),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: available ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Icon(option.icon, color: AppColors.primary),
                  ),
                  const SizedBox(width: 12),
                  Expanded(child: _buildDetails()),
                  if (onInfo != null)
                    IconButton(
                      icon: Icon(
                        Icons.info_outline_rounded,
                        color: AppColors.mainGrey,
                      ),
                      onPressed: onInfo,
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(4, 10, 8, 0),
                    child: Icon(
                      selected
                          ? Icons.radio_button_checked_rounded
                          : Icons.radio_button_off_rounded,
                      color: selected ? AppColors.primary : AppColors.mainGrey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(option.title, style: medium(size: 15)),
        const SizedBox(height: 4),
        Text(
          unavailableReason ?? option.description,
          style: regular(size: 12, color: AppColors.mainGrey),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: <Widget>[
            for (final String tag in option.tags) _EngineTag(label: tag),
          ],
        ),
      ],
    );
  }
}

class _EngineTag extends StatelessWidget {
  const _EngineTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.06),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: medium(size: 11, color: AppColors.mainGrey)),
    );
  }
}
