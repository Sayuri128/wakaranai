import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_colors.dart';

buildImageSkeletonLoader({required double width, required double height}) {
  return Shimmer.fromColors(
      child: Container(
          width: width,
          height: height,
          decoration:
              BoxDecoration(color: AppColors.mainGrey, borderRadius: BorderRadius.circular(16.0))),
      baseColor: AppColors.mainGrey.withOpacity(0.3),
      highlightColor: AppColors.mainGrey.withOpacity(0.1));
}

buildDoujinshiCardLoader({required double width, required double height}) {
  return SizedBox(
    width: width,
    height: height,
    child: Stack(
      children: [
        SizedBox(
          width: width,
          height: height,
          child: Card(
              shadowColor: AppColors.mainGrey,
              color: AppColors.mainGrey.withOpacity(0.1),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0))),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              buildImageSkeletonLoader(width: width, height: height - 52),
              const SizedBox(height: 12),
              Shimmer.fromColors(
                baseColor: AppColors.mainGrey.withOpacity(0.3),
                highlightColor: AppColors.mainGrey.withOpacity(0.1),
                child: Container(
                    width: width,
                    height: 20,
                    decoration: BoxDecoration(
                        color: AppColors.mainGrey, borderRadius: BorderRadius.circular(8.0))),
              )
            ],
          ),
        ),
      ],
    ),
  );
}
