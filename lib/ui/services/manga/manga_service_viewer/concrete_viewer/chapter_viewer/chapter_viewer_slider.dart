part of 'chapter_viewer.dart';

mixin _ReaderSliderControl on State<ChapterViewer>, _ReaderStripNavigation {

  late final AnimationController _sliderController;
  double _sliderFrom = 1;
  double _sliderTarget = 1;
  double? _seekOverride;

  double _currentSliderValue() {
    return _sliderFrom +
        (_sliderTarget - _sliderFrom) *
            Curves.easeOut.transform(_sliderController.value);
  }

  void _animateSliderTo(ChapterViewInitialized state, {required bool animate}) {
    final double maxValue = max(2, state.totalPages).toDouble();
    final double target = state.currentPage.toDouble().clamp(1.0, maxValue);
    _sliderFrom = _currentSliderValue();
    _sliderTarget = target;
    if (animate) {
      _sliderController
        ..reset()
        ..forward();
    } else {
      _sliderController.value = 1.0;
    }
  }

  Widget _buildSlider(BuildContext context, ChapterViewInitialized state) {
    final double maxValue = max(2, state.totalPages).toDouble();

    return AnimatedBuilder(
      animation: _sliderController,
      builder: (BuildContext context, Widget? child) {
        final double value = (_seekOverride ?? _currentSliderValue()).clamp(
          1.0,
          maxValue,
        );
        return FlutterSlider(
          values: <double>[value],
          min: 1,
          max: maxValue,
          jump: true,
          handlerHeight: 20,
          handlerWidth: 20,
          onDragStarted: (_, lower, __) {
            _seekOverride = (lower as num).toDouble();
            _sliderController.stop();
          },
          onDragging: (_, lower, __) {
            _seekOverride = (lower as num).toDouble();
          },
          onDragCompleted: (_, index, __) {
            final double dragged = (index as num).toDouble();
            _seekOverride = dragged;
            _sliderFrom = dragged;
            _sliderTarget = dragged;
            _sliderController.value = 1.0;
            switch (state.mode) {
              case ChapterViewMode.rightToLeft:
              case ChapterViewMode.leftToRight:
                _jumpPagedTo(
                  state,
                  _stripIndexOfCurrentPage(state, dragged.toInt()),
                );
                break;
              case ChapterViewMode.webtoon:
                _itemScrollController.jumpTo(
                  index: _stripIndexOfCurrentPage(state, dragged.toInt()),
                );
                break;
            }

            if (mounted) {
              setState(() {});
            }
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _seekOverride = null;
              if (mounted) {
                setState(() {});
              }
            });
          },
          tooltip: FlutterSliderTooltip(
            custom: (v) => ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image(
                image: pageImageProvider(
                  state.currentPages.value[min(
                    (v as double).toInt(),
                    state.currentPages.value.length - 1,
                  )],
                  state.headers,
                ),
                fit: BoxFit.cover,
                loadingBuilder:
                    (
                      BuildContext context,
                      Widget child,
                      ImageChunkEvent? progress,
                    ) {
                      if (progress == null) {
                        return child;
                      }
                      return CircularProgressIndicator(
                        value: progress.expectedTotalBytes != null
                            ? progress.cumulativeBytesLoaded /
                                  progress.expectedTotalBytes!
                            : 0.01,
                        color: AppColors.onMedia,
                      );
                    },
              ),
            ),
            textStyle: regular(color: AppColors.onMedia),
          ),
          trackBar: FlutterSliderTrackBar(
            activeTrackBarHeight: 5,
            inactiveTrackBarHeight: 5,
            inactiveTrackBar: BoxDecoration(
              color: AppColors.overlay(0.25),
              borderRadius: BorderRadius.circular(16.0),
            ),
            activeTrackBar: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(16.0),
            ),
          ),
          handler: FlutterSliderHandler(
            child: const SizedBox(),
            decoration: BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
