import 'package:flutter/material.dart';
import 'package:wakaranai/ui/widgets/shimmer.dart';

class ConfigsListSkeleton extends StatelessWidget {
  const ConfigsListSkeleton({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: Column(
        children: <Widget>[
          const SizedBox(height: 24),
          for (int i = 0; i < itemCount; i++)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: <Widget>[
                  ShimmerBox(width: 56, height: 56, borderRadius: 12),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ShimmerBox(width: 150, height: 14, borderRadius: 6),
                        SizedBox(height: 10),
                        ShimmerBox(width: 70, height: 12, borderRadius: 6),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
