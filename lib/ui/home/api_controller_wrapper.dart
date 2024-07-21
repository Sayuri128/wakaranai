import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/home/configs_page/bloc/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ApiControllerWrapper<T extends ApiClient> extends StatelessWidget {
  const ApiControllerWrapper(
      {super.key, required this.remoteConfig, required this.builder});

  final BaseExtension? remoteConfig;
  final Widget Function(T apiClient, ConfigInfo) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => ApiClientControllerCubit(
        remoteConfig: remoteConfig,
        remoteConfigsCubit: context.read<RemoteConfigsCubit>(),
        extensionRepository: context.read<ExtensionRepository>(),
      )..buildApiClient(),
      child: BlocBuilder<ApiClientControllerCubit, ApiClientControllerState>(
        builder: (BuildContext context, ApiClientControllerState state) {
          if (state is ApiClientControllerInitialized<T>) {
            return builder(state.apiClient, state.configInfo);
          }
          return const Material(
            color: AppColors.backgroundColor,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }
}
