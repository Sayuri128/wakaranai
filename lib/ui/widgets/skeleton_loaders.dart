import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../../utils/app_colors.dart';

buildImageSkeletonLoader({required double width, required double height}) {
  return Shimmer.fromColors(
      child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
              color: AppColors.mainGrey, borderRadius: BorderRadius.circular(16.0))),
      baseColor: AppColors.mainGrey.withOpacity(0.3),
      highlightColor: AppColors.mainGrey.withOpacity(0.1));
}
