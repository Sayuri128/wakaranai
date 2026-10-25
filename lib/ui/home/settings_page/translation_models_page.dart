import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/language_packs/language_packs_cubit.dart';
import 'package:wakaranai/blocs/on_device_model/on_device_model_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/page_translation/engines/on_device_model.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/home/settings_page/translation_engine_section.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/download_estimate_text.dart';
import 'package:wakaranai/utils/app_colors.dart';

class TranslationModelsPage extends StatefulWidget {
  const TranslationModelsPage({super.key});

  @override
  State<TranslationModelsPage> createState() => _TranslationModelsPageState();
}

class _TranslationModelsPageState extends State<TranslationModelsPage> {
  @override
  void initState() {
    super.initState();
    context.read<OnDeviceModelCubit>().refresh();
    context.read<LanguagePacksCubit>().refresh();
  }

  @override
  Widget build(BuildContext context) {
    final OnDeviceModelState models = context.watch<OnDeviceModelCubit>().state;
    final int downloadedPacks = context.select(
      (LanguagePacksCubit cubit) => cubit.state.downloadedCount,
    );
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: <Widget>[
            SettingsPageHeader(title: S.current.translation_models_title),
            Expanded(
              child: ListView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: 24 + MediaQuery.of(context).viewPadding.bottom,
                ),
                children: <Widget>[
                  SettingsSection(
                    title: S.current.translation_models_ai_section,
                    tiles: <Widget>[
                      for (final OnDeviceModel model in OnDeviceModel.values)
                        _ModelTile(model: model, state: models),
                    ],
                  ),
                  SettingsSection(
                    title: S.current.translation_models_packs_section,
                    tiles: <Widget>[
                      SettingsTile(
                        icon: Icons.translate_rounded,
                        title: S.current.language_packs_title,
                        subtitle: S.current.translation_models_packs_count(
                          downloadedPacks,
                        ),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: AppColors.mainGrey,
                        ),
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(Routes.languagePacks),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModelTile extends StatelessWidget {
  const _ModelTile({required this.model, required this.state});

  final OnDeviceModel model;
  final OnDeviceModelState state;

  bool get _downloading =>
      state.variant == model && state.status == OnDeviceModelStatus.downloading;

  bool get _installed => state.installedVariants.contains(model);

  bool get _canDownload =>
      state.variant == model && state.supports(model) && !_installed;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        SettingsTile(
          icon: Icons.memory_rounded,
          title: model.displayName,
          subtitle: _subtitle(),
          trailing: _buildAction(context),
        ),
        if (_downloading)
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

  String _subtitle() {
    if (_downloading) {
      return withDownloadEstimate(
        S.current.page_translation_ai_model_downloading(state.progress),
        state.estimate,
      );
    }
    if (_installed) {
      return S.current.translation_models_downloaded(model.sizeLabel);
    }
    if (!state.supports(model)) {
      return S.current.translation_models_unsupported;
    }
    if (_canDownload) {
      return S.current.translation_ai_model_missing(model.sizeLabel);
    }
    return S.current.translation_models_pick_first(model.sizeLabel);
  }

  Widget? _buildAction(BuildContext context) {
    final OnDeviceModelCubit cubit = context.read<OnDeviceModelCubit>();
    if (_downloading) {
      return SettingsPillButton(
        label: S.current.language_packs_cancel,
        onTap: cubit.cancel,
      );
    }
    if (_installed) {
      return SettingsPillButton(
        label: S.current.page_translation_settings_delete_pack,
        onTap: () => confirmDeleteOnDeviceModel(context, model),
      );
    }
    if (_canDownload) {
      return SettingsPillButton(
        label: S.current.page_translation_settings_download_pack,
        primary: true,
        onTap: cubit.download,
      );
    }
    return null;
  }
}
