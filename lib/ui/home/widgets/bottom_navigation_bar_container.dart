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
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.06)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < data.length; i++)
                BottomNavigationBarItemWidget(
                  data: data[i],
                  selected: i == currentIndex,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
