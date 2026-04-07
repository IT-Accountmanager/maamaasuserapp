import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

enum CartSkeletonType { items, summary, fullCart, coupons, payment }

class CartSkeleton extends StatelessWidget {
  final CartSkeletonType type;
  final int itemCount;

  const CartSkeleton({super.key, required this.type, this.itemCount = 3});

  @override
  Widget build(BuildContext context) {
    switch (type) {
      case CartSkeletonType.items:
        return _cartItems(itemCount);

      case CartSkeletonType.summary:
        return _summarySkeleton();

      case CartSkeletonType.fullCart:
        return Column(
          children: [
            _cartItems(itemCount),
            SizedBox(height: 12.h),
            _summarySkeleton(),
          ],
        );

      case CartSkeletonType.coupons:
        return _couponSkeletonList();

      case CartSkeletonType.payment:
        return _paymentSkeleton();
    }
  }

  Widget _cartItems(int count) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          children: List.generate(count, (_) => _cartItemSkeleton()),
        ),
      ),
    );
  }

  Widget _skeletonBox({
    required double height,
    double? width,
    BorderRadius? radius,
  }) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: radius ?? BorderRadius.circular(12),
      ),
    );
  }

  Widget _cartItemSkeleton() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: Row(
          children: [
            _skeletonBox(
              height: 70.h,
              width: 70.h,
              radius: BorderRadius.circular(12),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _skeletonBox(height: 14.h),
                  SizedBox(height: 8.h),
                  _skeletonBox(height: 12.h, width: 120.w),
                  SizedBox(height: 8.h),
                  _skeletonBox(height: 12.h, width: 80.w),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summarySkeleton() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(height: 22, width: 22, color: Colors.white),
                  SizedBox(width: 8),
                  Container(height: 16, width: 140, color: Colors.white),
                ],
              ),
              const Divider(),

              // Charges
              ...List.generate(
                5,
                (_) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(height: 12, width: 120, color: Colors.white),
                      Container(height: 12, width: 60, color: Colors.white),
                    ],
                  ),
                ),
              ),

              const Divider(),

              // Grand total
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  Container(height: 14, width: 80, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }



  Widget _couponSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 90,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _paymentSkeleton() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
