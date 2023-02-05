import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/ui/anime_service_viewer/anime_service_viewer.dart';
import 'package:wakaranai/ui/manga_service_viewer/manga_service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_clients/anime_api_client.dart';
import 'package:wakascript/api_clients/api_client.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';

import '../routes.dart';
import 'config_card.dart';

class ConfigsGroup<T extends ApiClient> extends StatelessWidget {
  const ConfigsGroup({Key? key, required this.title, required this.apiClients})
      : super(key: key);

  final String title;
  final List<T> apiClients;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(title,
                style: semibold(size: 18, color: AppColors.mainWhite)),
          ),
          const SizedBox(height: 16.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6.0),
            child: Wrap(
              children: [
                ...apiClients.map((e) =>
                    BlocProvider<ApiClientControllerCubit<T>>(
                        create: (context) =>
                            ApiClientControllerCubit(apiClient: e)
                              ..getConfigInfo(),
                        child: BlocBuilder<ApiClientControllerCubit<T>,
                            ApiClientControllerState>(
                          builder: (context, state) {
                            if (state is ApiClientControllerConfigInfo) {
                              return ConfigCard(
                                  configInfo: state.configInfo,
                                  onTap: () {
                                    _onCardClick(context, e, state);
                                  });
                            } else {
                              return const SizedBox();
                            }
                          },
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCardClick(
      BuildContext context, T e, ApiClientControllerConfigInfo state) async {
    if (e is MangaApiClient) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.mangaServiceViewer, (route) => false,
          arguments:
              MangaServiceViewData(apiClient: e, configInfo: state.configInfo));
    } else if (e is AnimeApiClient) {
      Navigator.of(context).pushNamedAndRemoveUntil(
          Routes.animeServiceViewer, (route) => false,
          arguments: AnimeServiceViewerData(
              apiClient: e, configInfo: state.configInfo));
    }
  }
}
