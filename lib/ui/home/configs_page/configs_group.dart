import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/data/models/remote_config/remote_config.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/anime_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/activity_history_page/cubit/manga_activity_history_cubit.dart';
import 'package:wakaranai/ui/home/configs_page/config_card.dart';
import 'package:wakaranai/ui/home/configs_page/extension_compatibility_texts.dart';
import 'package:wakaranai/ui/services/anime/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

import '../../routes.dart';

class ConfigsGroup extends StatefulWidget {
  const ConfigsGroup(
      {super.key,
      required this.title,
      required this.remoteConfigs,
      this.listingStatusOf = _alwaysAvailable});

  final String title;
  final List<BaseExtension> remoteConfigs;
  final ExtensionListingStatus Function(BaseExtension extension)
      listingStatusOf;

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
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ...widget.remoteConfigs.map(
                        (BaseExtension e) => _buildCard(context, e),
                      ),
                    ],
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, BaseExtension extension) {
    final ExtensionListingStatus status = widget.listingStatusOf(extension);
    return ConfigCard(
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
    if (extension.config.protectorConfig == null) {
      return null;
    }
    return () => _showSessionActions(context, extension.config);
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

  Future<void> _showSessionActions(BuildContext context, ConfigInfo config) {
    return showActionSheet(
      context,
      title: config.name.trim(),
      child: Builder(
        builder: (BuildContext sheetContext) => ActionSheetRow(
          label: S.current.extension_clear_session,
          icon: Icons.cleaning_services_rounded,
          destructive: true,
          onTap: () {
            Navigator.of(sheetContext).pop();
            unawaited(_clearSession(context, config));
          },
        ),
      ),
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
    }
  }
}
