import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/services/configs_service/extension_client_lifecycle.dart';
import 'package:wakaranai/ui/home/configs_page/configs_view_options.dart';
import 'package:wakaranai/ui/widgets/text_input_sheet.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/services/configs_service/extension_instances.dart';
import 'package:wakaranai/data/domain/database/extension_domain.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/database/wakaranai_database.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/repositories/database/extension_storage_repository.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';
import 'package:wakaranai/services/extension_preferences/extension_host_services.dart';
import 'package:wakaranai/services/extension_preferences/extension_preference_values.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/home/configs_page/extension_settings/extension_settings_sheet.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/config_card.dart';
import 'package:wakaranai/ui/home/configs_page/local_books_actions.dart';
import 'package:wakaranai/ui/home/configs_page/local_source_actions.dart';
import 'package:wakaranai/services/local_source/local_books_source.dart';
import 'package:wakaranai/services/local_source/local_source.dart';
import 'package:wakaranai/ui/home/configs_page/extension_compatibility_texts.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/services/audio/audio_service_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/ui/services/novel/novel_service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

import '../../routes.dart';

class ConfigsGroup extends StatefulWidget {
  const ConfigsGroup(
      {super.key,
      required this.title,
      required this.remoteConfigs,
      this.listingStatusOf = _alwaysAvailable,
      this.onInstancesChanged});

  final String title;
  final List<BaseExtension> remoteConfigs;
  final ExtensionListingStatus Function(BaseExtension extension)
      listingStatusOf;
  final VoidCallback? onInstancesChanged;

  static ExtensionListingStatus _alwaysAvailable(BaseExtension extension) {
    return ExtensionListingStatus.available;
  }

  @override
  State<ConfigsGroup> createState() => _ConfigsGroupState();
}

