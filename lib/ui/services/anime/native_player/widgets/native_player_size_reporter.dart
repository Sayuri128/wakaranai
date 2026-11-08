import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

class NativePlayerSizeReporter extends SingleChildRenderObjectWidget {
  const NativePlayerSizeReporter({
    super.key,
    required this.onSizeChanged,
    super.child,
  });

  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderNativePlayerSizeReporter(onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderNativePlayerSizeReporter renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class RenderNativePlayerSizeReporter extends RenderProxyBox {
  RenderNativePlayerSizeReporter(this.onSizeChanged);

  ValueChanged<Size> onSizeChanged;
  Size? _reportedSize;

  @override
  void performLayout() {
    super.performLayout();
    final Size measured = size;
    if (measured == _reportedSize) {
      return;
    }
    _reportedSize = measured;
    SchedulerBinding.instance.addPostFrameCallback((Duration timeStamp) {
      onSizeChanged(measured);
    });
  }
}
