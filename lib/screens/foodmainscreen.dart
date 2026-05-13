// import 'dart:math';
// import 'package:maamaas/screens/screens/advertisements/popup_message.dart';
// import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
// import 'package:maamaas/screens/screens/advertisements/videoscreen.dart';
// import '../Services/App_color_service/app_colours.dart';
// import '../Services/Auth_service/promotion_services_Authservice.dart';
// import '../../widgets/widgets/food/currentcart_notifier.dart';
// import 'package:maamaas/screens/screens/profile_screen.dart';
// import '../../Services/Auth_service/food_authservice.dart';
// import '../Models/promotions_model/promotions_model.dart';
// import 'Food&beverages/RestaurentsScreen/restaurentsnew.dart';
// import 'Food&beverages/commonCartscreen.dart';
// import 'package:flutter/rendering.dart';
// import 'package:flutter/material.dart';
// import '../../utils/utils.dart';
//
// class MainScreenfood extends StatefulWidget {
//   final int? initialIndex;
//   final int? campaignId;
//
//   const MainScreenfood({super.key, this.initialIndex, this.campaignId});
//
//   @override
//   State<MainScreenfood> createState() => _MainScreenState();
// }
//
// class _MainScreenState extends State<MainScreenfood> {
//   final GlobalKey<ReelsScreenState> reelsKey = GlobalKey();
//   int _currentIndex = 0;
//
//   bool _showBottomBar = true;
//   final ScrollController _scrollController = ScrollController();
//
//   @override
//   void initState() {
//     super.initState();
//     Utils.refreshCartCount();
//     FirebaseInAppMessaging.instance.triggerEvent("app_open");
//     _scrollController.addListener(_handleScroll);
//
//     // ✅ Honor initialIndex from deep link (e.g. Deals tab = 1)
//     _currentIndex = widget.initialIndex ?? 0;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final isDeepLink =
//           widget.initialIndex != null || widget.campaignId != null;
//
//       if (!isDeepLink) {
//         checkPromotions(); // ✅ Only show popup for normal app open
//       } else {
//         debugPrint("🚫 Skipping promotion popup due to deep link navigation");
//       }
//
//       if (widget.campaignId != null && _currentIndex == 1) {
//         debugPrint(
//           "📌 MainScreen: campaignId=${widget.campaignId} passed to ReelsScreen",
//         );
//       }
//     });
//   }
//
//   void _handleScroll() {
//     if (_scrollController.position.userScrollDirection ==
//         ScrollDirection.reverse) {
//       if (_showBottomBar) setState(() => _showBottomBar = false);
//     } else if (_scrollController.position.userScrollDirection ==
//         ScrollDirection.forward) {
//       if (!_showBottomBar) setState(() => _showBottomBar = true);
//     }
//   }
//
//   void checkPromotions() async {
//     try {
//       final result = await promotion_Authservice.fetchcampaign();
//       if (!mounted) return;
//
//       final filteredAds = result.where((campaign) {
//         return campaign.medium == Medium.APP &&
//             campaign.addDisplayPosition == AddDisplayPosition.IN_APP_POPUP;
//       }).toList();
//
//       if (filteredAds.isEmpty) return;
//
//       final random = Random();
//       final randomAd = filteredAds[random.nextInt(filteredAds.length)];
//
//       Future.delayed(const Duration(seconds: 2), () {
//         if (!mounted) return;
//         PromotionPopup.show(context, randomAd);
//       });
//     } catch (e) {
//       debugPrint("Promotion error: $e");
//     }
//   }
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
//
//   Future<void> loadCartData() async {
//     try {
//       final count = await food_Authservice.fetchCartCount();
//       CartNotifier.update(count);
//     } catch (_) {}
//   }
//
//   // ✅ Kept for programmatic tab switching (e.g. from a banner widget)
//   void openReelsTab() {
//     setState(() => _currentIndex = 1);
//   }
//
//   late final _screens = [
//     Restaurents(scrollController: _scrollController),
//     ReelsScreen(
//       key: reelsKey,
//       campaignId: widget.campaignId, // ✅ passed through from deep link
//     ),
//     CommonCartScreen(),
//     Profile(),
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: AnimatedSwitcher(
//         duration: const Duration(milliseconds: 250),
//         child: IndexedStack(
//           index: _currentIndex.clamp(0, _screens.length - 1),
//           children: _screens,
//         ),
//       ),
//       bottomNavigationBar: SafeArea(
//         child: AnimatedContainer(
//           duration: const Duration(milliseconds: 250),
//           height: _showBottomBar ? kBottomNavigationBarHeight : 0,
//           child: Wrap(children: [_buildBottomBar()]),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBottomBar() {
//     return BottomNavigationBar(
//       backgroundColor: Colors.white,
//       currentIndex: _currentIndex,
//       type: BottomNavigationBarType.fixed,
//       selectedItemColor: AppColors.primary,
//       unselectedItemColor: Colors.grey,
//       onTap: (index) {
//         // Pause reels when leaving the Deals tab
//         if (_currentIndex == 1 && index != 1) {
//           reelsKey.currentState?.setScreenActive(false);
//         }
//
//         // Resume reels when returning to the Deals tab
//         if (index == 1) {
//           reelsKey.currentState?.setScreenActive(true);
//         }
//
//         // Reload cart when opening the Cart tab
//         if (index == 2) {
//           final cartScreen = _screens[2] as CommonCartScreen;
//           cartScreen.reloadCart?.call();
//         }
//
//         setState(() {
//           _currentIndex = index;
//           _showBottomBar = true;
//         });
//       },
//       items: [
//         const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.play_circle_rounded),
//           label: 'Deals',
//         ),
//         _cartNavItem(),
//         const BottomNavigationBarItem(
//           icon: Icon(Icons.person),
//           label: 'Profile',
//         ),
//       ],
//     );
//   }
//
//   BottomNavigationBarItem _cartNavItem() {
//     return BottomNavigationBarItem(
//       label: 'Cart',
//       icon: ValueListenableBuilder<int>(
//         valueListenable: CartNotifier.count,
//         builder: (context, count, _) {
//           return Stack(
//             clipBehavior: Clip.none,
//             children: [
//               const Icon(Icons.shopping_cart),
//               if (count > 0)
//                 Positioned(
//                   right: -6,
//                   top: -4,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 5,
//                       vertical: 2,
//                     ),
//                     constraints: const BoxConstraints(
//                       minWidth: 18,
//                       minHeight: 18,
//                     ),
//                     decoration: BoxDecoration(
//                       color: Colors.red,
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: Text(
//                       count > 9 ? '9+' : count.toString(),
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 10,
//                         fontWeight: FontWeight.bold,
//                         height: 1,
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                   ),
//                 ),
//             ],
//           );
//         },
//       ),
//     );
//   }
// }

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:maamaas/screens/screens/advertisements/popup_message.dart';
import 'package:maamaas/screens/screens/advertisements/videoscreen.dart';
import 'package:maamaas/screens/screens/orders/food%20orders/food_orders.dart';
import 'package:maamaas/screens/screens/profile_screen.dart';

import '../../utils/utils.dart';

import '../Services/App_color_service/app_colours.dart';
import '../Services/Auth_service/promotion_services_Authservice.dart';
import '../Services/Auth_service/food_authservice.dart';

import '../Models/promotions_model/promotions_model.dart';
import '../Models/food/orders_model.dart';

import '../Services/websockets/web_socket_manager.dart';

import '../../widgets/widgets/food/currentcart_notifier.dart';

import '../widgets/datetimehelper.dart';
import 'Food&beverages/RestaurentsScreen/restaurentsnew.dart';
import 'Food&beverages/commonCartscreen.dart';

class MainScreenfood extends StatefulWidget {
  final int? initialIndex;
  final int? campaignId;

  const MainScreenfood({super.key, this.initialIndex, this.campaignId});

  @override
  State<MainScreenfood> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenfood>
    with WidgetsBindingObserver {
  final GlobalKey<ReelsScreenState> reelsKey = GlobalKey();

  final ScrollController _scrollController = ScrollController();

  int _currentIndex = 0;

  bool _showBottomBar = true;

  /// ACTIVE ORDER
  Order? activeOrder;

  bool isLoadingOrder = false;

  bool _isSubscribedToOrder = false;

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

      if (!isDeepLink) {
        checkPromotions();
      } else {
        debugPrint("🚫 Skipping promotion popup due to deep link navigation");
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint("🔄 App resumed");

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
      debugPrint("❌ Active order error: $e");
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

    debugPrint("🟢 Subscribed to order: $orderId");

    WebSocketManager().subscribeOrderStatus(orderId, (data) {
      if (!mounted || activeOrder == null) return;

      try {
        final newStatus = OrderStatus.fromString(
          data['status'] as String? ?? '',
        );

        debugPrint("📦 Order update received: ${newStatus.name}");

        final updatedOrder = activeOrder!.copyWith(status: newStatus);

        if (!updatedOrder.isActive) {
          debugPrint("✅ Order completed");

          _unsubscribeFromOrder();

          setState(() {
            activeOrder = null;
          });

          return;
        }

        setState(() {
          activeOrder = updatedOrder;
        });
      } catch (e) {
        debugPrint("❌ Websocket parse error: $e");
      }
    }, listenerId: 'bottom_bar');

    _isSubscribedToOrder = true;
  }

  void _unsubscribeFromOrder() {
    if (activeOrder != null) {
      WebSocketManager().unsubscribeOrderStatus(
        activeOrder!.orderId,
        listenerId: 'bottom_bar',
      );

      debugPrint("🔴 Unsubscribed from order ${activeOrder!.orderId}");
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
    } catch (e) {
      debugPrint("Promotion error: $e");
    }
  }

  Future<void> loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();

      CartNotifier.update(count);
    } catch (_) {}
  }

  void openReelsTab() {
    setState(() => _currentIndex = 1);
  }

  String getOrderStatusText(OrderStatus status) {
    switch (status) {
      case OrderStatus.pending:
        return "Waiting for confirmation";

      case OrderStatus.confirmed:
        return "Order confirmed";

      case OrderStatus.beingPrepared:
        return "Preparing your food";

      case OrderStatus.orderIsReady:
        return "Order ready";

      case OrderStatus.waitingForPickup:
        return "Waiting for pickup";

      case OrderStatus.ontheway:
        return "On the way";

      case OrderStatus.completed:
        return "Delivered";

      default:
        return "Processing";
    }
  }

  late final _screens = [
    Restaurents(scrollController: _scrollController),

    ReelsScreen(key: reelsKey, campaignId: widget.campaignId),

    CommonCartScreen(),

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
          /// ACTIVE ORDER BAR
          // if (activeOrder != null)
          //   GestureDetector(
          //     onTap: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(
          //           builder: (_) => OrderDetailsScreen(
          //             orderId: activeOrder!.orderId,
          //             order: activeOrder!,
          //             formattedDate: DateTimeHelper.formatDate(
          //               DateTime.utc(
          //                 activeOrder!.parsedDateTime.year,
          //                 activeOrder!.parsedDateTime.month,
          //                 activeOrder!.parsedDateTime.day,
          //                 activeOrder!.parsedDateTime.hour,
          //                 activeOrder!.parsedDateTime.minute,
          //                 activeOrder!.parsedDateTime.second,
          //                 activeOrder!.parsedDateTime.millisecond,
          //               ),
          //             ),
          //
          //             formattedTime: DateTimeHelper.formatTime(
          //               DateTime.utc(
          //                 activeOrder!.parsedDateTime.year,
          //                 activeOrder!.parsedDateTime.month,
          //                 activeOrder!.parsedDateTime.day,
          //                 activeOrder!.parsedDateTime.hour,
          //                 activeOrder!.parsedDateTime.minute,
          //                 activeOrder!.parsedDateTime.second,
          //                 activeOrder!.parsedDateTime.millisecond,
          //               ),
          //             ),
          //             items: activeOrder!.items,
          //             isActive: activeOrder!.isActive,
          //             date: activeOrder!.date,
          //             time: activeOrder!.time,
          //           ),
          //         ),
          //       ).then((_) {
          //         loadActiveOrder();
          //       });
          //     },
          //
          //     child: Container(
          //       margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          //
          //       padding: const EdgeInsets.symmetric(
          //         horizontal: 14,
          //         vertical: 14,
          //       ),
          //
          //       decoration: BoxDecoration(
          //         color: Colors.black,
          //         borderRadius: BorderRadius.circular(18),
          //         boxShadow: [
          //           BoxShadow(
          //             color: Colors.black.withOpacity(0.15),
          //             blurRadius: 10,
          //             offset: const Offset(0, 3),
          //           ),
          //         ],
          //       ),
          //
          //       child: Row(
          //         children: [
          //           /// LIVE DOT
          //           Container(
          //             width: 10,
          //             height: 10,
          //             decoration: const BoxDecoration(
          //               color: Colors.green,
          //               shape: BoxShape.circle,
          //             ),
          //           ),
          //
          //           const SizedBox(width: 12),
          //
          //           Expanded(
          //             child: Column(
          //               crossAxisAlignment: CrossAxisAlignment.start,
          //               children: [
          //                 Text(
          //                   "Order #${activeOrder!.id}",
          //                   style: const TextStyle(
          //                     color: Colors.white,
          //                     fontWeight: FontWeight.w700,
          //                     fontSize: 14,
          //                   ),
          //                 ),
          //
          //                 const SizedBox(height: 3),
          //
          //                 Text(
          //                   getOrderStatusText(activeOrder!.status),
          //                   style: const TextStyle(
          //                     color: Colors.white70,
          //                     fontSize: 12,
          //                   ),
          //                 ),
          //               ],
          //             ),
          //           ),
          //
          //           const Icon(
          //             Icons.arrow_forward_ios_rounded,
          //             color: Colors.white,
          //             size: 16,
          //           ),
          //         ],
          //       ),
          //     ),
          //   ),
          // if (_currentIndex == 0 && activeOrder != null)
          if (_currentIndex == 0 &&
              activeOrder != null &&
              activeOrder!.orderType == OrderType.DELIVERY)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderDetailsScreen(
                      orderId: activeOrder!.orderId,
                      order: activeOrder!,
                      formattedDate: DateTimeHelper.formatDate(
                        activeOrder!.parsedDateTime.toUtc(),
                      ),
                      formattedTime: DateTimeHelper.formatTime(
                        activeOrder!.parsedDateTime.toUtc(),
                      ),
                      items: activeOrder!.items,
                      isActive: activeOrder!.isActive,
                      date: activeOrder!.date,
                      time: activeOrder!.time,
                    ),
                  ),
                ).then((_) => loadActiveOrder());
              },
              child: Container(
                margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  // color: Theme.of(context).cardColor,
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.withOpacity(0.15)),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        // Pulsing live dot in a rounded square
                        // Container(
                        //   width: 40,
                        //   height: 40,
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFFEAFFF4),
                        //     borderRadius: BorderRadius.circular(12),
                        //   ),
                        //   child: Center(child: _PulsingDot()),
                        // ),
                        const SizedBox(width: 14),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    "Order #${activeOrder!.id}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    getOrderStatusText(activeOrder!.status),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.white,
                          size: 20,
                        ),

                        // ── Progress steps ──
                      ],
                    ),
                    const SizedBox(height: 16),
                    _OrderProgressStepper(status: activeOrder!.status),
                  ],
                ),
              ),
            ),

          /// BOTTOM NAV
          SafeArea(
            top: false,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: _showBottomBar ? kBottomNavigationBarHeight : 0,
              child: Wrap(children: [_buildBottomBar()]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,

      currentIndex: _currentIndex,

      type: BottomNavigationBarType.fixed,

      selectedItemColor: AppColors.primary,

      unselectedItemColor: Colors.grey,

      onTap: (index) {
        /// Pause reels
        if (_currentIndex == 1 && index != 1) {
          reelsKey.currentState?.setScreenActive(false);
        }

        /// Resume reels
        if (index == 1) {
          reelsKey.currentState?.setScreenActive(true);
        }

        /// Reload cart
        if (index == 2) {
          final cartScreen = _screens[2] as CommonCartScreen;

          cartScreen.reloadCart?.call();
        }

        setState(() {
          _currentIndex = index;
          _showBottomBar = true;
        });
      },

      items: [
        const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),

        const BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_rounded),
          label: 'Deals',
        ),

        _cartNavItem(),

        const BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }

  BottomNavigationBarItem _cartNavItem() {
    return BottomNavigationBarItem(
      label: 'Cart',

      icon: ValueListenableBuilder<int>(
        valueListenable: CartNotifier.count,

        builder: (context, count, _) {
          return Stack(
            clipBehavior: Clip.none,

            children: [
              const Icon(Icons.shopping_cart),

              if (count > 0)
                Positioned(
                  right: -6,
                  top: -4,

                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 5,
                      vertical: 2,
                    ),

                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),

                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),

                    child: Text(
                      count > 9 ? '9+' : count.toString(),

                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),

                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _OrderProgressStepper extends StatelessWidget {
  final OrderStatus status;

  const _OrderProgressStepper({required this.status});

  int get _currentStep {
    switch (status) {
      case OrderStatus.pending:
        return 0;
      case OrderStatus.confirmed:
        return 1;
      case OrderStatus.beingPrepared:
      case OrderStatus.orderIsReady:
        return 2;
      case OrderStatus.waitingForPickup:
      case OrderStatus.ontheway:
        return 3;
      case OrderStatus.completed:
        return 4;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    const steps = [
      {'label': 'Placed', 'icon': Icons.receipt_long_rounded},
      {'label': 'Confirmed', 'icon': Icons.check_circle_outline_rounded},
      {'label': 'Preparing', 'icon': Icons.restaurant_rounded},
      {'label': 'On the way', 'icon': Icons.directions_bike_rounded},
      {'label': 'Delivered', 'icon': Icons.inventory_2_rounded},
    ];

    return Row(
      children: List.generate(steps.length * 2 - 1, (i) {
        if (i.isOdd) {
          final isDone = (i ~/ 2) < _currentStep;
          return Expanded(
            child: Container(
              height: 2,
              margin: const EdgeInsets.only(bottom: 18),
              color: isDone ? const Color(0xFF22C55E) : Colors.grey.shade200,
            ),
          );
        }

        final stepIndex = i ~/ 2;
        final isDone = stepIndex <= _currentStep;
        final isActive = stepIndex == _currentStep;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDone ? const Color(0xFF22C55E) : Colors.grey.shade100,
                border: Border.all(
                  color: isDone
                      ? const Color(0xFF22C55E)
                      : Colors.grey.shade300,
                  width: 0.5,
                ),
              ),
              child: Center(
                child: Icon(
                  isDone && !isActive
                      ? Icons.check_rounded
                      : steps[stepIndex]['icon'] as IconData,
                  size: 13,
                  color: isDone ? Colors.white : Colors.grey.shade400,
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIndex]['label'] as String,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: isDone ? Colors.white : Colors.white,
              ),
            ),
          ],
        );
      }),
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
