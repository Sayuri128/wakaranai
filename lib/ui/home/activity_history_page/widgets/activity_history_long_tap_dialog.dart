import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class ActivityHistoryLongTapDialog<TDomain extends BaseActivityDomain>
    extends StatelessWidget {
  const ActivityHistoryLongTapDialog({
    super.key,
    required this.domain,
    required this.onDelete,
  });

  final BaseActivityDomain domain;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Text(
              domain.title.trim(),
              style: semibold(size: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              onDelete();
              Navigator.of(context).pop();
            },
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.delete_outline_rounded,
                      color: AppColors.red, size: 22),
                  const SizedBox(width: 14),
                  Text(
                    S.current.activity_history_long_tap_dialog_delete_button,
                    style: medium(size: 15, color: AppColors.red),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