class _ConfigsGroupState extends State<ConfigsGroup> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildHeader(),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            alignment: Alignment.topCenter,
            child: _expanded
                ? _buildEntries(context)
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  ConfigsViewOptions _viewOptions(BuildContext context) {
    return context.watch<ConfigsViewOptionsCubit>().state;
  }

  Widget _buildEntries(BuildContext context) {
    final ConfigsLayout layout = _viewOptions(context).layout;
    switch (layout) {
      case ConfigsLayout.cards:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            for (final BaseExtension extension in widget.remoteConfigs)
              _buildCard(context, extension, ConfigCardStyle.card),
          ],
        );
      case ConfigsLayout.compact:
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Material(
            color: AppColors.overlay(0.04),
            borderRadius: BorderRadius.circular(14),
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                for (int index = 0;
                    index < widget.remoteConfigs.length;
                    index++) ...<Widget>[
                  if (index > 0)
                    Divider(
                      height: 1,
                      indent: 64,
                      color: AppColors.overlay(0.06),
                    ),
                  _buildCard(
                    context,
                    widget.remoteConfigs[index],
                    ConfigCardStyle.compact,
                  ),
                ],
              ],
            ),
          ),
        );
      case ConfigsLayout.grid:
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 6),
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              const double spacing = 10;
              final int columns = (constraints.maxWidth / 104).floor().clamp(3, 8);
              final double width =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;
              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: <Widget>[
                  for (final BaseExtension extension in widget.remoteConfigs)
                    SizedBox(
                      width: width,
                      child: _buildCard(
                        context,
                        extension,
                        ConfigCardStyle.tile,
                      ),
                    ),
                ],
              );
            },
          ),
        );
    }
  }

  Widget _buildCard(
    BuildContext context,
    BaseExtension extension,
    ConfigCardStyle style,
  ) {
    final ExtensionListingStatus status = widget.listingStatusOf(extension);
    return ConfigCard(
      style: style,
      pinned: _viewOptions(context).isPinned(extension.config.uid),
      configInfo: extension.config,
      listingStatus: status,
      onTap: () => _onCardTap(context, extension, status),
      onLongPress: _longPressAction(context, extension, status),
    );
  }

  void _onCardTap(
    BuildContext context,
    BaseExtension extension,
    ExtensionListingStatus status,
  ) {
    if (status.isDisabled) {
      unawaited(_showCompatibilityInfo(context, extension, status));
      return;
    }
    _onCardClick(context, extension);
  }

  VoidCallback? _longPressAction(
    BuildContext context,
    BaseExtension extension,
    ExtensionListingStatus status,
  ) {
    if (status == ExtensionListingStatus.updateNeedsNewerApp) {
      return () => _showCompatibilityInfo(context, extension, status);
    }
    if (LocalBooksSource.isLocal(extension.config.uid)) {
      return () => unawaited(showLocalBooksActions(
            context,
            pinned: context
                .read<ConfigsViewOptionsCubit>()
                .state
                .isPinned(extension.config.uid),
            onTogglePin: () => context
                .read<ConfigsViewOptionsCubit>()
                .togglePin(extension.config.uid),
          ));
    }
    if (LocalSource.isLocal(extension.config.uid)) {
      return () => unawaited(showLocalSourceActions(
            context,
            pinned: context
                .read<ConfigsViewOptionsCubit>()
                .state
                .isPinned(extension.config.uid),
            onTogglePin: () => context
                .read<ConfigsViewOptionsCubit>()
                .togglePin(extension.config.uid),
          ));
    }
    return () => unawaited(_showExtensionActions(
          context,
          extension,
          allowSettings: !status.isDisabled,
        ));
  }

  Future<void> _showCompatibilityInfo(
    BuildContext context,
    BaseExtension extension,
    ExtensionListingStatus status,
  ) {
    final ConfigInfo config = extension.config;
    final bool installed =
        status == ExtensionListingStatus.updateNeedsNewerApp;
    return showActionSheet(
      context,
      title: config.name.trim(),
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            ..._buildCompatibilityTexts(extension, status),
            if (installed)
              ActionSheetRow(
                label: S.current.compat_open_installed,
                icon: Icons.play_arrow_rounded,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  _onCardClick(context, extension);
                },
              ),
            if (installed && hasExtensionSettings(config))
              _buildSettingsRow(context, sheetContext, config),
            if (installed && config.protectorConfig != null)
              ActionSheetRow(
                label: S.current.extension_clear_session,
                icon: Icons.cleaning_services_rounded,
                destructive: true,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_clearSession(context, config));
                },
              ),
            _buildLatestReleaseRow(sheetContext),
          ],
        ),
      ),
    );
  }

  List<String> _compatibilityLines(
    BaseExtension extension,
    ExtensionListingStatus status,
  ) {
    final List<String> lines = <String>[];
    final String? message = extensionListingStatusMessage(status);
    if (message != null) {
      lines.add(message);
    }
    if (extension is RemoteConfig) {
      final String? reason =
          extensionCompatibilityReason(extension.compatibility);
      if (reason != null) {
        lines.add(reason);
      }
    }
    if (status == ExtensionListingStatus.updateNeedsNewerApp) {
      lines.add(S.current.compat_installed_keeps_working);
    }
    return lines;
  }

  List<Widget> _buildCompatibilityTexts(
    BaseExtension extension,
    ExtensionListingStatus status,
  ) {
    final List<String> lines = _compatibilityLines(extension, status);
    return <Widget>[
      for (int index = 0; index < lines.length; index++)
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: Text(
            lines[index],
            style: _compatibilityTextStyle(index),
          ),
        ),
      const SizedBox(height: 4),
    ];
  }

  TextStyle _compatibilityTextStyle(int index) {
    if (index == 0) {
      return medium(size: 15);
    }
    return regular(size: 14, color: AppColors.mainGrey);
  }

  Widget _buildLatestReleaseRow(BuildContext sheetContext) {
    return BlocBuilder<LatestReleaseCubit, LatestReleaseState>(
      builder: (BuildContext context, LatestReleaseState state) {
        if (state is! LatestReleaseLoaded || !state.releaseData.needsUpdate) {
          return const SizedBox.shrink();
        }
        return ActionSheetRow(
          label: S.current.compat_download_latest_app,
          icon: Icons.system_update_rounded,
          onTap: () {
            Navigator.of(sheetContext).pop();
            unawaited(launchUrl(
              Uri.parse(state.releaseData.url),
              mode: LaunchMode.externalApplication,
            ));
          },
        );
      },
    );
  }

  Widget _buildHeader() {
    return InkWell(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 8.0),
        child: Row(
          children: <Widget>[
            Text(widget.title,
                style: semibold(size: 18, color: AppColors.mainWhite)),
            const SizedBox(width: 8),
            _buildCountBadge(widget.remoteConfigs.length),
            const Spacer(),
            AnimatedRotation(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              turns: _expanded ? 0.5 : 0.0,
              child: Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppColors.mainGrey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCountBadge(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.overlay(0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text('$count', style: medium(size: 12, color: AppColors.mainGrey)),
    );
  }

  Future<void> _showExtensionActions(
    BuildContext context,
    BaseExtension extension, {
    required bool allowSettings,
  }) async {
    final ConfigInfo config = extension.config;
    final bool isInstance =
        extension is ExtensionDomain && extension.isInstance;
    final bool canAddInstance =
        config.multiInstance && !isInstance && allowSettings;
    final bool showSettings = allowSettings && hasExtensionSettings(config);
    final bool showSession = config.protectorConfig != null;
    final bool showClearData = await _hasStoredData(context, config);
    final bool installed = await _isInstalled(context, config);
    if (!context.mounted) {
      return;
    }
    await showActionSheet(
      context,
      title: config.name.trim(),
      child: Builder(
        builder: (BuildContext sheetContext) => Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            _buildPinRow(context, sheetContext, config),
            if (canAddInstance)
              ActionSheetRow(
                label: S.current.extension_instance_add,
                icon: Icons.add_rounded,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_addInstance(context, extension));
                },
              ),
            if (isInstance)
              ActionSheetRow(
                label: S.current.extension_instance_rename,
                icon: Icons.drive_file_rename_outline_rounded,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_renameInstance(context, extension));
                },
              ),
            if (showSettings) _buildSettingsRow(context, sheetContext, config),
            if (showSession)
              ActionSheetRow(
                label: S.current.extension_clear_session,
                icon: Icons.cleaning_services_rounded,
                destructive: true,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_clearSession(context, config));
                },
              ),
            if (showClearData)
              ActionSheetRow(
                label: S.current.ext_prefs_clear_data,
                icon: Icons.delete_sweep_rounded,
                destructive: true,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_clearStoredData(context, config));
                },
              ),
            if (installed)
              ActionSheetRow(
                label: S.current.extension_uninstall,
                icon: Icons.delete_forever_rounded,
                destructive: true,
                onTap: () {
                  Navigator.of(sheetContext).pop();
                  unawaited(_confirmUninstall(context, config));
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsRow(
    BuildContext context,
    BuildContext sheetContext,
    ConfigInfo config,
  ) {
    return ActionSheetRow(
      label: S.current.ext_prefs_sheet_title,
      icon: Icons.settings_rounded,
      onTap: () {
        Navigator.of(sheetContext).pop();
        unawaited(showExtensionSettingsSheet(context, config: config));
      },
    );
  }

  ExtensionStorageRepository _storageRepository(BuildContext context) {
    return ExtensionStorageRepository(
      database: context.read<WakaranaiDatabase>(),
    );
  }

  Future<bool> _hasStoredData(BuildContext context, ConfigInfo config) async {
    try {
      return await _storageRepository(context).countEntries(config.uid) > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _isInstalled(BuildContext context, ConfigInfo config) async {
    try {
      return await context.read<ExtensionRepository>().getByUid(config.uid) !=
          null;
    } catch (e) {
      return false;
    }
  }

  Future<void> _confirmUninstall(
    BuildContext context,
    ConfigInfo config,
  ) async {
    final String name = config.name.trim();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        title: S.current.extension_uninstall_title(name),
        message: S.current.extension_uninstall_message,
        yesText: S.current.extension_uninstall,
        noText: S.current.downloads_confirm_cancel,
        destructive: true,
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    await ExtensionDataCleaner(storageRepository: _storageRepository(context))
        .uninstall(
      config.uid,
      extensionRepository: context.read<ExtensionRepository>(),
    );
    await ProtectorStorageService().clearForConfig(config);
    widget.onInstancesChanged?.call();
    if (!context.mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: S.current.extension_uninstall_done(name),
    );
  }

  Widget _buildPinRow(
    BuildContext context,
    BuildContext sheetContext,
    ConfigInfo config,
  ) {
    final ConfigsViewOptionsCubit options =
        context.read<ConfigsViewOptionsCubit>();
    final bool pinned = options.state.isPinned(config.uid);
    return ActionSheetRow(
      label: pinned ? S.current.configs_unpin : S.current.configs_pin,
      icon: pinned ? Icons.push_pin_outlined : Icons.push_pin_rounded,
      onTap: () {
        Navigator.of(sheetContext).pop();
        unawaited(options.togglePin(config.uid));
      },
    );
  }

  ExtensionInstances _instances(BuildContext context) {
    return ExtensionInstances(repository: context.read<ExtensionRepository>());
  }

  Future<String> _scriptFor(
    BuildContext context,
    BaseExtension extension,
  ) async {
    if (extension is ExtensionDomain) {
      return extension.sourceCode;
    }
    final RemoteConfig remote = extension as RemoteConfig;
    final ExtensionDomain? cached =
        await context.read<ExtensionRepository>().getByUid(remote.config.uid);
    if (cached != null && cached.revision == remote.revision) {
      return cached.sourceCode;
    }
    final RemoteConfigsCubit configs = context.read<RemoteConfigsCubit>();
    return (await configs.configService.getRemoteScript(remote.path)).script;
  }

  Future<void> _addInstance(
    BuildContext context,
    BaseExtension extension,
  ) async {
    final ExtensionInstances instances = _instances(context);
    final String? name = await showTextInputSheet(
      context,
      title: S.current.extension_instance_add,
      initialValue: await instances.nextName(extension.config),
      confirmLabel: S.current.extension_instance_add_confirm,
    );
    if (name == null || !context.mounted) {
      return;
    }
    try {
      final String? revision =
          extension is RemoteConfig ? extension.revision : null;
      await instances.create(
        base: extension.config,
        revision: revision ?? (extension as ExtensionDomain).revision,
        name: name,
        script: () => _scriptFor(context, extension),
      );
      widget.onInstancesChanged?.call();
      if (context.mounted) {
        SnackBars.showSnackBar(
          context: context,
          message: S.current.extension_instance_added(name),
        );
      }
    } catch (error) {
      if (context.mounted) {
        SnackBars.showErrorSnackBar(
          context: context,
          error: S.current.extension_instance_add_failed,
        );
      }
    }
  }

  Future<void> _renameInstance(
    BuildContext context,
    BaseExtension extension,
  ) async {
    if (extension is! ExtensionDomain) {
      return;
    }
    final ExtensionInstances instances = _instances(context);
    final String? name = await showTextInputSheet(
      context,
      title: S.current.extension_instance_rename,
      initialValue: extension.config.name,
      confirmLabel: S.current.extension_instance_rename_confirm,
    );
    if (name == null) {
      return;
    }
    await instances.rename(extension, name);
    widget.onInstancesChanged?.call();
  }

  Future<void> _clearStoredData(BuildContext context, ConfigInfo config) async {
    await ExtensionDataCleaner(storageRepository: _storageRepository(context))
        .clearStorage(config.uid);
    ExtensionClientLifecycle.instance.reset(config.uid);
    if (!context.mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: S.current.ext_prefs_clear_data_done(config.name.trim()),
    );
  }

  Future<void> _clearSession(BuildContext context, ConfigInfo config) async {
    await ProtectorStorageService().clearForConfig(config);
    if (!context.mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: S.current.extension_clear_session_done(config.name.trim()),
    );
  }

  void _onCardClick(
    BuildContext context,
    BaseExtension remoteConfig,
  ) async {
    if (remoteConfig.config.type == ConfigInfoType.MANGA) {
      unawaited(Navigator.of(context)
          .pushNamed(
              Routes.mangaServiceViewer,
              arguments: MangaServiceViewData(remoteConfig: remoteConfig))
          .then((_) {
        context.read<MangaActivityHistoryCubit>().init();
      }));
    } else if (remoteConfig.config.type == ConfigInfoType.ANIME) {
      unawaited(Navigator.of(context)
          .pushNamed(
              Routes.animeServiceViewer,
              arguments: AnimeServiceViewerData(remoteConfig: remoteConfig))
          .then((_) {
        context.read<AnimeActivityHistoryCubit>().init();
      }));
    } else if (remoteConfig.config.type == ConfigInfoType.NOVEL) {
      unawaited(Navigator.of(context)
          .pushNamed(
              Routes.novelServiceViewer,
              arguments: NovelServiceViewData(remoteConfig: remoteConfig))
          .then((_) {
        context.read<MangaActivityHistoryCubit>().init();
      }));
    } else if (remoteConfig.config.type == ConfigInfoType.AUDIO) {
      unawaited(Navigator.of(context)
          .pushNamed(
              Routes.audioServiceViewer,
              arguments: AudioServiceViewData(remoteConfig: remoteConfig))
          .then((_) {
        context.read<MangaActivityHistoryCubit>().init();
      }));
    }
  }
}
