import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/config_info/source_pricing/source_pricing.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/configs_service/extension_listing_status.dart';
import 'package:wakaranai/ui/home/configs_page/configs_filter.dart';
import 'package:wakaranai/ui/home/configs_page/extension_compatibility_texts.dart';
import 'package:wakaranai/ui/widgets/extension_logo.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

enum ConfigCardStyle { card, compact, tile }

class ConfigCard extends StatelessWidget {
  const ConfigCard({
    super.key,
    this.onTap,
    this.onLongPress,
    required this.configInfo,
    this.listingStatus = ExtensionListingStatus.available,
    this.style = ConfigCardStyle.card,
    this.pinned = false,
  });

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ConfigInfo configInfo;
  final ExtensionListingStatus listingStatus;
  final ConfigCardStyle style;
  final bool pinned;

  static const double _disabledOpacity = 0.5;

  @override
  Widget build(BuildContext context) {
    switch (style) {
      case ConfigCardStyle.card:
        return _buildCard(context);
      case ConfigCardStyle.compact:
        return _buildCompact(context);
      case ConfigCardStyle.tile:
        return _buildTile(context);
    }
  }

  Widget _buildCompact(BuildContext context) {
    final String language = configInfo.language.trim();
    return InkWell(
      splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: <Widget>[
            Opacity(
              opacity: _contentOpacity,
              child: _buildLogo(context, size: 36),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Opacity(
                opacity: _contentOpacity,
                child: Text(
                  configInfo.name.trim(),
                  style: medium(size: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            if (configInfo.nsfw) ...<Widget>[
              _buildChip(S.current.home_nsfw_suffix, color: AppColors.red),
              const SizedBox(width: 6),
            ],
            if (_showsPricing) ...<Widget>[
              _buildPricingChip(),
              const SizedBox(width: 6),
            ],
            if (language.isNotEmpty)
              Text(language, style: regular(size: 12, color: AppColors.mainGrey)),
            if (pinned) ...<Widget>[
              const SizedBox(width: 6),
              Icon(Icons.push_pin_rounded, size: 14, color: AppColors.primary),
            ],
            const SizedBox(width: 4),
            _buildTrailingIcon(),
          ],
        ),
      ),
    );
  }

  Widget _buildTile(BuildContext context) {
    return Material(
      color: AppColors.overlay(0.04),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: onTap,
        onLongPress: onLongPress,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Opacity(
            opacity: _contentOpacity,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    _buildLogo(context, size: 52),
                    if (pinned)
                      Positioned(
                        top: -4,
                        right: -4,
                        child: Icon(
                          Icons.push_pin_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  configInfo.name.trim(),
                  style: medium(size: 13),
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _tileCaption(),
                  style: regular(
                    size: 11,
                    color: configInfo.nsfw ? AppColors.red : AppColors.mainGrey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _tileCaption() {
    final List<String> parts = <String>[
      if (configInfo.language.trim().isNotEmpty) configInfo.language.trim(),
      if (configInfo.nsfw) S.current.home_nsfw_suffix,
      if (_showsPricing) pricingLabel(configInfo.pricing),
    ];
    return parts.join(' · ');
  }

  bool get _showsPricing => configInfo.pricing != SourcePricing.free;

  Widget _buildPricingChip() {
    if (configInfo.pricing == SourcePricing.paid) {
      return _buildChip(pricingLabel(configInfo.pricing), color: AppColors.primary);
    }
    return _buildChip(pricingLabel(configInfo.pricing));
  }

  Widget _buildCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Material(
        color: AppColors.overlay(0.04),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: <Widget>[
                Opacity(
                  opacity: _contentOpacity,
                  child: _buildLogo(context),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Opacity(
                        opacity: _contentOpacity,
                        child: Text(
                          configInfo.name.trim(),
                          style: semibold(size: 16),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: <Widget>[
                          if (configInfo.language.trim().isNotEmpty)
                            _buildChip(configInfo.language.trim()),
                          if (configInfo.nsfw)
                            _buildChip(S.current.home_nsfw_suffix,
                                color: AppColors.red),
                          if (_showsPricing) _buildPricingChip(),
                          if (pinned)
                            Icon(
                              Icons.push_pin_rounded,
                              size: 14,
                              color: AppColors.primary,
                            ),
                        ],
                      ),
                      ..._buildStatusMessage(),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _buildTrailingIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double get _contentOpacity {
    if (listingStatus.isDisabled) {
      return _disabledOpacity;
    }
    return 1;
  }

  List<Widget> _buildStatusMessage() {
    final String? message = extensionListingStatusMessage(listingStatus);
    if (message == null) {
      return const <Widget>[];
    }
    final Color color = listingStatus.isDisabled
        ? AppColors.mainGrey
        : AppColors.primary;
    return <Widget>[
      const SizedBox(height: 6),
      Text(
        message,
        style: regular(size: 12, color: color),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    ];
  }

  Widget _buildTrailingIcon() {
    if (listingStatus.isDisabled) {
      return Icon(Icons.system_update_rounded, color: AppColors.mainGrey);
    }
    return Icon(Icons.chevron_right_rounded, color: AppColors.mainGrey);
  }

  Widget _buildLogo(BuildContext context, {double size = 56}) {
    return ExtensionLogo(configInfo: configInfo, size: size);
  }

  Widget _buildChip(String label, {Color? color}) {
    final Color tint = color ?? AppColors.mainGrey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: medium(size: 11, color: color ?? AppColors.mainWhite),
      ),
    );
  }
}
