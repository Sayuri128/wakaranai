import 'package:capyscript/api_clients/api_client.dart';
import 'package:capyscript/modules/waka_models/models/config_info/config_info.dart';
import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/ui/common/service_viewer/service_viewer_message.dart';
import 'package:wakaranai/ui/home/web_browser_page.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/source_error_description.dart';

SourceErrorDescription? describeSourceErrorFor(
  Object? error,
  ConfigInfo configInfo,
) {
  return describeSourceError(
    error,
    sourceName: configInfo.name,
    canSignIn: configInfo.protectorConfig != null,
  );
}

Future<void> signInToSource(
  BuildContext context, {
  required ApiClient apiClient,
  required ConfigInfo configInfo,
  required VoidCallback onSignedIn,
}) async {
  final bool signedIn = await openWebView(context, apiClient, configInfo);
  if (signedIn) {
    onSignedIn();
  }
}

void showSourceErrorSnackBar(
  BuildContext context, {
  required SourceErrorDescription description,
  VoidCallback? onRetry,
  VoidCallback? onSignIn,
}) {
  if (description.offersSignIn && onSignIn != null) {
    SnackBars.showActionSnackBar(
      context: context,
      message: description.summary,
      icon: description.icon,
      action: SnackBarActionData(
        label: S.current.source_error_sign_in_button,
        onPressed: onSignIn,
      ),
    );
    return;
  }
  if (description.offersRetry && onRetry != null) {
    SnackBars.showActionSnackBar(
      context: context,
      message: description.summary,
      icon: description.icon,
      action: SnackBarActionData(
        label: S.current.source_error_retry_button,
        onPressed: onRetry,
      ),
    );
    return;
  }
  SnackBars.showErrorSnackBar(context: context, error: description.summary);
}

class SourceErrorView extends StatelessWidget {
  const SourceErrorView({
    super.key,
    required this.description,
    this.onRetry,
    this.onSignIn,
    this.extraActions = const <SourceErrorExtraAction>[],
  });

  final SourceErrorDescription description;
  final VoidCallback? onRetry;
  final VoidCallback? onSignIn;
  final List<SourceErrorExtraAction> extraActions;

  @override
  Widget build(BuildContext context) {
    return ServiceViewerMessage(
      icon: description.icon,
      title: description.title,
      message: description.detail,
      actions: _buildActions(),
    );
  }

  List<Widget> _buildActions() {
    final List<SourceErrorExtraAction> specs = <SourceErrorExtraAction>[
      ..._builtInActions(),
      ...extraActions,
    ];
    final List<Widget> buttons = <Widget>[];
    for (int index = 0; index < specs.length; index++) {
      buttons.add(_buildButton(specs[index], primary: index == 0));
    }
    return buttons;
  }

  List<SourceErrorExtraAction> _builtInActions() {
    final List<SourceErrorExtraAction> specs = <SourceErrorExtraAction>[];
    final VoidCallback? signIn = onSignIn;
    if (description.offersSignIn && signIn != null) {
      specs.add(SourceErrorExtraAction(
        icon: Icons.login_rounded,
        label: S.current.source_error_sign_in_button,
        onPressed: signIn,
      ));
    }
    final VoidCallback? retry = onRetry;
    if (description.offersRetry && retry != null) {
      specs.add(SourceErrorExtraAction(
        icon: Icons.refresh_rounded,
        label: S.current.source_error_retry_button,
        onPressed: retry,
      ));
    }
    return specs;
  }

  Widget _buildButton(SourceErrorExtraAction spec, {required bool primary}) {
    if (primary) {
      return ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.mainBlack,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        onPressed: spec.onPressed,
        icon: Icon(spec.icon),
        label: Text(spec.label),
      );
    }
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.mainWhite,
        side: BorderSide(color: AppColors.mainGrey),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      onPressed: spec.onPressed,
      icon: Icon(spec.icon),
      label: Text(spec.label),
    );
  }
}

class SourceErrorExtraAction {
  const SourceErrorExtraAction({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;
}
