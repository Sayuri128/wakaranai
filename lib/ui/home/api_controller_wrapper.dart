import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/models/remote_config/remote_config.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakascript/api_clients/api_client.dart';

class ApiControllerWrapper<T extends ApiClient> extends StatelessWidget {
  const ApiControllerWrapper(
      {Key? key, required this.remoteConfig, required this.builder})
      : super(key: key);

  final RemoteConfig remoteConfig;
  final Widget Function(T apiClient) builder;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApiClientControllerCubit(
          remoteConfig: remoteConfig,
          remoteConfigsCubit: context.read<RemoteConfigsCubit>())
        ..buildApiClient(),
      child: BlocBuilder<ApiClientControllerCubit, ApiClientControllerState>(
        builder: (context, state) {
          if (state is ApiClientControllerInitialized<T>) {
            return builder(state.apiClient);
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
