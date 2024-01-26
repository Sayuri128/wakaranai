import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/service_view/service_view_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ServiceViewerLoader extends StatelessWidget {
  const ServiceViewerLoader({super.key, required this.cubit});

  final ServiceViewCubit cubit;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder(
      bloc: cubit,
      builder: (BuildContext context, Object? state) {
        if (state is ServiceViewInitialized && state.loading) {
          return const Column(
            children: <Widget>[
              SizedBox(
                height: 24,
              ),
              CircularProgressIndicator(color: AppColors.primary),
              SizedBox(
                height: 24,
              ),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}
