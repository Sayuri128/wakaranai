import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/services/page_translation/engines/deepl_translator.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/services/page_translation/translation_prerequisites.dart';
import 'package:wakaranai/ui/home/settings_page/deepl_key_dialog.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/home/settings_page/translation_engine_picker.dart';
import 'package:wakaranai/ui/widgets/download_estimate_text.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class TranslationEngineSection extends StatelessWidget {
  const TranslationEngineSection({super.key, required this.settings});

  final PageTranslationSettings settings;

  @override
  Widget build(BuildContext context) {
    final OnDeviceModelState gemma = context.watch<OnDeviceModelCubit>().state;
    final PageTranslationSettingsCubit cubit = context
        .read<PageTranslationSettingsCubit>();
    final String selectedId = effectiveTranslationSettings(
      settings,
      gemma,
    ).translatorId;
    final OnDeviceModel? selectedGemma = OnDeviceModel.forEngine(selectedId);
    final bool deepLSelected = selectedId == deepLEngineId;

    final TranslationEngineOption selected = TranslationEngineOption.byId(
      selectedId,
    );

    return SettingsSection(
      title: S.current.translation_engine_section,
      tiles: <Widget>[
        SettingsTile(
          icon: selected.icon,
          title: selected.title,
          subtitle: selected.description,
          trailing: SettingsPillButton(
            label: S.current.translation_engine_change,
            onTap: () => _pickEngine(context, cubit, selectedId, gemma),
          ),
          onTap: () => _pickEngine(context, cubit, selectedId, gemma),
        ),
        if (selectedGemma != null) _GemmaModelTile(state: gemma),
        for (final OnDeviceModel variant in gemma.otherInstalledVariants)
          _OtherGemmaModelTile(variant: variant),
        if (deepLSelected) const _DeepLKeyTile(),
      ],
    );
  }

  static Future<void> _pickEngine(
    BuildContext context,
    PageTranslationSettingsCubit cubit,
    String selectedId,
    OnDeviceModelState gemma,
  ) async {
    final String? picked = await showTranslationEnginePicker(
      context,
      selectedId: selectedId,
      unavailableReason: (OnDeviceModel variant) =>
          _gemmaUnavailableReason(variant, gemma),
      onShowGemmaInfo: (OnDeviceModel model) =>
          showOnDeviceAiInfo(context, model),
    );
    if (picked == null || picked == selectedId || !context.mounted) {
      return;
    }
    if (picked == deepLEngineId) {
      await _selectDeepL(context, cubit);
      return;
    }
    await cubit.setTranslator(picked);
  }

  static Future<void> _selectDeepL(
    BuildContext context,
    PageTranslationSettingsCubit cubit,
  ) async {
    if (await DeepLApiKeyStore.read() == null) {
      if (!context.mounted) {
        return;
      }
      final bool saved = await showDeepLKeyDialog(context);
      if (!saved) {
        return;
      }
    }
    await cubit.setTranslator(deepLEngineId);
  }

  static String? _gemmaUnavailableReason(
    OnDeviceModel variant,
    OnDeviceModelState gemma,
  ) {
    final OnDeviceAiSupport? support = gemma.supportByVariant[variant];
    if (support == null || support.supported) {
      return null;
    }
    return _unsupportedReason(support);
  }

  static String _unsupportedReason(OnDeviceAiSupport support) {
    final List<OnDeviceAiIssue> issues = support.issues;
    if (issues.contains(OnDeviceAiIssue.notAndroid)) {
      return S.current.translation_engine_gemma_unavailable_platform;
    }
    if (issues.contains(OnDeviceAiIssue.androidTooOld)) {
      return S.current.translation_engine_gemma_unavailable_android;
    }
    if (issues.contains(OnDeviceAiIssue.not64Bit)) {
      return S.current.translation_engine_gemma_unavailable_64bit;
    }
    return S.current.translation_engine_gemma_unavailable_ram(
      _marketedRamGb(support.minRamGb),
      (support.device?.totalRamGb ?? 0).round(),
    );
  }

  static int _marketedRamGb(double minRamGb) {
    if (minRamGb <= 8) {
      return 8;
    }
    return 12;
  }
}

