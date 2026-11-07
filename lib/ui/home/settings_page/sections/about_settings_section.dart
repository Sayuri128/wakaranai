
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/utils/app_colors.dart';

class AboutSettingsSection extends StatelessWidget {
  const AboutSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return SettingsSection(
      title: S.current.settings_about_section_title,
      tiles: <Widget>[
        SettingsTile(
          icon: Icons.bug_report_outlined,
          title: S.current.settings_submit_issue,
          trailing: Icon(Icons.open_in_new_rounded, color: AppColors.mainGrey),
          onTap: () => launchUrl(
            Uri.parse(
              "https://github.com/Sayuri128/wakaranai/issues/new/choose",
            ),
          ),
        ),
      ],
    );
  }
}
