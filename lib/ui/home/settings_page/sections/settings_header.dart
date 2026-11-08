
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wakaranai/blocs/latest_release_cubit/latest_release_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class SettingsHeader extends StatelessWidget {
  const SettingsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      S.current.home_navigation_bar_settings_title,
      style: semibold(size: 24),
    );
  }
}

class SettingsUpdateBanner extends StatefulWidget {
  const SettingsUpdateBanner({super.key});

  @override
  State<SettingsUpdateBanner> createState() => _SettingsUpdateBannerState();
}

class _SettingsUpdateBannerState extends State<SettingsUpdateBanner> {
  @override
  void initState() {
    super.initState();
    unawaited(context.read<LatestReleaseCubit>().check());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LatestReleaseCubit, LatestReleaseState>(
      builder: (BuildContext context, LatestReleaseState state) {
        if (state is! LatestReleaseLoaded || !state.releaseData.needsUpdate) {
          return const SizedBox.shrink();
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Material(
            color: AppColors.primary.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => launchUrl(
                Uri.parse(state.releaseData.url),
                mode: LaunchMode.externalApplication,
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.system_update_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        S.current.settings_download_latest_release(
                          state.releaseData.latestVersion,
                        ),
                        style: semibold(size: 15, color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(Icons.download_rounded, color: AppColors.primary),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
