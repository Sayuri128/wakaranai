import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:capyscript/modules/waka_models/models/manga/manga_gallery_view/filters/data/filters/filter_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/gallery_layout/gallery_layout_cubit.dart';
import 'package:wakaranai/blocs/service_view/service_gallery_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/gallery_layout.dart';
import 'package:wakaranai/ui/home/configs_page/extension_settings/extension_settings_entry.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/services/filters/gallery_filters_button.dart';
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
    required this.gallery,
    super.key,
  });

  final ServiceGalleryCubit gallery;
  final ConfigInfo configInfo;
  final ApiClient apiClient;
  final TextEditingController searchController;

  Map<String, FilterData> get _selectedFilters => gallery.state.filters;

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
                ExtensionSettingsButton(config: configInfo, gallery: gallery),
                _buildLayoutButton(),
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
                        onSubmitted: (String value) => gallery.search(value),
                        onClear: () => gallery.search(''),
                      ),
                    ),
                  if (configInfo.searchAvailable && hasFilters)
                    const SizedBox(width: 10),
                  if (hasFilters)
                    if (configInfo.searchAvailable)
                      GalleryFiltersButton(
                        filters: configInfo.filters,
                        selected: _selectedFilters,
                        onApplied: gallery.applyFilters,
                      )
                    else
                      Expanded(
                        child: GalleryFiltersButton(
                          filters: configInfo.filters,
                          selected: _selectedFilters,
                          onApplied: gallery.applyFilters,
                          expanded: true,
                        ),
                      ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutButton() {
    return BlocBuilder<GalleryLayoutCubit, GalleryLayout>(
      builder: (BuildContext context, GalleryLayout layout) =>
          _buildRoundIconButton(
            icon: galleryLayoutIcon(layout),
            tooltip: S.current.gallery_layout_button_tooltip(
              galleryLayoutLabel(layout),
            ),
            onTap: () => context.read<GalleryLayoutCubit>().cycle(),
          ),
    );
  }

  Widget _buildRoundIconButton({
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return IconButton(
      tooltip: tooltip,
      splashRadius: 22,
      icon: Icon(icon, color: AppColors.mainWhite),
      onPressed: onTap,
    );
  }
}
