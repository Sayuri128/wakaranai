import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart'
    as avif_platform;
import 'package:flutter_avif_platform_interface/models/frame.pb.dart'
    as avif_models;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

// Conservative cap for the thumbnail provider only. Page rendering never uses
// it: the engine already clamps a decode to the GPU max texture size, and
// hardcoding a smaller limit throws away resolution on capable devices.
const int _thumbnailMaxDimension = 2048;

bool isLocalPagePath(String path) =>
    !path.startsWith('http') && !path.startsWith('data:');

ImageProvider pageImageProvider(String path, Map<String, String> headers) {
  return PageImageProvider(path, headers);
}

Future<void> evictPage(String path, Map<String, String> headers) async {
  PaintingBinding.instance.imageCache.evict(PageImageProvider(path, headers));
  if (!isLocalPagePath(path)) {
    await DefaultCacheManager().removeFile(path);
  }
}

Future<Uint8List> _loadPageBytes(
    String path, Map<String, String> headers) async {
  if (path.startsWith('data:')) {
    return base64Decode(path.split(',').last);
  }
  if (isLocalPagePath(path)) {
    return File(path).readAsBytes();
  }
  final File file =
      await DefaultCacheManager().getSingleFile(path, headers: headers);
  return file.readAsBytes();
}

bool _isAvif(Uint8List bytes) {
  if (bytes.length < 12) {
    return false;
  }
  const String ftyp = 'ftyp';
  for (int i = 0; i < 4; i++) {
    if (bytes[4 + i] != ftyp.codeUnitAt(i)) {
      return false;
    }
  }
  return bytes[8] == 0x61 && bytes[9] == 0x76 && bytes[10] == 0x69;
}

Future<avif_models.Frame> _decodeAvifFrame(Uint8List bytes) {
  return avif_platform.FlutterAvifPlatform.api
      .decodeSingleFrameImage(avifBytes: bytes);
}

Uint8List _framePixels(avif_models.Frame frame) {
  final List<int> data = frame.data;
  return data is Uint8List ? data : Uint8List.fromList(data);
}

/// A decoded page. [image] is whatever the engine produced — Impeller clamps
/// each axis independently to the GPU max texture size, so for tall webtoon
/// strips it is shorter than [height] and must be drawn stretched back to
/// [aspectRatio] rather than at its own dimensions.
class PageBitmap {
  const PageBitmap(this.image, this.width, this.height);

  final ui.Image image;
  final int width;
  final int height;

  Size get size => Size(width.toDouble(), height.toDouble());
  double get aspectRatio => width / height;

  void dispose() => image.dispose();
}

Future<PageBitmap> loadPageBitmap(
    String path, Map<String, String> headers) async {
  final Uint8List bytes = await _loadPageBytes(path, headers);
  if (_isAvif(bytes)) {
    final avif_models.Frame frame = await _decodeAvifFrame(bytes);
    final ui.Image image =
        await _rawImage(_framePixels(frame), frame.width, frame.height);
    return PageBitmap(image, frame.width, frame.height);
  }

  final ui.ImmutableBuffer buffer =
      await ui.ImmutableBuffer.fromUint8List(bytes);
  final ui.ImageDescriptor descriptor =
      await ui.ImageDescriptor.encoded(buffer);
  final int width = descriptor.width;
  final int height = descriptor.height;
  final ui.Codec codec = await descriptor.instantiateCodec();
  final ui.FrameInfo frame = await codec.getNextFrame();
  descriptor.dispose();
  codec.dispose();
  return PageBitmap(frame.image, width, height);
}

Future<ui.Image> _rawImage(Uint8List pixels, int width, int height) async {
  final ui.ImmutableBuffer buffer =
      await ui.ImmutableBuffer.fromUint8List(pixels);
  final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
    buffer,
    width: width,
    height: height,
    pixelFormat: ui.PixelFormat.rgba8888,
  );
  final ui.Codec codec = await descriptor.instantiateCodec();
  final ui.FrameInfo frame = await codec.getNextFrame();
  descriptor.dispose();
  codec.dispose();
  return frame.image;
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(PageImage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path) {
      _bitmap?.dispose();
      _bitmap = null;
      _error = null;
      _load();
    }
  }

  @override
  void dispose() {
    _bitmap?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final PageBitmap bitmap =
          await loadPageBitmap(widget.path, widget.headers);
      if (!mounted) {
        bitmap.dispose();
        return;
      }
      setState(() {
        _bitmap = bitmap;
        _error = null;
      });
      widget.onSizeResolved?.call(bitmap.size);
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = e);
    }
  }

  Future<void> _retry() async {
    setState(() => _error = null);
    await evictPage(widget.path, widget.headers);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(context, _retry) ?? const SizedBox();
    }
    final PageBitmap? bitmap = _bitmap;
    if (bitmap == null) {
      return widget.loadingBuilder?.call(context) ?? const SizedBox();
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
    final Uint8List bytes = await _loadPageBytes(path, headers);
    if (_isAvif(bytes)) {
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
    final avif_models.Frame frame = await _decodeAvifFrame(bytes);
    final ui.ImmutableBuffer buffer =
        await ui.ImmutableBuffer.fromUint8List(_framePixels(frame));
    final ui.ImageDescriptor descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: frame.width,
      height: frame.height,
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final ui.TargetImageSize target = _fitTargetSize(frame.width, frame.height);
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
