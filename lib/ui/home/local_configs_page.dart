import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/local_configs/local_configs_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_group.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakascript/api_clients/manga_api_client.dart';

class LocalConfigsPage extends StatelessWidget {
  const LocalConfigsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 20),
              BlocBuilder<LocalConfigsCubit, LocalConfigsState>(
                builder: (context, state) {
                  if (state is LocalConfigsInitialized) {
                    return _buildConfigs(state);
                  } else {
                    return const Center(child: CircularProgressIndicator(color: AppColors.primary,));
                  }
                },
              )
            ],
          )),
    );
  }

  Widget _buildConfigs(LocalConfigsInitialized state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConfigsGroup<MangaApiClient>(
          title: S.current.home_manga_group_title,
          apiClients: state.mangas.map((e) => e.client).toList(),
        )
      ],
    );
  }
}
