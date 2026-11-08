import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/trackers/trackers_cubit.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/services/trackers/tracker_models.dart';
import 'package:wakaranai/ui/home/settings_page/settings_widgets.dart';
import 'package:wakaranai/ui/widgets/confirmation_dialog/confirmation_dialog.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';

class TrackersSettingsSection extends StatelessWidget {
  const TrackersSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TrackersCubit, TrackersState>(
      builder: (BuildContext context, TrackersState state) {
        if (state.available.isEmpty) {
          return const SizedBox.shrink();
        }
        final TrackersCubit cubit = context.read<TrackersCubit>();
        return SettingsSection(
          title: S.current.settings_trackers_title,
          tiles: <Widget>[
            for (final TrackerId id in state.available)
              _buildTile(context, cubit, state, id),
          ],
        );
      },
    );
  }

  Widget _buildTile(
    BuildContext context,
    TrackersCubit cubit,
    TrackersState state,
    TrackerId id,
  ) {
    final TrackerAccount? account = state.accounts[id];
    final bool busy = state.busy == id;
    return SettingsTile(
      icon: account == null ? Icons.sync_disabled_rounded : Icons.sync_rounded,
      title: cubit.nameOf(id),
      subtitle: account == null
          ? S.current.settings_tracker_signed_out
          : S.current.settings_tracker_signed_in(account.userName),
      trailing: busy
          ? SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          : null,
      onTap: busy
          ? null
          : () => unawaited(
                account == null
                    ? _login(context, cubit, id)
                    : _confirmLogout(context, cubit, id),
              ),
    );
  }

  Future<void> _login(
    BuildContext context,
    TrackersCubit cubit,
    TrackerId id,
  ) async {
    final bool signedIn = await cubit.login(id);
    if (signedIn || !context.mounted) {
      return;
    }
    SnackBars.showErrorSnackBar(
      context: context,
      error: S.current.settings_tracker_login_failed(cubit.nameOf(id)),
    );
  }

  Future<void> _confirmLogout(
    BuildContext context,
    TrackersCubit cubit,
    TrackerId id,
  ) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => ConfirmationDialog(
        title: S.current.settings_tracker_logout_title(cubit.nameOf(id)),
        message: S.current.settings_tracker_logout_message,
        yesText: S.current.settings_tracker_logout,
        noText: S.current.downloads_confirm_cancel,
        destructive: true,
      ),
    );
    if (confirmed == true) {
      await cubit.logout(id);
    }
  }
}
