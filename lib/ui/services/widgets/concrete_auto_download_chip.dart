import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wakaranai/blocs/auto_download/auto_download_settings_cubit.dart';
import 'package:wakaranai/blocs/library/library_cubit.dart';
import 'package:wakaranai/data/domain/database/library_entry_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/auto_download_preferences.dart';
import 'package:wakaranai/services/downloads/auto_download/auto_download_policy.dart';
import 'package:wakaranai/ui/widgets/auto_download_override_sheet.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ConcreteAutoDownloadChip extends StatelessWidget {
  const ConcreteAutoDownloadChip({super.key, required this.concreteUid});

  final String concreteUid;

  @override
  Widget build(BuildContext context) {
    final AutoDownloadSettings settings =
        context.watch<AutoDownloadSettingsCubit>().state;
    final LibraryEntryDomain? entry = context.select(
      (LibraryCubit library) => library.state.entries.firstWhereOrNull(
        (LibraryEntryDomain candidate) => candidate.uid == concreteUid,
      ),
    );
    if (!settings.enabled || entry == null) {
      return const SizedBox.shrink();
    }
    final bool active = AutoDownloadPolicy(settings).appliesTo(entry);
    final Color accent = active ? AppColors.primary : AppColors.mainGrey;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Material(
          color: active
              ? AppColors.primary.withValues(alpha: 0.14)
              : AppColors.overlay(0.06),
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => unawaited(
              showAutoDownloadOverrideSheet(
                context,
                <LibraryEntryDomain>[entry],
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    active
                        ? Icons.downloading_rounded
                        : Icons.file_download_off_outlined,
                    size: 18,
                    color: accent,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      active
                          ? S.of(context).auto_download_chip_on
                          : S.of(context).auto_download_chip_off,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: medium(
                        size: 13,
                        color: active ? AppColors.primary : AppColors.mainWhite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
