
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/models/protector/protector_storage_item.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';
import 'package:wakascript/api_controller.dart';
import 'package:wakascript/models/config_info/config_info.dart';

import '../routes.dart';
import 'config_card.dart';

class ConfigsGroup extends StatelessWidget {
  const ConfigsGroup({Key? key, required this.title, required this.apiClients})
      : super(key: key);

  final String title;
  final List<ApiClient> apiClients;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(title,
              style: semibold(size: 18, color: AppColors.mainWhite)),
        ),
        const SizedBox(height: 16.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              const SizedBox(width: 16.0),
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
              const SizedBox(width: 16.0)
            ],
          ),
        ),
      ],
    );
  }

  void _onCardClick(BuildContext context, ApiClient e,
      ApiClientControllerConfigInfo state) async {
    final config = await e.getConfigInfo();

    if (config.protectorConfig != null && state.cachedProtector == null) {
      final result = await Navigator.of(context)
          .pushNamed(Routes.webBrowser, arguments: config.protectorConfig);
      if (result != null) {
        await e.passProtector(headers: result as Map<String, String>);
        final ConfigInfo configInfo = await e.getConfigInfo();
        await ProtectorStorageService().saveItem(
            item: ProtectorStorageItem(
                uid: '${configInfo.name}_${configInfo.version}',
                headers: result));
      } else {
        return;
      }
    } else {
      await e.passProtector(headers: state.cachedProtector!.headers);
    }

    Navigator.of(context).pushNamedAndRemoveUntil(
        Routes.serviceViewer, (route) => false,
        arguments: e);
  }
}
