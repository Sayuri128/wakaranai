import 'package:flutter/material.dart';
import 'package:wakaranai/ui/widgets/cover_image.dart';
import 'package:wakaranai/utils/app_colors.dart';

class DownloadCover extends StatelessWidget {
  const DownloadCover({
    super.key,
    required this.url,
    required this.isEpisode,
    this.width = 48,
    this.height = 64,
  });

  final String? url;
  final bool isEpisode;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final String? coverUrl = url;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        height: height,
        child: coverUrl == null
            ? _placeholder()
            : CoverImage(
                url: coverUrl,
                logicalWidth: width,
                placeholder: (BuildContext context) => _placeholder(),
              ),
      ),
    );
  }

  Widget _placeholder() {
    return ColoredBox(
      color: AppColors.overlay(0.08),
      child: Center(
        child: Icon(
          isEpisode ? Icons.movie_rounded : Icons.menu_book_rounded,
          color: AppColors.mainGrey,
          size: 22,
        ),
      ),
    );
  }
}
