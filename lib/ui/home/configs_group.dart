import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/ui/service_viewer/service_viewer.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_controller.dart';

import '../routes.dart';
import 'config_card.dart';

class ConfigsGroup extends StatelessWidget {
  const ConfigsGroup({Key? key, required this.title, required this.apiClients})
      : super(key: key);

  final String title;
  final List<ApiClient> apiClients;

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
                ...apiClients.map((e) => BlocProvider<ApiClientControllerCubit>(
                    create: (context) =>
                        ApiClientControllerCubit(apiClient: e)..getConfigInfo(),
                    child: BlocBuilder<ApiClientControllerCubit,
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

  void _onCardClick(BuildContext context, ApiClient e,
      ApiClientControllerConfigInfo state) async {
    Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.serviceViewer, (route) => false,
        arguments: ServiceViewData(apiClient: e, configInfo: state.configInfo));
  }
}
