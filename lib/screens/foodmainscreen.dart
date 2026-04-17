import 'dart:math';

import 'package:maamaas/screens/screens/advertisements/popup_message.dart';
import 'package:firebase_in_app_messaging/firebase_in_app_messaging.dart';
import 'package:maamaas/screens/screens/advertisements/videoscreen.dart';
import '../Services/Auth_service/promotion_services_Authservice.dart';
import 'package:maamaas/Services/App_color_service/app_colours.dart';
import '../../widgets/widgets/food/currentcart_notifier.dart';
import 'package:maamaas/screens/screens/profile_screen.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../Models/promotions_model/promotions_model.dart';
import 'Food&beverages/RestaurentsScreen/restaurentsnew.dart';
import 'Food&beverages/commonCartscreen.dart';
import 'Food&beverages/food_cartscreen.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import '../../utils/utils.dart';
import 'homescreens/home_page.dart';

class MainScreenfood extends StatefulWidget {
  const MainScreenfood({super.key});

  @override
  State<MainScreenfood> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenfood> {
  final GlobalKey<ReelsScreenState> reelsKey = GlobalKey();
  int _currentIndex = 0;
  int seatingId = 0;

  bool _showBottomBar = true;
  final ScrollController _scrollController = ScrollController();
  List<Campaign> ads = [];

  @override
  void initState() {
    super.initState();
    // Utils.itemCount.addListener(_updateCount);
    // loadCartData();
    Utils.refreshCartCount();
    // _loadUserType();
    FirebaseInAppMessaging.instance.triggerEvent("app_open");
    _scrollController.addListener(_handleScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkPromotions();
    });
  }

  void _handleScroll() {
    if (_scrollController.position.userScrollDirection ==
        ScrollDirection.reverse) {
      // scrolling up → hide footer
      if (_showBottomBar) {
        setState(() => _showBottomBar = false);
      }
    } else if (_scrollController.position.userScrollDirection ==
        ScrollDirection.forward) {
      // scrolling down → show footer
      if (!_showBottomBar) {
        setState(() => _showBottomBar = true);
      }
    }
  }

  void checkPromotions() async {
    try {
      final result = await promotion_Authservice.fetchcampaign();

      if (!mounted) return;

      final filteredAds = result.where((campaign) {
        return campaign.status == Status.ACTIVE &&
            campaign.approvalStatus == ApprovalStatus.APPROVED &&
            campaign.addDisplayPosition == AddDisplayPosition.IN_APP_POPUP;
      }).toList();

      if (filteredAds.isEmpty) return;

      /// 🎯 Pick random ad
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> loadCartData() async {
    try {
      final count = await food_Authservice.fetchCartCount();
      CartNotifier.update(count);
    } catch (e) {}
  }

  void openReelsTab() {
    setState(() {
      _currentIndex = 1; // Ads / Reels tab
    });
  }

  late final _screens = [
    Restaurents(scrollController: _scrollController),
    // HomePage(scrollController: _scrollController),
    ReelsScreen(key: reelsKey),
    // const food_cartScreen(),
    CommonCartScreen(),
    Profile(),
  ];

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
      bottomNavigationBar: SafeArea(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: _showBottomBar ? kBottomNavigationBarHeight : 0,
          child: Wrap(children: [_buildBottomBar()]),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return BottomNavigationBar(
      backgroundColor: Colors.white,
      // currentIndex: _currentIndex,
      currentIndex: _currentIndex,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: Colors.grey,
      // onTap: (index) {
      //   if (_currentIndex == 1 && index != 1) {
      //     reelsKey.currentState?.setScreenActive(false);
      //   }
      //
      //   if (index == 1) {
      //     reelsKey.currentState?.setScreenActive(true);
      //   }
      //
      //   setState(() {
      //     _currentIndex = index;
      //     _showBottomBar = true;
      //   });
      // },
      onTap: (index) {
        if (_currentIndex == 1 && index != 1) {
          reelsKey.currentState?.setScreenActive(false);
        }

        if (index == 1) {
          reelsKey.currentState?.setScreenActive(true);
        }

        /// 🟢 IMPORTANT: Reload cart when opening cart tab
        if (index == 2) {
          final cartScreen = _screens[2] as CommonCartScreen;
          cartScreen.reloadCart?.call(); // we'll add this
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
        // BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Cart'),
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