class _GemmaModelTile extends StatelessWidget {
  const _GemmaModelTile({required this.state});

  final OnDeviceModelState state;

  @override
  Widget build(BuildContext context) {
    final OnDeviceModelCubit cubit = context.read<OnDeviceModelCubit>();
    final OnDeviceModel variant = state.variant;
    final String subtitle = switch (state.status) {
      OnDeviceModelStatus.installed => S.current.translation_ai_model_installed(
        variant.displayName,
        variant.sizeLabel,
      ),
      OnDeviceModelStatus.downloading => withDownloadEstimate(
        S.current.page_translation_ai_model_downloading(state.progress),
        state.estimate,
      ),
      OnDeviceModelStatus.failed => S.current.translation_ai_model_failed,
      _ => S.current.translation_ai_model_missing(variant.sizeLabel),
    };
    final Widget action = switch (state.status) {
      OnDeviceModelStatus.installed => SettingsPillButton(
        label: S.current.page_translation_settings_delete_pack,
        onTap: () => _confirmDeleteModel(context, variant),
      ),
      OnDeviceModelStatus.downloading => SettingsPillButton(
        label: S.current.language_packs_cancel,
        onTap: cubit.cancel,
      ),
      OnDeviceModelStatus.unknown => const SizedBox.shrink(),
      _ => SettingsPillButton(
        label: S.current.page_translation_settings_download_pack,
        primary: true,
        onTap: cubit.download,
      ),
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsTile(
          icon: Icons.memory_rounded,
          title: S.current.translation_ai_model_title,
          subtitle: subtitle,
          destructive: state.status == OnDeviceModelStatus.failed,
          trailing: action,
        ),
        if (state.status == OnDeviceModelStatus.downloading)
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 16, 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                minHeight: 5,
                value: state.progress / 100,
                color: AppColors.primary,
                backgroundColor: AppColors.overlay(0.08),
              ),
            ),
          ),
      ],
    );
  }
}

class _OtherGemmaModelTile extends StatelessWidget {
  const _OtherGemmaModelTile({required this.variant});

  final OnDeviceModel variant;

  @override
  Widget build(BuildContext context) {
    return SettingsTile(
      icon: Icons.sd_storage_outlined,
      title: S.current.translation_ai_model_other_installed(
        variant.displayName,
        variant.sizeLabel,
      ),
      trailing: SettingsPillButton(
        label: S.current.page_translation_settings_delete_pack,
        onTap: () => _confirmDeleteModel(context, variant),
      ),
    );
  }
}

Future<void> _confirmDeleteModel(
  BuildContext context,
  OnDeviceModel variant,
) async {
  final OnDeviceModelCubit cubit = context.read<OnDeviceModelCubit>();
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext dialogContext) => ConfirmationDialog(
      destructive: true,
      icon: Icons.delete_outline_rounded,
      title: S.current.translation_ai_model_delete_title,
      message: S.current.translation_ai_model_delete_message(variant.sizeLabel),
      yesText: S.current.page_translation_settings_delete_pack,
      noText: S.current.page_translation_models_cancel,
    ),
  );
  if (confirmed == true) {
    await cubit.delete(variant);
  }
}

class _DeepLKeyTile extends StatefulWidget {
  const _DeepLKeyTile();

  @override
  State<_DeepLKeyTile> createState() => _DeepLKeyTileState();
}

