import 'dart:async';
import 'package:flutter/material.dart';
import 'package:maamaas/screens/Food&beverages/RestaurentsScreen/Restaurentsmainscreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Services/Auth_service/delivery_service.dart';
import '../Logistics&supply/finding_driver_screen.dart';
import '../Logistics&supply/logistics_homepage.dart';

class VerticalCategory {
  final String title;
  final String subtitle;
  final Color color;
  final List<String> carouselImages;
  final Widget route;

  VerticalCategory({
    required this.title,
    required this.subtitle,
    required this.color,
    required this.carouselImages,
    required this.route,
  });
}

class Vertical extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  late final List<VerticalCategory> verticals = [
    VerticalCategory(
      title: 'Food & Beverages',
      subtitle: 'Order from your favorite restaurants',
      color: const Color(0xFFFF6B35),
      carouselImages: [
        'assets/food/pizza.webp',
        'assets/food/burger.webp',
        'assets/food/biryani.webp',
        'assets/food/icecream.webp',
      ],
      route: Restaurents(scrollController: _scrollController),
    ),
    VerticalCategory(
      title: 'Travel & Logistics',
      subtitle: 'Bike, Auto, Car & EV rides',
      color: const Color(0xFF2196F3),
      carouselImages: [
        'assets/logistics/bike.webp',
        'assets/logistics/ev_bike.webp',
        'assets/logistics/car.webp',
        'assets/logistics/auto.webp',
      ],
      route: logistic_HomePage(scrollController: _scrollController),
    ),
  ];

  Vertical({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: verticals
            .map(
              (v) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CategoryCard(category: v),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  final VerticalCategory category;
  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  late final PageController _pageController;
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.42);
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!_pageController.hasClients) return;
      final itemCount = widget.category.carouselImages.length;
      _currentPage = (_currentPage + 1) % itemCount;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  Future<bool> hasActiveLogisticsOrder() async {
    final prefs = await SharedPreferences.getInstance();

    final orderId = prefs.getInt("activeLogisticsOrderId");

    if (orderId == null) return false;

    try {
      final order = await DeliveryService.getOrderById(orderId);

      return order.status != "COMPLETED" && order.status != "CANCELLED";
    } catch (_) {
      return false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => category.route),
        ),
        // onTap: () async {
        //   if (category.title == "Travel & Logistics") {
        //     final active = await hasActiveLogisticsOrder();
        //
        //     if (!context.mounted) return;
        //
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(
        //         builder: (_) => active
        //             ? const FindingDriverScreen()
        //             : logistic_HomePage(scrollController: ScrollController()),
        //       ),
        //     );
        //   } else {
        //     Navigator.push(
        //       context,
        //       MaterialPageRoute(builder: (_) => category.route),
        //     );
        //   }
        // },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [category.color, category.color.withOpacity(0.75)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: category.color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      category.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      category.subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          'Explore',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.95),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.arrow_forward_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 5,
                child: SizedBox(
                  height: 90,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: category.carouselImages.length,
                    itemBuilder: (context, index) {
                      return AnimatedBuilder(
                        animation: _pageController,
                        builder: (context, child) {
                          double scale = 1.0;
                          if (_pageController.position.haveDimensions) {
                            double page =
                                _pageController.page ?? _currentPage.toDouble();
                            scale = (1 - ((page - index).abs() * 0.3)).clamp(
                              0.7,
                              1.0,
                            );
                          }
                          return Center(
                            child: Transform.scale(scale: scale, child: child),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Image.asset(
                                category.carouselImages[index],
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
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
