import 'package:flutter/material.dart';
import 'package:maamaas/screens/Food&beverages/RestaurentsScreen/restaurentsnew.dart';
import '../Logistics&supply/logistics_homepage.dart';

class QuickAccessItem {
  final String image;
  final String title;
  final String subtitle;
  final Color color;
  final IconData? icon;
  final Widget route;

  QuickAccessItem({
    required this.image,
    required this.title,
    required this.subtitle,
    required this.color,
    this.icon,
    required this.route,
  });
}

class Vertical extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  late final List<Map<String, dynamic>> verticals = [
    {
      'image': 'assets/FOODBEVERAGES.webp',
      'title': 'Food & Beverages',
      'color': Color(0xFFFF6B35),
      'route': Restaurents(scrollController: _scrollController),
    },
    // {
    //   'image': 'assets/FRESHGROCERIES.webp',
    //   'title': 'Groceries & Meat',
    //   'color': Color(0xFF4CAF50),
    //   'route': stores(),
    // },
    {
      'image': 'assets/LOGISTICSANDSUPPLY.webp',
      'title': 'Travel & Logistics',
      'color': Color(0xFF2196F3),
      'route': logistic_HomePage(scrollController: _scrollController),
    },
    // {
    //   'image': 'assets/FOODBEVERAGES.webp',
    //   'title': 'Food & Beverages',
    //   'color': Color(0xFFFF6B35),
    //   'route': MainScreenfood(),
    // },
    // {
    //   'image': 'assets/FRESHGROCERIES.webp',
    //   'title': 'Groceries & Meat',
    //   'color': Color(0xFF4CAF50),
    //   'route': stores(),
    // },
    // {
    //   'image': 'assets/LOGISTICSANDSUPPLY.webp',
    //   'title': 'Travel & Logistics',
    //   'color': Color(0xFF2196F3),
    //   'route': LogisticsScreen(),
    // },
  ];

  @override
  // Widget build(BuildContext context) {
  //   return SizedBox(
  //     height: 120, // 👈 REQUIRED for horizontal ListView
  //     child: ListView.separated(
  //       scrollDirection: Axis.horizontal,
  //       padding: const EdgeInsets.symmetric(horizontal: 16),
  //       itemCount: verticals.length,
  //       separatorBuilder: (_, __) => const SizedBox(width: 16),
  //       itemBuilder: (context, index) {
  //         return SizedBox(
  //           width: 100, // 👈 card width
  //           child: _buildCategoryCard(context, verticals[index]),
  //         );
  //       },
  //     ),
  //   );
  // }
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        shrinkWrap: true, // ✅ VERY IMPORTANT
        physics: const NeverScrollableScrollPhysics(), // ✅ VERY IMPORTANT
        itemCount: verticals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, index) {
          return _buildCategoryCard(context, verticals[index]);
        },
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
  ) {
    return Material(
      color: Colors.transparent, // 👈 REQUIRED
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => category['route']),
        ),
        child: Container(
          decoration: BoxDecoration(
            color: category['color'],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  // color: category['color'].withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: Image.asset(
                    category['image'],
                    width: 50, // image controls size
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              Padding(
                padding: const EdgeInsets.only(
                  top: 8,
                  left: 4,
                  right: 4,
                ), // adjust as needed
                child: Text(
                  category['title'],
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
