import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';

import '../routes.dart';

class ServiceView extends StatelessWidget {
  const ServiceView({Key? key, required this.apiClient}) : super(key: key);

  final ApiClient apiClient;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pushNamedAndRemoveUntil(Routes.home, (route) => false);
        return Future.value(false);
      },
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ApiClientControllerCubit>(
              create: (context) => ApiClientControllerCubit(apiClient: apiClient)..getConfigInfo())
        ],
        child: Scaffold(
          backgroundColor: AppColors.backgroundColor,
          extendBodyBehindAppBar: true,
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [],
          ),
        ),
      ),
    );
  }
}
