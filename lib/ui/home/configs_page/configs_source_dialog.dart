import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/configs_sources/configs_sources_cubit.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/env.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/models/configs_source_item/configs_source_item.dart';
import 'package:wakaranai/models/configs_source_type/configs_source_type.dart';
import 'package:wakaranai/ui/home/configs_page/add_configs_source_dialog.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConfigsSourceDialog extends StatelessWidget {
  const ConfigsSourceDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(
            height: 12,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                S.current.change_configs_source_dialog,
                style: semibold(size: 18),
              ),
            ),
          ),
          const Divider(
            color: AppColors.primary,
          ),
          ListTile(
            onTap: () {
              context.read<RemoteConfigsCubit>().changeSource(ConfigsSourceItem(
                  baseUrl:
                      '${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_ORG}/${Env.OFFICIAL_GITHUB_CONFIGS_SOURCE_REPOSITORY}',
                  type: ConfigsSourceType.GIT_HUB,
                  name: S.current.official_github_configs_source_repository));
              Navigator.of(context).pop();
            },
            title: Text(S.current.official_github_configs_source_repository),
          ),
          BlocBuilder<ConfigsSourcesCubit, ConfigsSourcesState>(
              builder: (context, state) {
            if (state is ConfigsSourcesInitialized) {
              return Column(
                  children: state.sources
                      .map((e) => ListTile(
                            onTap: () {
                              context
                                  .read<RemoteConfigsCubit>()
                                  .changeSource(e);
                              Navigator.of(context).pop();
                            },
                            title: Text(e.name, style: medium()),
                            trailing: IconButton(
                              icon: const Icon(
                                Icons.delete_forever,
                                color: AppColors.red,
                              ),
                              onPressed: () {
                                showOkCancelAlertDialog(
                                        context: context,
                                        title: S.current
                                            .delete_configs_source_confirmation_dialog_title,
                                        message: S.current
                                            .delete_configs_source_confirmation_dialog_message(
                                                e.name))
                                    .then((value) {
                                  if (value.index == 0) {
                                    context
                                        .read<ConfigsSourcesCubit>()
                                        .delete(e);
                                  }
                                });
                              },
                            ),
                          ))
                      .toList());
            } else {
              return const CircularProgressIndicator();
            }
          }),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(AppColors.primary)),
                      onPressed: () {
                        showDialog(
                            context: context,
                            builder: (context) =>
                                const AddConfigsSourceDialog());
                      },
                      child: Text(
                        S.current.add_new_configs_source_button,
                        style: medium(color: AppColors.mainWhite),
                      )),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
