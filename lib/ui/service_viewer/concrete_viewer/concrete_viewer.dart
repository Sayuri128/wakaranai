import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/api_client_controller/api_client_controller_cubit.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai_json_runtime/api/api_client.dart';

class ConcreteViewerData {
  final String uid;
  final ApiClient client;

  const ConcreteViewerData({
    required this.uid,
    required this.client,
  });
}

class ConcreteViewer extends StatelessWidget {
  const ConcreteViewer({Key? key, required this.data}) : super(key: key);

  final ConcreteViewerData data;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ApiClientControllerCubit>(
          create: (context) =>
              ApiClientControllerCubit(apiClient: data.client)..getConcrete(data.uid),
        )
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBodyBehindAppBar: true,
        body: BlocBuilder<ApiClientControllerCubit, ApiClientControllerState>(
          builder: (context, state) {
            if (state is ApiClientControllerConcreteView) {
              return Column(
                children: [
                  const SizedBox(height: 150),
                  Text(state.concreteView
                      .toJson()
                      .entries
                      .map((e) => '${e.key} : ${e.value}')
                      .join('\n'))
                ],
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
