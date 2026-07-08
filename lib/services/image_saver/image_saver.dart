import 'dart:convert';
import 'dart:typed_data';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wakaranai/generated/l10n.dart';
import 'package:wakaranai/main.dart';
import 'package:wakaranai/ui/widgets/snackbars.dart';

class ImageSaver {
  const ImageSaver._();

  /// Opens the system "save as" picker so the user chooses the destination.
  static Future<void> save(
    BuildContext context, {
    required String url,
    Map<String, String> headers = const <String, String>{},
  }) async {
    try {
      final _ResolvedImage image = await _resolve(url, headers);
      await FileSaver.instance.saveAs(
        name: 'wakaranai_${DateTime.now().millisecondsSinceEpoch}',
        bytes: image.bytes,
        ext: image.ext,
        mimeType: image.mimeType,
      );

      if (!context.mounted) return;
      SnackBars.showSnackBar(
        context: context,
        message: S.current.save_image_success,
      );
    } catch (e) {
      logger.e(e);
      if (!context.mounted) return;
      SnackBars.showErrorSnackBar(
        context: context,
        error: S.current.save_image_error,
      );
    }
  }

  static Future<_ResolvedImage> _resolve(
      String url, Map<String, String> headers) async {
    if (url.startsWith('data:')) {
      final Uint8List bytes = base64Decode(url.split(',').last);
      final String ext = _extFromMime(url.substring(5, url.indexOf(';')));
      return _ResolvedImage(bytes, ext, _mimeFromExt(ext));
    }

    final file =
        await DefaultCacheManager().getSingleFile(url, headers: headers);
    final Uint8List bytes = await file.readAsBytes();
    final String ext = _extFromUrl(url);
    return _ResolvedImage(bytes, ext, _mimeFromExt(ext));
  }

  static String _extFromUrl(String url) {
    final String path = Uri.tryParse(url)?.path ?? url;
    final int dot = path.lastIndexOf('.');
    if (dot == -1 || dot == path.length - 1) return 'jpg';
    final String ext = path.substring(dot + 1).toLowerCase();
    if (ext.length > 4) return 'jpg';
    return ext;
  }

  static String _extFromMime(String mime) {
    switch (mime) {
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/bmp':
        return 'bmp';
      case 'image/webp':
        return 'webp';
      default:
        return 'jpg';
    }
  }

  static MimeType _mimeFromExt(String ext) {
    switch (ext) {
      case 'png':
        return MimeType.png;
      case 'gif':
        return MimeType.gif;
      case 'bmp':
        return MimeType.bmp;
      default:
        return MimeType.jpeg;
    }
  }
}

class _ResolvedImage {
  const _ResolvedImage(this.bytes, this.ext, this.mimeType);

  final Uint8List bytes;
  final String ext;
  final MimeType mimeType;
}
