import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/configs_group.dart';
import 'package:wakaranai/ui/home/configs_source_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class RemoteConfigPage extends StatelessWidget {
  const RemoteConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              Container(
                decoration:
                    BoxDecoration(color: AppColors.backgroundColor, boxShadow: [
                  BoxShadow(
                      color: AppColors.mainBlack.withOpacity(0.5),
                      blurRadius: 8,
                      spreadRadius: 2)
                ]),
                child: Padding(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 12, bottom: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.center,
                        child: Text("Configs", style: medium(size: 24)),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      const ConfigsSourceDialog());
                            },
                            icon: const Icon(
                              Icons.filter_list_rounded,
                              color: AppColors.mainWhite,
                            )),
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
                  builder: (context, state) {
                    if (state is RemoteConfigsLoaded) {
                      return Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).padding.top + 20),
                        child:
                            SingleChildScrollView(child: _buildConfigs(state)),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              ),
            ],
          ),
          Align(
            alignment: Alignment.center,
            child: BlocBuilder<RemoteConfigsCubit, RemoteConfigsState>(
              builder: (context, state) {
                if (state is RemoteConfigsError) {
                  return Center(
                      child: Text(
                    state.message,
                    style: regular(size: 18, color: AppColors.red),
                  ));
                } else if (state is RemoteConfigsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          )
        ],
      ),
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
