import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class WebBrowserToolbar extends StatelessWidget {
  const WebBrowserToolbar({
    super.key,
    required this.host,
    required this.isSecure,
    required this.isLoading,
    required this.canGoBack,
    required this.canGoForward,
    required this.enabled,
    required this.onBack,
    required this.onForward,
    required this.onReload,
    required this.onStop,
    required this.onAddressTap,
    required this.onMore,
  });

  final String host;
  final bool isSecure;
  final bool isLoading;
  final bool canGoBack;
  final bool canGoForward;
  final bool enabled;
  final VoidCallback onBack;
  final VoidCallback onForward;
  final VoidCallback onReload;
  final VoidCallback onStop;
  final VoidCallback onAddressTap;
  final VoidCallback onMore;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        WebBrowserToolbarButton(
          icon: Icons.arrow_back_rounded,
          tooltip: S.current.web_browser_back,
          onPressed: enabled && canGoBack ? onBack : null,
        ),
        WebBrowserToolbarButton(
          icon: Icons.arrow_forward_rounded,
          tooltip: S.current.web_browser_forward,
          onPressed: enabled && canGoForward ? onForward : null,
        ),
        _buildReloadButton(),
        const SizedBox(width: 4),
        Expanded(child: _buildAddressLabel()),
        const SizedBox(width: 4),
        WebBrowserToolbarButton(
          icon: Icons.more_vert_rounded,
          tooltip: S.current.web_browser_more,
          onPressed: onMore,
        ),
      ],
    );
  }

  Widget _buildReloadButton() {
    if (isLoading) {
      return WebBrowserToolbarButton(
        icon: Icons.close_rounded,
        tooltip: S.current.web_browser_stop,
        onPressed: enabled ? onStop : null,
      );
    }
    return WebBrowserToolbarButton(
      icon: Icons.refresh_rounded,
      tooltip: S.current.web_browser_reload,
      onPressed: enabled ? onReload : null,
    );
  }

  Widget _buildAddressLabel() {
    final IconData leadingIcon = isSecure
        ? Icons.lock_rounded
        : Icons.public_rounded;
    return Material(
      color: AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onAddressTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          child: Row(
            children: <Widget>[
              Icon(leadingIcon, size: 14, color: AppColors.mainGrey),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  host,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: medium(size: 13),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WebBrowserToolbarButton extends StatelessWidget {
  const WebBrowserToolbarButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      tooltip: tooltip,
      color: AppColors.mainWhite,
      disabledColor: AppColors.mainGrey.withValues(alpha: 0.4),
      visualDensity: VisualDensity.compact,
      onPressed: onPressed,
    );
  }
}

class WebBrowserProgressBar extends StatelessWidget {
  const WebBrowserProgressBar({
    super.key,
    required this.isLoading,
    required this.progress,
  });

  final bool isLoading;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isLoading ? 1 : 0,
      duration: const Duration(milliseconds: 200),
      child: SizedBox(
        height: 2,
        child: LinearProgressIndicator(
          value: progress > 0 ? progress : null,
          minHeight: 2,
          backgroundColor: AppColors.overlay(0.06),
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
        ),
      ),
    );
  }
}
