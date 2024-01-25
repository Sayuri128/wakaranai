import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:wakaranai/utils/app_colors.dart';

class ImageWidget extends StatefulWidget {
  const ImageWidget(
      {super.key, required this.url, required this.uid, required this.headers});

  final String uid;
  final String url;
  final Map<String, String> headers;

  @override
  State<ImageWidget> createState() => _ImageWidgetState();
}

class _ImageWidgetState extends State<ImageWidget> {
  File? _file;
  bool _initialized = false;

  @override
  void initState() {
    if (widget.url.startsWith("data:")) {
      (() async {
        final Directory temp = await getTemporaryDirectory();
        final File file = File("${temp.path}/${widget.uid}.png");
        if (!(await file.exists())) {
          await file.writeAsBytes(base64Decode(widget.url.split(',').last));
        }

        _file = file;
      })()
          .then((Object? value) {
        _initialized = true;
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      _initialized = true;
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        width: MediaQuery.of(context).size.width,
        child: const Center(
          child: CircularProgressIndicator(
            color: AppColors.primary,
          ),
        ),
      );
    }

    final double height = MediaQuery.of(context).size.height * 0.7;
    final double width = MediaQuery.of(context).size.width;

    if (_file != null) {
      return Image.file(_file!,
          width: width,
          height: height,
          fit: BoxFit.cover,
          isAntiAlias: true,
          errorBuilder:
              (BuildContext context, Object error, StackTrace? stackTrace) =>
                  SizedBox(
                    height: height,
                    width: width,
                    child: Center(
                      child: Text(
                        "Error",
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                    ),
                  ));
    }

    return CachedNetworkImage(
      imageUrl: widget.url,
      width: width,
      fit: BoxFit.cover,
      progressIndicatorBuilder:
          (BuildContext context, String url, DownloadProgress progress) =>
              SizedBox(
        height: height,
        width: width,
        child: Center(
          child: CircularProgressIndicator(
              color: AppColors.primary, value: progress.progress),
        ),
      ),
    );
  }
}
