import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../Logistics&supply/logistics_homepage.dart' as _A;

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

Widget addressListShimmer() {
  return ListView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: 4,
    itemBuilder: (_, __) {
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _A.surface,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Column(
              children: [
                ShimmerBox(height: 42.r, width: 42.r, radius: 21),
                SizedBox(height: 6.h),
                ShimmerBox(height: 10.h, width: 40.w),
              ],
            ),

            SizedBox(width: 12.w),

            // Address content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(height: 12.h, width: 120.w),
                  SizedBox(height: 6.h),
                  ShimmerBox(height: 10.h, width: double.infinity),
                  SizedBox(height: 6.h),
                  ShimmerBox(height: 10.h, width: 180.w),
                ],
              ),
            ),

            SizedBox(width: 8.w),

            // Actions
            Column(
              children: [
                ShimmerBox(height: 34.r, width: 34.r, radius: 20),
                SizedBox(height: 6.h),
                ShimmerBox(height: 34.r, width: 34.r, radius: 20),
              ],
            ),
          ],
        ),
      );
    },
  );
}