import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/auto_download/auto_download_settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';
import 'package:wakaranai/repositories/shared_pref/download_storage_preferences.dart';
import 'package:wakaranai/ui/home/settings_page/auto_download_settings_tiles.dart';
import 'package:wakaranai/ui/home/settings_page/download_runtime_settings_section.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

IconData downloadQualityIcon(DownloadQuality quality) {
  switch (quality) {
    case DownloadQuality.sameAsPlayer:
      return Icons.link_rounded;
    case DownloadQuality.highest:
      return Icons.high_quality_rounded;
    case DownloadQuality.p1080:
      return Icons.hd_rounded;
    case DownloadQuality.p720:
      return Icons.hd_rounded;
    case DownloadQuality.p480:
      return Icons.sd_rounded;
  }
}

String downloadQualityLabel(DownloadQuality quality) {
  switch (quality) {
    case DownloadQuality.sameAsPlayer:
      return S.current.downloads_quality_same_as_player;
    case DownloadQuality.highest:
      return S.current.downloads_quality_highest;
    case DownloadQuality.p1080:
      return S.current.downloads_quality_1080;
    case DownloadQuality.p720:
      return S.current.downloads_quality_720;
    case DownloadQuality.p480:
      return S.current.downloads_quality_480;
  }
}

class DownloadStorageSettingsSection extends StatefulWidget {
  DownloadStorageSettingsSection({
    super.key,
    DownloadStoragePreferences? preferences,
  }) : preferences = preferences ?? DownloadStoragePreferences();

  final DownloadStoragePreferences preferences;

  @override
  State<DownloadStorageSettingsSection> createState() =>
      _DownloadStorageSettingsSectionState();
}

class _DownloadStorageSettingsSectionState
    extends State<DownloadStorageSettingsSection> {
  DownloadQuality _quality = kDefaultDownloadQuality;
  bool _deleteAfterWatching = kDefaultDeleteEpisodesAfterWatching;

  @override
  void initState() {
    super.initState();
    unawaited(_restore());
  }

  Future<void> _restore() async {
    final DownloadQuality quality = await widget.preferences.getQuality();
    final bool deleteAfterWatching =
        await widget.preferences.getDeleteAfterWatching();
    if (!mounted) {
      return;
    }
    setState(() {
      _quality = quality;
      _deleteAfterWatching = deleteAfterWatching;
    });
  }

  void _changeQuality(DownloadQuality quality) {
    setState(() => _quality = quality);
    unawaited(widget.preferences.setQuality(quality));
  }

  void _changeDeleteAfterWatching(bool enabled) {
    setState(() => _deleteAfterWatching = enabled);
    unawaited(widget.preferences.setDeleteAfterWatching(enabled));
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoDownloadSettingsCubit, AutoDownloadSettings>(
      builder: (BuildContext context, AutoDownloadSettings autoDownload) =>
          _buildSection(context, autoDownload),
    );
  }

  Widget _buildSection(
    BuildContext context,
    AutoDownloadSettings autoDownload,
  ) {
    return SettingsSection(
      title: S.of(context).downloads_storage_section_title,
      tiles: <Widget>[
        DownloadWifiOnlyTile(),
        SettingsTile(
          icon: Icons.high_quality_rounded,
          title: S.of(context).downloads_quality_title,
          trailing: _buildValueTrailing(downloadQualityLabel(_quality)),
          onTap: () => _showQualityPicker(context),
        ),
        SettingsTile(
          icon: Icons.auto_delete_outlined,
          title: S.of(context).downloads_storage_delete_after_watching_title,
          subtitle:
              S.of(context).downloads_storage_delete_after_watching_subtitle,
          trailing: Switch(
            value: _deleteAfterWatching,
            activeThumbColor: AppColors.mainBlack,
            activeTrackColor: AppColors.primary,
            onChanged: _changeDeleteAfterWatching,
          ),
          onTap: () => _changeDeleteAfterWatching(!_deleteAfterWatching),
        ),
        ...buildAutoDownloadSettingsTiles(context, autoDownload),
      ],
    );
  }

  Widget _buildValueTrailing(String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(value, style: medium(size: 13, color: AppColors.mainGrey)),
        const SizedBox(width: 4),
        Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey),
      ],
    );
  }

  void _showQualityPicker(BuildContext context) {
    unawaited(showActionSheet(
      context,
      title: S.of(context).downloads_quality_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final DownloadQuality quality in DownloadQuality.values)
            ActionSheetRow(
              icon: downloadQualityIcon(quality),
              label: downloadQualityLabel(quality),
              selected: quality == _quality,
              onTap: () {
                Navigator.of(context).pop();
                _changeQuality(quality);
              },
            ),
        ],
      ),
    ));
  }
}
