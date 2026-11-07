import 'package:flutter/material.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/utils/app_colors.dart';
import 'package:wakaranai/utils/text_styles.dart';

class WebBrowserDoneButton extends StatefulWidget {
  const WebBrowserDoneButton({
    super.key,
    required this.highlighted,
    required this.busy,
    required this.onPressed,
  });

  final bool highlighted;
  final bool busy;
  final VoidCallback? onPressed;

  @override
  State<WebBrowserDoneButton> createState() => _WebBrowserDoneButtonState();
}

class _WebBrowserDoneButtonState extends State<WebBrowserDoneButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  );

  @override
  void initState() {
    super.initState();
    _syncPulse();
  }

  @override
  void didUpdateWidget(covariant WebBrowserDoneButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.highlighted != widget.highlighted) {
      _syncPulse();
    }
  }

  void _syncPulse() {
    if (widget.highlighted) {
      _pulseController.repeat(reverse: true);
    } else {
      _pulseController.stop();
      _pulseController.value = 0;
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (BuildContext context, Widget? child) {
        final double pulse = Curves.easeInOut.transform(_pulseController.value);
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              width: 3,
              color: widget.highlighted
                  ? AppColors.primary.withValues(alpha: 0.2 + 0.4 * pulse)
                  : Colors.transparent,
            ),
          ),
          child: Padding(padding: const EdgeInsets.all(3), child: child),
        );
      },
      child: SizedBox(
        height: 50,
        width: double.infinity,
        child: ElevatedButton(
          onPressed: widget.onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.mainBlack,
            disabledBackgroundColor: AppColors.overlay(0.08),
            disabledForegroundColor: AppColors.mainGrey,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _buildLabel(),
        ),
      ),
    );
  }

  Widget _buildLabel() {
    if (widget.busy) {
      return SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: AppColors.mainGrey,
        ),
      );
    }
    final String label = widget.highlighted
        ? S.current.web_browser_looks_good
        : S.current.web_browser_no_login_button;
    final Color labelColor = widget.onPressed == null
        ? AppColors.mainGrey
        : AppColors.mainBlack;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        if (widget.highlighted) ...<Widget>[
          Icon(Icons.check_circle_rounded, size: 20, color: labelColor),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: semibold(size: 16, color: labelColor),
          ),
        ),
      ],
    );
  }
}
