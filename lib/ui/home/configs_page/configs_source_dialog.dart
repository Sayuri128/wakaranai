import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/remote_configs/remote_configs_cubit.dart';
import 'package:wakaranai/blocs/settings/settings_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
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
              context
                  .read<RemoteConfigsCubit>()
                  .changeSource(SettingsCubit.DefaultConfigsServiceItem);
              Navigator.of(context).pop();
            },
            title: Text(S.current.official_github_configs_source_repository),
          ),
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
