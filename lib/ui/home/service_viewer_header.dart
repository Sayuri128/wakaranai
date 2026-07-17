import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/services/filters/gallery_filters_sheet.dart';
import 'package:wakaranai/ui/widgets/search_field.dart';
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

  Map<String, FilterData> get _selectedFilters {
    final ServiceViewState state = cubit.state;
    if (state is ServiceViewInitialized) {
      return state.selectedFilters;
    }
    return const <String, FilterData>{};
  }

  @override
  Widget build(BuildContext context) {
    final bool hasFilters = configInfo.filters.isNotEmpty;
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
            if (configInfo.searchAvailable || hasFilters) ...<Widget>[
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  if (configInfo.searchAvailable)
                    Expanded(
                      child: SearchField(
                        controller: searchController,
                        hintText:
                            S.current.service_viewer_search_field_hint_text,
                        onSubmitted: (String value) => cubit.search(value),
                        onClear: () => cubit.search(''),
                      ),
                    ),
                  if (configInfo.searchAvailable && hasFilters)
                    const SizedBox(width: 10),
                  if (hasFilters)
                    _buildFilterButton(
                      context,
                      count: _selectedFilters.length,
                      expanded: !configInfo.searchAvailable,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(
    BuildContext context, {
    required int count,
    required bool expanded,
  }) {
    final Widget button = Material(
      color: count > 0 ? AppColors.primary.withValues(alpha: 0.16) : AppColors.overlay(0.06),
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        splashColor: AppColors.mediumLight.withValues(alpha: 0.2),
        onTap: () => _openFilters(context),
        child: Container(
          height: 48,
          padding: EdgeInsets.symmetric(horizontal: expanded ? 20 : 14),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: expanded ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.tune_rounded,
                size: 22,
                color: count > 0 ? AppColors.primary : AppColors.mainGrey,
              ),
              if (expanded) ...<Widget>[
                const SizedBox(width: 8),
                Text(
                  S.current.gallery_filters_button_label,
                  style: medium(
                    size: 15,
                    color: count > 0 ? AppColors.primary : AppColors.mainWhite,
                  ),
                ),
              ],
              if (count > 0) ...<Widget>[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '$count',
                    style: medium(size: 12, color: AppColors.mainBlack),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );

    return expanded ? Expanded(child: button) : button;
  }

  Future<void> _openFilters(BuildContext context) async {
    final Map<String, FilterData>? result = await showGalleryFiltersSheet(
      context,
      filters: configInfo.filters,
      current: _selectedFilters,
    );
    if (result == null) return;
    cubit.applyFilters(result);
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
