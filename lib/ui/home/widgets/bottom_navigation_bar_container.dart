import 'package:flutter/material.dart';
import 'package:wakaranai/ui/home/widgets/bottom_navigation_bar_item_widget.dart';
import 'package:wakaranai/utils/app_colors.dart';

class BottomNavigationBarContainer extends StatelessWidget {
  const BottomNavigationBarContainer({
    super.key,
    required this.data,
    required this.currentIndex,
    required this.onTap,
  });

  final List<BottomNavigationBarItemWidgetData> data;
  final int currentIndex;
  final void Function(int) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8.0,
            spreadRadius: 2.0,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
        child: Material(
          child: Ink(
            decoration: const BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                top: 4.0,
                left: 4.0,
                right: 4.0,
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: (MediaQuery.of(context).size.width - 12) /
                        data.length *
                        currentIndex,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: 64,
                      width: MediaQuery.of(context).size.width / data.length,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.only(
                          topLeft: currentIndex == 0
                              ? const Radius.circular(16.0)
                              : Radius.zero,
                          topRight: currentIndex == data.length - 1
                              ? const Radius.circular(16.0)
                              : Radius.zero,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.shadowColor,
                            blurRadius: 16.0,
                            spreadRadius: 4.0,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      for (int i = 0; i < data.length; i++)
                        BottomNavigationBarItemWidget(
                            data: data[i],
                            index: i,
                            selected: i == currentIndex,
                            borderRadius: BorderRadius.only(
                              topLeft: i == 0
                                  ? const Radius.circular(16.0)
                                  : Radius.zero,
                              topRight: i == data.length - 1
                                  ? const Radius.circular(16.0)
                                  : Radius.zero,
                            ))
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
