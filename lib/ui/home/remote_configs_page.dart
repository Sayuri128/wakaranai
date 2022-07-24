import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_group.dart';
import 'package:wakaranai/utils/app_colors.dart';

class RemoteConfigPage extends StatelessWidget {
  const RemoteConfigPage({Key? key}) : super(key: key);

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
              BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
                builder: (context, state) {
                  if (state is RemoteConfigsLoaded) {
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

  Widget _buildConfigs(RemoteConfigsLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ConfigsGroup(
          title: S.current.home_manga_group_title,
          apiClients: state.mangaApiClients,
        )
      ],
    );
  }
}
