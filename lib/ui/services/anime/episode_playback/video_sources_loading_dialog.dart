import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class VideoSourcesLoadingHandle {
  VideoSourcesLoadingHandle._(this._navigator, this._route);

  final NavigatorState _navigator;
  final Route<void> _route;
  bool _cancelledByUser = false;
  bool _closed = false;

  bool get cancelledByUser => _cancelledByUser;

  void _markCancelled() {
    if (!_closed) {
      _cancelledByUser = true;
    }
  }

  void close() {
    if (_closed || _cancelledByUser) {
      return;
    }
    _closed = true;
    if (_route.isCurrent) {
      _navigator.pop();
      return;
    }
    if (_route.isActive) {
      _navigator.removeRoute(_route);
    }
  }
}

VideoSourcesLoadingHandle showVideoSourcesLoading(BuildContext context) {
  final NavigatorState navigator = Navigator.of(context);
  late final VideoSourcesLoadingHandle handle;
  final DialogRoute<void> route = DialogRoute<void>(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext dialogContext) => PopScope(
      onPopInvokedWithResult: (bool didPop, Object? result) {
        if (didPop) {
          handle._markCancelled();
        }
      },
      child: const VideoSourcesLoadingDialog(),
    ),
  );
  handle = VideoSourcesLoadingHandle._(navigator, route);
  navigator.push(route);
  return handle;
}

class VideoSourcesLoadingDialog extends StatelessWidget {
  const VideoSourcesLoadingDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.dialogSurface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 64, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(
              width: 32,
              height: 32,
              child: CircularProgressIndicator(
                color: AppColors.primary,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              S.of(context).episode_playback_loading_sources,
              textAlign: TextAlign.center,
              style: medium(size: 15),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).maybePop(),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.mainGrey,
              ),
              child: Text(S.of(context).common_cancel),
            ),
          ],
        ),
      ),
    );
  }
}
