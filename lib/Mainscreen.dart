import 'dart:math';
import '../utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'Models/food/orders_model.dart';
import 'screens/homescreens/home_page.dart';
import 'screens/screens/orders/food orders/food_helper.dart';
import 'Services/websockets/web_socket_manager.dart';
import 'Services/Auth_service/food_authservice.dart';
import 'Services/App_color_service/app_colours.dart';
import 'Models/promotions_model/promotions_model.dart';
import 'package:maamaas/screens/screens/profile_screen.dart';
import 'package:maamaas/screens/screens/orders/ordertracking.dart';
import 'Services/Auth_service/promotion_services_Authservice.dart';
import 'package:maamaas/screens/screens/advertisements/videoscreen.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:maamaas/screens/screens/advertisements/popup_message.dart';

class MainScreen extends StatefulWidget {
  final int? initialIndex;
  final int? campaignId;
  final bool showPromotion;

  const MainScreen({
    super.key,
    this.initialIndex,
    this.campaignId,
    this.showPromotion = false,
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  final GlobalKey<ReelsScreenState> reelsKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;

  bool _showBottomBar = true;

  Order? activeOrder;

  bool isLoadingOrder = false;

  bool _isSubscribedToOrder = false;

  bool _showOrderTracking = true;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    Utils.refreshCartCount();

    FirebaseInAppMessaging.instance.triggerEvent("app_open");

    _scrollController.addListener(_handleScroll);

    _currentIndex = widget.initialIndex ?? 0;

    loadActiveOrder();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isDeepLink =
          widget.initialIndex != null || widget.campaignId != null;

      if (widget.showPromotion && !isDeepLink) {
        checkPromotions();
      } else {}
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      loadActiveOrder();

      if (activeOrder != null) {
        _subscribeToActiveOrder(activeOrder!.orderId);
      }
    }
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      if (!_showBottomBar) {
        setState(() => _showBottomBar = true);
      }
    }
  }

  Future<void> loadActiveOrder() async {
    try {
      setState(() => isLoadingOrder = true);

      final response = await food_Authservice.getAllOrders();

      final fetchedOrders = response
          .map((json) => Order.fromJson(json))
          .toList();

      final activeOrders = fetchedOrders.where((o) => o.isActive).toList();

      if (activeOrders.isNotEmpty) {
        activeOrders.sort((a, b) => b.orderId.compareTo(a.orderId));

        final latestOrder = activeOrders.first;

        final changedOrder = activeOrder?.orderId != latestOrder.orderId;

        activeOrder = latestOrder;

        if (changedOrder || !_isSubscribedToOrder) {
          _subscribeToActiveOrder(latestOrder.orderId);
        }
      } else {
        _unsubscribeFromOrder();

        activeOrder = null;
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
    } finally {
      if (mounted) {
        setState(() => isLoadingOrder = false);
      }
    }
  }

  void _subscribeToActiveOrder(int orderId) {
    if (_isSubscribedToOrder) {
      WebSocketManager().unsubscribeOrderStatus(
        orderId,
        listenerId: 'bottom_bar',
      );
    }

    WebSocketManager().subscribeOrderStatus(orderId, (data) {
      if (!mounted || activeOrder == null) return;

      try {
        final newStatus = OrderStatus.fromString(
          data['status'] as String? ?? '',
        );

        final updatedOrder = activeOrder!.copyWith(status: newStatus);

        if (!updatedOrder.isActive) {
          _unsubscribeFromOrder();

          setState(() {
            activeOrder = null;
          });

          return;
        }

        setState(() {
          activeOrder = updatedOrder;
        });
      } catch (e) {}
    }, listenerId: 'bottom_bar');

    _isSubscribedToOrder = true;
  }

  void _unsubscribeFromOrder() {
    if (activeOrder != null) {
      WebSocketManager().unsubscribeOrderStatus(
        activeOrder!.orderId,
        listenerId: 'bottom_bar',
      );
    }

    _isSubscribedToOrder = false;
  }

  void checkPromotions() async {
    try {
      final result = await promotion_Authservice.fetchcampaign();

      if (!mounted) return;

      final filteredAds = result.where((campaign) {
        return campaign.medium == Medium.APP &&
            campaign.addDisplayPosition == AddDisplayPosition.IN_APP_POPUP;
      }).toList();

      if (filteredAds.isEmpty) return;

      final random = Random();

      final randomAd = filteredAds[random.nextInt(filteredAds.length)];

      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return;

        PromotionPopup.show(context, randomAd);
      });
    } catch (e) {}
  }

  // Future<void> loadCartData() async {
  //   try {
  //     final count = await food_Authservice.fetchCartCount();
  //
  //     CartNotifier.update(count);
  //   } catch (_) {}
  // }

  void openReelsTab() {
    setState(() => _currentIndex = 1);
  }

  late final _screens = [
    HomePage(scrollController: _scrollController),

    ReelsScreen(key: reelsKey, campaignId: widget.campaignId),

    Profile(),
  ];

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _unsubscribeFromOrder();

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        child: IndexedStack(
          index: _currentIndex.clamp(0, _screens.length - 1),
          children: _screens,
        ),
      ),

      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentIndex == 0 &&
              activeOrder != null &&
              activeOrder!.orderType == OrderType.DELIVERY &&
              _showOrderTracking)
            OrderTrackingBanner(
              order: activeOrder!,
              visible: _showOrderTracking,

              onDismiss: () {
                setState(() {
                  _showOrderTracking = false;
                });
              },

              onRefresh: loadActiveOrder,
            ),

          _showBottomBar
              ? Padding(
                  padding: EdgeInsets.only(
                    left: 12,
                    right: 12,
                    bottom: MediaQuery.of(context).padding.bottom + 8,
                  ),
                  child: _buildModernBottomBar(),
                  // child: _buildBottomBar(),
                )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }

  Widget _buildModernBottomBar() {
    return Container(
      height: 68,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _navItem(Icons.home_rounded, 'Home', 0),
          _navItem(Icons.play_circle_fill_rounded, 'Deals', 1),
          // _cartNavButton(),
          _navItem(Icons.person_rounded, 'Profile', 2),
        ],
      ),
    );
  }

  Widget _navItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;

    return InkWell(
      borderRadius: BorderRadius.circular(15),
      onTap: () {
        setState(() {
          _currentIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PulsingDot extends StatefulWidget {
  @override
  State<_PulsingDot> createState() => _PulsingDotState();
}

class _PulsingDotState extends State<_PulsingDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat(reverse: true);
    _anim = Tween(
      begin: 1.0,
      end: 0.5,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Container(
        width: 9,
        height: 9,
        decoration: const BoxDecoration(
          color: Color(0xFF22C55E),
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
