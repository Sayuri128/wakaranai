import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:wakaranai/blocs/auto_backup/auto_backup_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';

class AutoBackupTiles extends StatelessWidget {
  const AutoBackupTiles({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AutoBackupCubit, AutoBackupState>(
      builder: (BuildContext context, AutoBackupState backup) {
        final AutoBackupCubit cubit = context.read<AutoBackupCubit>();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            SettingsTile(
              icon: Icons.backup_outlined,
              title: S.current.settings_auto_backup_title,
              subtitle: _subtitle(backup),
              trailing: Switch(
                value: backup.enabled,
                activeThumbColor: AppColors.mainBlack,
                activeTrackColor: AppColors.primary,
                onChanged: cubit.setEnabled,
              ),
              onTap: () => cubit.setEnabled(!backup.enabled),
            ),
            if (backup.enabled)
              SettingsTile(
                icon: Icons.save_alt_rounded,
                title: S.current.settings_auto_backup_now,
                trailing: backup.running
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      )
                    : null,
                onTap: backup.running ? null : () => _backUpNow(context, cubit),
              ),
          ],
        );
      },
    );
  }

  Future<void> _backUpNow(BuildContext context, AutoBackupCubit cubit) async {
    final bool saved = await cubit.backUpNow();
    if (!context.mounted) {
      return;
    }
    if (saved) {
      SnackBars.showSnackBar(
        context: context,
        message: S.current.settings_auto_backup_saved,
      );
    } else {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.settings_auto_backup_failed,
      );
    }
  }

  String _subtitle(AutoBackupState backup) {
    if (!backup.enabled) {
      return S.current.settings_auto_backup_off;
    }
    if (backup.failed) {
      return S.current.settings_auto_backup_failed;
    }
    final DateTime? last = backup.lastBackupAt;
    if (last == null) {
      return S.current.settings_auto_backup_never;
    }
    return S.current.settings_auto_backup_last(
      DateFormat.yMMMd().add_Hm().format(last),
    );
  }
}
