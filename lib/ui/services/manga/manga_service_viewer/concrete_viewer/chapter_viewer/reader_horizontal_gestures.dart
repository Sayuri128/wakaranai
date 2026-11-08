import 'package:flutter/material.dart';
import 'package:transparent_pointer/transparent_pointer.dart';
import 'package:wakaranai/ui/services/manga/manga_service_viewer/concrete_viewer/chapter_viewer/chapter_view_mode.dart';

class ReaderTapZones extends StatelessWidget {
  const ReaderTapZones({
    super.key,
    required this.mode,
    required this.controlsEnabled,
    required this.onForward,
    required this.onBackward,
  });

  static const double _sideFraction = 0.25;
  static const double _verticalFraction = 0.3;

  final ChapterViewMode mode;
  final bool controlsEnabled;
  final VoidCallback onForward;
  final VoidCallback onBackward;

  @override
  Widget build(BuildContext context) {
    if (!controlsEnabled) {
      return const SizedBox();
    }
    if (mode == ChapterViewMode.webtoon) {
      return _buildVertical(context);
    }
    return _buildHorizontal(context);
  }

  Widget _buildHorizontal(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    final bool rightToLeft = mode == ChapterViewMode.rightToLeft;
    return TransparentPointer(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            _zone(
              width: size.width * _sideFraction,
              height: size.height * 0.8,
              onTap: rightToLeft ? onForward : onBackward,
            ),
            _zone(
              width: size.width * _sideFraction,
              height: size.height * 0.8,
              onTap: rightToLeft ? onBackward : onForward,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVertical(BuildContext context) {
    final Size size = MediaQuery.sizeOf(context);
    return TransparentPointer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _zone(
            width: size.width,
            height: size.height * _verticalFraction,
            onTap: onBackward,
          ),
          _zone(
            width: size.width,
            height: size.height * _verticalFraction,
            onTap: onForward,
          ),
        ],
      ),
    );
  }

  Widget _zone({
    required double width,
    required double height,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: SizedBox(width: width, height: height),
    );
  }
}
