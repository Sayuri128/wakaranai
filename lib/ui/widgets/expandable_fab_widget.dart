import 'package:flutter/material.dart';

enum ExpandableFabDirection {
  left,
  top,
}

class ExpandableFabItemData {
  final Widget icon;
  final VoidCallback? onPressed;

  const ExpandableFabItemData({
    required this.icon,
    this.onPressed,
  });
}

class ExpandableFabWidget extends StatefulWidget {
  const ExpandableFabWidget({
    super.key,
    required this.child,
    required this.expanded,
    required this.items,
  });

  final Widget child;
  final bool expanded;
  final Map<ExpandableFabDirection, List<ExpandableFabItemData>> items;

  @override
  State<ExpandableFabWidget> createState() => _ExpandableFabWidgetState();
}

class _ExpandableFabWidgetState extends State<ExpandableFabWidget>
    with TickerProviderStateMixin {
  final Map<ExpandableFabDirection, List<AnimationController>> _controllers =
      {};

  static const Duration _delayBetweenItems = Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();

    for (final entry in widget.items.entries) {
      if (!_controllers.containsKey(entry.key)) {
        _controllers[entry.key] = [];
      }
      for (final item in entry.value) {
        _controllers[entry.key]!.add(AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 200),
        ));
      }
    }
  }

  @override
  void dispose() {
    for (final list in _controllers.values) {
      for (final controller in list) {
        controller.dispose();
      }
    }
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ExpandableFabWidget oldWidget) {
    if (widget != oldWidget) {
      for (final item in _controllers.values) {
        (() async {
          if (widget.expanded) {
            for (int i = 0; i < item.length; i++) {
              await Future<void>.delayed(
                _delayBetweenItems,
              );
              item[i].forward();
            }
          } else {
            for (int i = 0; i < item.length; i++) {
              await Future<void>.delayed(
                _delayBetweenItems,
              );
              item[i].reverse();
            }
          }
        })();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: <Widget>[
        for (final items in _controllers.entries)
          for (int i = 0; i < items.value.length; i++)
            AnimatedBuilder(
              animation: items.value[i],
              child: IgnorePointer(
                ignoring: !widget.expanded,
                child: InkWell(
                  onTap: widget.items[items.key]![i].onPressed,
                  child: widget.items[items.key]![i].icon,
                ),
              ),
              builder: (
                context,
                child,
              ) {
                return Positioned(
                  bottom: 16.0 +
                      (items.key == ExpandableFabDirection.top
                          ? (_controllers[items.key]![i].value * (i + 1) * 56)
                          : 0),
                  right: 16.0 +
                      (items.key == ExpandableFabDirection.left
                          ? (_controllers[items.key]![i].value * (i + 1) * 56)
                          : 0),
                  child: Opacity(
                    opacity: _controllers[items.key]![i].value,
                    child: child!,
                  ),
                );
              },
            ),
        Positioned(
          bottom: 16.0,
          right: 16.0,
          child: widget.child,
        ),
      ],
    );
  }
}
