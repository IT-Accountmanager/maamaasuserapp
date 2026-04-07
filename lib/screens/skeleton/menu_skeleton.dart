import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MenuSkeletonScreen extends StatelessWidget {
  const MenuSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _skeletonBox(height: 180), // Banner
          const SizedBox(height: 16),

          _skeletonBox(height: 20, width: 140),
          const SizedBox(height: 12),

          Row(
            children: List.generate(
              4,
              (_) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _skeletonBox(height: 90),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 6,
            itemBuilder: (_, __) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _skeletonBox(height: 110),
            ),
          ),
        ],
      ),
    );
  }

  Widget _skeletonBox({double height = 100, double width = double.infinity}) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
