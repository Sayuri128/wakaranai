import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/data/domain/database/base_extension.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/database/extension_repository.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
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
          if (state is ApiClientControllerError) {
            return _buildError(context, state);
          }
          return Material(
            color: AppColors.backgroundColor,
            child: Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        },
      ),
    );
  }

  Widget _buildError(BuildContext context, ApiClientControllerError state) {
    return Material(
      color: AppColors.backgroundColor,
      child: SafeArea(
        child: ServiceViewerMessage(
          icon: Icons.extension_off_rounded,
          title: S.of(context).api_client_error_title,
          message: state.message,
          actions: <Widget>[
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.mainBlack,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () =>
                  context.read<ApiClientControllerCubit>().buildApiClient(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(S.of(context).service_view_retry_button_title),
            ),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.mainWhite,
                side: BorderSide(color: AppColors.overlay(0.16)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
              ),
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(Icons.arrow_back_rounded),
              label: Text(S.of(context).common_go_back),
            ),
          ],
        ),
      ),
    );
  }
}
