import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wakaranai/utils/page_bitmap.dart';
import 'package:wakaranai/utils/page_bitmap_cache.dart';

export 'package:wakaranai/utils/page_bitmap.dart'
    show PageBitmap, isLocalPagePath, loadPageBitmap;

// Conservative cap for the thumbnail provider only. Page rendering never uses
// it: the engine already clamps a decode to the GPU max texture size, and
// hardcoding a smaller limit throws away resolution on capable devices.
const int _thumbnailMaxDimension = 2048;

ImageProvider pageImageProvider(String path, Map<String, String> headers) {
  return PageImageProvider(path, headers);
}

Future<void> evictPage(String path, Map<String, String> headers) async {
  PaintingBinding.instance.imageCache.evict(PageImageProvider(path, headers));
  await PageBitmapCache.instance.evict(path);
}

void prefetchPages(Iterable<String> paths, Map<String, String> headers) {
  for (final String path in paths) {
    PageBitmapCache.instance.prefetch(path, headers);
  }
}

/// Renders a page at the highest resolution the GPU allows, correcting the
/// aspect ratio the engine loses when it clamps a tall strip.
///
/// With [intrinsic] the widget sizes itself to the source dimensions, as an
/// [Image] would, for parents that need unbounded layout (photo_view).
/// Otherwise it fills the available width. [onSizeResolved] fires once the
/// source dimensions are known.
class PageImage extends StatefulWidget {
  const PageImage({
    super.key,
    required this.path,
    required this.headers,
    this.intrinsic = false,
    this.onSizeResolved,
    this.loadingBuilder,
    this.errorBuilder,
  });

  final String path;
  final Map<String, String> headers;
  final bool intrinsic;
  final ValueChanged<Size>? onSizeResolved;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(BuildContext context, VoidCallback retry)? errorBuilder;

  @override
  State<PageImage> createState() => _PageImageState();
}

class _PageImageState extends State<PageImage> {
  PageBitmap? _bitmap;
  Object? _error;
  PageBitmapLease? _lease;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _releaseCurrent();
      _bitmap = null;
      _error = null;
      _load();
    }
  }

  @override
  void dispose() {
    _releaseCurrent();
    super.dispose();
  }

  void _releaseCurrent() {
    _lease?.release();
    _lease = null;
  }

  Future<void> _load() async {
    final PageBitmapLease lease =
        PageBitmapCache.instance.acquire(widget.path, widget.headers);
    _lease = lease;
    try {
      final PageBitmap bitmap = await lease.bitmap;
      if (!mounted || !identical(_lease, lease)) {
        return;
      }
      setState(() {
        _bitmap = bitmap;
        _error = null;
      });
      widget.onSizeResolved?.call(bitmap.size);
    } catch (e) {
      if (!mounted || !identical(_lease, lease)) {
        return;
      }
      setState(() => _error = e);
    }
  }

  Future<void> _retry() async {
    _releaseCurrent();
    setState(() {
      _error = null;
      _bitmap = null;
    });
    await evictPage(widget.path, widget.headers);
    await _load();
  }

  Widget _placeholder(BuildContext context) {
    final Widget child =
        widget.loadingBuilder?.call(context) ?? const SizedBox();
    if (widget.intrinsic) return child;

    final Size? known = PageBitmapCache.instance.knownSize(widget.path);
    if (known == null) return child;
    return AspectRatio(
        aspectRatio: known.width / known.height, child: child);
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _retry) ?? const SizedBox();
    }
    final PageBitmap? bitmap = _bitmap;
    if (bitmap == null) {
      return _placeholder(context);
    }
    final CustomPaint painter = CustomPaint(
      size: widget.intrinsic ? bitmap.size : Size.infinite,
      painter: _PageBitmapPainter(bitmap.image),
    );
    if (widget.intrinsic) {
      return SizedBox.fromSize(size: bitmap.size, child: painter);
    }
    return AspectRatio(aspectRatio: bitmap.aspectRatio, child: painter);
  }
}

class _PageBitmapPainter extends CustomPainter {
  const _PageBitmapPainter(this.image);

  final ui.Image image;

  @override
  void paint(ui.Canvas canvas, Size size) {
    canvas.drawImageRect(
      image,
      Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble()),
      Offset.zero & size,
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_PageBitmapPainter oldDelegate) =>
      oldDelegate.image != image;
}

/// Downscales uniformly to a thumbnail-sized texture. Only appropriate for the
/// reader's slider preview; page rendering goes through [PageImage].
class PageImageProvider extends ImageProvider<PageImageProvider> {
  const PageImageProvider(this.path, this.headers);

  final String path;
  final Map<String, String> headers;

  @override
  Future<PageImageProvider> obtainKey(ImageConfiguration configuration) =>
      SynchronousFuture<PageImageProvider>(this);

  @override
  ImageStreamCompleter loadImage(
      PageImageProvider key, ImageDecoderCallback decode) {
    return MultiFrameImageStreamCompleter(
      codec: _loadCodec(decode),
      scale: 1.0,
      debugLabel: path,
    );
  }

  Future<ui.Codec> _loadCodec(ImageDecoderCallback decode) async {
    final Uint8List bytes = await loadPageBytes(path, headers);
    if (isAvif(bytes)) {
      return _decodeAvif(bytes);
    }
    final ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromUint8List(bytes);
    return decode(buffer, getTargetSize: _fitTargetSize);
  }

  static ui.TargetImageSize _fitTargetSize(int width, int height) {
    if (width <= _thumbnailMaxDimension && height <= _thumbnailMaxDimension) {
      return ui.TargetImageSize(width: width, height: height);
    }
    final double scale = min(
        _thumbnailMaxDimension / width, _thumbnailMaxDimension / height);
    return ui.TargetImageSize(
      width: max(1, (width * scale).round()),
      height: max(1, (height * scale).round()),
    );
  }

  static Future<ui.Codec> _decodeAvif(Uint8List bytes) async {
    final avifFrame = await decodeAvifFrame(bytes);
    final ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromUint8List(framePixels(avifFrame));
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: avifFrame.width,
      height: avifFrame.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final ui.TargetImageSize target =
        _fitTargetSize(avifFrame.width, avifFrame.height);
    return descriptor.instantiateCodec(
      targetWidth: target.width,
      targetHeight: target.height,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is PageImageProvider && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
