import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gemma_model/gemma_model_cubit.dart';
import 'package:wakaranai/blocs/page_translation_settings/page_translation_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/device/device_capabilities.dart';
import 'package:wakaranai/services/page_translation/engines/gemma_prompt.dart';
import 'package:wakaranai/services/page_translation/engines/page_translation_engines.dart';
import 'package:wakaranai/services/page_translation/page_translation_settings.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class TranslationEngineSection extends StatelessWidget {
  const TranslationEngineSection({super.key, required this.settings});

  final PageTranslationSettings settings;

  @override
  Widget build(BuildContext context) {
    final GemmaModelState gemma = context.watch<GemmaModelCubit>().state;
    final PageTranslationSettingsCubit cubit = context
        .read<PageTranslationSettingsCubit>();
    final bool gemmaSelected =
        settings.translatorId == gemmaEngineId && gemma.supported;
    final String mlKitId = PageTranslationEngines.translators.first.id;

    return SettingsSection(
      title: S.current.translation_engine_section,
      tiles: <Widget>[
        _EngineTile(
          icon: Icons.bolt_rounded,
          title: S.current.translation_engine_mlkit,
          subtitle: S.current.translation_engine_mlkit_subtitle,
          selected: !gemmaSelected,
          enabled: true,
          onTap: () => cubit.setTranslator(mlKitId),
        ),
        _EngineTile(
          icon: Icons.auto_awesome_rounded,
          title: S.current.translation_engine_gemma,
          subtitle: _gemmaSubtitle(gemma),
          selected: gemmaSelected,
          enabled: gemma.supported,
          onTap: () => cubit.setTranslator(gemmaEngineId),
          trailing: IconButton(
            icon: Icon(Icons.info_outline_rounded, color: AppColors.mainGrey),
            onPressed: () => showOnDeviceAiInfo(context),
          ),
        ),
        if (gemmaSelected) _GemmaModelTile(state: gemma),
      ],
    );
  }

  static String _gemmaSubtitle(GemmaModelState gemma) {
    final bool supportStillUnknown = gemma.status == GemmaModelStatus.unknown;
    if (supportStillUnknown || gemma.supported) {
      return S.current.translation_engine_gemma_subtitle;
    }
    return _unsupportedReason(gemma.support);
  }

  static String _unsupportedReason(OnDeviceAiSupport? support) {
    final List<OnDeviceAiIssue> issues =
        support?.issues ?? const <OnDeviceAiIssue>[];
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
      (support?.device?.totalRamGb ?? 0).round(),
    );
  }
}

class _EngineTile extends StatelessWidget {
  const _EngineTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.enabled,
    required this.onTap,
    this.trailing,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final bool enabled;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: SettingsTile(
        icon: icon,
        title: title,
        subtitle: subtitle,
        onTap: enabled ? onTap : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (trailing != null) trailing!,
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: selected ? AppColors.primary : AppColors.mainGrey,
            ),
          ],
        ),
      ),
    );
  }
}

class _GemmaModelTile extends StatelessWidget {
  const _GemmaModelTile({required this.state});

  final GemmaModelState state;

  @override
  Widget build(BuildContext context) {
    final GemmaModelCubit cubit = context.read<GemmaModelCubit>();
    final String subtitle = switch (state.status) {
      GemmaModelStatus.installed => S.current.translation_ai_model_installed,
      GemmaModelStatus.downloading =>
        S.current.page_translation_ai_model_downloading(state.progress),
      GemmaModelStatus.failed => S.current.translation_ai_model_failed,
      _ => S.current.translation_ai_model_missing,
    };
    final Widget action = switch (state.status) {
      GemmaModelStatus.installed => SettingsPillButton(
        label: S.current.page_translation_settings_delete_pack,
        onTap: () => _confirmDelete(context, cubit),
      ),
      GemmaModelStatus.downloading => SettingsPillButton(
        label: S.current.language_packs_cancel,
        onTap: cubit.cancel,
      ),
      GemmaModelStatus.unknown => const SizedBox.shrink(),
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
          destructive: state.status == GemmaModelStatus.failed,
          trailing: action,
        ),
        if (state.status == GemmaModelStatus.downloading)
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

  Future<void> _confirmDelete(
    BuildContext context,
    GemmaModelCubit cubit,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        destructive: true,
        icon: Icons.delete_outline_rounded,
        title: S.current.translation_ai_model_delete_title,
        message: S.current.translation_ai_model_delete_message,
        yesText: S.current.page_translation_settings_delete_pack,
        noText: S.current.page_translation_models_cancel,
      ),
    );
    if (confirmed == true) {
      await cubit.delete();
    }
  }
}

Future<void> showOnDeviceAiInfo(BuildContext context) async {
  final OnDeviceAiSupport support = await DeviceCapabilities.onDeviceAi();
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
      return _OnDeviceAiInfoSheet(device: support.device);
    },
  );
}

class _OnDeviceAiInfoSheet extends StatelessWidget {
  const _OnDeviceAiInfoSheet({required this.device});

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
            Text(
              S.current.translation_engine_info_title,
              style: semibold(size: 18),
            ),
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
      ramMet = device.totalRamGb >= OnDeviceAiSupport.minRamGb;
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
      _RequirementRow(label: S.current.translation_engine_req_ram, met: ramMet),
      _RequirementRow(
        label: S.current.translation_engine_req_storage,
        met: null,
      ),
    ];
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
