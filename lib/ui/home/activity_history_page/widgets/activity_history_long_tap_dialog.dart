import 'package:flutter/material.dart';
import 'package:wakaranai/data/domain/base_domain.dart';
import 'package:wakaranai/data/domain/database/base_activity_domain.dart';
import 'package:wakaranai/data/domain/ui/activity_list_item.dart';
import 'package:wakaranai/generated/l10n.dart';

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
    return AlertDialog(
      title: Text(domain.title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(S.current.activity_history_long_tap_dialog_delete_button),
            onTap: () {
              onDelete();
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }
}
