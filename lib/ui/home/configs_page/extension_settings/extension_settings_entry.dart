import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/blocs/service_view/service_gallery_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/extension_preferences/extension_preference_values.dart';
import 'package:wakaranai/ui/home/configs_page/extension_settings/extension_settings_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ExtensionSettingsButton extends StatelessWidget {
  const ExtensionSettingsButton({
    super.key,
    required this.config,
    required this.gallery,
  });

  final ConfigInfo config;
  final ServiceGalleryCubit gallery;

  @override
  Widget build(BuildContext context) {
    if (!hasExtensionSettings(config)) {
      return const SizedBox.shrink();
    }
    return IconButton(
      tooltip: S.current.ext_prefs_sheet_title,
      splashRadius: 22,
      icon: Icon(Icons.settings_rounded, color: AppColors.mainWhite),
      onPressed: () => _open(context),
    );
  }

  Future<void> _open(BuildContext context) async {
    final bool changed = await showExtensionSettingsSheet(
      context,
      config: config,
    );
    if (!changed || gallery.isClosed) {
      return;
    }
    await reloadServiceViewAfterPreferenceChange(gallery);
  }
}

Future<void> reloadServiceViewAfterPreferenceChange(
  ServiceGalleryCubit gallery,
) {
  return gallery.reloadLoadedGalleries();
}
