import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../Logistics&supply/logistics_homepage.dart' as _W;

class ShimmerBox extends StatelessWidget {
  final double height;
  final double width;
  final double radius;

  const ShimmerBox({
    super.key,
    required this.height,
    required this.width,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
Widget txnShimmer() {
  return Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: _W.surface,
      borderRadius: BorderRadius.circular(16.r),
    ),
    child: Row(
      children: [
        ShimmerBox(height: 40.r, width: 40.r, radius: 20),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(height: 12.h, width: 120.w),
              SizedBox(height: 6.h),
              ShimmerBox(height: 10.h, width: 160.w),
              SizedBox(height: 6.h),
              ShimmerBox(height: 10.h, width: 100.w),
            ],
          ),
        ),
        ShimmerBox(height: 14.h, width: 60.w),
      ],
    ),
  );
}
