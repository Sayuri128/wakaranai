import 'package:flutter/material.dart';
import 'package:wakaranai/utils/app_colors.dart';

class SettingsOverlayEntry {
  final VoidCallback onTap;
  final Widget icon;

  const SettingsOverlayEntry({
    required this.onTap,
    required this.icon,
  });
}

class SettingsOverlay extends StatefulWidget {
  const SettingsOverlay({Key? key, required this.child, required this.entries})
      : super(key: key);

  final List<SettingsOverlayEntry> entries;

  final Widget child;

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _settingsOverlayAnimationController;
  final List<Animation<double>> _settingsOverlaysAnimation = [];

  bool _showOverlay = false;

  @override
  void initState() {
    _settingsOverlayAnimationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500))
      ..addListener(() {
        if (mounted) {
          setState(() {});
        }
      });

    for (int i = widget.entries.length; i > 0; i--) {
      _settingsOverlaysAnimation.add(Tween<double>(begin: 0.0, end: 1.0)
          .animate(CurvedAnimation(
              parent: _settingsOverlayAnimationController,
              curve: Interval(0.2 * i, 1.0, curve: Curves.easeOutCubic))));
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_showOverlay)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (int i = 0; i < _settingsOverlaysAnimation.length; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ScaleTransition(
                    scale: _settingsOverlaysAnimation[i],
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.backgroundColor),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(32),
                          onTap: widget.entries[i].onTap,
                          child: widget.entries[i].icon,
                        ),
                      ),
                    ),
                  ),
                )
            ],
          ),
        const SizedBox(
          height: 8,
        ),
        InkWell(
            onTap: () async {
              if (!_showOverlay) {
                _showOverlay = !_showOverlay;
                _settingsOverlayAnimationController.forward().then((value) {
                  setState(() {});
                });
              } else {
                _settingsOverlayAnimationController.reverse().then((value) {
                  _showOverlay = !_showOverlay;
                  setState(() {});
                });
              }
            },
            child: widget.child),
      ],
    );
  }
}
