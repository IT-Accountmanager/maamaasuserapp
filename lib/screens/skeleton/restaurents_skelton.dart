import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class RestaurantsSkeleton extends StatelessWidget {
  const RestaurantsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              const Skeleton(height: 90, width: 90, borderRadius: 12),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Skeleton(height: 14, width: 150),
                    SizedBox(height: 8),
                    Skeleton(height: 12, width: 120),
                    SizedBox(height: 8),
                    Skeleton(height: 12, width: 80),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class CategorySkeleton extends StatelessWidget {
  const CategorySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return const Column(
            children: [
              Skeleton(height: 50, width: 50, borderRadius: 25),
              SizedBox(height: 8),
              Skeleton(height: 10, width: 50),
            ],
          );
        },
      ),
    );
  }
}

class Skeleton extends StatelessWidget {
  final double height;
  final double width;
  final double borderRadius;
  const Skeleton({
    super.key,
    required this.height,
    required this.width,
    this.borderRadius = 12,
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
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}