class _DeepLKeyTileState extends State<_DeepLKeyTile> {
  String? _apiKey;
  DeepLUsage? _usage;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final String? apiKey = await DeepLApiKeyStore.read();
    DeepLUsage? usage;
    if (apiKey != null) {
      try {
        usage = await DeepLClient(apiKey).usage();
      } on DeepLException catch (e) {
        logger.w('DeepL usage unavailable: $e');
      }
    }
    if (mounted) {
      setState(() {
        _apiKey = apiKey;
        _usage = usage;
        _loaded = true;
      });
    }
  }

  Future<void> _changeKey() async {
    await showDeepLKeyDialog(context);
    if (!mounted) {
      return;
    }
    if (await DeepLApiKeyStore.read() == null) {
      final String mlKitId = PageTranslationEngines.translators.first.id;
      await context.read<PageTranslationSettingsCubit>().setTranslator(mlKitId);
      return;
    }
    await _load();
  }

  String? _subtitle() {
    if (!_loaded) {
      return null;
    }
    final String? apiKey = _apiKey;
    if (apiKey == null) {
      return S.current.deepl_key_missing;
    }
    return S.current.deepl_key_masked(_maskedEnd(apiKey));
  }

  static String _maskedEnd(String apiKey) {
    const int visibleCharacters = 4;
    final String withoutSuffix = apiKey.replaceAll(':fx', '');
    final int start = (withoutSuffix.length - visibleCharacters).clamp(
      0,
      withoutSuffix.length,
    );
    return withoutSuffix.substring(start);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsTile(
          icon: Icons.key_rounded,
          title: S.current.deepl_key_title,
          subtitle: _subtitle(),
          trailing: SettingsPillButton(
            label: S.current.deepl_key_change,
            onTap: _changeKey,
          ),
        ),
        if (_apiKey != null || !_loaded)
          Padding(
            padding: const EdgeInsets.fromLTRB(64, 0, 16, 14),
            child: _DeepLUsageView(loaded: _loaded, usage: _usage),
          ),
      ],
    );
  }
}

class _DeepLUsageView extends StatelessWidget {
  const _DeepLUsageView({required this.loaded, required this.usage});

  final bool loaded;
  final DeepLUsage? usage;

  static const double _warningShare = 0.9;

  @override
  Widget build(BuildContext context) {
    final DeepLUsage? usage = this.usage;
    if (!loaded) {
      return _buildBar(null, AppColors.primary);
    }
    if (usage == null) {
      return Text(
        S.current.deepl_usage_unavailable,
        style: regular(size: 12, color: AppColors.mainGrey),
      );
    }

    final NumberFormat numbers = NumberFormat.decimalPattern();
    final double share = usage.usedShare.clamp(0, 1).toDouble();
    final Color tint = share >= _warningShare
        ? AppColors.red
        : AppColors.primary;
    final int remaining = (usage.characterLimit - usage.characterCount).clamp(
      0,
      usage.characterLimit,
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Text(_percentLabel(usage), style: semibold(size: 20, color: tint)),
            const SizedBox(width: 6),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                S.current.deepl_usage_used,
                style: regular(size: 12, color: AppColors.mainGrey),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Text(
                S.current.deepl_usage_left(numbers.format(remaining)),
                style: medium(size: 12),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        _buildBar(share, tint),
        const SizedBox(height: 6),
        Text(
          S.current.deepl_usage_characters(
            numbers.format(usage.characterCount),
            numbers.format(usage.characterLimit),
          ),
          style: regular(size: 11, color: AppColors.mainGrey),
        ),
      ],
    );
  }

  String _percentLabel(DeepLUsage usage) {
    final double percent = usage.usedShare * 100;
    if (usage.characterCount > 0 && percent < 1) {
      return '<1%';
    }
    return '${percent.round()}%';
  }

  Widget _buildBar(double? value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: LinearProgressIndicator(
        minHeight: 6,
        value: value,
        color: color,
        backgroundColor: AppColors.overlay(0.08),
      ),
    );
  }
}

Future<void> showOnDeviceAiInfo(
  BuildContext context,
  OnDeviceModel model,
) async {
  final OnDeviceAiSupport support = await DeviceCapabilities.onDeviceAi(
    minRamGb: model.minRamGb,
  );
  if (!context.mounted) {
    return;
  }
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.backgroundColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext sheetContext) {
      return _OnDeviceAiInfoSheet(model: model, device: support.device);
    },
  );
}

class _OnDeviceAiInfoSheet extends StatelessWidget {
  const _OnDeviceAiInfoSheet({required this.model, required this.device});

  final OnDeviceModel model;
  final DeviceInfo? device;

