import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ServiceViewerAppBar extends StatelessWidget {
  const ServiceViewerAppBar(
      {required this.configInfo,
      required this.apiClient,
      required this.searchController,
      required this.cubit,
      this.state,
      super.key});

  final ServiceViewCubit cubit;
  final ServiceViewInitialized? state;
  final ConfigInfo configInfo;
  final ApiClient apiClient;
  final TextEditingController searchController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  configInfo.name,
                  style: medium(size: 24),
                ),
              ),
              if (configInfo.protectorConfig != null)
                IconButton(
                  icon: const Icon(
                    Icons.explore_rounded,
                    color: AppColors.mainWhite,
                  ),
                  onPressed: () {
                    openWebView(context, apiClient, configInfo);
                  },
                )
            ],
          ),
          if (state != null && configInfo.searchAvailable)
            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: TextField(
                  controller: searchController,
                  onSubmitted: (value) {
                    cubit.search(searchController.text);
                  },
                  cursorColor: AppColors.primary,
                  style: medium(size: 16),
                  decoration: InputDecoration(
                      contentPadding: const EdgeInsets.only(bottom: 4.0),
                      isCollapsed: true,
                      enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary)),
                      focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: AppColors.primary)),
                      hintText: S.current.service_viewer_search_field_hint_text,
                      hintStyle: medium(size: 16)),
                ),
              ),
            )
        ],
      ),
    );
  }
}
