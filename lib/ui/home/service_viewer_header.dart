import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

/// Header for the service viewer page. Replaces the old app bar: a compact
/// source title row plus a modern pill-shaped search field, laid out as normal
/// page content (no Material [AppBar]).
class ServiceViewerHeader extends StatelessWidget {
  const ServiceViewerHeader({
    required this.configInfo,
    required this.apiClient,
    required this.searchController,
    required this.cubit,
    super.key,
  });

  final ServiceViewCubit cubit;
  final ConfigInfo configInfo;
  final ApiClient apiClient;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    configInfo.name,
                    style: semibold(size: 24),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (configInfo.protectorConfig != null)
                  _buildRoundIconButton(
                    icon: Icons.explore_rounded,
                    onTap: () => openWebView(context, apiClient, configInfo),
                  ),
              ],
            ),
            if (configInfo.searchAvailable) ...<Widget>[
              const SizedBox(height: 12),
              _buildSearchField(context),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        children: <Widget>[
          const SizedBox(width: 16),
          const Icon(
            Icons.search_rounded,
            color: AppColors.mainGrey,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: searchController,
              onSubmitted: (String value) => cubit.search(value),
              textInputAction: TextInputAction.search,
              cursorColor: AppColors.primary,
              style: medium(size: 16),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: S.current.service_viewer_search_field_hint_text,
                hintStyle: medium(size: 16, color: AppColors.mainGrey),
              ),
            ),
          ),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: searchController,
            builder: (BuildContext context, TextEditingValue value, _) {
              if (value.text.isEmpty) {
                return const SizedBox(width: 12);
              }
              return IconButton(
                splashRadius: 20,
                icon: const Icon(
                  Icons.close_rounded,
                  color: AppColors.mainGrey,
                  size: 20,
                ),
                onPressed: () {
                  searchController.clear();
                  cubit.search('');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRoundIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return IconButton(
      splashRadius: 22,
      icon: Icon(icon, color: AppColors.mainWhite),
      onPressed: onTap,
    );
  }
}
