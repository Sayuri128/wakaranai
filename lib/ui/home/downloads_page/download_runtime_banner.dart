import 'package:flutter/material.dart';
import 'package:wakaranai/blocs/downloads/download_manager_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class DownloadRuntimeBanner extends StatelessWidget {
  const DownloadRuntimeBanner({
    super.key,
    required this.state,
    this.margin = EdgeInsets.zero,
  });

  final DownloadManagerState state;
  final EdgeInsetsGeometry margin;

  @override
  Widget build(BuildContext context) {
    final List<Widget> notices = <Widget>[
      if (state.waitingForWifi)
        _RuntimeNotice(
          icon: Icons.wifi_off_rounded,
          tint: AppColors.primary,
          title: S.of(context).downloads_runtime_waiting_for_wifi,
          message: S.of(context).downloads_runtime_waiting_for_wifi_message,
        ),
      if (state.runsOnlyWhileAppOpen && state.active.isNotEmpty)
        _RuntimeNotice(
          icon: Icons.warning_amber_rounded,
          tint: AppColors.red,
          message: S.of(context).downloads_runtime_app_must_stay_open,
        ),
    ];
    if (notices.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: margin,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (int index = 0; index < notices.length; index++) ...<Widget>[
            if (index > 0) const SizedBox(height: 8),
            notices[index],
          ],
        ],
      ),
    );
  }
}

class _RuntimeNotice extends StatelessWidget {
  const _RuntimeNotice({
    required this.icon,
    required this.tint,
    required this.message,
    this.title,
  });

  final IconData icon;
  final Color tint;
  final String? title;
  final String message;

  @override
  Widget build(BuildContext context) {
    final String? heading = title;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: tint),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (heading != null) ...<Widget>[
                  Text(heading, style: semibold(size: 14)),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: regular(size: 13, color: AppColors.mainGrey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
