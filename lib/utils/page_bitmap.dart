import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter_avif_platform_interface/flutter_avif_platform_interface.dart'
    as avif_platform;
import 'package:flutter_avif_platform_interface/models/frame.pb.dart'
    as avif_models;
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

bool isLocalPagePath(String path) =>
    !path.startsWith('http') && !path.startsWith('data:');

Future<void> evictPageSource(String path) async {
  if (!isLocalPagePath(path)) {
    await DefaultCacheManager().removeFile(path);
  }
}

Future<Uint8List> loadPageBytes(
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

bool isAvif(Uint8List bytes) {
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

Future<avif_models.Frame> decodeAvifFrame(Uint8List bytes) {
  return avif_platform.FlutterAvifPlatform.api
      .decodeSingleFrameImage(avifBytes: bytes);
}

Uint8List framePixels(avif_models.Frame frame) {
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

  ui.Size get size => ui.Size(width.toDouble(), height.toDouble());
  double get aspectRatio => width / height;

  void dispose() => image.dispose();
}

Future<PageBitmap> loadPageBitmap(
    String path, Map<String, String> headers) async {
  final Uint8List bytes = await loadPageBytes(path, headers);
  if (isAvif(bytes)) {
    final avif_models.Frame frame = await decodeAvifFrame(bytes);
    final ui.Image image =
        await rawImage(framePixels(frame), frame.width, frame.height);
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

Future<ui.Image> rawImage(Uint8List pixels, int width, int height) async {
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
