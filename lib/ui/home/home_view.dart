import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/configs/configs_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';

import 'configs_group.dart';

class BottomNavigationItem {
  final String title;
  final Widget widget;

  const BottomNavigationItem({
    required this.title,
    required this.widget,
  });
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ConfigsCubit>(
          create: (context) => ConfigsCubit()..getConfigs(),
        )
      ],
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        extendBodyBehindAppBar: true,
        body: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(height: MediaQuery.of(context).padding.top),
                BlocBuilder<ConfigsCubit, ConfigsState>(
                  builder: (context, state) {
                    if (state is ConfigsLoaded) {
                      return SingleChildScrollView(
                          child: Column(
                        children: [_buildConfigs(state), const SizedBox(height: 720)],
                      ));
                    } else {
                      return const CircularProgressIndicator();
                    }
                  },
                )
              ],
            )),
      ),
    );
  }

  Widget _buildConfigs(ConfigsLoaded state) {
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
