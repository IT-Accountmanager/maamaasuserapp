import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RestaurantsSkeleton extends StatelessWidget {
  const RestaurantsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _bannerSkeleton(),
        SizedBox(height: 16.h),
        _restaurantListSkeleton(),
      ],
    );
  }

  // ---------------- BANNER SKELETON ----------------

  Widget _bannerSkeleton() {
    return SizedBox(
      height: 200.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        itemCount: 3,
        separatorBuilder: (_, __) => SizedBox(width: 12.w),
        itemBuilder: (_, __) {
          return Container(
            width: 220.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14.r),
              color: Colors.grey.shade200,
            ),
          );
        },
      ),
    );
  }

  // ---------------- RESTAURANT CARD SKELETON ----------------

  Widget _restaurantListSkeleton() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (_, __) {
        return Container(
          height: 200.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: const [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: Column(
            children: [
              Container(
                height: 130.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius:
                  BorderRadius.vertical(top: Radius.circular(16.r)),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line(120),
                      SizedBox(height: 6.h),
                      _line(80),
                      SizedBox(height: 6.h),
                      _line(150),
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _line(double width) {
    return Container(
      height: 10.h,
      width: width.w,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(6.r),
      ),
    );
  }
}

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 10.w),
        itemCount: 8,
        separatorBuilder: (_, __) => SizedBox(width: 14.w),
        itemBuilder: (_, __) {
          return Column(
            children: [
              Container(
                height: 60.h,
                width: 60.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey.shade300,
                ),
              ),
              SizedBox(height: 6.h),
              Container(
                height: 8.h,
                width: 40.w,
                color: Colors.grey.shade300,
              )
            ],
          );
        },
      ),
    );
  }
}