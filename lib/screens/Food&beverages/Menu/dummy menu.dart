// // import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
// // import 'package:marquee/marquee.dart';
// // import '../../../Models/subscrptions/coupon_model.dart';
// // import '../../../Services/App_color_service/app_colours.dart';
// // import '../../../Services/Auth_service/food_authservice.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import '../../../widgets/widgets/food/favorite_button.dart';
// // import '../../../Models/food/restaurent_banner_model.dart';
// // import '../../../Models/food/aboutus_model.dart';
// // import '../../../Models/food/team_model.dart';
// // import '../../skeleton/menu_skeleton.dart';
// // import '../../../Models/food/dish.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'cart_footer_button.dart';
// // import '../../Mainscreen.dart';
// // import '../table/Table.dart';
// // import 'cart_button.dart';
// // import 'fullscreen.dart';
// // import 'Menuhelper.dart';
// // import 'Top_banner.dart';
// // import 'colours.dart';
// // import 'dart:async';
// //
// // class MenuResponse {
// //   final List<Dish> categories;
// //   final List<Dish> dishes;
// //   final String? errorMessage;
// //   final bool hasError;
// //
// //   MenuResponse({
// //     required this.categories,
// //     required this.dishes,
// //     this.errorMessage,
// //     this.hasError = false,
// //   });
// // }
// //
// // class MenuScreen extends StatefulWidget {
// //   final int vendorId;
// //   final String? initialCategoryName;
// //   // final Restaurent_Banner? banner;
// //
// //   const MenuScreen({
// //     super.key,
// //     required this.vendorId,
// //     this.initialCategoryName,
// //     // this.banner,
// //   });
// //
// //   @override
// //   State<MenuScreen> createState() => _MenuScreenState();
// // }
// //
// // class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
// //   final ScrollController _scrollController = ScrollController();
// //   Timer? _scrollTimer;
// //
// //   bool _isCollapsed = false;
// //   bool? isVeg;
// //   int selectedTabIndex = 0;
// //   int? selectedCategoryId;
// //   List<Dish> categories = [];
// //   // String orderType = "";
// //   String orderType = "DINE_IN";
// //   String searchQuery = "";
// //   Restaurent_Banner? _bannerItem;
// //   AboutUsModel? _aboutus;
// //   List<vendorteam> _team = [];
// //   Map<int, int> favoriteMap = {};
// //
// //   DishFilterType selectedFilter = DishFilterType.none;
// //
// //   late Future<void> _screenFuture;
// //   late AnimationController _fadeController;
// //   late Animation<double> _fadeAnim;
// //   BannerContentType selectedContent = BannerContentType.none;
// //   static const double _expandedHeight = 400.0;
// //
// //   String get normalizedOrderType => orderType.trim().toUpperCase();
// //   bool get showMenuTab =>
// //       ["DINE_IN", "TAKEAWAY", "DELIVERY"].contains(normalizedOrderType);
// //   bool get showTableTab => normalizedOrderType == "TABLE_DINE_IN";
// //
// //   List<CouponModel> coupons = [];
// //
// //   final ScrollController _couponController = ScrollController();
// //   Timer? _couponTimer;
// //
// //   void _startCouponScroll() {
// //     _couponTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
// //       if (!_couponController.hasClients) return;
// //
// //       final max = _couponController.position.maxScrollExtent;
// //       final current = _couponController.offset + 1;
// //
// //       if (current >= max) {
// //         _couponController.jumpTo(0);
// //       } else {
// //         _couponController.jumpTo(current);
// //       }
// //     });
// //   }
// //
// //   List<CouponModel> get vendorCoupons {
// //     return coupons.where((c) {
// //       return c.vendorId == widget.vendorId &&
// //           c.isCurrentlyAvailable &&
// //           c.active;
// //     }).toList();
// //   }
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _fadeController = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 400),
// //     );
// //     _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
// //
// //     // Single future — FutureBuilder waits on this, no separate call
// //     _screenFuture = _initializeScreen();
// //     // _bannerItem = widget.banner;
// //
// //     _scrollController.addListener(() {
// //       final collapsed =
// //           _scrollController.offset > (_expandedHeight - kToolbarHeight);
// //       if (collapsed != _isCollapsed) {
// //         setState(() => _isCollapsed = collapsed);
// //       }
// //     });
// //     _startCouponScroll();
// //   }
// //
// //   List<CouponModel> get visibleCoupons {
// //     return vendorCoupons.where((coupon) {
// //       return coupon.isCurrentlyAvailable;
// //     }).toList();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _scrollTimer?.cancel();
// //     _scrollController.dispose();
// //     _fadeController.dispose();
// //     _couponTimer?.cancel();
// //     _couponController.dispose();
// //     super.dispose();
// //   }
// //
// //   Future<void> _initializeScreen() async {
// //     await _loadPrefs();
// //     await Future.wait([
// //       _loadBannerData(),
// //       _loadMenu(),
// //       _loadaboutus(),
// //       _loadteam(),
// //       _loadFavorites(),
// //       _loadCoupons(),
// //     ]);
// //     if (mounted) _fadeController.forward();
// //   }
// //
// //   Future<void> _loadCoupons() async {
// //     final data = await food_Authservice.fetchCoupons();
// //
// //     if (!mounted) return;
// //
// //     setState(() {
// //       coupons = data;
// //     });
// //   }
// //
// //   Future<void> _loadFavorites() async {
// //     try {
// //       final favs = await food_Authservice.getFavoritesByUserId();
// //
// //       if (!mounted) return;
// //
// //       setState(() {
// //         favoriteMap = {
// //           for (var f in favs)
// //             if (f.dishId != null && f.favId != null) f.dishId!: f.favId!,
// //         };
// //       });
// //     } catch (e) {
// //       //       debugPrint("Fav error: $e");
// //     }
// //   }
// //
// //   Future<void> _loadBannerData() async {
// //     try {
// //       final banner = await Authservice().fetchVendorBanner(widget.vendorId);
// //       if (mounted) {
// //         setState(() {
// //           _bannerItem = banner;
// //         });
// //       }
// //     } catch (_) {}
// //   }
// //
// //   Future<void> _loadaboutus() async {
// //     try {
// //       final about = await food_Authservice.fetchAboutUsData(widget.vendorId);
// //       if (mounted) {
// //         setState(() {
// //           _aboutus = about;
// //         });
// //       }
// //     } catch (_) {}
// //   }
// //
// //   Future<void> _loadteam() async {
// //     try {
// //       final team = await food_Authservice.fetchteam(widget.vendorId);
// //       if (mounted) {
// //         setState(() {
// //           _team = team;
// //         });
// //       }
// //     } catch (_) {}
// //   }
// //
// //   Future<void> _loadPrefs() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     if (mounted) {
// //       setState(() {
// //         orderType =
// //             prefs.getString('orderType')?.trim().toUpperCase() ?? "DINE_IN";
// //       });
// //     }
// //   }
// //
// //   Future<void> _onRefresh() async {
// //     HapticFeedback.lightImpact();
// //     await Future.delayed(const Duration(milliseconds: 500));
// //     await _loadMenu();
// //   }
// //
// //   Future<void> _loadMenu() async {
// //     final menu = await Authservice.fetchMenu(widget.vendorId);
// //     if (!mounted) return;
// //     setState(() {
// //       categories = menu.categories.where((c) => c.parentId == 0).toList();
// //
// //       // Auto-select the category passed from Restaurants screen
// //       if (widget.initialCategoryName != null && categories.isNotEmpty) {
// //         final match = categories.firstWhere(
// //           (c) =>
// //               c.dishName?.toLowerCase() ==
// //               widget.initialCategoryName!.toLowerCase(),
// //           orElse: () => categories.first,
// //         );
// //         selectedCategoryId = match.dishId;
// //       }
// //     });
// //   }
// //
// //   String formatTime(String time) {
// //     final parts = time.split(':');
// //
// //     final dt = DateTime(2026, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
// //
// //     return TimeOfDay.fromDateTime(dt).format(context);
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return AnnotatedRegion<SystemUiOverlayStyle>(
// //       value: SystemUiOverlayStyle.light,
// //       child: Scaffold(
// //         // backgroundColor: Colors.white,
// //         backgroundColor: Colors.grey.shade50,
// //         body: Stack(
// //           children: [
// //             FutureBuilder<void>(
// //               future: _screenFuture,
// //               builder: (context, snapshot) {
// //                 if (snapshot.connectionState == ConnectionState.waiting ||
// //                     categories.isEmpty ||
// //                     _bannerItem == null) {
// //                   return const MenuSkeletonScreen();
// //                 }
// //                 if (snapshot.hasError) {
// //                   return _buildFullError();
// //                 }
// //                 return FadeTransition(
// //                   opacity: _fadeAnim,
// //                   child: _buildMainScreen(),
// //                 );
// //               },
// //             ),
// //
// //             // Floating cart bars
// //             if (showMenuTab)
// //               Positioned(
// //                 left: 16,
// //                 right: 16,
// //                 bottom: 16,
// //                 child: const food_Cart_count(),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildFullError() {
// //     return Center(
// //       child: Column(
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           Container(
// //             width: 80.r,
// //             height: 80.r,
// //             decoration: BoxDecoration(
// //               color: Menucolours.surfaceAlt,
// //               shape: BoxShape.circle,
// //             ),
// //             child: Icon(
// //               Icons.wifi_off_rounded,
// //               size: 36.sp,
// //               color: Menucolours.textM,
// //             ),
// //           ),
// //           SizedBox(height: 16.h),
// //           Text('Failed to load menu', style: Menucolours.h2()),
// //           SizedBox(height: 6.h),
// //           Text(
// //             'Pull down to try again',
// //             style: Menucolours.body(color: Menucolours.textS),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildMainScreen() {
// //     return RefreshIndicator(
// //       color: Menucolours.primary,
// //       backgroundColor: Menucolours.surface,
// //       displacement: 80,
// //       strokeWidth: 2.5,
// //       onRefresh: _onRefresh,
// //       child: CustomScrollView(
// //         controller: _scrollController,
// //         physics: const BouncingScrollPhysics(),
// //         slivers: [
// //           // ── Banner AppBar ──────────────────────────────────────────
// //           SliverAppBar(
// //             pinned: true,
// //             expandedHeight: _expandedHeight,
// //             collapsedHeight: 64,
// //             backgroundColor: Menucolours.surface,
// //             elevation: 0,
// //             scrolledUnderElevation: 1,
// //             // ignore: deprecated_member_use
// //             shadowColor: Colors.black.withOpacity(0.08),
// //             automaticallyImplyLeading: true,
// //             leading: IconButton(
// //               icon: const Icon(
// //                 Icons.arrow_back_ios_new_rounded,
// //                 size: 18,
// //                 color: Colors.black,
// //               ),
// //               onPressed: () => Navigator.maybePop(context),
// //             ),
// //             title: _isCollapsed
// //                 ? _CollapsedFilterBar(
// //                     isVeg: isVeg ?? false,
// //                     vendorId: widget.vendorId,
// //                     onToggle: (v) => setState(() => isVeg = v),
// //                     onSearch: (v) => setState(() => searchQuery = v),
// //                   )
// //                 : null,
// //             titleSpacing: 0,
// //             flexibleSpace: FlexibleSpaceBar(
// //               collapseMode: CollapseMode.parallax,
// //               background: BannerSection(
// //                 bannerItem: _bannerItem,
// //                 aboutus: _aboutus,
// //                 team: _team,
// //                 isVeg: isVeg ?? false,
// //                 vendorId: widget.vendorId,
// //                 onToggle: (v) => setState(() => isVeg = v),
// //                 onSearch: (v) => setState(() => searchQuery = v),
// //                 onContentSelected: (BannerContentType type) {
// //                   setState(() {
// //                     selectedContent = selectedContent == type
// //                         ? BannerContentType.none
// //                         : type;
// //                   });
// //                 },
// //               ),
// //             ),
// //           ),
// //
// //           SliverToBoxAdapter(child: _buildBannerContent()),
// //
// //           // ── Sticky category + table tabs ────────────────────────────
// //           SliverPersistentHeader(
// //             pinned: true,
// //             delegate: _StickyTabsDelegate(
// //               height: _headerHeight,
// //               child: _StickyTabsContent(
// //                 categories: categories,
// //                 showTableTab: !showMenuTab,
// //                 vendorId: widget.vendorId,
// //                 selectedCategoryId: selectedCategoryId,
// //                 onCategorySelected: (id) =>
// //                     setState(() => selectedCategoryId = id),
// //               ),
// //             ),
// //           ),
// //
// //           // ── Dish grid ───────────────────────────────────────────────
// //           SliverToBoxAdapter(
// //             child: visibleCoupons.isEmpty
// //                 ? const SizedBox()
// //                 : OfferTicker(coupons: visibleCoupons, formatTime: formatTime),
// //           ),
// //           SliverToBoxAdapter(
// //             child: Padding(
// //               padding: EdgeInsets.only(bottom: 100.h),
// //               child: MenuTabContent(
// //                 selectedFilter: selectedFilter,
// //                 isVeg: isVeg,
// //                 vendorId: widget.vendorId,
// //                 selectedVendorId: widget.vendorId,
// //                 favoriteMap: favoriteMap,
// //                 cartButton: (dish) => CartButton(
// //                   dishId: dish.dishId,
// //                   balanceQuantity: dish.balanceQuantity,
// //                 ),
// //                 // favoriteButton: favbutton(),
// //                 isOutOfStock: (dish) => dish.stock?.toLowerCase() != 'in stock',
// //                 selectedCategoryId: selectedCategoryId,
// //                 searchQuery: searchQuery,
// //                 showCartButton: !showTableTab,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   double get _headerHeight {
// //     double base = 88.h;
// //     double table = 52.h;
// //     return !showMenuTab ? base + table : base;
// //   }
// //
// //   Widget _buildBannerContent() {
// //     if (selectedContent == BannerContentType.none) {
// //       return SizedBox();
// //     }
// //
// //     final about = _aboutus;
// //     if (about == null) return SizedBox();
// //
// //     // =======================
// //     // ✅ ABOUT SECTION
// //     // =======================
// //     if (selectedContent == BannerContentType.about) {
// //       return Container(
// //         color: Colors.white,
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             // 🔹 Top Image
// //             if (about.image.isNotEmpty)
// //               Image.network(
// //                 about.image,
// //                 width: double.infinity,
// //                 height: 160.h,
// //                 fit: BoxFit.cover,
// //               ),
// //
// //             Padding(
// //               padding: EdgeInsets.all(16.w),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   // 🔹 ABOUT TEXT
// //                   Text(
// //                     "About Us",
// //                     style: TextStyle(
// //                       fontSize: 18.sp,
// //                       fontWeight: FontWeight.bold,
// //                     ),
// //                   ),
// //
// //                   SizedBox(height: 8.h),
// //
// //                   Text(
// //                     about.aboutUs,
// //                     style: TextStyle(
// //                       fontSize: 13.sp,
// //                       height: 1.4,
// //                       color: Colors.grey.shade800,
// //                     ),
// //                   ),
// //
// //                   SizedBox(height: 20.h),
// //
// //                   if (about.mission.isNotEmpty)
// //                     _infoCard(
// //                       title: "Our Mission",
// //                       description: about.mission,
// //                       image: about.missionImage,
// //                     ),
// //
// //                   SizedBox(height: 12.h),
// //
// //                   // 🔹 Vision Card
// //                   if (about.vision.isNotEmpty)
// //                     _infoCard(
// //                       title: "Our Vision",
// //                       description: about.vision,
// //                       image: about.visionImage,
// //                     ),
// //
// //                   // 🔹 TEAM ONLY (NO GALLERY HERE)
// //                   if (_team.isNotEmpty) ...[
// //                     Text(
// //                       "Our Team",
// //                       style: TextStyle(
// //                         fontSize: 16.sp,
// //                         fontWeight: FontWeight.w600,
// //                       ),
// //                     ),
// //                     SizedBox(height: 10.h),
// //
// //                     SizedBox(
// //                       height: 140.h,
// //                       child: ListView.builder(
// //                         scrollDirection: Axis.horizontal,
// //                         itemCount: _team.length,
// //                         itemBuilder: (context, index) {
// //                           final member = _team[index];
// //
// //                           return Container(
// //                             width: 120.w,
// //                             margin: EdgeInsets.only(right: 12.w),
// //                             padding: EdgeInsets.all(10.w),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(14.r),
// //                               boxShadow: [
// //                                 BoxShadow(
// //                                   // ignore: deprecated_member_use
// //                                   color: Colors.black.withOpacity(0.08),
// //                                   blurRadius: 6,
// //                                   offset: Offset(0, 3),
// //                                 ),
// //                               ],
// //                             ),
// //                             child: Column(
// //                               children: [
// //                                 CircleAvatar(
// //                                   radius: 26.r,
// //                                   backgroundImage: NetworkImage(member.image),
// //                                 ),
// //                                 SizedBox(height: 8.h),
// //
// //                                 Text(
// //                                   member.name,
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                   textAlign: TextAlign.center,
// //                                   style: TextStyle(
// //                                     fontSize: 12.sp,
// //                                     fontWeight: FontWeight.w600,
// //                                   ),
// //                                 ),
// //
// //                                 SizedBox(height: 2.h),
// //
// //                                 Text(
// //                                   member.designation,
// //                                   maxLines: 1,
// //                                   overflow: TextOverflow.ellipsis,
// //                                   style: TextStyle(
// //                                     fontSize: 10.sp,
// //                                     color: Colors.grey,
// //                                   ),
// //                                 ),
// //
// //                                 Expanded(
// //                                   child: Text(
// //                                     member.description,
// //                                     maxLines: 3,
// //                                     overflow: TextOverflow.ellipsis,
// //                                     textAlign: TextAlign.center,
// //                                     style: TextStyle(
// //                                       fontSize: 9.sp,
// //                                       color: Colors.grey.shade700,
// //                                     ),
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           );
// //                         },
// //                       ),
// //                     ),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     // =======================
// //     // ✅ GALLERY SECTION ONLY
// //     // =======================
// //     if (selectedContent == BannerContentType.gallery) {
// //       if (about.allImages.isEmpty) {
// //         return SizedBox();
// //       }
// //
// //       return Container(
// //         color: Colors.white,
// //         padding: EdgeInsets.all(16.w),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             Text(
// //               "Gallery",
// //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
// //             ),
// //
// //             SizedBox(height: 12.h),
// //
// //             SizedBox(
// //               height: 140.h,
// //               child: ListView.builder(
// //                 scrollDirection: Axis.horizontal,
// //                 itemCount: about.allImages.length,
// //                 itemBuilder: (context, index) {
// //                   final img = about.allImages[index];
// //
// //                   return GestureDetector(
// //                     onTap: () {
// //                       _openFullScreenGallery(index);
// //                     },
// //                     child: Container(
// //                       width: 140.w,
// //                       margin: EdgeInsets.only(right: 12.w),
// //                       child: ClipRRect(
// //                         borderRadius: BorderRadius.circular(12.r),
// //                         child: Image.network(img, fit: BoxFit.cover),
// //                       ),
// //                     ),
// //                   );
// //                 },
// //               ),
// //             ),
// //           ],
// //         ),
// //       );
// //     }
// //
// //     return SizedBox();
// //   }
// //
// //   void _openFullScreenGallery(int initialIndex) {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => FullScreenGallery(
// //           images: _aboutus!.allImages,
// //           initialIndex: initialIndex,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _infoCard({
// //     required String title,
// //     required String description,
// //     required String image,
// //   }) {
// //     return Container(
// //       padding: EdgeInsets.all(12.w),
// //       decoration: BoxDecoration(
// //         color: Colors.grey.shade50,
// //         borderRadius: BorderRadius.circular(14.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.05),
// //             blurRadius: 6,
// //             offset: Offset(0, 2),
// //           ),
// //         ],
// //       ),
// //       child: Row(
// //         children: [
// //           // 🔹 Image
// //           if (image.isNotEmpty)
// //             ClipRRect(
// //               borderRadius: BorderRadius.circular(10.r),
// //               child: Image.network(
// //                 image,
// //                 height: 60.h,
// //                 width: 60.w,
// //                 fit: BoxFit.cover,
// //               ),
// //             ),
// //
// //           if (image.isNotEmpty) SizedBox(width: 10.w),
// //
// //           // 🔹 Text
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   title,
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //                 SizedBox(height: 4.h),
// //                 Text(
// //                   description,
// //                   maxLines: 3,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     fontSize: 11.sp,
// //                     color: Colors.grey.shade700,
// //                     height: 1.3,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Collapsed filter bar (shown in AppBar when scrolled) ─────────────────────
// // class _CollapsedFilterBar extends StatefulWidget {
// //   final bool isVeg;
// //   final int vendorId;
// //   final Function(bool) onToggle;
// //   final Function(String) onSearch;
// //
// //   const _CollapsedFilterBar({
// //     required this.isVeg,
// //     required this.vendorId,
// //     required this.onToggle,
// //     required this.onSearch,
// //   });
// //
// //   @override
// //   State<_CollapsedFilterBar> createState() => _CollapsedFilterBarState();
// // }
// //
// // class _CollapsedFilterBarState extends State<_CollapsedFilterBar> {
// //   late bool _isVeg;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _isVeg = widget.isVeg;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Row(
// //       children: [
// //         SizedBox(width: 12.w),
// //         Expanded(
// //           child: SearchField(
// //             onSearch: widget.onSearch,
// //             fillColor: Menucolours.surfaceAlt,
// //           ),
// //         ),
// //         SizedBox(width: 8.w),
// //         VegToggle(
// //           isVeg: _isVeg,
// //           onToggle: (v) {
// //             setState(() => _isVeg = v);
// //             widget.onToggle(v);
// //           },
// //           compact: true,
// //         ),
// //         SizedBox(width: 12.w),
// //       ],
// //     );
// //   }
// // }
// //
// // // ── Banner section with filter bar ───────────────────────────────────────────
// //
// // // ── Shared search field ────────────────────────────────────────────────────────
// //
// // // ── Sticky tabs delegate ───────────────────────────────────────────────────────
// // class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
// //   final Widget child;
// //   final double height;
// //
// //   const _StickyTabsDelegate({required this.child, required this.height});
// //
// //   @override
// //   double get minExtent => height;
// //   @override
// //   double get maxExtent => height;
// //
// //   @override
// //   Widget build(
// //     BuildContext context,
// //     double shrinkOffset,
// //     bool overlapsContent,
// //   ) {
// //     return SizedBox(height: height, child: child);
// //   }
// //
// //   @override
// //   bool shouldRebuild(covariant _StickyTabsDelegate old) =>
// //       old.child != child || old.height != height;
// // }
// //
// // // ── Sticky tabs content ───────────────────────────────────────────────────────
// // class _StickyTabsContent extends StatelessWidget {
// //   final List<Dish> categories;
// //   final bool showTableTab;
// //   final int vendorId;
// //   final int? selectedCategoryId;
// //   final Function(int?) onCategorySelected;
// //
// //   const _StickyTabsContent({
// //     required this.categories,
// //     required this.showTableTab,
// //     required this.vendorId,
// //     required this.selectedCategoryId,
// //     required this.onCategorySelected,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       color: Menucolours.surface,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           if (showTableTab) ...[
// //             TableTabContent(vendorId: vendorId),
// //             Divider(height: 1, thickness: 1, color: Menucolours.borderLight),
// //           ],
// //           Expanded(
// //             child: _CategoryTabStrip(
// //               categories: categories,
// //               selectedCategoryId: selectedCategoryId,
// //               onCategorySelected: onCategorySelected,
// //             ),
// //           ),
// //           Divider(height: 1, thickness: 1, color: Menucolours.borderLight),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Category tab strip ────────────────────────────────────────────────────────
// // class _CategoryTabStrip extends StatelessWidget {
// //   final List<Dish> categories;
// //   final int? selectedCategoryId;
// //   final Function(int?) onCategorySelected;
// //
// //   const _CategoryTabStrip({
// //     required this.categories,
// //     required this.selectedCategoryId,
// //     required this.onCategorySelected,
// //   });
// //
// //   @override
// //   @override
// //   Widget build(BuildContext context) {
// //     final sortedCategories = List<Dish>.from(categories);
// //
// //     sortedCategories.sort((a, b) {
// //       final aIsCombo = (a.dishName ?? '').toLowerCase() == 'offers';
// //       final bIsCombo = (b.dishName ?? '').toLowerCase() == 'offers';
// //
// //       if (aIsCombo && !bIsCombo) return -1;
// //       if (!aIsCombo && bIsCombo) return 1;
// //       return 0;
// //     });
// //
// //     return ListView.builder(
// //       scrollDirection: Axis.horizontal,
// //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //       itemCount: sortedCategories.length + 1,
// //       itemBuilder: (context, index) {
// //         if (index == 0) {
// //           return _CategoryChip(
// //             title: 'All',
// //             image: const AssetImage('assets/allitems.jpg'),
// //             isSelected: selectedCategoryId == null,
// //             onTap: () => onCategorySelected(null),
// //           );
// //         }
// //
// //         final cat = sortedCategories[index - 1];
// //
// //         return _CategoryChip(
// //           title: cat.dishName ?? '',
// //           image: (cat.dishImage != null && cat.dishImage!.isNotEmpty)
// //               ? NetworkImage(cat.dishImage!)
// //               : null,
// //           isSelected: selectedCategoryId == cat.dishId,
// //           onTap: () => onCategorySelected(cat.dishId),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ── Category chip ─────────────────────────────────────────────────────────────
// // class _CategoryChip extends StatelessWidget {
// //   final String title;
// //   final ImageProvider? image;
// //   final bool isSelected;
// //   final VoidCallback onTap;
// //
// //   const _CategoryChip({
// //     required this.title,
// //     this.image,
// //     required this.isSelected,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: () {
// //         HapticFeedback.selectionClick();
// //         onTap();
// //       },
// //       child: Container(
// //         margin: EdgeInsets.only(right: 10.w),
// //         child: Column(
// //           mainAxisAlignment: MainAxisAlignment.center,
// //           children: [
// //             AnimatedContainer(
// //               duration: const Duration(milliseconds: 220),
// //               curve: Curves.easeOutCubic,
// //               width: isSelected ? 52.r : 48.r,
// //               height: isSelected ? 52.r : 48.r,
// //               decoration: BoxDecoration(
// //                 shape: BoxShape.circle,
// //                 color: isSelected ? AppColors.primary : Menucolours.surfaceAlt,
// //                 border: Border.all(
// //                   color: isSelected ? AppColors.primary : Menucolours.border,
// //                   width: isSelected ? 2.5 : 1.5,
// //                 ),
// //                 boxShadow: isSelected
// //                     ? [
// //                         BoxShadow(
// //                           color: Menucolours.primary.withOpacity(0.18),
// //                           blurRadius: 12,
// //                           offset: const Offset(0, 3),
// //                         ),
// //                       ]
// //                     : [],
// //               ),
// //               child: ClipOval(
// //                 child: image != null
// //                     ? Image(image: image!, fit: BoxFit.cover)
// //                     : Icon(
// //                         Icons.restaurant_rounded,
// //                         size: 20.sp,
// //                         color: isSelected
// //                             ? Menucolours.primary
// //                             : Menucolours.textM,
// //                       ),
// //               ),
// //             ),
// //             SizedBox(height: 4.h),
// //             SizedBox(
// //               width: 60.w,
// //               child: AnimatedDefaultTextStyle(
// //                 duration: const Duration(milliseconds: 200),
// //                 style: Menucolours.label(
// //                   color: isSelected ? AppColors.primary : Menucolours.textS,
// //                   size: 10.sp,
// //                 ),
// //                 child: Text(
// //                   title,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   textAlign: TextAlign.center,
// //                 ),
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // MenuFilterBar (public, used externally)
// // // ─────────────────────────────────────────────────────────────────────────────
// // class MenuFilterBar extends StatefulWidget {
// //   final bool isVeg;
// //   final Function(bool) onToggle;
// //   final int selectedFilterIndex;
// //   final int vendorId;
// //   final String? orderType;
// //   final Function(String) onSearch;
// //   final double searchWidth;
// //   final Color searchFillColor;
// //
// //   const MenuFilterBar({
// //     super.key,
// //     required this.isVeg,
// //     required this.onToggle,
// //     required this.vendorId,
// //     this.orderType,
// //     this.selectedFilterIndex = 0,
// //     required this.onSearch,
// //     this.searchWidth = 180,
// //     this.searchFillColor = const Color(0xFFF0F2F8),
// //   });
// //
// //   @override
// //   State<MenuFilterBar> createState() => _MenuFilterBarState();
// // }
// //
// // class _MenuFilterBarState extends State<MenuFilterBar> {
// //   late bool _isVeg;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _isVeg = widget.isVeg;
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       color: Menucolours.surface,
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
// //       child: Row(
// //         children: [
// //           SizedBox(
// //             width: widget.searchWidth,
// //             child: SearchField(
// //               onSearch: widget.onSearch,
// //               fillColor: widget.searchFillColor,
// //             ),
// //           ),
// //           SizedBox(width: 10.w),
// //           VegToggle(
// //             isVeg: _isVeg,
// //             onToggle: (v) {
// //               setState(() => _isVeg = v);
// //               widget.onToggle(v);
// //             },
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class SearchField extends StatelessWidget {
// //   final Function(String) onSearch;
// //   final Color fillColor;
// //
// //   const SearchField({
// //     super.key,
// //     required this.onSearch,
// //     required this.fillColor,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       height: 38.h,
// //       decoration: BoxDecoration(
// //         color: fillColor,
// //         borderRadius: Menucolours.r12,
// //         border: Border.all(color: Menucolours.border),
// //       ),
// //       child: TextField(
// //         onChanged: onSearch,
// //         style: Menucolours.body(size: 13.sp),
// //         decoration: InputDecoration(
// //           hintText: 'Search dishes...',
// //           hintStyle: Menucolours.body(color: Menucolours.textM, size: 13.sp),
// //
// //           prefixIcon: Icon(
// //             Icons.search_rounded,
// //             size: 17.sp,
// //             color: Menucolours.textM,
// //           ),
// //
// //           border: InputBorder.none,
// //           isDense: true,
// //
// //           // ✅ FIX: vertical centering
// //           contentPadding: EdgeInsets.symmetric(vertical: 10.h),
// //
// //           // ✅ FIX: reduce prefixIcon extra space
// //           prefixIconConstraints: BoxConstraints(
// //             minHeight: 20.h,
// //             minWidth: 36.w,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Veg toggle ────────────────────────────────────────────────────────────────
// // class VegToggle extends StatelessWidget {
// //   final bool isVeg;
// //   final Function(bool) onToggle;
// //   final bool compact;
// //
// //   const VegToggle({
// //     super.key,
// //     required this.isVeg,
// //     required this.onToggle,
// //     this.compact = false,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;
// //
// //     return GestureDetector(
// //       onTap: () {
// //         HapticFeedback.selectionClick();
// //         onToggle(!isVeg);
// //       },
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 200),
// //         padding: EdgeInsets.symmetric(
// //           horizontal: compact ? 8.w : 10.w,
// //           vertical: 6.h,
// //         ),
// //         decoration: BoxDecoration(
// //           color: isVeg ? Menucolours.primaryDim : Menucolours.surfaceAlt,
// //           borderRadius: Menucolours.r8,
// //           border: Border.all(
// //             color: isVeg
// //                 ? Menucolours.primary.withOpacity(0.4)
// //                 : Menucolours.border,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 10.r,
// //               height: 10.r,
// //               decoration: BoxDecoration(color: color, shape: BoxShape.circle),
// //             ),
// //             SizedBox(width: 5.w),
// //             AnimatedDefaultTextStyle(
// //               duration: const Duration(milliseconds: 200),
// //               style: Menucolours.label(
// //                 color: color,
// //                 size: compact ? 11.sp : 12.sp,
// //               ),
// //               child: Text(isVeg ? 'Veg' : 'Non veg'),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _DiscountFilterBar extends StatelessWidget {
// //   final DishFilterType selectedFilter;
// //   final ValueChanged<DishFilterType> onFilterChanged;
// //
// //   const _DiscountFilterBar({
// //     required this.selectedFilter,
// //     required this.onFilterChanged,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final filters = [
// //       (DishFilterType.none, 'All', Icons.grid_view_rounded),
// //       (DishFilterType.discount50, 'upto 50% OFF', Icons.sell_outlined),
// //       (DishFilterType.discount20, 'upto 20% OFF', Icons.local_offer_outlined),
// //       (DishFilterType.discount10, 'upto 10% OFF', Icons.local_offer_outlined),
// //       (DishFilterType.under150, 'Under ₹150', Icons.currency_rupee_rounded),
// //       (DishFilterType.under300, 'Under ₹300', Icons.currency_rupee_rounded),
// //     ];
// //
// //     return SizedBox(
// //       height: 52,
// //       child: ListView.separated(
// //         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
// //         scrollDirection: Axis.horizontal,
// //         itemCount: filters.length,
// //         separatorBuilder: (_, __) => const SizedBox(width: 8),
// //         itemBuilder: (_, i) {
// //           final (filter, label, icon) = filters[i];
// //           final active = selectedFilter == filter;
// //
// //           return GestureDetector(
// //             onTap: () => onFilterChanged(filter),
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 150),
// //               padding: const EdgeInsets.symmetric(horizontal: 14),
// //               decoration: BoxDecoration(
// //                 color: active ? const Color(0xFFFAEEDA) : Colors.white,
// //                 borderRadius: BorderRadius.circular(34),
// //                 border: Border.all(
// //                   color: active
// //                       ? const Color(0xFFEF9F27)
// //                       : const Color(0xFFE0DDD8),
// //                   width: 0.5,
// //                 ),
// //               ),
// //               child: Row(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Icon(
// //                     icon,
// //                     size: 14,
// //                     color: active
// //                         ? const Color(0xFF854F0B)
// //                         : const Color(0xFF9C9890),
// //                   ),
// //                   const SizedBox(width: 5),
// //                   Text(
// //                     label,
// //                     style: TextStyle(
// //                       fontSize: 13,
// //                       fontWeight: FontWeight.w500,
// //                       color: active
// //                           ? const Color(0xFF633806)
// //                           : const Color(0xFF6B6760),
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // MenuTabContent
// // // ─────────────────────────────────────────────────────────────────────────────
// // class MenuTabContent extends StatefulWidget {
// //   final bool? isVeg;
// //   final Widget Function(Dish dish) cartButton;
// //   final bool Function(Dish) isOutOfStock;
// //   final int vendorId;
// //   final int selectedVendorId;
// //   // final favoriteButton;
// //   final int? selectedCategoryId;
// //   final String searchQuery;
// //   final bool showCartButton;
// //   final Map<int, int> favoriteMap;
// //   final DishFilterType selectedFilter;
// //
// //   const MenuTabContent({
// //     super.key,
// //     required this.isVeg,
// //     required this.cartButton,
// //     required this.isOutOfStock,
// //     required this.selectedFilter,
// //     // required this.favoriteButton,
// //     required this.selectedVendorId,
// //     required this.vendorId,
// //     this.selectedCategoryId,
// //     required this.searchQuery,
// //     required this.showCartButton,
// //     required this.favoriteMap,
// //   });
// //
// //   @override
// //   State<MenuTabContent> createState() => _MenuTabContentState();
// // }
// //
// // class _MenuTabContentState extends State<MenuTabContent> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return DishGridTab(
// //       selectedFilter: widget.selectedFilter,
// //       parentId: widget.selectedCategoryId,
// //       vendorId: widget.vendorId,
// //       filterTag: widget.isVeg == null
// //           ? null
// //           : widget.isVeg!
// //           ? 'veg'
// //           : 'non_veg',
// //       emptyMessage: widget.isVeg == true
// //           ? 'No veg dishes found.'
// //           : widget.isVeg == false
// //           ? 'No non-veg dishes found.'
// //           : 'No dishes available.',
// //       searchQuery: widget.searchQuery,
// //       showCartButton: widget.showCartButton,
// //       favoriteMap: widget.favoriteMap,
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // DishGridTab
// // // ─────────────────────────────────────────────────────────────────────────────
// // class DishGridTab extends StatefulWidget {
// //   final int? parentId;
// //   final int vendorId;
// //   final String? filterTag;
// //   final String emptyMessage;
// //   final String searchQuery;
// //   final bool showCartButton;
// //   final Map<int, int> favoriteMap;
// //   final DishFilterType selectedFilter;
// //
// //   const DishGridTab({
// //     super.key,
// //     this.parentId,
// //     required this.vendorId,
// //     required this.filterTag,
// //     required this.emptyMessage,
// //     required this.searchQuery,
// //     required this.showCartButton,
// //     required this.favoriteMap,
// //     required this.selectedFilter,
// //   });
// //
// //   @override
// //   // ignore: library_private_types_in_public_api
// //   _DishGridTabState createState() => _DishGridTabState();
// // }
// //
// // class _DishGridTabState extends State<DishGridTab> {
// //   bool _isLoading = true;
// //   List<Dish> _allDishes = [];
// //   String? _errorMessage;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadMenu();
// //   }
// //
// //   @override
// //   void didUpdateWidget(DishGridTab old) {
// //     super.didUpdateWidget(old);
// //     if (widget.parentId != old.parentId || widget.filterTag != old.filterTag) {
// //       _loadMenu();
// //     }
// //   }
// //
// //   Future<void> _loadMenu() async {
// //     setState(() {
// //       _isLoading = true;
// //       _errorMessage = null;
// //     });
// //     final menu = await Authservice.fetchMenu(widget.vendorId);
// //     if (!mounted) return;
// //
// //     if (menu.hasError) {
// //       setState(() {
// //         _isLoading = false;
// //         _errorMessage = menu.errorMessage ?? 'Something went wrong.';
// //       });
// //       return;
// //     }
// //
// //     final dishes = (widget.parentId != null && widget.parentId! > 0)
// //         ? menu.dishes.where((d) => d.parentId == widget.parentId).toList()
// //         : menu.dishes;
// //     for (var dish in dishes) {
// //       if (dish.dishImage != null && dish.dishImage!.isNotEmpty) {
// //         precacheImage(NetworkImage(dish.dishImage!), context);
// //       }
// //     }
// //
// //     setState(() {
// //       _allDishes = dishes;
// //       _isLoading = false;
// //     });
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (_isLoading || _allDishes.isEmpty) {
// //       return const MenuSkeletonScreen();
// //     }
// //     if (_errorMessage != null) return _buildError();
// //
// //     final filtered = _allDishes.where((dish) {
// //       bool discountMatch = true;
// //
// //       switch (widget.selectedFilter) {
// //         case DishFilterType.discount10:
// //           discountMatch = dish.discount <= 10;
// //           break;
// //         case DishFilterType.discount20:
// //           discountMatch = dish.discount <= 20;
// //           break;
// //
// //         case DishFilterType.discount50:
// //           discountMatch = dish.discount <= 50;
// //           break;
// //
// //         case DishFilterType.under150:
// //           discountMatch = (dish.effectivePrice ?? 0) <= 150;
// //           break;
// //
// //         case DishFilterType.under300:
// //           discountMatch = (dish.effectivePrice ?? 0) <= 300;
// //           break;
// //
// //         case DishFilterType.none:
// //           discountMatch = true;
// //           break;
// //       }
// //
// //       final ok = dish.menuStatus == 'Enable';
// //       final veg =
// //           widget.filterTag == null ||
// //           dish.tag?.toLowerCase() == widget.filterTag!.toLowerCase();
// //       final q =
// //           widget.searchQuery.isEmpty ||
// //           dish.dishName!.toLowerCase().contains(
// //             widget.searchQuery.toLowerCase(),
// //           );
// //       // return ok && veg && q;
// //       return ok && veg && q && discountMatch;
// //     }).toList();
// //
// //     filtered.sort((a, b) {
// //       final aOut =
// //           a.balanceQuantity <= 0 || a.stock?.toLowerCase() != 'in_stock';
// //       final bOut =
// //           b.balanceQuantity <= 0 || b.stock?.toLowerCase() != 'in_stock';
// //       if (aOut == bOut) return 0;
// //       return aOut ? 1 : -1;
// //     });
// //
// //     if (filtered.isEmpty) {
// //       return _buildEmpty();
// //     }
// //
// //     final crossAxis = Radiusc.crossAxis(context);
// //     final cardExtent = Radiusc.cardExtent(
// //       context,
// //       showCart: widget.showCartButton,
// //     );
// //
// //     return Padding(
// //       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
// //       child: GridView.builder(
// //         shrinkWrap: true,
// //         physics: const NeverScrollableScrollPhysics(),
// //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //           crossAxisCount: crossAxis,
// //           crossAxisSpacing: 10.w,
// //           mainAxisSpacing: 12.h,
// //           mainAxisExtent: cardExtent,
// //         ),
// //         itemCount: filtered.length,
// //         itemBuilder: (_, i) {
// //           final dish = filtered[i];
// //           final isOut =
// //               dish.balanceQuantity <= 0 ||
// //               dish.stock?.toLowerCase() != 'in_stock';
// //           final isFav = widget.favoriteMap.containsKey(dish.dishId);
// //           return _AnimatedProductCard(
// //             index: i,
// //             child: ProductCard(
// //               dish: dish,
// //               imageWidget: _buildDishImage(dish.dishImage),
// //               name: dish.dishName ?? '',
// //               price: '₹${dish.price}',
// //               effectivePrice: '₹${dish.effectivePrice}',
// //               description: dish.description ?? '',
// //               favoriteButton: FavoriteButton(
// //                 dish: dish,
// //                 isInitiallyLiked: isFav,
// //                 favId: widget.favoriteMap[dish.dishId],
// //                 onChanged: (dishId, isLiked, favId) {
// //                   setState(() {
// //                     if (isLiked) {
// //                       if (favId != null) {
// //                         widget.favoriteMap[dishId] = favId;
// //                       }
// //                     } else {
// //                       widget.favoriteMap.remove(dishId);
// //                     }
// //                   });
// //                 },
// //               ),
// //               cartButton: CartButton(
// //                 dishId: dish.dishId,
// //                 balanceQuantity: dish.balanceQuantity,
// //               ),
// //               isOutOfStock: isOut,
// //               balanceQuantity: dish.balanceQuantity,
// //               discount: dish.discount,
// //               tag: dish.tag,
// //               showCartButton: widget.showCartButton,
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   Widget _buildDishImage(String? url) {
// //     if (url != null && url.isNotEmpty) {
// //       return Container(
// //         color: Colors.white,
// //         width: double.infinity,
// //         height: double.infinity,
// //         child: Image.network(
// //           url,
// //           fit: BoxFit.contain,
// //           errorBuilder: (_, __, ___) => _imagePlaceholder(),
// //         ),
// //       );
// //     }
// //     return _imagePlaceholder();
// //   }
// //
// //   Widget _imagePlaceholder() {
// //     return Container(
// //       color: Menucolours.surfaceAlt,
// //       child: Center(
// //         child: Icon(
// //           Icons.fastfood_rounded,
// //           size: 32.sp,
// //           // color: Menucolours.textM,
// //           color: Colors.white,
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildEmpty() {
// //     return Padding(
// //       padding: EdgeInsets.symmetric(vertical: 60.h),
// //       child: Center(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Container(
// //               width: 72.r,
// //               height: 72.r,
// //               decoration: BoxDecoration(
// //                 color: Menucolours.surfaceAlt,
// //                 shape: BoxShape.circle,
// //               ),
// //               child: Icon(
// //                 Icons.search_off_rounded,
// //                 size: 32.sp,
// //                 color: Menucolours.textM,
// //               ),
// //             ),
// //             SizedBox(height: 14.h),
// //             Text(
// //               'Nothing here',
// //               style: Menucolours.h2(color: Menucolours.textH),
// //             ),
// //             SizedBox(height: 6.h),
// //             Text(
// //               widget.emptyMessage,
// //               style: Menucolours.body(color: Menucolours.textS),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildError() {
// //     return Padding(
// //       padding: EdgeInsets.all(20.w),
// //       child: Center(
// //         child: Container(
// //           constraints: const BoxConstraints(maxWidth: 360),
// //           padding: EdgeInsets.all(24.w),
// //           decoration: BoxDecoration(
// //             color: Menucolours.surface,
// //             borderRadius: Menucolours.r20,
// //             border: Border.all(color: Menucolours.border),
// //             boxShadow: Menucolours.cardShadow,
// //           ),
// //           child: Column(
// //             mainAxisSize: MainAxisSize.min,
// //             children: [
// //               Container(
// //                 width: 64.r,
// //                 height: 64.r,
// //                 decoration: BoxDecoration(
// //                   color: Menucolours.nonVegRed.withOpacity(0.08),
// //                   shape: BoxShape.circle,
// //                 ),
// //                 child: Icon(
// //                   Icons.restaurant_menu_rounded,
// //                   color: Menucolours.nonVegRed,
// //                   size: 28.sp,
// //                 ),
// //               ),
// //               SizedBox(height: 16.h),
// //               Text(
// //                 'Action Required',
// //                 style: Menucolours.h2(),
// //                 textAlign: TextAlign.center,
// //               ),
// //               SizedBox(height: 8.h),
// //               Text(
// //                 _errorMessage!,
// //                 style: Menucolours.body(color: Menucolours.textS),
// //                 textAlign: TextAlign.center,
// //               ),
// //               SizedBox(height: 20.h),
// //               SizedBox(
// //                 width: double.infinity,
// //                 height: 48.h,
// //                 child: ElevatedButton.icon(
// //                   onPressed: () => Navigator.pushAndRemoveUntil(
// //                     context,
// //                     MaterialPageRoute(builder: (_) => MainScreenfood()),
// //                     (r) => false,
// //                   ),
// //                   icon: Icon(Icons.swap_horiz_rounded, size: 18.sp),
// //                   label: Text(
// //                     _errorMessage!,
// //                     style: TextStyle(
// //                       fontSize: 12.sp,
// //                       fontWeight: FontWeight.w600,
// //                     ),
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                   ),
// //                   style: ElevatedButton.styleFrom(
// //                     backgroundColor: Menucolours.primary,
// //                     foregroundColor: Colors.white,
// //                     elevation: 0,
// //                     shape: RoundedRectangleBorder(
// //                       borderRadius: Menucolours.r12,
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Staggered card animation ──────────────────────────────────────────────────
// // class _AnimatedProductCard extends StatefulWidget {
// //   final int index;
// //   final Widget child;
// //
// //   const _AnimatedProductCard({required this.index, required this.child});
// //
// //   @override
// //   State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
// // }
// //
// // class _AnimatedProductCardState extends State<_AnimatedProductCard>
// //     with SingleTickerProviderStateMixin {
// //   late AnimationController _ctrl;
// //   late Animation<double> _scale;
// //   late Animation<double> _fade;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _ctrl = AnimationController(
// //       vsync: this,
// //       duration: const Duration(milliseconds: 350),
// //     );
// //     final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
// //     _scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
// //     _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
// //     Future.delayed(Duration(milliseconds: 80 * (widget.index % 6)), () {
// //       if (mounted) _ctrl.forward();
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _ctrl.dispose();
// //     super.dispose();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FadeTransition(
// //       opacity: _fade,
// //       child: ScaleTransition(scale: _scale, child: widget.child),
// //     );
// //   }
// // }
// //
// // // ─────────────────────────────────────────────────────────────────────────────
// // // ProductCard
// // // ─────────────────────────────────────────────────────────────────────────────
// // class ProductCard extends StatelessWidget {
// //   final Widget imageWidget;
// //   final String name;
// //   final String price;
// //   final String description;
// //   final String effectivePrice;
// //   final Widget favoriteButton;
// //   final Widget cartButton;
// //   final bool isOutOfStock;
// //   final int balanceQuantity;
// //   final num discount;
// //   final String? tag;
// //   final bool showCartButton;
// //   final Dish dish;
// //
// //   const ProductCard({
// //     super.key,
// //     required this.imageWidget,
// //     required this.name,
// //     required this.price,
// //     required this.description,
// //     required this.effectivePrice,
// //     required this.favoriteButton,
// //     required this.cartButton,
// //     required this.isOutOfStock,
// //     required this.balanceQuantity,
// //     required this.discount,
// //     required this.tag,
// //     required this.showCartButton,
// //     required this.dish,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final isPhone = Radiusc.isPhone(context);
// //     // final imgH = isPhone ? 115.0 : 140.0;
// //     final imgH = 100.0;
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: Menucolours.surface,
// //         borderRadius: Menucolours.r16,
// //         border: Border.all(color: Menucolours.borderLight),
// //         boxShadow: Menucolours.cardShadow,
// //       ),
// //       clipBehavior: Clip.antiAlias,
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           // ── Image section ────────────────────────────────────────
// //           SizedBox(
// //             height: imgH,
// //             child: Stack(
// //               fit: StackFit.expand,
// //               children: [
// //                 imageWidget,
// //
// //                 // Scrim for readability
// //                 Container(
// //                   decoration: BoxDecoration(
// //                     gradient: LinearGradient(
// //                       begin: Alignment.topCenter,
// //                       end: Alignment.bottomCenter,
// //                       stops: const [0.6, 1.0],
// //                       colors: [
// //                         Colors.transparent,
// //                         Colors.black.withOpacity(0.15),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //
// //                 // Discount badge
// //                 if (discount > 0)
// //                   Positioned(
// //                     top: 8,
// //                     left: 8,
// //                     child: Container(
// //                       padding: EdgeInsets.symmetric(
// //                         horizontal: 7.w,
// //                         vertical: 3.h,
// //                       ),
// //                       decoration: BoxDecoration(
// //                         color: Menucolours.accent,
// //                         borderRadius: Menucolours.r8,
// //                       ),
// //                       child: Text(
// //                         '${discount.toStringAsFixed(0)}%',
// //                         style: TextStyle(
// //                           fontSize: 9.sp,
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w800,
// //                           letterSpacing: 0.2,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //
// //                 // Favourite button
// //                 Positioned(
// //                   top: 8,
// //                   right: 8,
// //                   child: Container(
// //                     width: 30.r,
// //                     height: 30.r,
// //                     decoration: BoxDecoration(
// //                       color: Colors.white,
// //                       shape: BoxShape.circle,
// //                       boxShadow: [
// //                         BoxShadow(
// //                           color: Colors.black.withOpacity(0.12),
// //                           blurRadius: 6,
// //                         ),
// //                       ],
// //                     ),
// //                     child: Center(child: favoriteButton),
// //                   ),
// //                 ),
// //
// //                 // Out-of-stock overlay
// //                 if (isOutOfStock)
// //                   Positioned.fill(
// //                     child: Container(
// //                       color: Colors.black.withOpacity(0.52),
// //                       child: Center(
// //                         child: Container(
// //                           padding: EdgeInsets.symmetric(
// //                             horizontal: 10.w,
// //                             vertical: 5.h,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: Menucolours.r20,
// //                           ),
// //                           child: Text(
// //                             'Out of Stock',
// //                             style: TextStyle(
// //                               fontSize: 10.sp,
// //                               fontWeight: FontWeight.w700,
// //                               color: Menucolours.nonVegRed,
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //               ],
// //             ),
// //           ),
// //
// //           // ── Details section ───────────────────────────────────────
// //           Expanded(
// //             child: Padding(
// //               padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   SizedBox(
// //                     height: 38.h, // 👈 FIXED HEIGHT (adjust if needed)
// //                     child: Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Expanded(
// //                           child: Text(
// //                             name,
// //                             maxLines: 2,
// //                             overflow: TextOverflow.ellipsis,
// //                             style: TextStyle(
// //                               fontSize: 15.sp,
// //                               fontWeight: FontWeight.bold,
// //                               color: AppColors.primary,
// //                               height: 1.3,
// //                             ),
// //                           ),
// //                         ),
// //
// //                         SizedBox(width: 6.w),
// //
// //                         if (description.trim().isNotEmpty == true)
// //                           Padding(
// //                             padding: EdgeInsets.only(top: 2.h),
// //                             child: GestureDetector(
// //                               onTap: () => showDishBottomSheet(
// //                                 context,
// //                                 dish,
// //                                 showCartButton,
// //                               ),
// //                               child: Container(
// //                                 width: 20.r,
// //                                 height: 20.r,
// //                                 alignment: Alignment.center,
// //                                 decoration: BoxDecoration(
// //                                   color: AppColors.primary,
// //                                   shape: BoxShape.circle,
// //                                 ),
// //                                 child: Text(
// //                                   'i',
// //                                   style: TextStyle(
// //                                     fontSize: 13.sp,
// //
// //                                     fontWeight: FontWeight.bold,
// //                                     color: Colors.white,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           ),
// //                       ],
// //                     ),
// //                   ),
// //
// //                   // Name
// //                   SizedBox(height: 4.h),
// //
// //                   // Price row
// //                   Row(
// //                     crossAxisAlignment: CrossAxisAlignment.center,
// //                     children: [
// //                       if (discount > 0) ...[
// //                         Text(
// //                           price,
// //                           style: TextStyle(
// //                             decoration: TextDecoration.lineThrough,
// //                             decorationColor: Colors.black,
// //                             fontSize: 15.sp,
// //                             color: Colors.black,
// //                           ),
// //                         ),
// //                         SizedBox(width: 4.w),
// //                       ],
// //                       Text(effectivePrice, style: Menucolours.price()),
// //                       const Spacer(),
// //                       vegNonVegIndicator(tag),
// //                     ],
// //                   ),
// //
// //                   if (showCartButton) ...[
// //                     const Spacer(),
// //                     Center(child: cartButton),
// //                   ],
// //                 ],
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ── Veg/Non-veg dot indicator ─────────────────────────────────────────────────
// // Widget vegNonVegIndicator(String? tag) {
// //   final isVeg = tag?.toLowerCase() == 'veg';
// //   final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;
// //
// //   return Container(
// //     padding: const EdgeInsets.all(2),
// //     decoration: BoxDecoration(
// //       border: Border.all(color: color, width: 1.5),
// //       borderRadius: const BorderRadius.all(Radius.circular(3)),
// //     ),
// //     child: Container(
// //       width: 7,
// //       height: 7,
// //       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
// //     ),
// //   );
// // }
// //
// // // ── Dish detail bottom sheet ──────────────────────────────────────────────────
// // void showDishBottomSheet(BuildContext context, Dish dish, bool showCartButton) {
// //   showModalBottomSheet(
// //     context: context,
// //     backgroundColor: Colors.transparent,
// //     isScrollControlled: true,
// //     useSafeArea: true,
// //     builder: (ctx) {
// //       return SafeArea(
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: Menucolours.surface,
// //             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
// //           ),
// //           child: SafeArea(
// //             top: false,
// //             child: Padding(
// //               padding: EdgeInsets.only(
// //                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
// //               ),
// //               child: SingleChildScrollView(
// //                 physics: const BouncingScrollPhysics(),
// //                 child: Padding(
// //                   padding: EdgeInsets.all(20.w),
// //                   child: Column(
// //                     mainAxisSize: MainAxisSize.min,
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       // Drag handle
// //                       Center(
// //                         child: Container(
// //                           width: 36,
// //                           height: 4,
// //                           decoration: BoxDecoration(
// //                             color: Menucolours.border,
// //                             borderRadius: Menucolours.r4,
// //                           ),
// //                         ),
// //                       ),
// //
// //                       SizedBox(height: 16.h),
// //
// //                       // 🔥 Only Description
// //                       Text(
// //                         dish.description?.trim().isNotEmpty == true
// //                             ? dish.description!
// //                             : 'No description available.',
// //                         style: Menucolours.body(color: Menucolours.textS),
// //                       ),
// //
// //                       SizedBox(height: 10.h),
// //                     ],
// //                   ),
// //                 ),
// //               ),
// //             ),
// //           ),
// //         ),
// //       );
// //     },
// //   );
// // }
// //
// // // ─── Ticker ──────────────────────────────────────────────────────────────────
// //
// // class OfferTicker extends StatefulWidget {
// //   final List<CouponModel> coupons;
// //   final String Function(String) formatTime;
// //
// //   const OfferTicker({
// //     super.key,
// //     required this.coupons,
// //     required this.formatTime,
// //   });
// //
// //   @override
// //   State<OfferTicker> createState() => _OfferTickerState();
// // }
// //
// // class _OfferTickerState extends State<OfferTicker> {
// //   int _currentIndex = 0;
// //   Timer? _timer;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _timer = Timer.periodic(const Duration(seconds: 3), (_) {
// //       if (!mounted || widget.coupons.isEmpty) return;
// //       setState(() {
// //         _currentIndex = (_currentIndex + 1) % widget.coupons.length;
// //       });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     super.dispose();
// //   }
// //
// //   String _tickerText(CouponModel c) {
// //     final disc = _discountText(c);
// //     if (c.startTime != null && c.endTime != null) {
// //       return '${c.code} • $disc • Happy Hours ${c.startTime}–${c.endTime}';
// //     }
// //     return 'Use ${c.code} • Get $disc';
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     if (widget.coupons.isEmpty) return const SizedBox.shrink();
// //     final coupon = widget.coupons[_currentIndex];
// //
// //     return GestureDetector(
// //       onTap: () => _openSheet(context),
// //       child: Container(
// //         height: 48,
// //         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //         padding: const EdgeInsets.symmetric(horizontal: 14),
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Menucolours.kOrange, Menucolours.kOrangeLight],
// //           ),
// //           borderRadius: BorderRadius.circular(14),
// //         ),
// //         child: Stack(
// //           children: [
// //             // Diagonal stripe texture
// //             Positioned.fill(
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(14),
// //                 child: CustomPaint(painter: _StripePainter()),
// //               ),
// //             ),
// //             Row(
// //               children: [
// //                 const Icon(
// //                   Icons.local_offer_rounded,
// //                   color: Colors.white,
// //                   size: 18,
// //                 ),
// //                 const SizedBox(width: 10),
// //                 // Count badge
// //                 Container(
// //                   padding: const EdgeInsets.symmetric(
// //                     horizontal: 9,
// //                     vertical: 3,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: Colors.white.withOpacity(.22),
// //                     borderRadius: BorderRadius.circular(20),
// //                   ),
// //                   child: Text(
// //                     '${widget.coupons.length} Offers',
// //                     style: const TextStyle(
// //                       color: Colors.white,
// //                       fontWeight: FontWeight.w700,
// //                       fontSize: 10,
// //                       letterSpacing: .4,
// //                     ),
// //                   ),
// //                 ),
// //                 const SizedBox(width: 10),
// //                 // Animated text
// //                 Expanded(
// //                   child: AnimatedSwitcher(
// //                     duration: const Duration(milliseconds: 420),
// //                     transitionBuilder: (child, anim) => SlideTransition(
// //                       position:
// //                           Tween<Offset>(
// //                             begin: const Offset(0, 1),
// //                             end: Offset.zero,
// //                           ).animate(
// //                             CurvedAnimation(
// //                               parent: anim,
// //                               curve: Curves.easeOutCubic,
// //                             ),
// //                           ),
// //                       child: FadeTransition(opacity: anim, child: child),
// //                     ),
// //                     child: Center(
// //                       child: Text(
// //                         _tickerText(coupon),
// //                         key: ValueKey(_currentIndex),
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: const TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.w600,
// //                           fontSize: 13,
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //                 const Icon(
// //                   Icons.keyboard_arrow_up_rounded,
// //                   color: Colors.white,
// //                   size: 20,
// //                 ),
// //               ],
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _openSheet(BuildContext context) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => _OffersSheet(coupons: widget.coupons),
// //     );
// //   }
// // }
// //
// // // ─── Stripe Painter ──────────────────────────────────────────────────────────
// //
// // class _StripePainter extends CustomPainter {
// //   @override
// //   void paint(Canvas canvas, Size size) {
// //     final paint = Paint()
// //       ..color = Colors.white.withOpacity(.04)
// //       ..strokeWidth = 12
// //       ..style = PaintingStyle.stroke;
// //
// //     for (double x = -size.height; x < size.width + size.height; x += 24) {
// //       canvas.drawLine(
// //         Offset(x, 0),
// //         Offset(x + size.height, size.height),
// //         paint,
// //       );
// //     }
// //   }
// //
// //   @override
// //   bool shouldRepaint(_) => false;
// // }
// //
// // // ─── Bottom Sheet ─────────────────────────────────────────────────────────────
// //
// // class _OffersSheet extends StatelessWidget {
// //   final List<CouponModel> coupons;
// //   const _OffersSheet({required this.coupons});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return DraggableScrollableSheet(
// //       expand: false,
// //       initialChildSize: .72,
// //       maxChildSize: .92,
// //       minChildSize: .4,
// //       builder: (_, controller) {
// //         return Container(
// //           decoration: const BoxDecoration(
// //             color: Colors.white,
// //             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
// //           ),
// //           child: Column(
// //             children: [
// //               // Handle
// //               Container(
// //                 width: 40,
// //                 height: 4,
// //                 margin: const EdgeInsets.only(top: 12, bottom: 4),
// //                 decoration: BoxDecoration(
// //                   color: const Color(0xFFE0E0E0),
// //                   borderRadius: BorderRadius.circular(2),
// //                 ),
// //               ),
// //               // Header
// //               Padding(
// //                 padding: const EdgeInsets.symmetric(
// //                   horizontal: 20,
// //                   vertical: 12,
// //                 ),
// //                 child: Row(
// //                   children: [
// //                     Column(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         const Text(
// //                           'Available Offers',
// //                           style: TextStyle(
// //                             fontSize: 17,
// //                             fontWeight: FontWeight.w700,
// //                             color: Menucolours.kText,
// //                           ),
// //                         ),
// //                         Text(
// //                           '${coupons.length} coupons active right now',
// //                           style: const TextStyle(
// //                             fontSize: 12,
// //                             color: Menucolours.kMuted,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //               const Divider(height: 1, color: Color(0xFFF0F0F0)),
// //               // List
// //               Expanded(
// //                 child: ListView.builder(
// //                   controller: controller,
// //                   padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
// //                   itemCount: coupons.length,
// //                   itemBuilder: (_, i) => _CouponCard(coupon: coupons[i]),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         );
// //       },
// //     );
// //   }
// // }
// //
// // // ─── Coupon Card ─────────────────────────────────────────────────────────────
// //
// // class _CouponCard extends StatelessWidget {
// //   final CouponModel coupon;
// //
// //   const _CouponCard({required this.coupon});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final isHappy = coupon.startTime != null && coupon.endTime != null;
// //
// //     final discount = _discountText(coupon);
// //
// //     return Container(
// //       margin: const EdgeInsets.only(bottom: 14),
// //       decoration: BoxDecoration(
// //         color: Colors.white,
// //         borderRadius: BorderRadius.circular(18),
// //         border: Border.all(color: Colors.grey.shade200),
// //       ),
// //       child: Padding(
// //         padding: const EdgeInsets.all(16),
// //         child: Column(
// //           crossAxisAlignment: CrossAxisAlignment.start,
// //           children: [
// //             /// Discount Badge
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                     coupon.code,
// //                     style: const TextStyle(
// //                       fontSize: 16,
// //                       fontWeight: FontWeight.bold,
// //                       letterSpacing: 1,
// //                     ),
// //                   ),
// //                 ),
// //
// //                 _DiscountPill(text: discount, isHappy: isHappy),
// //               ],
// //             ),
// //
// //             const SizedBox(height: 10),
// //
// //             const SizedBox(height: 12),
// //
// //             /// Details
// //             Container(
// //               padding: const EdgeInsets.all(12),
// //               decoration: BoxDecoration(
// //                 color: Colors.grey.shade50,
// //                 borderRadius: BorderRadius.circular(12),
// //               ),
// //               child: Column(
// //                 children: [
// //                   _detailRow(
// //                     Icons.shopping_cart_outlined,
// //                     "Minimum Order",
// //                     "₹${coupon.minimumOrderValue.toInt()}",
// //                   ),
// //
// //                   _detailRow(
// //                     Icons.local_offer_outlined,
// //                     "Offer Type",
// //                     coupon.couponType,
// //                   ),
// //
// //                   if (isHappy)
// //                     _detailRow(
// //                       Icons.access_time,
// //                       "Happy Hours",
// //                       "${coupon.startTime} - ${coupon.endTime}",
// //                     ),
// //                 ],
// //               ),
// //             ),
// //
// //             const SizedBox(height: 12),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _detailRow(IconData icon, String title, String value) {
// //     return Padding(
// //       padding: const EdgeInsets.symmetric(vertical: 5),
// //       child: Row(
// //         children: [
// //           Icon(icon, size: 15, color: Colors.orange),
// //           const SizedBox(width: 8),
// //           Expanded(
// //             child: Text(
// //               title,
// //               style: const TextStyle(fontSize: 13, color: Colors.black54),
// //             ),
// //           ),
// //           Text(
// //             value,
// //             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// // // ─── Helpers ─────────────────────────────────────────────────────────────────
// //
// // String _discountText(CouponModel c) {
// //   return c.discountType.toUpperCase() == 'FIXED_AMOUNT'
// //       ? '₹${c.discountPercentage.toInt()} OFF'
// //       : '${c.discountPercentage.toInt()}% OFF';
// // }
// //
// // class _DiscountPill extends StatelessWidget {
// //   final String text;
// //   final bool isHappy;
// //   const _DiscountPill({required this.text, required this.isHappy});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
// //       decoration: BoxDecoration(
// //         color: isHappy ? Menucolours.kHappyBg : Menucolours.kOrangeBg,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Text(
// //         text,
// //         style: TextStyle(
// //           fontSize: 12,
// //           fontWeight: FontWeight.w700,
// //           color: isHappy ? Menucolours.kHappy : Menucolours.kOrange,
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _MetaTag extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final Color color;
// //   final Color bgColor;
// //
// //   const _MetaTag({
// //     required this.icon,
// //     required this.label,
// //     this.color = Menucolours.kMuted,
// //     this.bgColor = Menucolours.kSurface,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Container(
// //       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
// //       decoration: BoxDecoration(
// //         color: bgColor,
// //         borderRadius: BorderRadius.circular(20),
// //       ),
// //       child: Row(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Icon(icon, size: 12, color: color),
// //           const SizedBox(width: 4),
// //           Text(
// //             label,
// //             style: TextStyle(
// //               fontSize: 11,
// //               color: color,
// //               fontWeight: FontWeight.w500,
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
//
// import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
// import '../../../Services/App_color_service/app_colours.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../../widgets/widgets/food/favorite_button.dart';
// import '../../../Models/food/restaurent_banner_model.dart';
// import '../../../Models/subscrptions/coupon_model.dart';
// import '../../../Models/food/aboutus_model.dart';
// import '../../../Models/food/team_model.dart';
// import '../../skeleton/menu_skeleton.dart';
// import '../../../Models/food/dish.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'cart_footer_button.dart';
// import '../../Mainscreen.dart';
// import '../table/Table.dart';
// import 'cart_button.dart';
// import 'fullscreen.dart';
// import 'Menuhelper.dart';
// import 'Top_banner.dart';
// import 'colours.dart';
// import 'dart:async';
//
// class MenuResponse {
//   final List<Dish> categories;
//   final List<Dish> dishes;
//   final String? errorMessage;
//   final bool hasError;
//
//   MenuResponse({
//     required this.categories,
//     required this.dishes,
//     this.errorMessage,
//     this.hasError = false,
//   });
// }
//
// class MenuScreen extends StatefulWidget {
//   final int vendorId;
//   final String? initialCategoryName;
//   // final Restaurent_Banner? banner;
//
//   const MenuScreen({
//     super.key,
//     required this.vendorId,
//     this.initialCategoryName,
//     // this.banner,
//   });
//
//   @override
//   State<MenuScreen> createState() => _MenuScreenState();
// }
//
// class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
//   final ScrollController _scrollController = ScrollController();
//   Timer? _scrollTimer;
//
//   bool _isCollapsed = false;
//   bool? isVeg;
//   int selectedTabIndex = 0;
//   int? selectedCategoryId;
//   List<Dish> categories = [];
//   List<Dish> allDishes = [];
//   // String orderType = "";
//   String orderType = "DINE_IN";
//   String searchQuery = "";
//   Restaurent_Banner? _bannerItem;
//   AboutUsModel? _aboutus;
//   List<vendorteam> _team = [];
//   Map<int, int> favoriteMap = {};
//   bool _bannerLoaded = false;
//   bool _menuLoaded = false;
//
//   DishFilterType selectedFilter = DishFilterType.none;
//
//   late Future<void> _screenFuture;
//   late AnimationController _fadeController;
//   late Animation<double> _fadeAnim;
//   BannerContentType selectedContent = BannerContentType.none;
//   static const double _expandedHeight = 400.0;
//
//   String get normalizedOrderType => orderType.trim().toUpperCase();
//   bool get showMenuTab =>
//       ["DINE_IN", "TAKEAWAY", "DELIVERY"].contains(normalizedOrderType);
//   bool get showTableTab => normalizedOrderType == "TABLE_DINE_IN";
//
//   List<CouponModel> coupons = [];
//
//   final ScrollController _couponController = ScrollController();
//   Timer? _couponTimer;
//
//   void _startCouponScroll() {
//     _couponTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
//       if (!_couponController.hasClients) return;
//
//       final max = _couponController.position.maxScrollExtent;
//       final current = _couponController.offset + 1;
//
//       if (current >= max) {
//         _couponController.jumpTo(0);
//       } else {
//         _couponController.jumpTo(current);
//       }
//     });
//   }
//
//   List<CouponModel> get vendorCoupons {
//     return coupons.where((c) {
//       return c.vendorId == widget.vendorId &&
//           c.isCurrentlyAvailable &&
//           c.active;
//     }).toList();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fadeController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 400),
//     );
//     _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);
//
//     // Single future — FutureBuilder waits on this, no separate call
//     _screenFuture = _initializeScreen();
//     // _bannerItem = widget.banner;
//
//     _scrollController.addListener(() {
//       final collapsed =
//           _scrollController.offset > (_expandedHeight - kToolbarHeight);
//       if (collapsed != _isCollapsed) {
//         setState(() => _isCollapsed = collapsed);
//       }
//     });
//     _startCouponScroll();
//   }
//
//   List<CouponModel> get visibleCoupons {
//     return vendorCoupons.where((coupon) {
//       return coupon.isCurrentlyAvailable;
//     }).toList();
//   }
//
//   @override
//   void dispose() {
//     _scrollTimer?.cancel();
//     _scrollController.dispose();
//     _fadeController.dispose();
//     _couponTimer?.cancel();
//     _couponController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _initializeScreen() async {
//     await _loadPrefs();
//     await Future.wait([
//       _loadBannerData(),
//       _loadMenu(),
//       _loadaboutus(),
//       _loadteam(),
//       _loadFavorites(),
//       _loadCoupons(),
//     ]);
//     if (mounted) _fadeController.forward();
//   }
//
//   Future<void> _loadCoupons() async {
//     final data = await food_Authservice.fetchCoupons();
//
//     if (!mounted) return;
//
//     setState(() {
//       coupons = data;
//     });
//   }
//
//   Future<void> _loadFavorites() async {
//     try {
//       final favs = await food_Authservice.getFavoritesByUserId();
//
//       if (!mounted) return;
//
//       setState(() {
//         favoriteMap = {
//           for (var f in favs)
//             if (f.dishId != null && f.favId != null) f.dishId!: f.favId!,
//         };
//       });
//     } catch (e) {
//       debugPrint("Fav error: $e");
//     }
//   }
//
//   // Future<void> _loadBannerData() async {
//   //   try {
//   //     final banner = await Authservice().fetchVendorBanner(widget.vendorId);
//   //     if (mounted) {
//   //       setState(() {
//   //         _bannerItem = banner;
//   //       });
//   //     }
//   //   } catch (_) {}
//   // }
//   Future<void> _loadBannerData() async {
//     try {
//       final banner = await Authservice().fetchVendorBanner(widget.vendorId);
//
//       if (!mounted) return;
//
//       setState(() {
//         _bannerItem = banner;
//         _bannerLoaded = true;
//       });
//     } catch (_) {
//       _bannerLoaded = true;
//     }
//   }
//
//   Future<void> _loadaboutus() async {
//     try {
//       final about = await food_Authservice.fetchAboutUsData(widget.vendorId);
//       if (mounted) {
//         setState(() {
//           _aboutus = about;
//         });
//       }
//     } catch (_) {}
//   }
//
//   Future<void> _loadteam() async {
//     try {
//       final team = await food_Authservice.fetchteam(widget.vendorId);
//       if (mounted) {
//         setState(() {
//           _team = team;
//         });
//       }
//     } catch (_) {}
//   }
//
//   Future<void> _loadPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     if (mounted) {
//       setState(() {
//         orderType =
//             prefs.getString('orderType')?.trim().toUpperCase() ?? "DINE_IN";
//       });
//     }
//   }
//
//   Future<void> _onRefresh() async {
//     HapticFeedback.lightImpact();
//     await Future.delayed(const Duration(milliseconds: 500));
//     await _loadMenu();
//   }
//
//   // Future<void> _loadMenu() async {
//   //   final menu = await Authservice.fetchMenu(widget.vendorId);
//   //   if (!mounted) return;
//   //   setState(() {
//   //     allDishes = menu.dishes;
//   //     // categories = menu.categories.where((c) => c.parentId == 0).toList();
//   //     categories = allDishes
//   //         .where((d) => d.categoryId == null && d.parentId == 0)
//   //         .toList();
//   //     _menuLoaded = true;
//   //
//   //     List<Dish> getSubCategories(int categoryId) {
//   //       return allDishes.where((d) => d.parentId == categoryId).toList();
//   //     }
//   //
//   //     // Auto-select the category passed from Restaurants screen
//   //     if (widget.initialCategoryName != null && categories.isNotEmpty) {
//   //       final match = categories.firstWhere(
//   //         (c) =>
//   //             c.dishName?.toLowerCase() ==
//   //             widget.initialCategoryName!.toLowerCase(),
//   //         orElse: () => categories.first,
//   //       );
//   //       selectedCategoryId = match.dishId;
//   //     }
//   //   });
//   // }
//   Future<void> _loadMenu() async {
//     final menu = await Authservice.fetchMenu(widget.vendorId);
//     print("MENU DISHES = ${menu.dishes.length}");
//     print("MENU CATEGORIES = ${menu.categories.length}");
//
//     if (!mounted) return;
//
//     setState(() {
//       allDishes = menu.dishes;
//
//       print("ALL ITEMS = ${allDishes.length}");
//
//       // categories = allDishes.where((d) => d.parentId == 0).toList();
//       categories = allDishes.where((d) {
//         return d.parentId == d.categoryId &&
//             d.parentId != 0 &&
//             d.menuStatus == "Enable";
//       }).toList();
//       print("ALL ITEMS = ${allDishes.length}");
//
//       final subCats = allDishes.where((d) {
//         return d.parentId == d.categoryId && d.parentId != 0;
//       }).toList();
//
//       print("SUBCATEGORIES = ${subCats.length}");
//
//       for (final s in subCats) {
//         print("SUBCAT => ${s.dishName} (${s.dishId})");
//       }
//
//       _menuLoaded = true;
//
//       if (widget.initialCategoryName != null && categories.isNotEmpty) {
//         final match = categories.firstWhere(
//               (c) =>
//           c.dishName?.toLowerCase() ==
//               widget.initialCategoryName!.toLowerCase(),
//           orElse: () => categories.first,
//         );
//
//         selectedCategoryId = match.dishId;
//       }
//     });
//   }
//
//   String formatTime(String time) {
//     final parts = time.split(':');
//
//     final dt = DateTime(2026, 1, 1, int.parse(parts[0]), int.parse(parts[1]));
//
//     return TimeOfDay.fromDateTime(dt).format(context);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: SystemUiOverlayStyle.light,
//       child: Scaffold(
//         // backgroundColor: Colors.white,
//         backgroundColor: Colors.grey.shade50,
//         body: Stack(
//           children: [
//             FutureBuilder<void>(
//               future: _screenFuture,
//               builder: (context, snapshot) {
//                 // if (snapshot.connectionState == ConnectionState.waiting ||
//                 //     categories.isEmpty ||
//                 //     _bannerItem == null) {
//                 //   return const MenuSkeletonScreen();
//                 // }
//                 if (!_bannerLoaded || !_menuLoaded) {
//                   return const MenuSkeletonScreen();
//                 }
//                 if (snapshot.hasError) {
//                   return _buildFullError();
//                 }
//                 return FadeTransition(
//                   opacity: _fadeAnim,
//                   child: _buildMainScreen(),
//                 );
//               },
//             ),
//
//             // Floating cart bars
//             if (showMenuTab)
//               Positioned(
//                 left: 16,
//                 right: 16,
//                 bottom: 16,
//                 child: const food_Cart_count(),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildFullError() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Container(
//             width: 80.r,
//             height: 80.r,
//             decoration: BoxDecoration(
//               color: Menucolours.surfaceAlt,
//               shape: BoxShape.circle,
//             ),
//             child: Icon(
//               Icons.wifi_off_rounded,
//               size: 36.sp,
//               color: Menucolours.textM,
//             ),
//           ),
//           SizedBox(height: 16.h),
//           Text('Failed to load menu', style: Menucolours.h2()),
//           SizedBox(height: 6.h),
//           Text(
//             'Pull down to try again',
//             style: Menucolours.body(color: Menucolours.textS),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMainScreen() {
//     return RefreshIndicator(
//       color: Menucolours.primary,
//       backgroundColor: Menucolours.surface,
//       displacement: 80,
//       strokeWidth: 2.5,
//       onRefresh: _onRefresh,
//       child: CustomScrollView(
//         controller: _scrollController,
//         physics: const BouncingScrollPhysics(),
//         slivers: [
//           // ── Banner AppBar ──────────────────────────────────────────
//           SliverAppBar(
//             pinned: true,
//             expandedHeight: _expandedHeight,
//             collapsedHeight: 64,
//             backgroundColor: Menucolours.surface,
//             elevation: 0,
//             scrolledUnderElevation: 1,
//             // ignore: deprecated_member_use
//             shadowColor: Colors.black.withOpacity(0.08),
//             automaticallyImplyLeading: true,
//             leading: IconButton(
//               icon: const Icon(
//                 Icons.arrow_back_ios_new_rounded,
//                 size: 18,
//                 color: Colors.black,
//               ),
//               onPressed: () => Navigator.maybePop(context),
//             ),
//             title: _isCollapsed
//                 ? _CollapsedFilterBar(
//               isVeg: isVeg ?? false,
//               vendorId: widget.vendorId,
//               onToggle: (v) => setState(() => isVeg = v),
//               onSearch: (v) => setState(() => searchQuery = v),
//             )
//                 : null,
//             titleSpacing: 0,
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.parallax,
//               background: BannerSection(
//                 bannerItem: _bannerItem,
//                 aboutus: _aboutus,
//                 team: _team,
//                 isVeg: isVeg ?? false,
//                 vendorId: widget.vendorId,
//                 onToggle: (v) => setState(() => isVeg = v),
//                 onSearch: (v) => setState(() => searchQuery = v),
//                 onContentSelected: (BannerContentType type) {
//                   setState(() {
//                     selectedContent = selectedContent == type
//                         ? BannerContentType.none
//                         : type;
//                   });
//                 },
//               ),
//             ),
//           ),
//
//           SliverToBoxAdapter(child: _buildBannerContent()),
//
//           // ── Sticky category + table tabs ────────────────────────────
//           SliverPersistentHeader(
//             pinned: true,
//             delegate: _StickyTabsDelegate(
//               height: _headerHeight,
//               child: _StickyTabsContent(
//                 categories: categories,
//                 showTableTab: !showMenuTab,
//                 vendorId: widget.vendorId,
//                 selectedCategoryId: selectedCategoryId,
//                 // onCategorySelected: (id) => {
//                 //     print("Selected Category: $id");
//                 //     setState(() => selectedCategoryId = id),}
//                 onCategorySelected: (id) {
//                   print("Selected Category: $id");
//                   setState(() => selectedCategoryId = id);
//                 },
//               ),
//             ),
//           ),
//
//           SliverToBoxAdapter(
//             child: visibleCoupons.isEmpty
//                 ? const SizedBox()
//                 : OfferTicker(coupons: visibleCoupons, formatTime: formatTime),
//           ),
//
//           SliverToBoxAdapter(
//             child: _DiscountFilterBar(
//               selectedFilter: selectedFilter,
//               onFilterChanged: (filter) {
//                 setState(() {
//                   selectedFilter = filter;
//                 });
//               },
//             ),
//           ),
//           SliverToBoxAdapter(
//             child: Padding(
//               padding: EdgeInsets.only(bottom: 100.h),
//               child: MenuTabContent(
//                 dishes: allDishes,
//                 selectedFilter: selectedFilter,
//                 isVeg: isVeg,
//                 vendorId: widget.vendorId,
//                 selectedVendorId: widget.vendorId,
//                 favoriteMap: favoriteMap,
//                 cartButton: (dish) => CartButton(
//                   dishId: dish.dishId,
//                   balanceQuantity: dish.balanceQuantity,
//                 ),
//                 // favoriteButton: favbutton(),
//                 isOutOfStock: (dish) => dish.stock?.toLowerCase() != 'in stock',
//                 selectedCategoryId: selectedCategoryId,
//                 searchQuery: searchQuery,
//                 showCartButton: !showTableTab,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   double get _headerHeight {
//     double base = 88.h;
//     double table = 52.h;
//     return !showMenuTab ? base + table : base;
//   }
//
//   Widget _buildBannerContent() {
//     if (selectedContent == BannerContentType.none) {
//       return SizedBox();
//     }
//
//     final about = _aboutus;
//     if (about == null) return SizedBox();
//
//     // =======================
//     // ✅ ABOUT SECTION
//     // =======================
//     if (selectedContent == BannerContentType.about) {
//       return Container(
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // 🔹 Top Image
//             if (about.image.isNotEmpty)
//               Image.network(
//                 about.image,
//                 width: double.infinity,
//                 height: 160.h,
//                 fit: BoxFit.cover,
//               ),
//
//             Padding(
//               padding: EdgeInsets.all(16.w),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // 🔹 ABOUT TEXT
//                   Text(
//                     "About Us",
//                     style: TextStyle(
//                       fontSize: 18.sp,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//
//                   SizedBox(height: 8.h),
//
//                   Text(
//                     about.aboutUs,
//                     style: TextStyle(
//                       fontSize: 13.sp,
//                       height: 1.4,
//                       color: Colors.grey.shade800,
//                     ),
//                   ),
//
//                   SizedBox(height: 20.h),
//
//                   if (about.mission.isNotEmpty)
//                     _infoCard(
//                       title: "Our Mission",
//                       description: about.mission,
//                       image: about.missionImage,
//                     ),
//
//                   SizedBox(height: 12.h),
//
//                   // 🔹 Vision Card
//                   if (about.vision.isNotEmpty)
//                     _infoCard(
//                       title: "Our Vision",
//                       description: about.vision,
//                       image: about.visionImage,
//                     ),
//
//                   // 🔹 TEAM ONLY (NO GALLERY HERE)
//                   if (_team.isNotEmpty) ...[
//                     Text(
//                       "Our Team",
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                     SizedBox(height: 10.h),
//
//                     SizedBox(
//                       height: 140.h,
//                       child: ListView.builder(
//                         scrollDirection: Axis.horizontal,
//                         itemCount: _team.length,
//                         itemBuilder: (context, index) {
//                           final member = _team[index];
//
//                           return Container(
//                             width: 120.w,
//                             margin: EdgeInsets.only(right: 12.w),
//                             padding: EdgeInsets.all(10.w),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(14.r),
//                               boxShadow: [
//                                 BoxShadow(
//                                   // ignore: deprecated_member_use
//                                   color: Colors.black.withOpacity(0.08),
//                                   blurRadius: 6,
//                                   offset: Offset(0, 3),
//                                 ),
//                               ],
//                             ),
//                             child: Column(
//                               children: [
//                                 CircleAvatar(
//                                   radius: 26.r,
//                                   backgroundImage: NetworkImage(member.image),
//                                 ),
//                                 SizedBox(height: 8.h),
//
//                                 Text(
//                                   member.name,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   textAlign: TextAlign.center,
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//
//                                 SizedBox(height: 2.h),
//
//                                 Text(
//                                   member.designation,
//                                   maxLines: 1,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontSize: 10.sp,
//                                     color: Colors.grey,
//                                   ),
//                                 ),
//
//                                 Expanded(
//                                   child: Text(
//                                     member.description,
//                                     maxLines: 3,
//                                     overflow: TextOverflow.ellipsis,
//                                     textAlign: TextAlign.center,
//                                     style: TextStyle(
//                                       fontSize: 9.sp,
//                                       color: Colors.grey.shade700,
//                                     ),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           );
//                         },
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     // =======================
//     // ✅ GALLERY SECTION ONLY
//     // =======================
//     if (selectedContent == BannerContentType.gallery) {
//       if (about.allImages.isEmpty) {
//         return SizedBox();
//       }
//
//       return Container(
//         color: Colors.white,
//         padding: EdgeInsets.all(16.w),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               "Gallery",
//               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
//             ),
//
//             SizedBox(height: 12.h),
//
//             SizedBox(
//               height: 140.h,
//               child: ListView.builder(
//                 scrollDirection: Axis.horizontal,
//                 itemCount: about.allImages.length,
//                 itemBuilder: (context, index) {
//                   final img = about.allImages[index];
//
//                   return GestureDetector(
//                     onTap: () {
//                       _openFullScreenGallery(index);
//                     },
//                     child: Container(
//                       width: 140.w,
//                       margin: EdgeInsets.only(right: 12.w),
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12.r),
//                         child: Image.network(img, fit: BoxFit.cover),
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ],
//         ),
//       );
//     }
//
//     return SizedBox();
//   }
//
//   void _openFullScreenGallery(int initialIndex) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => FullScreenGallery(
//           images: _aboutus!.allImages,
//           initialIndex: initialIndex,
//         ),
//       ),
//     );
//   }
//
//   Widget _infoCard({
//     required String title,
//     required String description,
//     required String image,
//   }) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(14.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.05),
//             blurRadius: 6,
//             offset: Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: [
//           // 🔹 Image
//           if (image.isNotEmpty)
//             ClipRRect(
//               borderRadius: BorderRadius.circular(10.r),
//               child: Image.network(
//                 image,
//                 height: 60.h,
//                 width: 60.w,
//                 fit: BoxFit.cover,
//               ),
//             ),
//
//           if (image.isNotEmpty) SizedBox(width: 10.w),
//
//           // 🔹 Text
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   title,
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 SizedBox(height: 4.h),
//                 Text(
//                   description,
//                   maxLines: 3,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     color: Colors.grey.shade700,
//                     height: 1.3,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Collapsed filter bar (shown in AppBar when scrolled) ─────────────────────
// class _CollapsedFilterBar extends StatefulWidget {
//   final bool isVeg;
//   final int vendorId;
//   final Function(bool) onToggle;
//   final Function(String) onSearch;
//
//   const _CollapsedFilterBar({
//     required this.isVeg,
//     required this.vendorId,
//     required this.onToggle,
//     required this.onSearch,
//   });
//
//   @override
//   State<_CollapsedFilterBar> createState() => _CollapsedFilterBarState();
// }
//
// class _CollapsedFilterBarState extends State<_CollapsedFilterBar> {
//   late bool _isVeg;
//
//   @override
//   void initState() {
//     super.initState();
//     _isVeg = widget.isVeg;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         SizedBox(width: 12.w),
//         Expanded(
//           child: SearchField(
//             onSearch: widget.onSearch,
//             fillColor: Menucolours.surfaceAlt,
//           ),
//         ),
//         SizedBox(width: 8.w),
//         VegToggle(
//           isVeg: _isVeg,
//           onToggle: (v) {
//             setState(() => _isVeg = v);
//             widget.onToggle(v);
//           },
//           compact: true,
//         ),
//         SizedBox(width: 12.w),
//       ],
//     );
//   }
// }
//
// // ── Banner section with filter bar ───────────────────────────────────────────
//
// // ── Shared search field ────────────────────────────────────────────────────────
//
// // ── Sticky tabs delegate ───────────────────────────────────────────────────────
// class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   final double height;
//
//   const _StickyTabsDelegate({required this.child, required this.height});
//
//   @override
//   double get minExtent => height;
//   @override
//   double get maxExtent => height;
//
//   @override
//   Widget build(
//       BuildContext context,
//       double shrinkOffset,
//       bool overlapsContent,
//       ) {
//     return SizedBox(height: height, child: child);
//   }
//
//   @override
//   bool shouldRebuild(covariant _StickyTabsDelegate old) =>
//       old.child != child || old.height != height;
// }
//
// // ── Sticky tabs content ───────────────────────────────────────────────────────
// class _StickyTabsContent extends StatelessWidget {
//   final List<Dish> categories;
//   final bool showTableTab;
//   final int vendorId;
//   final int? selectedCategoryId;
//   final Function(int?) onCategorySelected;
//
//   const _StickyTabsContent({
//     required this.categories,
//     required this.showTableTab,
//     required this.vendorId,
//     required this.selectedCategoryId,
//     required this.onCategorySelected,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Menucolours.surface,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (showTableTab) ...[
//             TableTabContent(vendorId: vendorId),
//             Divider(height: 1, thickness: 1, color: Menucolours.borderLight),
//           ],
//           Expanded(
//             child: _CategoryTabStrip(
//               categories: categories,
//               selectedCategoryId: selectedCategoryId,
//               onCategorySelected: onCategorySelected,
//             ),
//           ),
//           Divider(height: 1, thickness: 1, color: Menucolours.borderLight),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Category tab strip ────────────────────────────────────────────────────────
// class _CategoryTabStrip extends StatelessWidget {
//   final List<Dish> categories;
//   final int? selectedCategoryId;
//   final Function(int?) onCategorySelected;
//
//   const _CategoryTabStrip({
//     required this.categories,
//     required this.selectedCategoryId,
//     required this.onCategorySelected,
//   });
//
//   @override
//   // Widget build(BuildContext context) {
//   //   return ListView.builder(
//   //     scrollDirection: Axis.horizontal,
//   //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//   //     itemCount: categories.length + 1,
//   //     itemBuilder: (context, index) {
//   //       if (index == 0) {
//   //         return _CategoryChip(
//   //           title: 'All',
//   //           image: const AssetImage('assets/allitems.jpg'),
//   //           isSelected: selectedCategoryId == null,
//   //           onTap: () => onCategorySelected(null),
//   //         );
//   //       }
//   //       final cat = categories[index - 1];
//   //       return _CategoryChip(
//   //         title: cat.dishName ?? '',
//   //         image: (cat.dishImage != null && cat.dishImage!.isNotEmpty)
//   //             ? NetworkImage(cat.dishImage!)
//   //             : null,
//   //         isSelected: selectedCategoryId == cat.dishId,
//   //         onTap: () => onCategorySelected(cat.dishId),
//   //       );
//   //     },
//   //   );
//   // }
//   @override
//   Widget build(BuildContext context) {
//     final sortedCategories = List<Dish>.from(categories);
//     print("Tabs count = ${categories.length}");
//
//     sortedCategories.sort((a, b) {
//       final aIsCombo = (a.dishName ?? '').toLowerCase() == 'offers';
//       final bIsCombo = (b.dishName ?? '').toLowerCase() == 'offers';
//
//       if (aIsCombo && !bIsCombo) return -1;
//       if (!aIsCombo && bIsCombo) return 1;
//       return 0;
//     });
//
//     return ListView.builder(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//       itemCount: sortedCategories.length + 1,
//       itemBuilder: (context, index) {
//         if (index == 0) {
//           return _CategoryChip(
//             title: 'All',
//             image: const AssetImage('assets/allitems.jpg'),
//             isSelected: selectedCategoryId == null,
//             onTap: () => onCategorySelected(null),
//           );
//         }
//
//         final cat = sortedCategories[index - 1];
//
//         return _CategoryChip(
//           title: cat.dishName ?? '',
//           image: (cat.dishImage != null && cat.dishImage!.isNotEmpty)
//               ? NetworkImage(cat.dishImage!)
//               : null,
//           isSelected: selectedCategoryId == cat.dishId,
//           onTap: () => onCategorySelected(cat.dishId),
//         );
//       },
//     );
//   }
// }
//
// // ── Category chip ─────────────────────────────────────────────────────────────
// class _CategoryChip extends StatelessWidget {
//   final String title;
//   final ImageProvider? image;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _CategoryChip({
//     required this.title,
//     this.image,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.selectionClick();
//         onTap();
//       },
//       child: Container(
//         margin: EdgeInsets.only(right: 10.w),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             AnimatedContainer(
//               duration: const Duration(milliseconds: 220),
//               curve: Curves.easeOutCubic,
//               width: isSelected ? 52.r : 48.r,
//               height: isSelected ? 52.r : 48.r,
//               decoration: BoxDecoration(
//                 shape: BoxShape.circle,
//                 color: isSelected ? AppColors.primary : Menucolours.surfaceAlt,
//                 border: Border.all(
//                   color: isSelected ? AppColors.primary : Menucolours.border,
//                   width: isSelected ? 2.5 : 1.5,
//                 ),
//                 boxShadow: isSelected
//                     ? [
//                   BoxShadow(
//                     color: Menucolours.primary.withOpacity(0.18),
//                     blurRadius: 12,
//                     offset: const Offset(0, 3),
//                   ),
//                 ]
//                     : [],
//               ),
//               child: ClipOval(
//                 child: image != null
//                     ? Image(image: image!, fit: BoxFit.cover)
//                     : Icon(
//                   Icons.restaurant_rounded,
//                   size: 20.sp,
//                   color: isSelected
//                       ? Menucolours.primary
//                       : Menucolours.textM,
//                 ),
//               ),
//             ),
//             SizedBox(height: 4.h),
//             SizedBox(
//               width: 60.w,
//               child: AnimatedDefaultTextStyle(
//                 duration: const Duration(milliseconds: 200),
//                 style: Menucolours.label(
//                   color: isSelected ? AppColors.primary : Menucolours.textS,
//                   size: 10.sp,
//                 ),
//                 child: Text(
//                   title,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   textAlign: TextAlign.center,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // MenuFilterBar (public, used externally)
// // ─────────────────────────────────────────────────────────────────────────────
// class MenuFilterBar extends StatefulWidget {
//   final bool isVeg;
//   final Function(bool) onToggle;
//   final int selectedFilterIndex;
//   final int vendorId;
//   final String? orderType;
//   final Function(String) onSearch;
//   final double searchWidth;
//   final Color searchFillColor;
//
//   const MenuFilterBar({
//     super.key,
//     required this.isVeg,
//     required this.onToggle,
//     required this.vendorId,
//     this.orderType,
//     this.selectedFilterIndex = 0,
//     required this.onSearch,
//     this.searchWidth = 180,
//     this.searchFillColor = const Color(0xFFF0F2F8),
//   });
//
//   @override
//   State<MenuFilterBar> createState() => _MenuFilterBarState();
// }
//
// class _MenuFilterBarState extends State<MenuFilterBar> {
//   late bool _isVeg;
//
//   @override
//   void initState() {
//     super.initState();
//     _isVeg = widget.isVeg;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       color: Menucolours.surface,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
//       child: Row(
//         children: [
//           SizedBox(
//             width: widget.searchWidth,
//             child: SearchField(
//               onSearch: widget.onSearch,
//               fillColor: widget.searchFillColor,
//             ),
//           ),
//           SizedBox(width: 10.w),
//           VegToggle(
//             isVeg: _isVeg,
//             onToggle: (v) {
//               setState(() => _isVeg = v);
//               widget.onToggle(v);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class SearchField extends StatelessWidget {
//   final Function(String) onSearch;
//   final Color fillColor;
//
//   const SearchField({
//     super.key,
//     required this.onSearch,
//     required this.fillColor,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 38.h,
//       decoration: BoxDecoration(
//         color: fillColor,
//         borderRadius: Menucolours.r12,
//         border: Border.all(color: Menucolours.border),
//       ),
//       child: TextField(
//         onChanged: onSearch,
//         style: Menucolours.body(size: 13.sp),
//         decoration: InputDecoration(
//           hintText: 'Search dishes...',
//           hintStyle: Menucolours.body(color: Menucolours.textM, size: 13.sp),
//
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             size: 17.sp,
//             color: Menucolours.textM,
//           ),
//
//           border: InputBorder.none,
//           isDense: true,
//
//           // ✅ FIX: vertical centering
//           contentPadding: EdgeInsets.symmetric(vertical: 10.h),
//
//           // ✅ FIX: reduce prefixIcon extra space
//           prefixIconConstraints: BoxConstraints(
//             minHeight: 20.h,
//             minWidth: 36.w,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Veg toggle ────────────────────────────────────────────────────────────────
// class VegToggle extends StatelessWidget {
//   final bool isVeg;
//   final Function(bool) onToggle;
//   final bool compact;
//
//   const VegToggle({
//     super.key,
//     required this.isVeg,
//     required this.onToggle,
//     this.compact = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;
//
//     return GestureDetector(
//       onTap: () {
//         HapticFeedback.selectionClick();
//         onToggle(!isVeg);
//       },
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 200),
//         padding: EdgeInsets.symmetric(
//           horizontal: compact ? 8.w : 10.w,
//           vertical: 6.h,
//         ),
//         decoration: BoxDecoration(
//           color: isVeg ? Menucolours.primaryDim : Menucolours.surfaceAlt,
//           borderRadius: Menucolours.r8,
//           border: Border.all(
//             color: isVeg
//                 ? Menucolours.primary.withOpacity(0.4)
//                 : Menucolours.border,
//           ),
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 10.r,
//               height: 10.r,
//               decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//             ),
//             SizedBox(width: 5.w),
//             AnimatedDefaultTextStyle(
//               duration: const Duration(milliseconds: 200),
//               style: Menucolours.label(
//                 color: color,
//                 size: compact ? 11.sp : 12.sp,
//               ),
//               child: Text(isVeg ? 'Veg' : 'Non veg'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class _DiscountFilterBar extends StatelessWidget {
//   final DishFilterType selectedFilter;
//   final ValueChanged<DishFilterType> onFilterChanged;
//
//   const _DiscountFilterBar({
//     required this.selectedFilter,
//     required this.onFilterChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final filters = [
//       (DishFilterType.none, 'All', Icons.grid_view_rounded),
//       (DishFilterType.under300, 'offers', Icons.currency_rupee_rounded),
//       (DishFilterType.discount50, 'upto 50% OFF', Icons.sell_outlined),
//       (DishFilterType.discount20, 'upto 20% OFF', Icons.local_offer_outlined),
//       (DishFilterType.discount10, 'upto 10% OFF', Icons.local_offer_outlined),
//       (DishFilterType.under150, 'Under ₹150', Icons.currency_rupee_rounded),
//     ];
//
//     return SizedBox(
//       height: 52,
//       child: ListView.separated(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
//         scrollDirection: Axis.horizontal,
//         itemCount: filters.length,
//         separatorBuilder: (_, __) => const SizedBox(width: 8),
//         itemBuilder: (_, i) {
//           final (filter, label, icon) = filters[i];
//           final active = selectedFilter == filter;
//
//           return GestureDetector(
//             onTap: () => onFilterChanged(filter),
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 150),
//               padding: const EdgeInsets.symmetric(horizontal: 14),
//               decoration: BoxDecoration(
//                 color: active ? const Color(0xFFFAEEDA) : Colors.white,
//                 borderRadius: BorderRadius.circular(34),
//                 border: Border.all(
//                   color: active
//                       ? const Color(0xFFEF9F27)
//                       : const Color(0xFFE0DDD8),
//                   width: 0.5,
//                 ),
//               ),
//               child: Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     icon,
//                     size: 14,
//                     color: active
//                         ? const Color(0xFF854F0B)
//                         : const Color(0xFF9C9890),
//                   ),
//                   const SizedBox(width: 5),
//                   Text(
//                     label,
//                     style: TextStyle(
//                       fontSize: 13,
//                       fontWeight: FontWeight.w500,
//                       color: active
//                           ? const Color(0xFF633806)
//                           : const Color(0xFF6B6760),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // MenuTabContent
// // ─────────────────────────────────────────────────────────────────────────────
// class MenuTabContent extends StatefulWidget {
//   final List<Dish> dishes;
//   final bool? isVeg;
//   final Widget Function(Dish dish) cartButton;
//   final bool Function(Dish) isOutOfStock;
//   final int vendorId;
//   final int selectedVendorId;
//   // final favoriteButton;
//   final int? selectedCategoryId;
//   final String searchQuery;
//   final bool showCartButton;
//   final Map<int, int> favoriteMap;
//   final DishFilterType selectedFilter;
//
//   const MenuTabContent({
//     super.key,
//     required this.dishes,
//     required this.isVeg,
//     required this.cartButton,
//     required this.isOutOfStock,
//     required this.selectedFilter,
//     // required this.favoriteButton,
//     required this.selectedVendorId,
//     required this.vendorId,
//     this.selectedCategoryId,
//     required this.searchQuery,
//     required this.showCartButton,
//     required this.favoriteMap,
//   });
//
//   @override
//   State<MenuTabContent> createState() => _MenuTabContentState();
// }
//
// class _MenuTabContentState extends State<MenuTabContent> {
//   @override
//   Widget build(BuildContext context) {
//     return DishGridTab(
//       dishes: widget.dishes,
//       selectedFilter: widget.selectedFilter,
//       parentId: widget.selectedCategoryId,
//       vendorId: widget.vendorId,
//       filterTag: widget.isVeg == null
//           ? null
//           : widget.isVeg!
//           ? 'veg'
//           : 'non_veg',
//       emptyMessage: widget.isVeg == true
//           ? 'No veg dishes found.'
//           : widget.isVeg == false
//           ? 'No non-veg dishes found.'
//           : 'No dishes available.',
//       searchQuery: widget.searchQuery,
//       showCartButton: widget.showCartButton,
//       favoriteMap: widget.favoriteMap,
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // DishGridTab
// // ─────────────────────────────────────────────────────────────────────────────
// class DishGridTab extends StatefulWidget {
//   final List<Dish> dishes;
//   final int? parentId;
//   final int vendorId;
//   final String? filterTag;
//   final String emptyMessage;
//   final String searchQuery;
//   final bool showCartButton;
//   final Map<int, int> favoriteMap;
//   final DishFilterType selectedFilter;
//
//   const DishGridTab({
//     super.key,
//     required this.dishes,
//     this.parentId,
//     required this.vendorId,
//     required this.filterTag,
//     required this.emptyMessage,
//     required this.searchQuery,
//     required this.showCartButton,
//     required this.favoriteMap,
//     required this.selectedFilter,
//   });
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _DishGridTabState createState() => _DishGridTabState();
// }
//
// class _DishGridTabState extends State<DishGridTab> {
//   String? _errorMessage;
//
//   @override
//   Widget build(BuildContext context) {
//     // final categoryFiltered = widget.parentId == null
//     //     ? widget.dishes
//     //     : widget.dishes.where((d) {
//     //         return d.parentId == widget.parentId && d.menuStatus == "Enable";
//     //       }).toList();
//
//     final categoryFiltered = widget.parentId == null
//         ? widget.dishes.where((d) {
//       return d.parentId != 0 &&
//           d.parentId != d.categoryId &&
//           d.menuStatus == "Enable";
//     }).toList()
//         : widget.dishes.where((d) {
//       return d.parentId == widget.parentId &&
//           d.parentId != d.categoryId &&
//           d.menuStatus == "Enable";
//     }).toList();
//
//     // final filtered = _allDishes.where((dish) {
//     final filtered = categoryFiltered.where((dish) {
//       bool discountMatch = true;
//       print("DishGrid parentId = ${widget.parentId}");
//
//       switch (widget.selectedFilter) {
//         case DishFilterType.discount10:
//           discountMatch = dish.discount <= 10;
//           break;
//         case DishFilterType.discount20:
//           discountMatch = dish.discount <= 20;
//           break;
//
//         case DishFilterType.discount50:
//           discountMatch = dish.discount <= 50;
//           break;
//
//         case DishFilterType.under150:
//           discountMatch = (dish.effectivePrice ?? 0) <= 150;
//           break;
//
//         case DishFilterType.under300:
//           discountMatch = (dish.effectivePrice ?? 0) <= 300;
//           break;
//
//         case DishFilterType.none:
//           discountMatch = true;
//           break;
//       }
//
//       final ok = dish.menuStatus == 'Enable';
//       final veg =
//           widget.filterTag == null ||
//               dish.tag?.toLowerCase() == widget.filterTag!.toLowerCase();
//       final q =
//           widget.searchQuery.isEmpty ||
//               dish.dishName!.toLowerCase().contains(
//                 widget.searchQuery.toLowerCase(),
//               );
//       // return ok && veg && q;
//       return ok && veg && q && discountMatch;
//     }).toList();
//
//     filtered.sort((a, b) {
//       final aOut =
//           a.balanceQuantity <= 0 || a.stock?.toLowerCase() != 'in_stock';
//       final bOut =
//           b.balanceQuantity <= 0 || b.stock?.toLowerCase() != 'in_stock';
//       if (aOut == bOut) return 0;
//       return aOut ? 1 : -1;
//     });
//
//     if (filtered.isEmpty) {
//       return _buildEmpty();
//     }
//
//     final crossAxis = Radiusc.crossAxis(context);
//     final cardExtent = Radiusc.cardExtent(
//       context,
//       showCart: widget.showCartButton,
//     );
//
//     return Padding(
//       padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: crossAxis,
//           crossAxisSpacing: 10.w,
//           mainAxisSpacing: 12.h,
//           mainAxisExtent: cardExtent,
//         ),
//         itemCount: filtered.length,
//         itemBuilder: (_, i) {
//           final dish = filtered[i];
//           final isOut =
//               dish.balanceQuantity <= 0 ||
//                   dish.stock?.toLowerCase() != 'in_stock';
//           final isFav = widget.favoriteMap.containsKey(dish.dishId);
//           return _AnimatedProductCard(
//             index: i,
//             child: ProductCard(
//               dish: dish,
//               imageWidget: _buildDishImage(dish.dishImage),
//               name: dish.dishName ?? '',
//               price: '₹${dish.price}',
//               effectivePrice: '₹${dish.effectivePrice}',
//               description: dish.description ?? '',
//               favoriteButton: FavoriteButton(
//                 dish: dish,
//                 isInitiallyLiked: isFav,
//                 favId: widget.favoriteMap[dish.dishId],
//                 onChanged: (dishId, isLiked, favId) {
//                   setState(() {
//                     if (isLiked) {
//                       if (favId != null) {
//                         widget.favoriteMap[dishId] = favId;
//                       }
//                     } else {
//                       widget.favoriteMap.remove(dishId);
//                     }
//                   });
//                 },
//               ),
//               cartButton: CartButton(
//                 dishId: dish.dishId,
//                 balanceQuantity: dish.balanceQuantity,
//               ),
//               isOutOfStock: isOut,
//               balanceQuantity: dish.balanceQuantity,
//               discount: dish.discount,
//               tag: dish.tag,
//               showCartButton: widget.showCartButton,
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildDishImage(String? url) {
//     if (url != null && url.isNotEmpty) {
//       return Container(
//         color: Colors.white,
//         width: double.infinity,
//         height: double.infinity,
//         // child: Image.network(
//         //   url,
//         //   fit: BoxFit.contain,
//         //   errorBuilder: (_, __, ___) => _imagePlaceholder(),
//         // ),
//         child: Image.network(
//           url,
//           fit: BoxFit.contain,
//           loadingBuilder: (_, child, progress) {
//             if (progress == null) return child;
//
//             return Container(
//               color: Colors.grey.shade100,
//               child: const Center(
//                 child: CircularProgressIndicator(strokeWidth: 2),
//               ),
//             );
//           },
//           errorBuilder: (_, __, ___) => _imagePlaceholder(),
//         ),
//       );
//     }
//     return _imagePlaceholder();
//   }
//
//   Widget _imagePlaceholder() {
//     return Container(
//       color: Menucolours.surfaceAlt,
//       child: Center(
//         child: Icon(
//           Icons.fastfood_rounded,
//           size: 32.sp,
//           // color: Menucolours.textM,
//           color: Colors.white,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildEmpty() {
//     return Padding(
//       padding: EdgeInsets.symmetric(vertical: 60.h),
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 72.r,
//               height: 72.r,
//               decoration: BoxDecoration(
//                 color: Menucolours.surfaceAlt,
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(
//                 Icons.search_off_rounded,
//                 size: 32.sp,
//                 color: Menucolours.textM,
//               ),
//             ),
//             SizedBox(height: 14.h),
//             Text(
//               'Nothing here',
//               style: Menucolours.h2(color: Menucolours.textH),
//             ),
//             SizedBox(height: 6.h),
//             Text(
//               widget.emptyMessage,
//               style: Menucolours.body(color: Menucolours.textS),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildError() {
//     return Padding(
//       padding: EdgeInsets.all(20.w),
//       child: Center(
//         child: Container(
//           constraints: const BoxConstraints(maxWidth: 360),
//           padding: EdgeInsets.all(24.w),
//           decoration: BoxDecoration(
//             color: Menucolours.surface,
//             borderRadius: Menucolours.r20,
//             border: Border.all(color: Menucolours.border),
//             boxShadow: Menucolours.cardShadow,
//           ),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 64.r,
//                 height: 64.r,
//                 decoration: BoxDecoration(
//                   color: Menucolours.nonVegRed.withOpacity(0.08),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   Icons.restaurant_menu_rounded,
//                   color: Menucolours.nonVegRed,
//                   size: 28.sp,
//                 ),
//               ),
//               SizedBox(height: 16.h),
//               Text(
//                 'Action Required',
//                 style: Menucolours.h2(),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 8.h),
//               Text(
//                 _errorMessage!,
//                 style: Menucolours.body(color: Menucolours.textS),
//                 textAlign: TextAlign.center,
//               ),
//               SizedBox(height: 20.h),
//               SizedBox(
//                 width: double.infinity,
//                 height: 48.h,
//                 child: ElevatedButton.icon(
//                   onPressed: () => Navigator.pushAndRemoveUntil(
//                     context,
//                     MaterialPageRoute(builder: (_) => MainScreenfood()),
//                         (r) => false,
//                   ),
//                   icon: Icon(Icons.swap_horiz_rounded, size: 18.sp),
//                   label: Text(
//                     _errorMessage!,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                     ),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Menucolours.primary,
//                     foregroundColor: Colors.white,
//                     elevation: 0,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: Menucolours.r12,
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ── Staggered card animation ──────────────────────────────────────────────────
// class _AnimatedProductCard extends StatefulWidget {
//   final int index;
//   final Widget child;
//
//   const _AnimatedProductCard({required this.index, required this.child});
//
//   @override
//   State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
// }
//
// class _AnimatedProductCardState extends State<_AnimatedProductCard>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _ctrl;
//   late Animation<double> _scale;
//   late Animation<double> _fade;
//
//   @override
//   void initState() {
//     super.initState();
//     _ctrl = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
//     _scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
//     _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);
//     Future.delayed(Duration(milliseconds: 80 * (widget.index % 6)), () {
//       if (mounted) _ctrl.forward();
//     });
//   }
//
//   @override
//   void dispose() {
//     _ctrl.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _fade,
//       child: ScaleTransition(scale: _scale, child: widget.child),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// // ProductCard
// // ─────────────────────────────────────────────────────────────────────────────
// class ProductCard extends StatelessWidget {
//   final Widget imageWidget;
//   final String name;
//   final String price;
//   final String description;
//   final String effectivePrice;
//   final Widget favoriteButton;
//   final Widget cartButton;
//   final bool isOutOfStock;
//   final int balanceQuantity;
//   final num discount;
//   final String? tag;
//   final bool showCartButton;
//   final Dish dish;
//
//   const ProductCard({
//     super.key,
//     required this.imageWidget,
//     required this.name,
//     required this.price,
//     required this.description,
//     required this.effectivePrice,
//     required this.favoriteButton,
//     required this.cartButton,
//     required this.isOutOfStock,
//     required this.balanceQuantity,
//     required this.discount,
//     required this.tag,
//     required this.showCartButton,
//     required this.dish,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final isPhone = Radiusc.isPhone(context);
//     // final imgH = isPhone ? 115.0 : 140.0;
//     final imgH = 100.0;
//     return Container(
//       decoration: BoxDecoration(
//         color: Menucolours.surface,
//         borderRadius: Menucolours.r16,
//         border: Border.all(color: Menucolours.borderLight),
//         boxShadow: Menucolours.cardShadow,
//       ),
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // ── Image section ────────────────────────────────────────
//           SizedBox(
//             height: imgH,
//             child: Stack(
//               fit: StackFit.expand,
//               children: [
//                 imageWidget,
//
//                 // Scrim for readability
//                 Container(
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       stops: const [0.6, 1.0],
//                       colors: [
//                         Colors.transparent,
//                         Colors.black.withOpacity(0.15),
//                       ],
//                     ),
//                   ),
//                 ),
//
//                 // Discount badge
//                 if (discount > 0)
//                   Positioned(
//                     top: 8,
//                     left: 8,
//                     child: Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 7.w,
//                         vertical: 3.h,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Menucolours.accent,
//                         borderRadius: Menucolours.r8,
//                       ),
//                       child: Text(
//                         '${discount.toStringAsFixed(0)}%',
//                         style: TextStyle(
//                           fontSize: 9.sp,
//                           color: Colors.white,
//                           fontWeight: FontWeight.w800,
//                           letterSpacing: 0.2,
//                         ),
//                       ),
//                     ),
//                   ),
//
//                 // Favourite button
//                 Positioned(
//                   top: 8,
//                   right: 8,
//                   child: Container(
//                     width: 30.r,
//                     height: 30.r,
//                     decoration: BoxDecoration(
//                       color: Colors.white,
//                       shape: BoxShape.circle,
//                       boxShadow: [
//                         BoxShadow(
//                           color: Colors.black.withOpacity(0.12),
//                           blurRadius: 6,
//                         ),
//                       ],
//                     ),
//                     child: Center(child: favoriteButton),
//                   ),
//                 ),
//
//                 // Out-of-stock overlay
//                 if (isOutOfStock)
//                   Positioned.fill(
//                     child: Container(
//                       color: Colors.black.withOpacity(0.52),
//                       child: Center(
//                         child: Container(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 10.w,
//                             vertical: 5.h,
//                           ),
//                           decoration: BoxDecoration(
//                             color: Colors.white,
//                             borderRadius: Menucolours.r20,
//                           ),
//                           child: Text(
//                             'Out of Stock',
//                             style: TextStyle(
//                               fontSize: 10.sp,
//                               fontWeight: FontWeight.w700,
//                               color: Menucolours.nonVegRed,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//           ),
//
//           // ── Details section ───────────────────────────────────────
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   SizedBox(
//                     height: 38.h, // 👈 FIXED HEIGHT (adjust if needed)
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             name,
//                             maxLines: 2,
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: 15.sp,
//                               fontWeight: FontWeight.bold,
//                               color: AppColors.primary,
//                               height: 1.3,
//                             ),
//                           ),
//                         ),
//
//                         SizedBox(width: 6.w),
//
//                         if (description.trim().isNotEmpty == true)
//                           Padding(
//                             padding: EdgeInsets.only(top: 2.h),
//                             child: GestureDetector(
//                               onTap: () => showDishBottomSheet(
//                                 context,
//                                 dish,
//                                 showCartButton,
//                               ),
//                               child: Container(
//                                 width: 20.r,
//                                 height: 20.r,
//                                 alignment: Alignment.center,
//                                 decoration: BoxDecoration(
//                                   color: AppColors.primary,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Text(
//                                   'i',
//                                   style: TextStyle(
//                                     fontSize: 13.sp,
//
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.white,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//
//                   // Name
//                   SizedBox(height: 4.h),
//
//                   // Price row
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: [
//                       if (discount > 0) ...[
//                         Text(
//                           price,
//                           style: TextStyle(
//                             decoration: TextDecoration.lineThrough,
//                             decorationColor: Colors.black,
//                             fontSize: 15.sp,
//                             color: Colors.black,
//                           ),
//                         ),
//                         SizedBox(width: 4.w),
//                       ],
//                       Text(effectivePrice, style: Menucolours.price()),
//                       const Spacer(),
//                       vegNonVegIndicator(tag),
//                     ],
//                   ),
//
//                   if (showCartButton) ...[
//                     const Spacer(),
//                     Center(child: cartButton),
//                   ],
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Veg/Non-veg dot indicator ─────────────────────────────────────────────────
// Widget vegNonVegIndicator(String? tag) {
//   final isVeg = tag?.toLowerCase() == 'veg';
//   final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;
//
//   return Container(
//     padding: const EdgeInsets.all(2),
//     decoration: BoxDecoration(
//       border: Border.all(color: color, width: 1.5),
//       borderRadius: const BorderRadius.all(Radius.circular(3)),
//     ),
//     child: Container(
//       width: 7,
//       height: 7,
//       decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//     ),
//   );
// }
//
// // ── Dish detail bottom sheet ──────────────────────────────────────────────────
// void showDishBottomSheet(BuildContext context, Dish dish, bool showCartButton) {
//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     isScrollControlled: true,
//     useSafeArea: true,
//     builder: (ctx) {
//       return SafeArea(
//         child: Container(
//           decoration: BoxDecoration(
//             color: Menucolours.surface,
//             borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: SafeArea(
//             top: false,
//             child: Padding(
//               padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(ctx).viewInsets.bottom,
//               ),
//               child: SingleChildScrollView(
//                 physics: const BouncingScrollPhysics(),
//                 child: Padding(
//                   padding: EdgeInsets.all(20.w),
//                   child: Column(
//                     mainAxisSize: MainAxisSize.min,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Drag handle
//                       Center(
//                         child: Container(
//                           width: 36,
//                           height: 4,
//                           decoration: BoxDecoration(
//                             color: Menucolours.border,
//                             borderRadius: Menucolours.r4,
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(height: 16.h),
//
//                       // 🔥 Only Description
//                       Text(
//                         dish.description?.trim().isNotEmpty == true
//                             ? dish.description!
//                             : 'No description available.',
//                         style: Menucolours.body(color: Menucolours.textS),
//                       ),
//
//                       SizedBox(height: 10.h),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ),
//       );
//     },
//   );
// }
//
// // class OfferTicker extends StatefulWidget {
// //   final List<CouponModel> coupons;
// //   final String Function(String) formatTime;
// //
// //   const OfferTicker({
// //     super.key,
// //     required this.coupons,
// //     required this.formatTime,
// //   });
// //
// //   @override
// //   State<OfferTicker> createState() => _OfferTickerState();
// // }
// //
// // class _OfferTickerState extends State<OfferTicker> {
// //   int currentIndex = 0;
// //   Timer? _timer;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //
// //     _timer = Timer.periodic(const Duration(seconds: 3), (_) {
// //       if (!mounted || widget.coupons.isEmpty) return;
// //
// //       setState(() {
// //         currentIndex = (currentIndex + 1) % widget.coupons.length;
// //       });
// //     });
// //   }
// //
// //   @override
// //   void dispose() {
// //     _timer?.cancel();
// //     super.dispose();
// //   }
// //
// //   String _offerText(CouponModel coupon) {
// //     final discountText = coupon.discountType.toUpperCase() == "PERCENTAGE"
// //         ? "${coupon.discountPercentage.toInt()}% OFF"
// //         : "₹${coupon.discountPercentage.toInt()} OFF";
// //
// //     final isHappyHour = coupon.startTime != null && coupon.endTime != null;
// //
// //     if (isHappyHour) {
// //       return "${coupon.code} • $discountText • Ends ${widget.formatTime(coupon.endTime!)}";
// //     }
// //
// //     return "Use ${coupon.code} • Get$discountText";
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final coupon = widget.coupons[currentIndex];
// //
// //     return GestureDetector(
// //       onTap: () => _showOffersBottomSheet(context),
// //       child: Container(
// //         height: 46,
// //         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
// //         padding: const EdgeInsets.symmetric(horizontal: 12),
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Color(0xFFFF6B00), Color(0xFFFF9A3C)],
// //           ),
// //           borderRadius: BorderRadius.circular(10),
// //         ),
// //         child: Row(
// //           children: [
// //             const Icon(
// //               Icons.local_offer_rounded,
// //               color: Colors.white,
// //               size: 18,
// //             ),
// //
// //             const SizedBox(width: 8),
// //
// //             Container(
// //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
// //               decoration: BoxDecoration(
// //                 color: Colors.white.withOpacity(.18),
// //                 borderRadius: BorderRadius.circular(20),
// //               ),
// //               child: Text(
// //                 "${widget.coupons.length} Offers",
// //                 style: const TextStyle(
// //                   color: Colors.white,
// //                   fontWeight: FontWeight.w700,
// //                   fontSize: 10,
// //                 ),
// //               ),
// //             ),
// //
// //             const SizedBox(width: 10),
// //
// //             Expanded(
// //               child: AnimatedSwitcher(
// //                 duration: const Duration(milliseconds: 500),
// //                 transitionBuilder: (child, animation) {
// //                   return SlideTransition(
// //                     position: Tween<Offset>(
// //                       begin: const Offset(0, 1),
// //                       end: Offset.zero,
// //                     ).animate(animation),
// //                     child: child,
// //                   );
// //                 },
// //                 child: Text(
// //                   _offerText(coupon),
// //                   key: ValueKey(currentIndex),
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontWeight: FontWeight.w600,
// //                   ),
// //                 ),
// //               ),
// //             ),
// //
// //             const Icon(Icons.keyboard_arrow_up_rounded, color: Colors.white),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   void _showOffersBottomSheet(BuildContext context) {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.white,
// //       shape: const RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
// //       ),
// //       builder: (_) {
// //         return DraggableScrollableSheet(
// //           expand: false,
// //           initialChildSize: .65,
// //           maxChildSize: .9,
// //           minChildSize: .4,
// //           builder: (_, controller) {
// //             return ListView.builder(
// //               controller: controller,
// //               padding: const EdgeInsets.all(16),
// //               itemCount: widget.coupons.length,
// //               itemBuilder: (_, index) {
// //                 final coupon = widget.coupons[index];
// //
// //                 final discountText =
// //                     coupon.discountType.toUpperCase() == "PERCENTAGE"
// //                     ? "${coupon.discountPercentage.toInt()}% OFF"
// //                     : "₹${coupon.discountPercentage.toInt()} OFF";
// //
// //                 final isHappyHour =
// //                     coupon.startTime != null && coupon.endTime != null;
// //
// //                 return Container(
// //                   margin: const EdgeInsets.only(bottom: 12),
// //                   padding: const EdgeInsets.all(14),
// //                   decoration: BoxDecoration(
// //                     border: Border.all(color: Colors.orange.shade200),
// //                     borderRadius: BorderRadius.circular(12),
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     children: [
// //                       Row(
// //                         children: [
// //                           Expanded(
// //                             child: Text(
// //                               coupon.code,
// //                               style: const TextStyle(
// //                                 fontSize: 16,
// //                                 fontWeight: FontWeight.bold,
// //                               ),
// //                             ),
// //                           ),
// //                           Text(
// //                             discountText,
// //                             style: const TextStyle(
// //                               color: Colors.orange,
// //                               fontWeight: FontWeight.bold,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //
// //                       const SizedBox(height: 6),
// //
// //                       if (coupon.minimumOrderValue > 0)
// //                         Text(
// //                           "Minimum Order: ₹${coupon.minimumOrderValue.toInt()}",
// //                         ),
// //
// //                       if (isHappyHour)
// //                         Padding(
// //                           padding: const EdgeInsets.only(top: 4),
// //                           child: Text(
// //                             "Happy Hours: ${widget.formatTime(coupon.startTime!)} - ${widget.formatTime(coupon.endTime!)}",
// //                             style: const TextStyle(
// //                               color: Colors.red,
// //                               fontWeight: FontWeight.w600,
// //                             ),
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 );
// //               },
// //             );
// //           },
// //         );
// //       },
// //     );
// //   }
// // }
//
// // ─── Constants ───────────────────────────────────────────────────────────────
//
// // ─── Ticker ──────────────────────────────────────────────────────────────────
//
// class OfferTicker extends StatefulWidget {
//   final List<CouponModel> coupons;
//   final String Function(String) formatTime;
//
//   const OfferTicker({
//     super.key,
//     required this.coupons,
//     required this.formatTime,
//   });
//
//   @override
//   State<OfferTicker> createState() => _OfferTickerState();
// }
//
// class _OfferTickerState extends State<OfferTicker> {
//   int _currentIndex = 0;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _timer = Timer.periodic(const Duration(seconds: 3), (_) {
//       if (!mounted || widget.coupons.isEmpty) return;
//       setState(() {
//         _currentIndex = (_currentIndex + 1) % widget.coupons.length;
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   String _tickerText(CouponModel c) {
//     final disc = _discountText(c);
//     if (c.startTime != null && c.endTime != null) {
//       return '${c.code} • $disc • Happy Hours ${c.startTime}–${c.endTime}';
//     }
//     return 'Use ${c.code} • Get $disc';
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (widget.coupons.isEmpty) return const SizedBox.shrink();
//     final coupon = widget.coupons[_currentIndex];
//
//     return GestureDetector(
//       onTap: () => _openSheet(context),
//       child: Container(
//         height: 48,
//         margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 14),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Menucolours.kOrange, Menucolours.kOrangeLight],
//           ),
//           borderRadius: BorderRadius.circular(14),
//         ),
//         child: Stack(
//           children: [
//             // Diagonal stripe texture
//             Positioned.fill(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(14),
//                 child: CustomPaint(painter: _StripePainter()),
//               ),
//             ),
//             Row(
//               children: [
//                 const Icon(
//                   Icons.local_offer_rounded,
//                   color: Colors.white,
//                   size: 18,
//                 ),
//                 const SizedBox(width: 10),
//                 // Count badge
//                 Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 9,
//                     vertical: 3,
//                   ),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(.22),
//                     borderRadius: BorderRadius.circular(20),
//                   ),
//                   child: Text(
//                     '${widget.coupons.length} Offers',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontWeight: FontWeight.w700,
//                       fontSize: 10,
//                       letterSpacing: .4,
//                     ),
//                   ),
//                 ),
//                 const SizedBox(width: 10),
//                 // Animated text
//                 Expanded(
//                   child: AnimatedSwitcher(
//                     duration: const Duration(milliseconds: 420),
//                     transitionBuilder: (child, anim) => SlideTransition(
//                       position:
//                       Tween<Offset>(
//                         begin: const Offset(0, 1),
//                         end: Offset.zero,
//                       ).animate(
//                         CurvedAnimation(
//                           parent: anim,
//                           curve: Curves.easeOutCubic,
//                         ),
//                       ),
//                       child: FadeTransition(opacity: anim, child: child),
//                     ),
//                     child: Center(
//                       child: Text(
//                         _tickerText(coupon),
//                         key: ValueKey(_currentIndex),
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: const TextStyle(
//                           color: Colors.white,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const Icon(
//                   Icons.keyboard_arrow_up_rounded,
//                   color: Colors.white,
//                   size: 20,
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   void _openSheet(BuildContext context) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => _OffersSheet(coupons: widget.coupons),
//     );
//   }
// }
//
// // ─── Stripe Painter ──────────────────────────────────────────────────────────
//
// class _StripePainter extends CustomPainter {
//   @override
//   void paint(Canvas canvas, Size size) {
//     final paint = Paint()
//       ..color = Colors.white.withOpacity(.04)
//       ..strokeWidth = 12
//       ..style = PaintingStyle.stroke;
//
//     for (double x = -size.height; x < size.width + size.height; x += 24) {
//       canvas.drawLine(
//         Offset(x, 0),
//         Offset(x + size.height, size.height),
//         paint,
//       );
//     }
//   }
//
//   @override
//   bool shouldRepaint(_) => false;
// }
//
// // ─── Bottom Sheet ─────────────────────────────────────────────────────────────
//
// class _OffersSheet extends StatelessWidget {
//   final List<CouponModel> coupons;
//   const _OffersSheet({required this.coupons});
//
//   @override
//   Widget build(BuildContext context) {
//     return DraggableScrollableSheet(
//       expand: false,
//       initialChildSize: .72,
//       maxChildSize: .92,
//       minChildSize: .4,
//       builder: (_, controller) {
//         return Container(
//           decoration: const BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//           ),
//           child: Column(
//             children: [
//               // Handle
//               Container(
//                 width: 40,
//                 height: 4,
//                 margin: const EdgeInsets.only(top: 12, bottom: 4),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFE0E0E0),
//                   borderRadius: BorderRadius.circular(2),
//                 ),
//               ),
//               // Header
//               Padding(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//                 child: Row(
//                   children: [
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Available Offers',
//                           style: TextStyle(
//                             fontSize: 17,
//                             fontWeight: FontWeight.w700,
//                             color: Menucolours.kText,
//                           ),
//                         ),
//                         Text(
//                           '${coupons.length} coupons active right now',
//                           style: const TextStyle(
//                             fontSize: 12,
//                             color: Menucolours.kMuted,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               const Divider(height: 1, color: Color(0xFFF0F0F0)),
//               // List
//               Expanded(
//                 child: ListView.builder(
//                   controller: controller,
//                   padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
//                   itemCount: coupons.length,
//                   itemBuilder: (_, i) => _CouponCard(coupon: coupons[i]),
//                 ),
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
// }
//
// // ─── Coupon Card ─────────────────────────────────────────────────────────────
//
// class _CouponCard extends StatelessWidget {
//   final CouponModel coupon;
//
//   const _CouponCard({required this.coupon});
//
//   @override
//   Widget build(BuildContext context) {
//     final isHappy = coupon.startTime != null && coupon.endTime != null;
//
//     final discount = _discountText(coupon);
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(18),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             /// Discount Badge
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     coupon.code,
//                     style: const TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       letterSpacing: 1,
//                     ),
//                   ),
//                 ),
//
//                 _DiscountPill(text: discount, isHappy: isHappy),
//               ],
//             ),
//
//             const SizedBox(height: 10),
//
//             /// Description
//             // if ((coupon.description ?? "").isNotEmpty)
//             //   Text(
//             //     coupon.description!,
//             //     style: TextStyle(
//             //       fontSize: 13,
//             //       color: Colors.grey.shade700,
//             //     ),
//             //   ),
//             const SizedBox(height: 12),
//
//             /// Details
//             Container(
//               padding: const EdgeInsets.all(12),
//               decoration: BoxDecoration(
//                 color: Colors.grey.shade50,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: Column(
//                 children: [
//                   _detailRow(
//                     Icons.shopping_cart_outlined,
//                     "Minimum Order",
//                     "₹${coupon.minimumOrderValue.toInt()}",
//                   ),
//
//                   // if (coupon.maximumDiscountAmount != null)
//                   //   _detailRow(
//                   //     Icons.currency_rupee,
//                   //     "Maximum Discount",
//                   //     "₹${coupon.maximumDiscountAmount!.toInt()}",
//                   //   ),
//                   _detailRow(
//                     Icons.local_offer_outlined,
//                     "Offer Type",
//                     coupon.couponType,
//                   ),
//
//                   if (isHappy)
//                     _detailRow(
//                       Icons.access_time,
//                       "Happy Hours",
//                       "${coupon.startTime} - ${coupon.endTime}",
//                     ),
//
//                   // if (coupon.validFrom != null)
//                   //   _detailRow(
//                   //     Icons.calendar_today,
//                   //     "Valid From",
//                   //     coupon.validFrom!,
//                   //   ),
//                   //
//                   // if (coupon.validTo != null)
//                   //   _detailRow(
//                   //     Icons.event_available,
//                   //     "Valid Till",
//                   //     coupon.validTo!,
//                   //   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 12),
//
//             /// Terms
//             // if ((coupon.termsAndConditions ?? "").isNotEmpty)
//             //   Container(
//             //     padding: const EdgeInsets.all(10),
//             //     decoration: BoxDecoration(
//             //       color: const Color(0xffFFF8E8),
//             //       borderRadius: BorderRadius.circular(10),
//             //     ),
//             //     child: Row(
//             //       crossAxisAlignment: CrossAxisAlignment.start,
//             //       children: [
//             //         const Icon(
//             //           Icons.info_outline,
//             //           size: 16,
//             //           color: Colors.orange,
//             //         ),
//             //         const SizedBox(width: 8),
//             //         Expanded(
//             //           child: Text(
//             //             coupon.termsAndConditions!,
//             //             style: const TextStyle(
//             //               fontSize: 12,
//             //             ),
//             //           ),
//             //         ),
//             //       ],
//             //     ),
//             //   ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _detailRow(IconData icon, String title, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 5),
//       child: Row(
//         children: [
//           Icon(icon, size: 15, color: Colors.orange),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               title,
//               style: const TextStyle(fontSize: 13, color: Colors.black54),
//             ),
//           ),
//           Text(
//             value,
//             style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
//           ),
//         ],
//       ),
//     );
//   }
// }
// // ─── Helpers ─────────────────────────────────────────────────────────────────
//
// String _discountText(CouponModel c) {
//   return c.discountType.toUpperCase() == 'FIXED_AMOUNT'
//       ? '₹${c.discountPercentage.toInt()} OFF'
//       : '${c.discountPercentage.toInt()}% OFF';
// }
//
// class _DiscountPill extends StatelessWidget {
//   final String text;
//   final bool isHappy;
//   const _DiscountPill({required this.text, required this.isHappy});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
//       decoration: BoxDecoration(
//         color: isHappy ? Menucolours.kHappyBg : Menucolours.kOrangeBg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Text(
//         text,
//         style: TextStyle(
//           fontSize: 12,
//           fontWeight: FontWeight.w700,
//           color: isHappy ? Menucolours.kHappy : Menucolours.kOrange,
//         ),
//       ),
//     );
//   }
// }
//
// class _MetaTag extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final Color color;
//   final Color bgColor;
//
//   const _MetaTag({
//     required this.icon,
//     required this.label,
//     this.color = Menucolours.kMuted,
//     this.bgColor = Menucolours.kSurface,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
//       decoration: BoxDecoration(
//         color: bgColor,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 4),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 11,
//               color: color,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
