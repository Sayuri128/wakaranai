import 'package:capyscript/modules/waka_models/models/config_info/protector_config/protector_config.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/data/models/protector/protector_storage_item.dart';
import 'package:wakaranai/data/models/web_browser_result/web_browser_result.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/repositories/shared_pref/source_attention_preferences.dart';
import 'package:wakaranai/services/configs_service/source_needs_attention.dart';
import 'package:wakaranai/services/library_updates/source_attention_text.dart';
import 'package:wakaranai/services/protector_storage/protector_storage_service.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/routes.dart';
import 'package:wakaranai/ui/widgets/action_sheet.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

class SourceAttentionPrompt {
  const SourceAttentionPrompt._();

  static void show(
    BuildContext context,
    List<SourceNeedsAttention> attentions,
  ) {
    if (attentions.isEmpty) {
      return;
    }
    if (attentions.length == 1) {
      final SourceNeedsAttention attention = attentions.single;
      SnackBars.showAttentionSnackBar(
        context: context,
        message: SourceAttentionText.message(attention),
        action: SnackBarActionData(
          label: S.current.updates_attention_action_open,
          onPressed: () => openSession(context, attention),
        ),
      );
      return;
    }
    SnackBars.showAttentionSnackBar(
      context: context,
      message: S.current.updates_attention_many(attentions.length),
      action: SnackBarActionData(
        label: S.current.updates_attention_action_review,
        onPressed: () => _showSheet(context, attentions),
      ),
    );
  }

  static Future<void> _showSheet(
    BuildContext context,
    List<SourceNeedsAttention> attentions,
  ) {
    if (!context.mounted) {
      return Future<void>.value();
    }
    return showActionSheet(
      context,
      title: S.current.updates_attention_sheet_title,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          for (final SourceNeedsAttention attention in attentions)
            Builder(
              builder: (BuildContext rowContext) => ActionSheetRow(
                label: SourceAttentionText.message(attention),
                icon: Icons.lock_outline_rounded,
                onTap: () {
                  Navigator.of(rowContext).pop();
                  openSession(context, attention);
                },
              ),
            ),
        ],
      ),
    );
  }

  static Future<void> openSession(
    BuildContext context,
    SourceNeedsAttention attention,
  ) async {
    if (!context.mounted) {
      return;
    }
    final ProtectorConfig? protector = attention.config.protectorConfig;
    if (protector == null) {
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.updates_attention_unavailable(attention.sourceName),
      );
      return;
    }

    final ProtectorStorageService storage = ProtectorStorageService();
    final ProtectorStorageItem? current =
        await storage.getItemForConfig(attention.config);
    if (!context.mounted) {
      return;
    }

    final Object? result = await Navigator.of(context).pushNamed(
      Routes.webBrowser,
      arguments: WebBrowserData(
        config: protector,
        protectorStorageItem: current,
      ),
    );
    if (result is! WebBrowserPageResult) {
      return;
    }

    await storage.saveItem(
      item: ProtectorStorageItem(uid: attention.sessionKey, data: result),
    );
    await SourceAttentionPreferences().clear(attention.sessionKey);

    if (!context.mounted) {
      return;
    }
    SnackBars.showSnackBar(
      context: context,
      message: S.current.updates_attention_session_saved(attention.sourceName),
    );
  }
}