  @override
  Widget build(BuildContext context) {
    final DeviceInfo? device = this.device;
    final double maxHeight = MediaQuery.of(context).size.height * 0.85;
    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          children: <Widget>[
            _buildHandle(),
            Text(model.displayName, style: semibold(size: 18)),
            const SizedBox(height: 8),
            Text(
              S.current.translation_engine_info_intro,
              style: regular(size: 14, color: AppColors.mainGrey),
            ),
            const SizedBox(height: 18),
            Text(
              S.current.translation_engine_info_requirements,
              style: semibold(size: 15),
            ),
            const SizedBox(height: 8),
            ..._buildRequirements(device),
            if (device != null) ...<Widget>[
              const SizedBox(height: 8),
              Text(
                S.current.translation_engine_info_this_phone(
                  device.model,
                  device.totalRamGb.round(),
                ),
                style: regular(size: 12, color: AppColors.mainGrey),
              ),
            ],
            const SizedBox(height: 18),
            Text(
              S.current.translation_engine_info_examples,
              style: semibold(size: 15),
            ),
            const SizedBox(height: 8),
            ..._buildSpeedTiers(),
            const SizedBox(height: 12),
            Text(
              S.current.translation_engine_info_footer,
              style: regular(size: 12, color: AppColors.mainGrey),
            ),
          ],
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

  List<Widget> _buildRequirements(DeviceInfo? device) {
    bool? androidVersionMet;
    bool? ramMet;
    if (device != null) {
      androidVersionMet = device.sdkInt >= OnDeviceAiSupport.minSdk;
      ramMet = device.totalRamGb >= model.minRamGb;
    }
    return <Widget>[
      _RequirementRow(
        label: S.current.translation_engine_req_android,
        met: androidVersionMet,
      ),
      _RequirementRow(
        label: S.current.translation_engine_req_64bit,
        met: device?.abis.contains('arm64-v8a'),
      ),
      _RequirementRow(
        label: S.current.translation_engine_req_ram_model(_marketedRam()),
        met: ramMet,
      ),
      _RequirementRow(
        label: S.current.translation_engine_req_storage_model(model.sizeLabel),
        met: null,
      ),
    ];
  }

  int _marketedRam() {
    return switch (model) {
      OnDeviceModel.e2b => 8,
      OnDeviceModel.e4b => 12,
    };
  }

  List<Widget> _buildSpeedTiers() {
    return switch (model) {
      OnDeviceModel.e2b => <Widget>[
        _ExampleRow(
          tier: S.current.translation_engine_tier_fast,
          phones: S.current.translation_engine_tier_fast_phones,
        ),
        _ExampleRow(
          tier: S.current.translation_engine_tier_ok,
          phones: S.current.translation_engine_tier_ok_phones,
        ),
        _ExampleRow(
          tier: S.current.translation_engine_tier_no,
          phones: S.current.translation_engine_tier_no_phones,
        ),
      ],
      OnDeviceModel.e4b => <Widget>[
        _ExampleRow(
          tier: S.current.translation_engine_tier_e4b,
          phones: S.current.translation_engine_tier_fast_phones,
        ),
        _ExampleRow(
          tier: S.current.translation_engine_tier_no,
          phones: S.current.translation_engine_tier_e4b_no_phones,
        ),
      ],
    };
  }
}

class _RequirementRow extends StatelessWidget {
  const _RequirementRow({required this.label, required this.met});

  final String label;
  final bool? met;

  @override
  Widget build(BuildContext context) {
    final (IconData icon, Color color) = switch (met) {
      null => (Icons.radio_button_unchecked_rounded, AppColors.mainGrey),
      true => (Icons.check_circle_rounded, AppColors.primary),
      false => (Icons.cancel_rounded, AppColors.red),
    };
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: <Widget>[
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(label, style: regular(size: 14))),
        ],
      ),
    );
  }
}

class _ExampleRow extends StatelessWidget {
  const _ExampleRow({required this.tier, required this.phones});

  final String tier;
  final String phones;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(tier, style: medium(size: 14)),
          const SizedBox(height: 4),
          Text(phones, style: regular(size: 13, color: AppColors.mainGrey)),
        ],
      ),
    );
  }
}
