// // // import 'dart:async';
// // // import '../../../Services/appconfigurations/app_configurtion_service.dart';
// // // import '../../../widgets/widgets/couponcards.dart';
// // // import '../Menu/menu_screen.dart';
// // // import '../Menu/menuscreen.dart';
// // // import '../distancehelpermethod.dart';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter/services.dart';
// // // import 'package:flutter/foundation.dart';
// // // import '../../screens/notifications.dart';
// // // import '../../screens/saved_address.dart';
// // // import '../../skeleton/Restaurents_screen.dart';
// // // import '../../Catering&Services/Caterings.dart';
// // // import 'package:in_app_update/in_app_update.dart';
// // // import '../../screens/advertisements/Advideo.dart';
// // // import '../../../Models/food/food_categries_model.dart';
// // // import '../../../Models/food/restaurent_banner_model.dart';
// // // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // // import '../../../Services/App_color_service/app_colours.dart';
// // // import '../../../Services/Auth_service/food_authservice.dart';
// // // import '../../screens/advertisements/banneradvertisement.dart';
// // // import '../../../Services/googleservices/Location_servces.dart';
// // // import '../../../Models/promotions_model/promotions_model.dart';
// // // import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// // // import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
// // // import '../../../Services/Auth_service/Subscription_authservice.dart';
// // // import '../../../Services/Auth_service/promotion_services_Authservice.dart';
// // // import 'package:maamaas/screens/Food&beverages/RestaurentsScreen/RestaurentsHelper.dart';
// // //
// // // class Restaurents extends StatefulWidget {
// // //   final ScrollController scrollController;
// // //   const Restaurents({super.key, required this.scrollController});
// // //
// // //   @override
// // //   // ignore: library_private_types_in_public_api
// // //   _RestaurentsState createState() => _RestaurentsState();
// // // }
// // //
// // // class _RestaurentsState extends State<Restaurents> {
// // //   // ── State ──────────────────────────────────────────────────────────────────
// // //   String _currentLocation = 'Fetching location...';
// // //   bool _updateAvailable = false;
// // //   AppUpdateInfo? _updateInfo;
// // //   String? selectedOrderType;
// // //   bool _isBannerCollapsed = false;
// // //   List<FoodCategory> categories = [];
// // //   bool isCategoriesLoading = true;
// // //   int selectedCategoryIndex = 0;
// // //   List<int>? selectedCategoryVendorIds;
// // //   String? selectedCategoryName;
// // //   String searchText = '';
// // //   Timer? _debounce;
// // //   bool _isLoggedIn = false;
// // //   bool _isGuestLocationLoading = false;
// // //   int _activeFilterIndex = -1;
// // //   List<Campaign> homepageAds = [];
// // //   bool _highlightOrderTabs = false;
// // //   bool _showOrderTypeHint = false;
// // //   final ValueNotifier<String?> selectedOrderTypeNotifier = ValueNotifier(null);
// // //
// // //   final GlobalKey _orderTypeKey = GlobalKey();
// // //   bool _hasShownLocationDialog = false;
// // //
// // //   int _refreshKey = 0;
// // //   String? _locationCategory;
// // //
// // //   // ── Banner height ──────────────────────────────────────────────────────────
// // //   double get _bannerHeight {
// // //     final h = MediaQuery.of(context).size.height;
// // //     return (h * 0.70).clamp(250.0, 350.0);
// // //   }
// // //
// // //   // ── Lifecycle ──────────────────────────────────────────────────────────────
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     widget.scrollController.addListener(_onScroll);
// // //     _checkLogin().then((_) {
// // //       if (_isLoggedIn) {
// // //         _loadLocationFromAPI();
// // //       } else {
// // //         _loadGuestLocation();
// // //       }
// // //     });
// // //     if (kReleaseMode) {
// // //       _checkForUpdate();
// // //     }
// // //     _fetchCategories();
// // //     _checkLogin();
// // //     _loadAds();
// // //   }
// // //
// // //   @override
// // //   void dispose() {
// // //     _debounce?.cancel();
// // //     widget.scrollController.removeListener(_onScroll);
// // //     selectedOrderTypeNotifier.dispose();
// // //     super.dispose();
// // //   }
// // //
// // //   // ── Scroll listener ────────────────────────────────────────────────────────
// // //   void _onScroll() {
// // //     final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
// // //     final collapsed = widget.scrollController.offset > collapseThreshold;
// // //     if (collapsed != _isBannerCollapsed && mounted) {
// // //       setState(() => _isBannerCollapsed = collapsed);
// // //     }
// // //   }
// // //
// // //   // ── Auth / Location ────────────────────────────────────────────────────────
// // //   Future<void> _checkLogin() async {
// // //     final v = await subscription_AuthService.isLoggedIn();
// // //     if (mounted) setState(() => _isLoggedIn = v);
// // //   }
// // //
// // //   Future<void> _loadGuestLocation() async {
// // //     setState(() => _isGuestLocationLoading = true);
// // //     try {
// // //       final r = await LocationService.getCurrentLocationWithAddress();
// // //       if (!mounted) return;
// // //       if (r != null) {
// // //         final parts = [
// // //           r.area,
// // //           r.adminArea,
// // //           r.city,
// // //           r.state,
// // //         ].where((e) => e != null && e.isNotEmpty).toList();
// // //         final addr = parts.join(', ');
// // //         setState(() {
// // //           _currentLocation = (r.pincode != null && r.pincode!.isNotEmpty)
// // //               ? '$addr - ${r.pincode}'
// // //               : addr;
// // //         });
// // //       } else {
// // //         setState(() => _currentLocation = 'Enable location');
// // //       }
// // //     } catch (e) {
// // //       //       debugPrint('Guest location error: $e');
// // //       if (mounted) setState(() => _currentLocation = 'Location unavailable');
// // //     } finally {
// // //       if (mounted) setState(() => _isGuestLocationLoading = false);
// // //     }
// // //   }
// // //
// // //   Future<void> _loadLocationFromAPI() async {
// // //     try {
// // //       final loc = await subscription_AuthService.fetchCurrentLocation();
// // //
// // //       if (!mounted) return;
// // //
// // //       // print("📍 RAW LOC: $loc");
// // //       // print("📍 ADDRESS CHECK: ${loc?.address}");
// // //       // print("📍 VALID: ${loc?.address.trim().isNotEmpty}");
// // //
// // //       // ✅ VALID LOCATION CHECK
// // //       final isValidLocation = loc != null && loc.address.trim().isNotEmpty;
// // //
// // //       if (isValidLocation) {
// // //         setState(() {
// // //           _currentLocation = loc.address;
// // //           _locationCategory = loc.category;
// // //         });
// // //
// // //         // ✅ Reset dialog flag (important if user later deletes address)
// // //         _hasShownLocationDialog = false;
// // //       } else {
// // //         _handleInvalidLocation();
// // //       }
// // //     } catch (e) {
// // //       //       debugPrint("❌ Location API Error: $e");
// // //       if (!mounted) return;
// // //
// // //       _handleInvalidLocation();
// // //     }
// // //   }
// // //
// // //   void _handleInvalidLocation() {
// // //     // ❌ Don't immediately show popup
// // //     Future.delayed(const Duration(milliseconds: 500), () {
// // //       if (!mounted) return;
// // //
// // //       if (_currentLocation == 'Fetching location...') {
// // //         if (!_hasShownLocationDialog) {
// // //           _hasShownLocationDialog = true;
// // //
// // //           WidgetsBinding.instance.addPostFrameCallback((_) {
// // //             if (mounted) {
// // //               _showUpdateLocationDialog();
// // //             }
// // //           });
// // //         }
// // //       }
// // //     });
// // //   }
// // //
// // //   void _showUpdateLocationDialog() {
// // //     showDialog(
// // //       context: context,
// // //       barrierDismissible: false,
// // //       builder: (_) => AlertDialog(
// // //         shape: RoundedRectangleBorder(
// // //           borderRadius: BorderRadius.circular(16.r),
// // //         ),
// // //         title: Row(
// // //           children: [
// // //             const Icon(Icons.location_off, color: Colors.red),
// // //             SizedBox(width: 8.w),
// // //             Text('Location Required', style: TextStyle(fontSize: 16.sp)),
// // //           ],
// // //         ),
// // //         content: Text(
// // //           "We couldn't detect your location. Please update to continue.",
// // //           style: TextStyle(fontSize: 13.sp),
// // //         ),
// // //         actions: [
// // //           ElevatedButton(
// // //             onPressed: () {
// // //               Navigator.pop(context);
// // //               _changeLocation();
// // //             },
// // //             style: ElevatedButton.styleFrom(
// // //               backgroundColor: restaurentsnewcolour.primary,
// // //               foregroundColor: Colors.white,
// // //             ),
// // //             child: const Text('Update Location'),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   void _changeLocation() {
// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder: (_) => SavedAddress(
// // //           onAddressSelected: (address) async {
// // //             setState(() {
// // //               // _currentLocation =
// // //               //     '${address.},${address.city}, ${address.state} - ${address.pincode}';
// // //               // _locationCategory = address.category;
// // //               _currentLocation = address.fullAddress;
// // //
// // //               // print("Category: ${address.category}");
// // //             });
// // //             _hasShownLocationDialog = false;
// // //             await _refreshAll();
// // //           },
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ── Data ───────────────────────────────────────────────────────────────────
// // //   Future<void> _fetchCategories() async {
// // //     setState(() => isCategoriesLoading = true);
// // //     try {
// // //       final res = await Authservice.fetchFoodCategories();
// // //       if (!mounted) return;
// // //       setState(() {
// // //         categories = res;
// // //         selectedCategoryIndex = 0;
// // //         selectedCategoryVendorIds = null;
// // //       });
// // //     } catch (e) {
// // //       //       debugPrint('Category error: $e');
// // //       if (mounted) setState(() => categories = []);
// // //     } finally {
// // //       if (mounted) setState(() => isCategoriesLoading = false);
// // //     }
// // //   }
// // //
// // //   Future<void> _loadAds() async {
// // //     try {
// // //       final result = await promotion_Authservice.fetchcampaign();
// // //       final filtered = result
// // //           .where(
// // //             (c) =>
// // //                 c.addDisplayPosition == AddDisplayPosition.HOMEPAGE_BANNER &&
// // //                 c.medium == Medium.APP,
// // //           )
// // //           .toList();
// // //       if (mounted) setState(() => homepageAds = filtered);
// // //     } catch (e) {
// // //       //       debugPrint('Ads error: $e');
// // //     }
// // //   }
// // //
// // //   Future<void> _refreshAll() async {
// // //     //     debugPrint("🔄 _refreshAll() STARTED");
// // //
// // //     try {
// // //       await Future.wait([_fetchCategories(), _loadAds()]);
// // //       //
// // //       //       debugPrint("✅ APIs completed successfully");
// // //     } catch (e) {
// // //       //       debugPrint("❌ Error in _refreshAll(): $e");
// // //     }
// // //
// // //     if (mounted) {
// // //       setState(() {
// // //         _refreshKey++;
// // //       });
// // //       //       debugPrint("🔁 UI refreshed, refreshKey: $_refreshKey");
// // //     } else {
// // //       //       debugPrint("⚠️ Widget not mounted, skipping setState");
// // //     }
// // //     //
// // //     //     debugPrint("🏁 _refreshAll() FINISHED");
// // //   }
// // //
// // //   // ── Update ─────────────────────────────────────────────────────────────────
// // //   Future<void> _checkForUpdate() async {
// // //     try {
// // //       final info = await InAppUpdate.checkForUpdate();
// // //       if (!mounted) return;
// // //       setState(() {
// // //         _updateInfo = info;
// // //         _updateAvailable =
// // //             info.updateAvailability == UpdateAvailability.updateAvailable;
// // //       });
// // //     } catch (e) {
// // //       //       debugPrint('Update check failed: $e');
// // //     }
// // //   }
// // //
// // //   void _startFlexibleUpdate() async {
// // //     if (_updateInfo != null) {
// // //       try {
// // //         await InAppUpdate.performImmediateUpdate();
// // //       } catch (e) {
// // //         //         debugPrint('Update error: $e');
// // //       }
// // //     }
// // //   }
// // //
// // //   // ── Order type ─────────────────────────────────────────────────────────────
// // //
// // //   String? _getApiOrderType() {
// // //     if (selectedOrderType == null) return null;
// // //
// // //     final raw = selectedOrderType!;
// // //     final normalized = raw.toLowerCase().trim();
// // //
// // //     final mapped = RestaurentsHelper.typeMapping[normalized];
// // //     //
// // //     //     debugPrint("📦 API Type: $mapped");
// // //
// // //     return mapped;
// // //   }
// // //
// // //   Future<void> _handleOrderTypeSelection(String type) async {
// // //     final cleanType = type.toLowerCase().trim();
// // //
// // //     /// ✅ 👉 HANDLE CATERING LOCALLY
// // //     if (cleanType == "catering") {
// // //       if (!mounted) return;
// // //
// // //       setState(() {
// // //         selectedOrderType = cleanType;
// // //       });
// // //
// // //       selectedOrderTypeNotifier.value = cleanType;
// // //
// // //       // print("🎯 Catering selected → No API call");
// // //       return; // 🚫 STOP HERE
// // //     }
// // //
// // //     /// ✅ OTHER TYPES → CALL API
// // //     final api = RestaurentsHelper.typeMapping[cleanType];
// // //
// // //     if (api == null) {
// // //       //       debugPrint("❌ Mapping failed for: $cleanType");
// // //       return;
// // //     }
// // //
// // //     // print("🚀 Trying to create cart for: $cleanType");
// // //
// // //     final result = await food_Authservice.createCart(api);
// // //
// // //     if (result["success"] == true) {
// // //       if (!mounted) return;
// // //
// // //       setState(() {
// // //         selectedOrderType = cleanType;
// // //       });
// // //
// // //       selectedOrderTypeNotifier.value = cleanType;
// // //     } else {
// // //       final message = result["message"] ?? "Something went wrong";
// // //
// // //       if (!mounted) return;
// // //       AppAlert.error(context, message);
// // //     }
// // //   }
// // //
// // //   void _focusOrderTypeSelection() {
// // //     final context = _orderTypeKey.currentContext;
// // //
// // //     if (context != null) {
// // //       Scrollable.ensureVisible(
// // //         context,
// // //         duration: const Duration(milliseconds: 500),
// // //         curve: Curves.easeInOut,
// // //         alignment: 0.1, // 👈 keeps it slightly below top
// // //       );
// // //     }
// // //
// // //     setState(() {
// // //       _highlightOrderTabs = true;
// // //       _showOrderTypeHint = true;
// // //     });
// // //
// // //     Future.delayed(const Duration(seconds: 2), () {
// // //       if (mounted) setState(() => _highlightOrderTabs = false);
// // //     });
// // //
// // //     Future.delayed(const Duration(seconds: 3), () {
// // //       if (mounted) setState(() => _showOrderTypeHint = false);
// // //     });
// // //   }
// // //
// // //   // ── Debounce search ────────────────────────────────────────────────────────
// // //   void _onSearchChanged(String value) {
// // //     _debounce?.cancel();
// // //     _debounce = Timer(const Duration(milliseconds: 400), () {
// // //       if (mounted) setState(() => searchText = value);
// // //     });
// // //   }
// // //
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //   // BUILD
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       // backgroundColor: restaurentsnewcolour.bg,
// // //       backgroundColor: Colors.white,
// // //       extendBodyBehindAppBar: false,
// // //       body: RefreshIndicator(
// // //         strokeWidth: 2,
// // //         color: restaurentsnewcolour.primary,
// // //         backgroundColor: restaurentsnewcolour.surface,
// // //         onRefresh: _refreshAll,
// // //         child: Stack(
// // //           children: [
// // //             CustomScrollView(
// // //               controller: widget.scrollController,
// // //               physics: const AlwaysScrollableScrollPhysics(),
// // //               slivers: [
// // //                 SliverAppBar(
// // //                   expandedHeight: _bannerHeight,
// // //                   collapsedHeight: kToolbarHeight,
// // //                   pinned: true,
// // //                   elevation: 0,
// // //                   scrolledUnderElevation: 0,
// // //
// // //                   backgroundColor: _isBannerCollapsed
// // //                       ? restaurentsnewcolour.surface
// // //                       : Colors.transparent,
// // //
// // //                   systemOverlayStyle: _isBannerCollapsed
// // //                       ? SystemUiOverlayStyle.dark
// // //                       : SystemUiOverlayStyle.light,
// // //
// // //                   automaticallyImplyLeading: false,
// // //
// // //                   title: _isBannerCollapsed ? _buildCollapsedBar() : null,
// // //                   flexibleSpace: FlexibleSpaceBar(
// // //                     collapseMode: CollapseMode.pin,
// // //                     background: _buildHeroBanner(),
// // //                   ),
// // //                 ),
// // //
// // //                 // ── 2. Sticky search bar ────────────────────────────────
// // //                 if (selectedOrderType != 'catering')
// // //                   SliverPersistentHeader(
// // //                     pinned: true,
// // //                     delegate: _StickyDelegate(
// // //                       height: 70.h, // ✅ FIXED
// // //                       child: Container(
// // //                         color: restaurentsnewcolour.surface,
// // //                         child: Column(
// // //                           children: [
// // //                             Padding(
// // //                               padding: EdgeInsets.symmetric(
// // //                                 horizontal: 16.w,
// // //                                 vertical: 10.h,
// // //                               ),
// // //                               child: SizedBox(
// // //                                 width: double.infinity,
// // //                                 child: _SearchBar(onChanged: _onSearchChanged),
// // //                               ),
// // //                             ),
// // //                             // Divider(height: 1, color: restaurentsnewcolour.border),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
// // //
// // //                 // ── 3. Coupon offers ────────────────────────────────────
// // //                 SliverToBoxAdapter(child: CouponsOffersSection()),
// // //
// // //                 // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
// // //
// // //                 // ── 4. Divider ──────────────────────────────────────────
// // //                 // SliverToBoxAdapter(child: _Divider()),
// // //
// // //                 // ── 5. Food categories ──────────────────────────────────
// // //                 if (selectedOrderType != 'catering')
// // //                   SliverPersistentHeader(
// // //                     pinned: true,
// // //                     delegate: _StickyDelegate(
// // //                       height: 120.h,
// // //                       // height: 95.h,
// // //                       child: Container(
// // //                         color: restaurentsnewcolour.surface,
// // //                         child: Column(
// // //                           crossAxisAlignment: CrossAxisAlignment.start,
// // //                           children: [
// // //                             Padding(
// // //                               // padding: EdgeInsets.fromLTRB(16.w, 10.h, 0, 6.h),
// // //                               padding: EdgeInsets.fromLTRB(
// // //                                 16.w,
// // //                                 4.h, // reduced from 10.h
// // //                                 0,
// // //                                 4.h, // reduced from 6.h
// // //                               ),
// // //                               child: Text(
// // //                                 "What's on your mind?",
// // //                                 style: TextStyle(
// // //                                   fontSize: 16.sp,
// // //                                   fontWeight: FontWeight.w700,
// // //                                   color: restaurentsnewcolour.text,
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                             Expanded(child: _buildFoodCategories()),
// // //                           ],
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ),
// // //
// // //                 // SliverToBoxAdapter(child: _Divider()),
// // //
// // //                 // ── 6. Order type tabs (sticky) ─────────────────────────
// // //                 SliverPersistentHeader(
// // //                   key: _orderTypeKey,
// // //                   pinned: false,
// // //                   delegate: _StickyDelegate(
// // //                     height: _showOrderTypeHint ? 88.h : 65.h,
// // //
// // //                     // height: _showOrderTypeHint ? 165.h : 115.h,
// // //                     child: Container(
// // //                       color: restaurentsnewcolour.surface,
// // //                       child: Column(
// // //                         mainAxisSize: MainAxisSize.min,
// // //                         children: [
// // //                           Padding(
// // //                             padding: EdgeInsets.symmetric(
// // //                               horizontal: 16.w,
// // //                               // vertical: 10.h,
// // //                               vertical: 10.h,
// // //                             ),
// // //                             child: _buildOrderTypeTabs(),
// // //                           ),
// // //                           if (_showOrderTypeHint)
// // //                             AnimatedOpacity(
// // //                               duration: const Duration(milliseconds: 300),
// // //                               opacity: _showOrderTypeHint ? 1 : 0,
// // //                               child: Padding(
// // //                                 padding: EdgeInsets.only(bottom: 6.h),
// // //                                 child: Text(
// // //                                   '👆 Please select an order type',
// // //                                   style: TextStyle(
// // //                                     fontSize: 16.sp,
// // //                                     color: Colors.red.shade600,
// // //                                     fontWeight: FontWeight.w500,
// // //                                   ),
// // //                                 ),
// // //                               ),
// // //                             ),
// // //                           // Divider(height: 1, color: restaurentsnewcolour.border),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //                 // ── 7. Filter chips ─────────────────────────────────────
// // //                 SliverPersistentHeader(
// // //                   pinned: false,
// // //                   delegate: _StickyDelegate(
// // //                     height: 50.h,
// // //                     child: Container(
// // //                       color: restaurentsnewcolour.surface,
// // //                       // child: _buildFilterChips(),
// // //                       child: FilterChipsBar(),
// // //                     ),
// // //                   ),
// // //                 ),
// // //
// // //                 SliverToBoxAdapter(child: SizedBox(height: 4.h)),
// // //
// // //                 // ── 8. Offer filter strip ───────────────────────────────
// // //                 SliverToBoxAdapter(child: _buildOfferStrip()),
// // //
// // //                 // ── 9. Restaurant list header ───────────────────────────
// // //                 if (selectedOrderType != 'catering')
// // //                   SliverToBoxAdapter(
// // //                     child: Padding(
// // //                       padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 4.h),
// // //                       child: Row(
// // //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //                         children: [
// // //                           Text(
// // //                             'Restaurants Near You',
// // //                             style: TextStyle(
// // //                               fontSize: 18.sp,
// // //                               fontWeight: FontWeight.w700,
// // //                               color: restaurentsnewcolour.text,
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ),
// // //                     ),
// // //                   ),
// // //                 SliverToBoxAdapter(child: SizedBox(height: 1.h)),
// // //
// // //                 // ── 10. Restaurant cards ────────────────────────────────
// // //                 SliverToBoxAdapter(child: _buildRestaurantList()),
// // //
// // //                 SliverToBoxAdapter(child: SizedBox(height: 32.h)),
// // //               ],
// // //             ),
// // //
// // //             // ── Update banner ───────────────────────────────────────────
// // //             if (_updateAvailable)
// // //               Positioned(
// // //                 left: 16.w,
// // //                 right: 16.w,
// // //                 bottom: 16.h,
// // //                 child: SafeArea(child: _buildUpdateBanner()),
// // //               ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildHeroBanner() {
// // //     return SizedBox.expand(
// // //       child: Stack(
// // //         fit: StackFit.expand,
// // //         children: [
// // //           /// 🔹 Background (Ad / Video)
// // //           _isLoggedIn
// // //               ? (homepageAds.isEmpty
// // //                     ? Container(color: const Color(0xFFCCCCCC))
// // //                     : BannerAdvertisement(
// // //                         ads: homepageAds,
// // //                         height: _bannerHeight,
// // //                       ))
// // //               : const VideoPreviewContainer(),
// // //
// // //           /// 🔹 Gradient overlay
// // //           IgnorePointer(
// // //             child: const DecoratedBox(
// // //               decoration: BoxDecoration(
// // //                 gradient: LinearGradient(
// // //                   begin: Alignment.topCenter,
// // //                   end: Alignment.bottomCenter,
// // //                   colors: [
// // //                     Color(0x99000000),
// // //                     Color(0x33000000),
// // //                     Colors.transparent,
// // //                   ],
// // //                 ),
// // //               ),
// // //             ),
// // //           ),
// // //
// // //           /// 🔹 Top Content (SafeArea prevents notch overlap)
// // //           // IgnorePointer(
// // //           //   child:
// // //           SafeArea(
// // //             bottom: false,
// // //             child: Padding(
// // //               padding: const EdgeInsets.symmetric(horizontal: 16),
// // //               child: Column(
// // //                 crossAxisAlignment: CrossAxisAlignment.start,
// // //                 children: [
// // //                   const SizedBox(height: 10),
// // //
// // //                   /// 📍 Location + Notification Row
// // //                   Row(
// // //                     children: [
// // //                       Expanded(
// // //                         child: _buildLocationContent(
// // //                           isDark: false, // white text
// // //                           isExpanded: true, // bigger UI
// // //                         ),
// // //                       ),
// // //
// // //                       /// 🔔 Notification Icon
// // //                       GestureDetector(
// // //                         onTap: () {
// // //                           Navigator.push(
// // //                             context,
// // //                             MaterialPageRoute(
// // //                               builder: (_) => NotificationScreen(),
// // //                             ),
// // //                           );
// // //                         },
// // //                         child: Container(
// // //                           width: 36.w,
// // //                           height: 36.w,
// // //                           decoration: BoxDecoration(
// // //                             // ignore: deprecated_member_use
// // //                             color: Colors.white.withOpacity(0.2),
// // //                             shape: BoxShape.circle,
// // //                           ),
// // //                           child: const Icon(
// // //                             Icons.notifications_none_rounded,
// // //                             color: Colors.white,
// // //                             size: 20,
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ],
// // //               ),
// // //             ),
// // //           ),
// // //           // ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildCollapsedBar() {
// // //     return Row(
// // //       children: [
// // //         /// 📍 Location Section
// // //         Expanded(
// // //           child: _buildLocationContent(
// // //             isDark: true, // dark text
// // //             isExpanded: false, // compact UI
// // //           ),
// // //         ),
// // //
// // //         SizedBox(width: 8.w),
// // //
// // //         /// 🔔 Notification Icon
// // //         GestureDetector(
// // //           onTap: () {
// // //             Navigator.push(
// // //               context,
// // //               MaterialPageRoute(builder: (_) => NotificationScreen()),
// // //             );
// // //           },
// // //           child: Container(
// // //             width: 36.w,
// // //             height: 36.w,
// // //             decoration: BoxDecoration(
// // //               // ignore: deprecated_member_use
// // //               color: restaurentsnewcolour.primary.withOpacity(
// // //                 0.1,
// // //               ), // better visibility
// // //               shape: BoxShape.circle,
// // //             ),
// // //             child: const Icon(
// // //               Icons.notifications_none_rounded,
// // //               color: restaurentsnewcolour.primary,
// // //               size: 20,
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _buildLocationContent({
// // //     required bool isDark,
// // //     required bool isExpanded,
// // //   }) {
// // //     return _isLoggedIn
// // //         ? _buildAppBarContent(isDark: isDark, isExpanded: isExpanded)
// // //         : _buildGuestAppBar(isDark: isDark, isExpanded: isExpanded);
// // //   }
// // //
// // //   IconData _getCategoryIcon() {
// // //     final cat = (_locationCategory ?? '').toLowerCase();
// // //
// // //     switch (cat) {
// // //       case 'home':
// // //         return Icons.home_rounded;
// // //       case 'office':
// // //         return Icons.work_rounded;
// // //       case 'others':
// // //         return Icons.work_rounded;
// // //       default:
// // //         return Icons.location_on_rounded;
// // //     }
// // //   }
// // //
// // //   Widget _buildAppBarContent({required bool isDark, required bool isExpanded}) {
// // //     final color = isDark ? restaurentsnewcolour.text : Colors.white;
// // //
// // //     return GestureDetector(
// // //       onTap: _changeLocation,
// // //       child: Row(
// // //         crossAxisAlignment: CrossAxisAlignment.center,
// // //         children: [
// // //           Icon(_getCategoryIcon(), color: color, size: isExpanded ? 18 : 16),
// // //           SizedBox(width: isExpanded ? 6.w : 4.w),
// // //
// // //           Expanded(
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               mainAxisSize: MainAxisSize.min,
// // //               children: [
// // //                 /// 👇 Show only in expanded (Hero)
// // //                 if (isExpanded)
// // //                   Text(
// // //                     (_locationCategory ?? 'Delivering to').replaceFirstMapped(
// // //                       RegExp(r'^[a-z]'),
// // //                       (m) => m.group(0)!.toUpperCase(),
// // //                     ),
// // //                     style: TextStyle(fontSize: 10.sp, color: Colors.grey),
// // //                   ),
// // //                 Text(
// // //                   _currentLocation,
// // //                   maxLines: 1,
// // //                   overflow: TextOverflow.ellipsis,
// // //                   style: TextStyle(
// // //                     fontSize: isExpanded ? 14.sp : 13.sp,
// // //                     fontWeight: FontWeight.w700,
// // //                     color: color,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //
// // //           Icon(
// // //             Icons.keyboard_arrow_down_rounded,
// // //             color: color,
// // //             size: isExpanded ? 18 : 20,
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _buildGuestAppBar({required bool isDark, required bool isExpanded}) {
// // //     final color = isDark ? restaurentsnewcolour.text : Colors.white;
// // //     final subColor = isDark ? restaurentsnewcolour.textMuted : Colors.white70;
// // //
// // //     return GestureDetector(
// // //       onTap: () {
// // //         // Navigate to login or location picker
// // //       },
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           /// 👇 Show title only in expanded (banner)
// // //           if (isExpanded)
// // //             Text(
// // //               "Current Location",
// // //               style: TextStyle(
// // //                 fontSize: 11.sp,
// // //                 fontWeight: FontWeight.w800,
// // //                 color: subColor,
// // //               ),
// // //             ),
// // //
// // //           if (isExpanded) SizedBox(height: 2.h),
// // //
// // //           /// 🔄 Loading State
// // //           if (_isGuestLocationLoading)
// // //             Row(
// // //               children: [
// // //                 Icon(
// // //                   Icons.location_on_rounded,
// // //                   color: color,
// // //                   size: isExpanded ? 18 : 16,
// // //                 ),
// // //                 SizedBox(
// // //                   width: isExpanded ? 14.w : 12.w,
// // //                   height: isExpanded ? 14.w : 12.w,
// // //                   child: CircularProgressIndicator(
// // //                     strokeWidth: 2,
// // //                     color: color,
// // //                   ),
// // //                 ),
// // //                 SizedBox(width: 6.w),
// // //                 Text(
// // //                   "Fetching location...",
// // //                   style: TextStyle(
// // //                     fontSize: isExpanded ? 12.sp : 11.sp,
// // //                     color: color,
// // //                   ),
// // //                 ),
// // //               ],
// // //             )
// // //           /// 📍 Location State
// // //           else
// // //             Row(
// // //               children: [
// // //                 Expanded(
// // //                   child: Text(
// // //                     _currentLocation.isNotEmpty
// // //                         ? _currentLocation
// // //                         : "Select Location",
// // //                     maxLines: 1,
// // //                     overflow: TextOverflow.ellipsis,
// // //                     style: TextStyle(
// // //                       fontSize: isExpanded ? 13.sp : 12.sp,
// // //                       fontWeight: FontWeight.w600,
// // //                       color: color,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //   // FOOD CATEGORIES
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //
// // //   List<FoodCategory> get displayCategories {
// // //     final list = List<FoodCategory>.from(categories);
// // //
// // //     final comboIndex = list.indexWhere(
// // //       (e) => e.name.toLowerCase().contains('offers'),
// // //     );
// // //
// // //     if (comboIndex > 0) {
// // //       final comboItem = list.removeAt(comboIndex);
// // //       list.insert(0, comboItem);
// // //     }
// // //
// // //     return list;
// // //   }
// // //
// // //   Widget _buildFoodCategories() {
// // //     if (isCategoriesLoading) return const CategorySkeleton();
// // //     if (categories.isEmpty) {
// // //       return Center(
// // //         child: Text(
// // //           'No categories available',
// // //           style: TextStyle(
// // //             fontSize: 12.sp,
// // //             color: restaurentsnewcolour.textMuted,
// // //           ),
// // //         ),
// // //       );
// // //     }
// // //     //
// // //     // final bool hasMore = categories.length > 10;
// // //     // final int visibleCount = hasMore ? 10 : categories.length;
// // //     final bool hasMore = displayCategories.length > 10;
// // //     final int visibleCount = hasMore ? 10 : displayCategories.length;
// // //     const double dia = 48.0;
// // //
// // //     return ListView.separated(
// // //       scrollDirection: Axis.horizontal,
// // //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// // //       itemCount: visibleCount + 1 + (hasMore ? 1 : 0),
// // //       separatorBuilder: (_, __) => SizedBox(width: 14.w),
// // //       itemBuilder: (context, index) {
// // //         final isAll = index == 0;
// // //         final isViewAll = hasMore && index == visibleCount + 1;
// // //         final isSelected = selectedCategoryIndex == index;
// // //
// // //         // final item = isAll ? null : categories[index -
// // //         final item = isAll ? null : displayCategories[index - 1];
// // //         if (isViewAll) {
// // //           return _CategoryItem(
// // //             dia: dia,
// // //             isSelected: false,
// // //             label: 'More',
// // //             onTap: _showAllCategoriesBottomSheet,
// // //             child: const Icon(
// // //               Icons.grid_view_rounded,
// // //               size: 22,
// // //               color: restaurentsnewcolour.textMuted,
// // //             ),
// // //           );
// // //         }
// // //
// // //         return _CategoryItem(
// // //           dia: dia,
// // //           isSelected: isSelected,
// // //           label: isAll ? 'All' : item!.name,
// // //           child: isAll
// // //               ? Icon(
// // //                   Icons.grid_view_rounded,
// // //                   size: 22,
// // //                   color: isSelected
// // //                       ? AppColors.primary
// // //                       : restaurentsnewcolour.textMuted,
// // //                 )
// // //               : (item!.image != null
// // //                     ? Image.network(
// // //                         item.image!,
// // //                         fit: BoxFit.cover,
// // //                         errorBuilder: (_, __, ___) =>
// // //                             const Icon(Icons.fastfood, size: 22),
// // //                       )
// // //                     : const Icon(Icons.fastfood, size: 22)),
// // //           onTap: () => setState(() {
// // //             selectedCategoryIndex = index;
// // //             selectedCategoryVendorIds = isAll ? null : item!.vendorIds;
// // //             selectedCategoryName = isAll ? null : item!.name;
// // //           }),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   void _showAllCategoriesBottomSheet() {
// // //     showModalBottomSheet(
// // //       backgroundColor: restaurentsnewcolour.surface,
// // //       context: context,
// // //       isScrollControlled: true,
// // //       shape: RoundedRectangleBorder(
// // //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// // //       ),
// // //       builder: (ctx) {
// // //         // final remaining = categories.skip(10).toList();
// // //         final remaining = displayCategories.skip(10).toList();
// // //         final sheetH = MediaQuery.of(ctx).size.height * 0.6;
// // //         return SafeArea(
// // //           child: Container(
// // //             height: sheetH,
// // //             padding: EdgeInsets.all(16.w),
// // //             child: Column(
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Row(
// // //                   children: [
// // //                     Text(
// // //                       'All Categories',
// // //                       style: TextStyle(
// // //                         fontSize: 16.sp,
// // //                         fontWeight: FontWeight.bold,
// // //                       ),
// // //                     ),
// // //                     const Spacer(),
// // //                     InkWell(
// // //                       onTap: () => Navigator.pop(ctx),
// // //                       borderRadius: BorderRadius.circular(20.r),
// // //                       child: Container(
// // //                         padding: EdgeInsets.all(6.w),
// // //                         decoration: BoxDecoration(
// // //                           shape: BoxShape.circle,
// // //                           // color: restaurentsnewcolour.bg,
// // //                           color: Colors.white,
// // //                         ),
// // //                         child: Icon(
// // //                           Icons.close,
// // //                           size: 20.sp,
// // //                           color: restaurentsnewcolour.text,
// // //                         ),
// // //                       ),
// // //                     ),
// // //                   ],
// // //                 ),
// // //                 SizedBox(height: 16.h),
// // //                 Expanded(
// // //                   child: GridView.builder(
// // //                     itemCount: remaining.length,
// // //                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// // //                       crossAxisCount: 4,
// // //                       crossAxisSpacing: 12.w,
// // //                       mainAxisSpacing: 12.h,
// // //                       childAspectRatio: 0.75,
// // //                     ),
// // //                     itemBuilder: (_, i) {
// // //                       final item = remaining[i];
// // //                       return InkWell(
// // //                         onTap: () {
// // //                           Navigator.pop(ctx);
// // //                           setState(() {
// // //                             // selectedCategoryIndex =
// // //                             //     categories.indexOf(item) + 1;
// // //                             selectedCategoryIndex =
// // //                                 displayCategories.indexOf(item) + 1;
// // //                             selectedCategoryVendorIds = item.vendorIds;
// // //                             selectedCategoryName = item.name;
// // //                           });
// // //                         },
// // //                         child: Column(
// // //                           children: [
// // //                             Container(
// // //                               width: 56.h,
// // //                               height: 56.h,
// // //                               decoration: BoxDecoration(
// // //                                 shape: BoxShape.circle,
// // //                                 color: restaurentsnewcolour.bg,
// // //                               ),
// // //                               child: ClipOval(
// // //                                 child: item.image != null
// // //                                     ? Image.network(
// // //                                         item.image!,
// // //                                         fit: BoxFit.cover,
// // //                                         errorBuilder: (_, __, ___) =>
// // //                                             const Icon(Icons.fastfood),
// // //                                       )
// // //                                     : const Icon(Icons.fastfood),
// // //                               ),
// // //                             ),
// // //                             SizedBox(height: 6.h),
// // //                             Text(
// // //                               item.name,
// // //                               textAlign: TextAlign.center,
// // //                               maxLines: 2,
// // //                               overflow: TextOverflow.ellipsis,
// // //                               style: TextStyle(
// // //                                 fontSize: 10.sp,
// // //                                 fontWeight: FontWeight.w600,
// // //                               ),
// // //                             ),
// // //                           ],
// // //                         ),
// // //                       );
// // //                     },
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //   // ORDER TYPE TABS
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //
// // //   Widget _buildOrderTypeTabs() {
// // //     return ValueListenableBuilder<String?>(
// // //       valueListenable: selectedOrderTypeNotifier,
// // //       builder: (_, selected, __) {
// // //         final visibleTabs = RestaurentsHelper.orderTabs.where((tab) {
// // //           final configKey = tab['configKey'] as String;
// // //           return AppConfigService.instance.isEnabled(configKey);
// // //         }).toList();
// // //
// // //         return SingleChildScrollView(
// // //           scrollDirection: Axis.horizontal,
// // //           child: Row(
// // //             children: visibleTabs.map((tab) {
// // //               final type = tab['type'] as String;
// // //               final isSelected = selected == type;
// // //
// // //               return GestureDetector(
// // //                 onTap: () => _handleOrderTypeSelection(type),
// // //                 child: AnimatedContainer(
// // //                   duration: const Duration(milliseconds: 220),
// // //                   margin: EdgeInsets.only(right: 8.w),
// // //                   padding: EdgeInsets.symmetric(
// // //                     horizontal: 14.w,
// // //                     vertical: 10.h,
// // //                   ),
// // //                   decoration: BoxDecoration(
// // //                     color: isSelected ? Colors.green : AppColors.primary,
// // //                     borderRadius: BorderRadius.circular(10.r),
// // //                   ),
// // //                   child: Row(
// // //                     mainAxisSize: MainAxisSize.min,
// // //                     children: [
// // //                       Icon(tab['icon'] as IconData, color: Colors.white),
// // //                       SizedBox(width: 6.w),
// // //                       Text(
// // //                         tab['label'] as String,
// // //                         style: TextStyle(
// // //                           color: Colors.white,
// // //                           fontWeight: FontWeight.bold,
// // //                         ),
// // //                       ),
// // //                     ],
// // //                   ),
// // //                 ),
// // //               );
// // //             }).toList(),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   // Widget _buildOrderTypeTabs() {
// // //   //   return ValueListenableBuilder<String?>(
// // //   //     valueListenable: selectedOrderTypeNotifier,
// // //   //     builder: (_, selected, __) {
// // //   //       final itemWidth = (MediaQuery.of(context).size.width - 48.w) / 3;
// // //   //
// // //   //       return Wrap(
// // //   //         alignment: WrapAlignment.center, // 👈 add this
// // //   //         spacing: 8.w,
// // //   //         runSpacing: 10.h,
// // //   //         children: RestaurentsHelper.orderTabs.map((tab) {
// // //   //           final type = tab['type'] as String;
// // //   //           final isSelected = selected == type;
// // //   //
// // //   //           return GestureDetector(
// // //   //             onTap: () => _handleOrderTypeSelection(type),
// // //   //             child: AnimatedContainer(
// // //   //               duration: const Duration(milliseconds: 220),
// // //   //               curve: Curves.easeInOut,
// // //   //               width: itemWidth,
// // //   //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
// // //   //               decoration: BoxDecoration(
// // //   //                 color: isSelected ? Colors.green : AppColors.primary,
// // //   //                 borderRadius: BorderRadius.circular(12.r),
// // //   //                 boxShadow: isSelected
// // //   //                     ? [
// // //   //                         BoxShadow(
// // //   //                           color: restaurentsnewcolour.green.withOpacity(0.25),
// // //   //                           blurRadius: 10,
// // //   //                           offset: const Offset(0, 4),
// // //   //                         ),
// // //   //                       ]
// // //   //                     : [],
// // //   //               ),
// // //   //               child: Row(
// // //   //                 mainAxisAlignment: MainAxisAlignment.center,
// // //   //                 children: [
// // //   //                   Icon(
// // //   //                     tab['icon'] as IconData,
// // //   //                     size: 18.sp,
// // //   //                     color: Colors.white,
// // //   //                   ),
// // //   //
// // //   //                   SizedBox(width: 6.w),
// // //   //
// // //   //                   Flexible(
// // //   //                     child: Text(
// // //   //                       tab['label'] as String,
// // //   //                       overflow: TextOverflow.ellipsis,
// // //   //                       textAlign: TextAlign.center,
// // //   //                       style: TextStyle(
// // //   //                         fontSize: 12.sp,
// // //   //                         fontWeight: FontWeight.bold,
// // //   //                         color: Colors.white,
// // //   //                       ),
// // //   //                     ),
// // //   //                   ),
// // //   //                 ],
// // //   //               ),
// // //   //             ),
// // //   //           );
// // //   //         }).toList(),
// // //   //       );
// // //   //     },
// // //   //   );
// // //   // }
// // //
// // //   // ═══════════════════════════════════_handleOrderTypeSelection═══════════════════════════════════════
// // //   // FILTER CHIPS
// // //   // ══════════════════════════════════════════════════════════════════════════
// // //
// // //   // Widget _buildFilterChips() {
// // //   //   return ListView.separated(
// // //   //     scrollDirection: Axis.horizontal,
// // //   //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// // //   //     itemCount: RestaurentsHelper.filters.length,
// // //   //     separatorBuilder: (_, __) => SizedBox(width: 8.w),
// // //   //     itemBuilder: (_, i) {
// // //   //       final f = RestaurentsHelper.filters[i];
// // //   //       final isSelected = _activeFilterIndex == i;
// // //   //       return GestureDetector(
// // //   //         onTap: () {
// // //   //           setState(() => _activeFilterIndex = isSelected ? -1 : i);
// // //   //           if (f['label'] == 'Filters') _openFilterBottomSheet();
// // //   //         },
// // //   //         child: AnimatedContainer(
// // //   //           duration: const Duration(milliseconds: 180),
// // //   //           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// // //   //           decoration: BoxDecoration(
// // //   //             color: isSelected
// // //   //                 ? restaurentsnewcolour.text
// // //   //                 : restaurentsnewcolour.surface,
// // //   //             borderRadius: BorderRadius.circular(8.r),
// // //   //             border: Border.all(
// // //   //               color: isSelected
// // //   //                   ? restaurentsnewcolour.text
// // //   //                   : restaurentsnewcolour.border,
// // //   //               width: 1.5,
// // //   //             ),
// // //   //           ),
// // //   //           child: Row(
// // //   //             mainAxisSize: MainAxisSize.min,
// // //   //             children: [
// // //   //               Icon(
// // //   //                 f['icon'] as IconData,
// // //   //                 size: 14.sp,
// // //   //                 color: isSelected
// // //   //                     ? Colors.white
// // //   //                     : restaurentsnewcolour.textMuted,
// // //   //               ),
// // //   //               SizedBox(width: 5.w),
// // //   //               Text(
// // //   //                 f['label'] as String,
// // //   //                 style: TextStyle(
// // //   //                   fontSize: 12.sp,
// // //   //                   fontWeight: FontWeight.w600,
// // //   //                   color: isSelected
// // //   //                       ? Colors.white
// // //   //                       : restaurentsnewcolour.textMuted,
// // //   //                 ),
// // //   //               ),
// // //   //             ],
// // //   //           ),
// // //   //         ),
// // //   //       );
// // //   //     },
// // //   //   );
// // //   // }
// // //
// // //   // ── Offer strip ───────────────────────────────────────────────────────────
// // //   Widget _buildOfferStrip() {
// // //     return SizedBox(
// // //       height: 68.h,
// // //       child: ListView.separated(
// // //         scrollDirection: Axis.horizontal,
// // //         padding: EdgeInsets.symmetric(horizontal: 16.w),
// // //         itemCount: RestaurentsHelper.offers.length,
// // //         separatorBuilder: (_, __) => SizedBox(width: 10.w),
// // //         itemBuilder: (_, i) {
// // //           final o = RestaurentsHelper.offers[i];
// // //           return Container(
// // //             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
// // //             decoration: BoxDecoration(
// // //               gradient: LinearGradient(
// // //                 colors: [Color(o['c1'] as int), Color(o['c2'] as int)],
// // //                 begin: Alignment.topLeft,
// // //                 end: Alignment.bottomRight,
// // //               ),
// // //               borderRadius: BorderRadius.circular(12.r),
// // //             ),
// // //             child: Column(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               crossAxisAlignment: CrossAxisAlignment.start,
// // //               children: [
// // //                 Text(
// // //                   o['title'] as String,
// // //                   style: TextStyle(
// // //                     fontSize: 13.sp,
// // //                     fontWeight: FontWeight.w800,
// // //                     color: Colors.white,
// // //                   ),
// // //                 ),
// // //                 Text(
// // //                   o['sub'] as String,
// // //                   style: TextStyle(
// // //                     fontSize: 10.sp,
// // //                     color: Colors.white70,
// // //                     fontWeight: FontWeight.w500,
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ── Restaurant list ───────────────────────────────────────────────────────
// // //   Widget _buildRestaurantList() {
// // //     return AnimatedSwitcher(
// // //       duration: const Duration(milliseconds: 250),
// // //       child: selectedOrderType == 'catering'
// // //           ? CateringsPage(key: const ValueKey('catering'))
// // //           : NearbyRestaurentBannersWidget(
// // //               key: ValueKey(
// // //                 '${_getApiOrderType()}-${selectedCategoryVendorIds?.join(',')}-$searchText-$_refreshKey',
// // //               ),
// // //               orderType: _getApiOrderType(),
// // //               categoryVendorIds: selectedCategoryVendorIds,
// // //               searchQuery: searchText,
// // //               onOrderTypeRequired: _focusOrderTypeSelection,
// // //               selectedCategoryName: selectedCategoryName,
// // //             ),
// // //     );
// // //   }
// // //
// // //   // ── Update banner ─────────────────────────────────────────────────────────
// // //   Widget _buildUpdateBanner() {
// // //     return Container(
// // //       decoration: BoxDecoration(
// // //         color: restaurentsnewcolour.surface,
// // //         borderRadius: BorderRadius.circular(16.r),
// // //         boxShadow: [
// // //           BoxShadow(
// // //             color: Colors.black.withOpacity(0.1),
// // //             blurRadius: 20.r,
// // //             offset: const Offset(0, 4),
// // //           ),
// // //         ],
// // //         border: Border.all(color: restaurentsnewcolour.border),
// // //       ),
// // //       child: Column(
// // //         mainAxisSize: MainAxisSize.min,
// // //         children: [
// // //           Padding(
// // //             padding: EdgeInsets.all(14.w),
// // //             child: Row(
// // //               children: [
// // //                 Container(
// // //                   width: 44.r,
// // //                   height: 44.r,
// // //                   decoration: BoxDecoration(
// // //                     color: Colors.red.withOpacity(0.1),
// // //                     borderRadius: BorderRadius.circular(12.r),
// // //                   ),
// // //                   child: const Icon(
// // //                     Icons.system_update_rounded,
// // //                     color: Colors.red,
// // //                     size: 24,
// // //                   ),
// // //                 ),
// // //                 SizedBox(width: 12.w),
// // //                 Expanded(
// // //                   child: Text(
// // //                     'New Update Available',
// // //                     style: TextStyle(
// // //                       fontSize: 15.sp,
// // //                       fontWeight: FontWeight.w700,
// // //                     ),
// // //                   ),
// // //                 ),
// // //               ],
// // //             ),
// // //           ),
// // //           Divider(height: 1, color: restaurentsnewcolour.border),
// // //           TextButton(
// // //             onPressed: _startFlexibleUpdate,
// // //             style: TextButton.styleFrom(
// // //               minimumSize: Size.fromHeight(48.h),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.only(
// // //                   bottomLeft: Radius.circular(16.r),
// // //                   bottomRight: Radius.circular(16.r),
// // //                 ),
// // //               ),
// // //             ),
// // //             child: Row(
// // //               mainAxisAlignment: MainAxisAlignment.center,
// // //               children: [
// // //                 Text(
// // //                   'UPDATE NOW',
// // //                   style: TextStyle(
// // //                     fontSize: 14.sp,
// // //                     fontWeight: FontWeight.w700,
// // //                     color: Colors.red,
// // //                   ),
// // //                 ),
// // //                 SizedBox(width: 8.w),
// // //                 const Icon(Icons.download_rounded, color: Colors.red, size: 18),
// // //               ],
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // //
// // //   // ── Filter bottom sheet ───────────────────────────────────────────────────
// // //   // void _openFilterBottomSheet() {
// // //   //   showModalBottomSheet(
// // //   //     context: context,
// // //   //     isScrollControlled: true,
// // //   //     backgroundColor: Colors.transparent,
// // //   //     builder: (_) => FractionallySizedBox(
// // //   //       heightFactor: 0.92,
// // //   //       child: Container(
// // //   //         decoration: BoxDecoration(
// // //   //           color: restaurentsnewcolour.surface,
// // //   //           borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// // //   //         ),
// // //   //         child: const FilterBottomSheet(),
// // //   //       ),
// // //   //     ),
// // //   //   );
// // //   // }
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // CATEGORY ITEM  (small, reusable)
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // class _CategoryItem extends StatelessWidget {
// // //   final double dia;
// // //   final bool isSelected;
// // //   final String label;
// // //   final Widget child;
// // //   final VoidCallback onTap;
// // //
// // //   const _CategoryItem({
// // //     required this.dia,
// // //     required this.isSelected,
// // //     required this.label,
// // //     required this.child,
// // //     required this.onTap,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: Column(
// // //         mainAxisSize: MainAxisSize.min,
// // //         mainAxisAlignment: MainAxisAlignment.center,
// // //         children: [
// // //           AnimatedContainer(
// // //             duration: const Duration(milliseconds: 220),
// // //             width: dia,
// // //             height: dia,
// // //             decoration: BoxDecoration(
// // //               shape: BoxShape.circle,
// // //               color: isSelected
// // //                   ? restaurentsnewcolour.primaryLight
// // //                   : restaurentsnewcolour.bg,
// // //               border: isSelected
// // //                   ? Border.all(color: AppColors.primary, width: 2)
// // //                   : null,
// // //             ),
// // //             child: ClipOval(child: child),
// // //           ),
// // //           SizedBox(height: 4.h),
// // //           SizedBox(
// // //             width: dia + 8,
// // //             child: Text(
// // //               label,
// // //               maxLines: 1,
// // //               overflow: TextOverflow.ellipsis,
// // //               textAlign: TextAlign.center,
// // //               style: TextStyle(
// // //                 fontSize: 10.sp,
// // //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
// // //                 color: isSelected
// // //                     ? AppColors.primary
// // //                     : restaurentsnewcolour.textMuted,
// // //               ),
// // //             ),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // SEARCH BAR  (white, used inside the sticky header)
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // class _SearchBar extends StatelessWidget {
// // //   final ValueChanged<String> onChanged;
// // //
// // //   const _SearchBar({required this.onChanged});
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return SizedBox(
// // //       height: 44.h,
// // //       width: double.infinity,
// // //       child: TextField(
// // //         onChanged: onChanged,
// // //         textInputAction: TextInputAction.search,
// // //         style: TextStyle(
// // //           fontSize: 14.sp,
// // //           color: restaurentsnewcolour.text,
// // //           fontWeight: FontWeight.w500,
// // //         ),
// // //         cursorColor: restaurentsnewcolour.primary,
// // //
// // //         decoration: InputDecoration(
// // //           hintText: 'Search restaurants, cuisines...',
// // //
// // //           // ✅ Makes it look like a container
// // //           filled: true,
// // //           fillColor: restaurentsnewcolour.bg,
// // //
// // //           // ✅ Rounded border like container
// // //           border: OutlineInputBorder(
// // //             borderRadius: BorderRadius.circular(12.r),
// // //             borderSide: BorderSide(
// // //               color: restaurentsnewcolour.border,
// // //               width: 1.5,
// // //             ),
// // //           ),
// // //
// // //           enabledBorder: OutlineInputBorder(
// // //             borderRadius: BorderRadius.circular(12.r),
// // //             borderSide: BorderSide(
// // //               color: restaurentsnewcolour.border,
// // //               width: 1.5,
// // //             ),
// // //           ),
// // //
// // //           focusedBorder: OutlineInputBorder(
// // //             borderRadius: BorderRadius.circular(12.r),
// // //             borderSide: BorderSide(
// // //               color: restaurentsnewcolour.primary,
// // //               width: 1.5,
// // //             ),
// // //           ),
// // //
// // //           // ✅ Icon inside field
// // //           prefixIcon: Icon(
// // //             Icons.search_rounded,
// // //             color: restaurentsnewcolour.textLight,
// // //             size: 20.sp,
// // //           ),
// // //
// // //           // spacing fix
// // //           contentPadding: EdgeInsets.symmetric(vertical: 0),
// // //
// // //           hintStyle: TextStyle(
// // //             color: restaurentsnewcolour.textLight,
// // //             fontSize: 13.sp,
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // NEARBY RESTAURANTS WIDGET
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // class NearbyRestaurentBannersWidget extends StatefulWidget {
// // //   final String? orderType;
// // //   final List<int>? categoryVendorIds;
// // //   final String? searchQuery;
// // //   final VoidCallback? onOrderTypeRequired;
// // //   final String? selectedCategoryName;
// // //
// // //   const NearbyRestaurentBannersWidget({
// // //     super.key,
// // //     this.orderType,
// // //     this.categoryVendorIds,
// // //     this.searchQuery,
// // //     this.onOrderTypeRequired,
// // //     this.selectedCategoryName,
// // //   });
// // //
// // //   @override
// // //   State<NearbyRestaurentBannersWidget> createState() =>
// // //       _NearbyRestaurentBannersWidgetState();
// // // }
// // //
// // // class _NearbyRestaurentBannersWidgetState
// // //     extends State<NearbyRestaurentBannersWidget> {
// // //   late Future<List<Restaurent_Banner>> _future;
// // //
// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _future = Authservice.fetchnearbyresturents();
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return FutureBuilder<List<Restaurent_Banner>>(
// // //       future: _future,
// // //       builder: (_, snap) {
// // //         if (snap.connectionState == ConnectionState.waiting) {
// // //           return const RestaurantsSkeleton();
// // //         }
// // //         if (snap.hasError) {
// // //           return _state(Icons.error_outline, 'Error loading restaurants');
// // //         }
// // //         if (!snap.hasData || snap.data!.isEmpty) {
// // //           return _state(Icons.location_off, 'No nearby restaurants');
// // //         }
// // //
// // //         final filtered = snap.data!.where((b) {
// // //           final matchType =
// // //               widget.orderType == null ||
// // //               b.orderTypes.contains(widget.orderType);
// // //           final matchCat =
// // //               widget.categoryVendorIds == null ||
// // //               widget.categoryVendorIds!.contains(b.vendorId);
// // //           final matchSearch =
// // //               (widget.searchQuery ?? '').trim().isEmpty ||
// // //               b.companyName.toLowerCase().contains(
// // //                 widget.searchQuery!.toLowerCase(),
// // //               );
// // //           return matchType && matchCat && matchSearch;
// // //         }).toList();
// // //
// // //         if (filtered.isEmpty) {
// // //           return _state(Icons.search_off, 'No restaurants match your filter');
// // //         }
// // //
// // //         return ListView.separated(
// // //           shrinkWrap: true,
// // //           physics: const NeverScrollableScrollPhysics(),
// // //           padding: EdgeInsets.symmetric(horizontal: 16.w),
// // //           itemCount: filtered.length,
// // //           separatorBuilder: (_, __) => SizedBox(height: 14.h),
// // //           itemBuilder: (_, i) => _RestaurantCard(
// // //             banner: filtered[i],
// // //             orderType: widget.orderType,
// // //             onOrderTypeRequired: widget.onOrderTypeRequired,
// // //             selectedCategoryName: widget.selectedCategoryName,
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // //
// // //   Widget _state(IconData icon, String msg) {
// // //     return SizedBox(
// // //       height: 200.h,
// // //       child: Center(
// // //         child: Column(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(icon, size: 38.sp, color: restaurentsnewcolour.textLight),
// // //             SizedBox(height: 10.h),
// // //             Text(
// // //               msg,
// // //               style: TextStyle(
// // //                 fontSize: 13.sp,
// // //                 color: restaurentsnewcolour.textMuted,
// // //               ),
// // //               textAlign: TextAlign.center,
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // RESTAURANT CARD
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // class _RestaurantCard extends StatelessWidget {
// // //   final Restaurent_Banner banner;
// // //   final String? orderType;
// // //   final VoidCallback? onOrderTypeRequired;
// // //   final String? selectedCategoryName;
// // //
// // //   const _RestaurantCard({
// // //     required this.banner,
// // //     this.orderType,
// // //     this.onOrderTypeRequired,
// // //     this.selectedCategoryName,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final double screenH = MediaQuery.of(context).size.height;
// // //     // final double cardH = (screenH * 0.28).clamp(200.0, 260.0);
// // //     final double cardH = (screenH * 0.30).clamp(220.0, 280.0);
// // //     final double imgH = cardH * 0.58;
// // //
// // //     return GestureDetector(
// // //       onTap: () {
// // //         if (orderType == null) {
// // //           onOrderTypeRequired?.call();
// // //           return;
// // //         }
// // //
// // //         Navigator.push(
// // //           context,
// // //           MaterialPageRoute(
// // //             builder: (_) => MenuScreen(
// // //               vendorId: banner.vendorId,
// // //               initialCategoryName: selectedCategoryName,
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //       child: IntrinsicHeight(
// // //         child: Container(
// // //           decoration: BoxDecoration(
// // //             color: restaurentsnewcolour.surface,
// // //             borderRadius: BorderRadius.circular(
// // //               restaurentsnewcolour.cardRadius.r,
// // //             ),
// // //             boxShadow: [
// // //               BoxShadow(
// // //                 color: Colors.black.withOpacity(0.07),
// // //                 blurRadius: 12,
// // //                 offset: const Offset(0, 4),
// // //               ),
// // //             ],
// // //           ),
// // //
// // //           child: Column(
// // //             crossAxisAlignment: CrossAxisAlignment.start,
// // //             children: [
// // //               // IMAGE
// // //               AspectRatio(
// // //                 aspectRatio: 10 / 4,
// // //                 child: Stack(
// // //                   fit: StackFit.expand,
// // //                   children: [
// // //                     ClipRRect(
// // //                       borderRadius: BorderRadius.vertical(
// // //                         top: Radius.circular(restaurentsnewcolour.cardRadius.r),
// // //                       ),
// // //                       child: banner.companyBanner.isNotEmpty
// // //                           ? Image.network(
// // //                               banner.companyBanner,
// // //                               fit: BoxFit.cover,
// // //                               errorBuilder: (_, __, ___) => _placeholder(),
// // //                             )
// // //                           : _placeholder(),
// // //                     ),
// // //
// // //                     Positioned(
// // //                       bottom: 0,
// // //                       left: 0,
// // //                       right: 0,
// // //                       height: 60,
// // //                       child: const DecoratedBox(
// // //                         decoration: BoxDecoration(
// // //                           gradient: LinearGradient(
// // //                             begin: Alignment.topCenter,
// // //                             end: Alignment.bottomCenter,
// // //                             colors: [Colors.transparent, Color(0x66000000)],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                     ),
// // //
// // //                     if ((banner.ratings) >= 4.0)
// // //                       Positioned(
// // //                         top: 8,
// // //                         left: 10,
// // //                         child: Container(
// // //                           padding: const EdgeInsets.symmetric(
// // //                             horizontal: 8,
// // //                             vertical: 3,
// // //                           ),
// // //                           decoration: BoxDecoration(
// // //                             color: Colors.white,
// // //                             borderRadius: BorderRadius.circular(6),
// // //                           ),
// // //                           child: Row(
// // //                             mainAxisSize: MainAxisSize.min,
// // //                             children: [
// // //                               Icon(
// // //                                 Icons.star_rounded,
// // //                                 color: restaurentsnewcolour.primary,
// // //                                 size: 11,
// // //                               ),
// // //                               SizedBox(width: 3),
// // //                               Text(
// // //                                 'Top Rated',
// // //                                 style: TextStyle(
// // //                                   fontSize: 10,
// // //                                   fontWeight: FontWeight.w700,
// // //                                   color: restaurentsnewcolour.primary,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //                       ),
// // //                   ],
// // //                 ),
// // //               ),
// // //
// // //               // INFO
// // //               Padding(
// // //                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
// // //                 child: Column(
// // //                   crossAxisAlignment: CrossAxisAlignment.start,
// // //                   mainAxisSize: MainAxisSize.min,
// // //                   children: [
// // //                     Row(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Expanded(
// // //                           child: Wrap(
// // //                             crossAxisAlignment: WrapCrossAlignment.center,
// // //                             children: [
// // //                               Text(
// // //                                 banner.companyName.toUpperCase(),
// // //                                 maxLines: 2,
// // //                                 overflow: TextOverflow.ellipsis,
// // //                                 style: TextStyle(
// // //                                   fontSize: 14.sp,
// // //                                   fontWeight: FontWeight.w700,
// // //                                   color: restaurentsnewcolour.text,
// // //                                 ),
// // //                               ),
// // //
// // //                               _dot(),
// // //
// // //                               Text(
// // //                                 banner.type,
// // //                                 style: TextStyle(
// // //                                   fontSize: 14.sp,
// // //                                   fontWeight: FontWeight.w600,
// // //                                   color: restaurentsnewcolour.text,
// // //                                 ),
// // //                               ),
// // //                             ],
// // //                           ),
// // //                         ),
// // //
// // //                         if ((banner.ratings) > 0) ...[
// // //                           SizedBox(width: 8.w),
// // //
// // //                           Container(
// // //                             padding: EdgeInsets.symmetric(
// // //                               horizontal: 6.w,
// // //                               vertical: 3.h,
// // //                             ),
// // //                             decoration: BoxDecoration(
// // //                               color: restaurentsnewcolour.green,
// // //                               borderRadius: BorderRadius.circular(6.r),
// // //                             ),
// // //                             child: Row(
// // //                               mainAxisSize: MainAxisSize.min,
// // //                               children: [
// // //                                 const Icon(
// // //                                   Icons.star_rounded,
// // //                                   color: Colors.white,
// // //                                   size: 11,
// // //                                 ),
// // //                                 SizedBox(width: 2.w),
// // //                                 Text(
// // //                                   banner.ratings.toString(),
// // //                                   style: TextStyle(
// // //                                     color: Colors.white,
// // //                                     fontSize: 11.sp,
// // //                                     fontWeight: FontWeight.w700,
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                         ],
// // //                       ],
// // //                     ),
// // //
// // //                     SizedBox(height: 4.h),
// // //
// // //                     if (banner.position.isNotEmpty)
// // //                       Text(
// // //                         '${banner.position[0].toUpperCase()}${banner.position.substring(1).toLowerCase()}',
// // //                         maxLines: 1,
// // //                         overflow: TextOverflow.ellipsis,
// // //                         style: TextStyle(
// // //                           fontSize: 11.sp,
// // //                           color: const Color(0xFF6C63FF),
// // //                           fontWeight: FontWeight.w600,
// // //                         ),
// // //                       ),
// // //
// // //                     SizedBox(height: 6.h),
// // //
// // //                     Row(
// // //                       crossAxisAlignment: CrossAxisAlignment.start,
// // //                       children: [
// // //                         Expanded(
// // //                           child: Text(
// // //                             '${banner.addressLine}, ${banner.city}',
// // //                             maxLines: 2,
// // //                             overflow: TextOverflow.ellipsis,
// // //                             style: TextStyle(
// // //                               fontSize: 11.sp,
// // //                               color: restaurentsnewcolour.textLight,
// // //                             ),
// // //                           ),
// // //                         ),
// // //
// // //                         SizedBox(width: 8.w),
// // //
// // //                         Text(
// // //                           Distancehelpermethod.formatDistance(banner.distance),
// // //                           style: TextStyle(
// // //                             fontSize: 12.sp,
// // //                             fontWeight: FontWeight.w600,
// // //                             color: restaurentsnewcolour.textMuted,
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   ],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   Widget _dot() => Padding(
// // //     padding: EdgeInsets.symmetric(horizontal: 5.w),
// // //     child: Container(
// // //       width: 3,
// // //       height: 3,
// // //       decoration: const BoxDecoration(
// // //         color: restaurentsnewcolour.textLight,
// // //         shape: BoxShape.circle,
// // //       ),
// // //     ),
// // //   );
// // //
// // //   Widget _placeholder() => Container(
// // //     color: restaurentsnewcolour.bg,
// // //     child: Center(
// // //       child: Icon(
// // //         Icons.restaurant_rounded,
// // //         size: 32.sp,
// // //         color: restaurentsnewcolour.textLight,
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // STICKY SLIVER DELEGATE
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // class _StickyDelegate extends SliverPersistentHeaderDelegate {
// // //   final double height;
// // //   final Widget child;
// // //
// // //   const _StickyDelegate({required this.height, required this.child});
// // //
// // //   @override
// // //   double get minExtent => height;
// // //   @override
// // //   double get maxExtent => height;
// // //
// // //   @override
// // //   Widget build(BuildContext ctx, double shrink, bool overlaps) =>
// // //       SizedBox.expand(child: child);
// // //
// // //   @override
// // //   bool shouldRebuild(covariant _StickyDelegate old) =>
// // //       height != old.height || child != old.child;
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // FILTER BOTTOM SHEET
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // class FilterBottomSheet extends StatefulWidget {
// // // //   final int initialTab;
// // // //   const FilterBottomSheet({super.key, this.initialTab = 0});
// // // //
// // // //   @override
// // // //   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// // // // }
// // // //
// // // // class _FilterBottomSheetState extends State<FilterBottomSheet> {
// // // //   int _sel = 0;
// // // //
// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Column(
// // // //       children: [
// // // //         _header(),
// // // //         Expanded(
// // // //           child: Row(
// // // //             children: [
// // // //               _leftMenu(),
// // // //               Expanded(child: _rightContent()),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //         _footer(),
// // // //       ],
// // // //     );
// // // //   }
// // // //
// // // //   Widget _header() => Column(
// // // //     children: [
// // // //       SizedBox(height: 10.h),
// // // //       Container(
// // // //         width: 45.w,
// // // //         height: 5.h,
// // // //         decoration: BoxDecoration(
// // // //           color: Colors.grey.shade300,
// // // //           borderRadius: BorderRadius.circular(20),
// // // //         ),
// // // //       ),
// // // //       SizedBox(height: 18.h),
// // // //       Padding(
// // // //         padding: EdgeInsets.symmetric(horizontal: 18.w),
// // // //         child: Row(
// // // //           children: [
// // // //             Text(
// // // //               "Filters",
// // // //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
// // // //             ),
// // // //             const Spacer(),
// // // //             TextButton(
// // // //               onPressed: () {},
// // // //               child: Text(
// // // //                 "Clear all",
// // // //                 style: TextStyle(
// // // //                   color: restaurentsnewcolour.primary,
// // // //                   fontWeight: FontWeight.w600,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //           ],
// // // //         ),
// // // //       ),
// // // //       Divider(height: 1),
// // // //     ],
// // // //   );
// // // //   Widget _leftMenu() => Container(
// // // //     width: 90.w,
// // // //     color: restaurentsnewcolour.bg,
// // // //     child: ListView.builder(
// // // //       itemCount: RestaurentsHelper.menu.length,
// // // //       itemBuilder: (_, i) {
// // // //         final sel = _sel == i;
// // // //         return InkWell(
// // // //           onTap: () => setState(() => _sel = i),
// // // //           child: Container(
// // // //             padding: EdgeInsets.all(14.w),
// // // //             decoration: BoxDecoration(
// // // //               color: sel ? restaurentsnewcolour.surface : Colors.transparent,
// // // //               border: Border(
// // // //                 left: BorderSide(
// // // //                   color: sel
// // // //                       ? restaurentsnewcolour.primary
// // // //                       : Colors.transparent,
// // // //                   width: 3,
// // // //                 ),
// // // //               ),
// // // //             ),
// // // //             child: Text(
// // // //               RestaurentsHelper.menu[i],
// // // //               style: TextStyle(
// // // //                 fontSize: 12.sp,
// // // //                 fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
// // // //                 color: sel
// // // //                     ? restaurentsnewcolour.text
// // // //                     : restaurentsnewcolour.textMuted,
// // // //               ),
// // // //             ),
// // // //           ),
// // // //         );
// // // //       },
// // // //     ),
// // // //   );
// // // //
// // // //   Widget _rightContent() {
// // // //     switch (_sel) {
// // // //       case 0:
// // // //         return _panel('Time', [
// // // //           _chip(Icons.schedule_rounded, 'Schedule'),
// // // //           _chip(Icons.flash_on_rounded, 'Near & Fast'),
// // // //         ]);
// // // //       case 1:
// // // //         return _panel('Restaurant Rating', [
// // // //           _chip(Icons.star_rounded, 'Rated 3.5+'),
// // // //           _chip(Icons.star_rounded, 'Rated 4.0+'),
// // // //         ]);
// // // //       case 2:
// // // //         return _panel('Offers', [
// // // //           _chip(Icons.local_offer_rounded, 'Buy 1 Get 1'),
// // // //           _chip(Icons.percent_rounded, 'Deals of the Day'),
// // // //         ]);
// // // //       case 3:
// // // //         return _panel('Dish Price', [
// // // //           _chip(Icons.currency_rupee_rounded, 'Under ₹150'),
// // // //           _chip(Icons.currency_rupee_rounded, 'Under ₹250'),
// // // //           _chip(Icons.currency_rupee_rounded, 'Under ₹500'),
// // // //         ]);
// // // //       case 4:
// // // //         return _panel('Trust Markers', [
// // // //           _chip(Icons.verified_rounded, 'Hygiene Rated'),
// // // //           _chip(Icons.verified_user_rounded, 'Trusted Seller'),
// // // //         ]);
// // // //       default:
// // // //         return const SizedBox.shrink();
// // // //     }
// // // //   }
// // // //
// // // //   Widget _panel(String title, List<Widget> chips) => Padding(
// // // //     padding: EdgeInsets.all(16.w),
// // // //     child: Column(
// // // //       crossAxisAlignment: CrossAxisAlignment.start,
// // // //       children: [
// // // //         Text(
// // // //           title,
// // // //           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
// // // //         ),
// // // //         SizedBox(height: 14.h),
// // // //         Wrap(spacing: 10.w, runSpacing: 10.h, children: chips),
// // // //       ],
// // // //     ),
// // // //   );
// // // //
// // // //   Widget _chip(IconData icon, String label) => Container(
// // // //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
// // // //     decoration: BoxDecoration(
// // // //       border: Border.all(color: restaurentsnewcolour.border, width: 1.5),
// // // //       borderRadius: BorderRadius.circular(10.r),
// // // //       color: restaurentsnewcolour.surface,
// // // //     ),
// // // //     child: Row(
// // // //       mainAxisSize: MainAxisSize.min,
// // // //       children: [
// // // //         Icon(icon, size: 14.sp, color: restaurentsnewcolour.green),
// // // //         SizedBox(width: 6.w),
// // // //         Text(
// // // //           label,
// // // //           style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
// // // //         ),
// // // //       ],
// // // //     ),
// // // //   );
// // // //
// // // //   Widget _footer() => Padding(
// // // //     padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
// // // //     child: Row(
// // // //       children: [
// // // //         Expanded(
// // // //           child: OutlinedButton(
// // // //             onPressed: () => Navigator.pop(context),
// // // //             style: OutlinedButton.styleFrom(
// // // //               side: BorderSide(color: restaurentsnewcolour.border),
// // // //               padding: EdgeInsets.symmetric(vertical: 12.h),
// // // //             ),
// // // //             child: const Text('Close'),
// // // //           ),
// // // //         ),
// // // //         SizedBox(width: 12.w),
// // // //         Expanded(
// // // //           child: ElevatedButton(
// // // //             onPressed: () => Navigator.pop(context),
// // // //             style: ElevatedButton.styleFrom(
// // // //               backgroundColor: restaurentsnewcolour.primary,
// // // //               foregroundColor: Colors.white,
// // // //               padding: EdgeInsets.symmetric(vertical: 12.h),
// // // //             ),
// // // //             child: const Text('Show results'),
// // // //           ),
// // // //         ),
// // // //       ],
// // // //     ),
// // // //   );
// // // // }
// // //
// // // class FilterChipsBar extends StatefulWidget {
// // //   const FilterChipsBar({super.key});
// // //
// // //   @override
// // //   State<FilterChipsBar> createState() => _FilterChipsBarState();
// // // }
// // //
// // // class _FilterChipsBarState extends State<FilterChipsBar> {
// // //   int _activeIndex = -1;
// // //
// // //   void _onChipTap(int i) {
// // //     final label = RestaurentsHelper.filters[i]['label'] as String;
// // //     setState(() => _activeIndex = (_activeIndex == i) ? -1 : i);
// // //     if (label == 'Filters') _openFilterSheet();
// // //   }
// // //
// // //   void _openFilterSheet() {
// // //     showModalBottomSheet(
// // //       context: context,
// // //       isScrollControlled: true,
// // //       backgroundColor: Colors.transparent,
// // //       builder: (_) => FractionallySizedBox(
// // //         heightFactor: 0.92,
// // //         child: Container(
// // //           decoration: BoxDecoration(
// // //             color: AppColors.surface,
// // //             borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// // //           ),
// // //           child: const FilterBottomSheet(),
// // //         ),
// // //       ),
// // //     );
// // //   }
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return SizedBox(
// // //       height: 44.h,
// // //       child: ListView.separated(
// // //         scrollDirection: Axis.horizontal,
// // //         padding: EdgeInsets.symmetric(horizontal: 16.w),
// // //         itemCount: RestaurentsHelper.filters.length,
// // //         separatorBuilder: (_, __) => SizedBox(width: 8.w),
// // //         itemBuilder: (_, i) {
// // //           final f = RestaurentsHelper.filters[i];
// // //           final active = _activeIndex == i;
// // //           return _FilterChip(
// // //             icon: f['icon'] as IconData,
// // //             label: f['label'] as String,
// // //             isActive: active,
// // //             onTap: () => _onChipTap(i),
// // //           );
// // //         },
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class _FilterChip extends StatelessWidget {
// // //   final IconData icon;
// // //   final String label;
// // //   final bool isActive;
// // //   final VoidCallback onTap;
// // //
// // //   const _FilterChip({
// // //     required this.icon,
// // //     required this.label,
// // //     required this.isActive,
// // //     required this.onTap,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: AnimatedContainer(
// // //         duration: const Duration(milliseconds: 160),
// // //         curve: Curves.easeOut,
// // //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// // //         decoration: BoxDecoration(
// // //           color: isActive ? restaurentsnewcolour.text : AppColors.surface,
// // //           borderRadius: BorderRadius.circular(8.r),
// // //           border: Border.all(
// // //             color: isActive ? restaurentsnewcolour.text : AppColors.border,
// // //             width: 1.5,
// // //           ),
// // //         ),
// // //         child: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(
// // //               icon,
// // //               size: 14.sp,
// // //               color: isActive ? Colors.white : restaurentsnewcolour.textMuted,
// // //             ),
// // //             SizedBox(width: 5.w),
// // //             Text(
// // //               label,
// // //               style: TextStyle(
// // //                 fontSize: 12.sp,
// // //                 fontWeight: FontWeight.w600,
// // //                 color: isActive ? Colors.white : restaurentsnewcolour.textMuted,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // // ─── Filter bottom sheet ──────────────────────────────────────────────────────
// // //
// // // class FilterBottomSheet extends StatefulWidget {
// // //   const FilterBottomSheet({super.key});
// // //
// // //   @override
// // //   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// // // }
// // //
// // // class _FilterBottomSheetState extends State<FilterBottomSheet> {
// // //   int _tab = 0;
// // //   // selected[tabIndex] = Set of option indices
// // //   final Map<int, Set<int>> _selected = {};
// // //
// // //   Set<int> _opts(int tab) => _selected.putIfAbsent(tab, () => {});
// // //
// // //   void _toggleOpt(int tab, int opt) {
// // //     setState(() {
// // //       final s = _opts(tab);
// // //       s.contains(opt) ? s.remove(opt) : s.add(opt);
// // //     });
// // //   }
// // //
// // //   void _clearAll() => setState(() => _selected.clear());
// // //
// // //   int get _totalSelected =>
// // //       _selected.values.fold(0, (sum, s) => sum + s.length);
// // //
// // //   int get _resultCount => (24 - _totalSelected * 3).clamp(2, 24);
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       children: [
// // //         _Handle(),
// // //         _Header(onClear: _clearAll),
// // //         Expanded(
// // //           child: Row(
// // //             children: [
// // //               _LeftNav(
// // //                 selected: _tab,
// // //                 onSelect: (i) => setState(() => _tab = i),
// // //               ),
// // //               Expanded(
// // //                 child: _RightPanel(
// // //                   tab: _tab,
// // //                   selectedOpts: _opts(_tab),
// // //                   onToggle: (opt) => _toggleOpt(_tab, opt),
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //         _ResultCount(count: _resultCount),
// // //         _Footer(),
// // //       ],
// // //     );
// // //   }
// // // }
// // //
// // // // ── Sub-widgets ──────────────────────────────────────────────────────────────
// // //
// // // class _Handle extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) => Center(
// // //     child: Container(
// // //       margin: EdgeInsets.symmetric(vertical: 10.h),
// // //       width: 36.w,
// // //       height: 4.h,
// // //       decoration: BoxDecoration(
// // //         color: AppColors.border,
// // //         borderRadius: BorderRadius.circular(2.r),
// // //       ),
// // //     ),
// // //   );
// // // }
// // //
// // // class _Header extends StatelessWidget {
// // //   final VoidCallback onClear;
// // //   const _Header({required this.onClear});
// // //
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
// // //     decoration: BoxDecoration(
// // //       border: Border(bottom: BorderSide(color: AppColors.border)),
// // //     ),
// // //     child: Row(
// // //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// // //       children: [
// // //         Text(
// // //           'Filters & sorting',
// // //           style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
// // //         ),
// // //         GestureDetector(
// // //           onTap: onClear,
// // //           child: Text(
// // //             'Clear all',
// // //             style: TextStyle(
// // //               fontSize: 12.sp,
// // //               fontWeight: FontWeight.w500,
// // //               color: AppColors.primary,
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }
// // //
// // // class _LeftNav extends StatelessWidget {
// // //   final int selected;
// // //   final ValueChanged<int> onSelect;
// // //
// // //   const _LeftNav({required this.selected, required this.onSelect});
// // //
// // //   @override
// // //   Widget build(BuildContext context) => Container(
// // //     width: 88.w,
// // //     decoration: BoxDecoration(
// // //       color: restaurentsnewcolour.bg,
// // //       border: Border(right: BorderSide(color: AppColors.border)),
// // //     ),
// // //     child: ListView.builder(
// // //       itemCount: RestaurentsHelper.menu.length,
// // //       itemBuilder: (_, i) {
// // //         final active = selected == i;
// // //         return InkWell(
// // //           onTap: () => onSelect(i),
// // //           child: AnimatedContainer(
// // //             duration: const Duration(milliseconds: 140),
// // //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
// // //             decoration: BoxDecoration(
// // //               color: active ? AppColors.surface : Colors.transparent,
// // //               border: Border(
// // //                 left: BorderSide(
// // //                   color: active ? AppColors.primary : Colors.transparent,
// // //                   width: 3,
// // //                 ),
// // //               ),
// // //             ),
// // //             child: Text(
// // //               RestaurentsHelper.menu[i],
// // //               style: TextStyle(
// // //                 fontSize: 12.sp,
// // //                 fontWeight: active ? FontWeight.w600 : FontWeight.w400,
// // //                 color: active
// // //                     ? restaurentsnewcolour.text
// // //                     : restaurentsnewcolour.textMuted,
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     ),
// // //   );
// // // }
// // //
// // // class _RightPanel extends StatelessWidget {
// // //   final int tab;
// // //   final Set<int> selectedOpts;
// // //   final ValueChanged<int> onToggle;
// // //
// // //   const _RightPanel({
// // //     required this.tab,
// // //     required this.selectedOpts,
// // //     required this.onToggle,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     final data = RestaurentsHelper.panelData[tab];
// // //     final title = data['title'] as String;
// // //     final opts = data['opts'] as List<Map<String, Object>>;
// // //
// // //     return SingleChildScrollView(
// // //       padding: EdgeInsets.all(16.w),
// // //       child: Column(
// // //         crossAxisAlignment: CrossAxisAlignment.start,
// // //         children: [
// // //           Text(
// // //             title.toUpperCase(),
// // //             style: TextStyle(
// // //               fontSize: 10.sp,
// // //               fontWeight: FontWeight.w600,
// // //               color: restaurentsnewcolour.textMuted,
// // //               letterSpacing: 0.6,
// // //             ),
// // //           ),
// // //           SizedBox(height: 12.h),
// // //           Wrap(
// // //             spacing: 8.w,
// // //             runSpacing: 8.h,
// // //             children: List.generate(opts.length, (i) {
// // //               final o = opts[i];
// // //               final sel = selectedOpts.contains(i);
// // //               return _OptionChip(
// // //                 icon: o['icon'] as IconData,
// // //                 label: o['label'] as String,
// // //                 isSelected: sel,
// // //                 onTap: () => onToggle(i),
// // //               );
// // //             }),
// // //           ),
// // //         ],
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class _OptionChip extends StatelessWidget {
// // //   final IconData icon;
// // //   final String label;
// // //   final bool isSelected;
// // //   final VoidCallback onTap;
// // //
// // //   const _OptionChip({
// // //     required this.icon,
// // //     required this.label,
// // //     required this.isSelected,
// // //     required this.onTap,
// // //   });
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return GestureDetector(
// // //       onTap: onTap,
// // //       child: AnimatedContainer(
// // //         duration: const Duration(milliseconds: 140),
// // //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
// // //         decoration: BoxDecoration(
// // //           color: isSelected
// // //               ? AppColors.primary.withOpacity(0.08)
// // //               : AppColors.surface,
// // //           border: Border.all(
// // //             color: isSelected ? AppColors.primary : AppColors.border,
// // //             width: isSelected ? 1.5 : 1,
// // //           ),
// // //           borderRadius: BorderRadius.circular(10.r),
// // //         ),
// // //         child: Row(
// // //           mainAxisSize: MainAxisSize.min,
// // //           children: [
// // //             Icon(
// // //               icon,
// // //               size: 14.sp,
// // //               color: isSelected
// // //                   ? AppColors.primary
// // //                   : restaurentsnewcolour.green,
// // //             ),
// // //             SizedBox(width: 6.w),
// // //             Text(
// // //               label,
// // //               style: TextStyle(
// // //                 fontSize: 12.sp,
// // //                 fontWeight: FontWeight.w500,
// // //                 color: isSelected
// // //                     ? AppColors.primary
// // //                     : restaurentsnewcolour.text,
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //     );
// // //   }
// // // }
// // //
// // // class _ResultCount extends StatelessWidget {
// // //   final int count;
// // //   const _ResultCount({required this.count});
// // //
// // //   @override
// // //   Widget build(BuildContext context) => Padding(
// // //     padding: EdgeInsets.symmetric(vertical: 6.h),
// // //     child: Text(
// // //       '$count restaurants match your filters',
// // //       style: TextStyle(fontSize: 11.sp, color: restaurentsnewcolour.textMuted),
// // //       textAlign: TextAlign.center,
// // //     ),
// // //   );
// // // }
// // //
// // // class _Footer extends StatelessWidget {
// // //   @override
// // //   Widget build(BuildContext context) => Padding(
// // //     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
// // //     child: Row(
// // //       children: [
// // //         Expanded(
// // //           child: OutlinedButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             style: OutlinedButton.styleFrom(
// // //               side: BorderSide(color: AppColors.border),
// // //               padding: EdgeInsets.symmetric(vertical: 12.h),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(8.r),
// // //               ),
// // //               foregroundColor: restaurentsnewcolour.textMuted,
// // //             ),
// // //             child: Text(
// // //               'Close',
// // //               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
// // //             ),
// // //           ),
// // //         ),
// // //         SizedBox(width: 10.w),
// // //         Expanded(
// // //           flex: 2,
// // //           child: ElevatedButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             style: ElevatedButton.styleFrom(
// // //               backgroundColor: AppColors.primary,
// // //               foregroundColor: Colors.white,
// // //               elevation: 0,
// // //               padding: EdgeInsets.symmetric(vertical: 12.h),
// // //               shape: RoundedRectangleBorder(
// // //                 borderRadius: BorderRadius.circular(8.r),
// // //               ),
// // //             ),
// // //             child: Text(
// // //               'Show results',
// // //               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
// // //             ),
// // //           ),
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }
// // //
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // // SEARCH BAR HEADER DELEGATE  (kept for external compatibility)
// // // // ══════════════════════════════════════════════════════════════════════════════
// // // class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
// // //   final ValueChanged<String> onSearchChanged;
// // //   final VoidCallback? onFilterPressed;
// // //   final double height;
// // //
// // //   const SearchBarHeaderDelegate({
// // //     required this.onSearchChanged,
// // //     required this.height,
// // //     this.onFilterPressed,
// // //   });
// // //
// // //   @override
// // //   double get minExtent => height;
// // //   @override
// // //   double get maxExtent => height;
// // //
// // //   @override
// // //   Widget build(BuildContext ctx, double shrink, bool overlaps) {
// // //     return Container(
// // //       color: restaurentsnewcolour.surface,
// // //       padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
// // //       child: _SearchBar(onChanged: onSearchChanged),
// // //     );
// // //   }
// // //
// // //   @override
// // //   bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
// // // }
// //
// // import 'dart:async';
// // import 'package:custom_cached_image/custom_cached_image.dart';
// //
// // import '../../../widgets/safearea.dart';
// // import '../../../widgets/widgets/couponcards.dart';
// // import '../Menu/menu_screen.dart';
// // import '../distancehelpermethod.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter/foundation.dart';
// // import '../../screens/notifications.dart';
// // import '../../screens/saved_address.dart';
// // import '../../skeleton/Restaurents_screen.dart';
// // import '../../Catering&Services/Caterings.dart';
// // import 'package:in_app_update/in_app_update.dart';
// // import '../../screens/advertisements/Advideo.dart';
// // import '../../../Models/food/food_categries_model.dart';
// // import '../../../Models/food/restaurent_banner_model.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import '../../../Services/App_color_service/app_colours.dart';
// // import '../../../Services/Auth_service/food_authservice.dart';
// // import '../../screens/advertisements/banneradvertisement.dart';
// // import '../../../Services/googleservices/Location_servces.dart';
// // import '../../../Models/promotions_model/promotions_model.dart';
// // import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// // import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
// // import '../../../Services/Auth_service/Subscription_authservice.dart';
// // import '../../../Services/Auth_service/promotion_services_Authservice.dart';
// // import 'package:maamaas/screens/Food&beverages/RestaurentsScreen/RestaurentsHelper.dart';
// //
// // class Restaurentshmepage extends StatefulWidget {
// //   final ScrollController scrollController;
// //   const Restaurentshmepage({super.key, required this.scrollController});
// //
// //   @override
// //   // ignore: library_private_types_in_public_api
// //   _RestaurentsState createState() => _RestaurentsState();
// // }
// //
// // class _RestaurentsState extends State<Restaurentshmepage> {
// //   // ── State ──────────────────────────────────────────────────────────────────
// //   String _currentLocation = 'Fetching location...';
// //   bool _updateAvailable = false;
// //   AppUpdateInfo? _updateInfo;
// //   String? selectedOrderType;
// //   bool _isBannerCollapsed = false;
// //   List<FoodCategory> categories = [];
// //   bool isCategoriesLoading = true;
// //   int selectedCategoryIndex = 0;
// //   List<int>? selectedCategoryVendorIds;
// //   String? selectedCategoryName;
// //   String searchText = '';
// //   Timer? _debounce;
// //   bool _isLoggedIn = false;
// //   bool _isGuestLocationLoading = false;
// //   int _activeFilterIndex = -1;
// //   List<Campaign> homepageAds = [];
// //   bool _highlightOrderTabs = false;
// //   bool _showOrderTypeHint = false;
// //   final ValueNotifier<String?> selectedOrderTypeNotifier = ValueNotifier(null);
// //
// //   final GlobalKey _orderTypeKey = GlobalKey();
// //   bool _hasShownLocationDialog = false;
// //
// //   // ── Top nav tabs (Food / Logistics) ──────────────────────────────────────
// //   int _selectedTopNavIndex = 0;
// //   final List<Map<String, dynamic>> _topNavTabs = [
// //     {'icon': Icons.restaurant_rounded, 'label': 'Food'},
// //     {'icon': Icons.local_shipping_rounded, 'label': 'Logistics'},
// //   ];
// //
// //   int _refreshKey = 0;
// //   String? _locationCategory;
// //
// //   // ── Banner height ──────────────────────────────────────────────────────────
// //   double get _bannerHeight {
// //     final h = MediaQuery.of(context).size.height;
// //     return (h * 0.70).clamp(250.0, 350.0);
// //   }
// //
// //   // ── Lifecycle ──────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     widget.scrollController.addListener(_onScroll);
// //     _checkLogin().then((_) {
// //       if (_isLoggedIn) {
// //         _loadLocationFromAPI();
// //       } else {
// //         _loadGuestLocation();
// //       }
// //     });
// //     if (kReleaseMode) {
// //       _checkForUpdate();
// //     }
// //     _fetchCategories();
// //     _checkLogin();
// //     _loadAds();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     widget.scrollController.removeListener(_onScroll);
// //     selectedOrderTypeNotifier.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── Scroll listener ────────────────────────────────────────────────────────
// //   void _onScroll() {
// //     final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
// //     final collapsed = widget.scrollController.offset > collapseThreshold;
// //     if (collapsed != _isBannerCollapsed && mounted) {
// //       setState(() => _isBannerCollapsed = collapsed);
// //     }
// //   }
// //
// //   // ── Auth / Location ────────────────────────────────────────────────────────
// //   Future<void> _checkLogin() async {
// //     final v = await subscription_AuthService.isLoggedIn();
// //     if (mounted) setState(() => _isLoggedIn = v);
// //   }
// //
// //   Future<void> _loadGuestLocation() async {
// //     setState(() => _isGuestLocationLoading = true);
// //     try {
// //       final r = await LocationService.getCurrentLocationWithAddress();
// //       if (!mounted) return;
// //       if (r != null) {
// //         final parts = [
// //           r.area,
// //           r.adminArea,
// //           r.city,
// //           r.state,
// //         ].where((e) => e != null && e.isNotEmpty).toList();
// //         final addr = parts.join(', ');
// //         setState(() {
// //           _currentLocation = (r.pincode != null && r.pincode!.isNotEmpty)
// //               ? '$addr - ${r.pincode}'
// //               : addr;
// //         });
// //       } else {
// //         setState(() => _currentLocation = 'Enable location');
// //       }
// //     } catch (e) {
// //       //       debugPrint('Guest location error: $e');
// //       if (mounted) setState(() => _currentLocation = 'Location unavailable');
// //     } finally {
// //       if (mounted) setState(() => _isGuestLocationLoading = false);
// //     }
// //   }
// //
// //   Future<void> _loadLocationFromAPI() async {
// //     try {
// //       final loc = await subscription_AuthService.fetchCurrentLocation();
// //
// //       if (!mounted) return;
// //
// //       // print("📍 RAW LOC: $loc");
// //       // print("📍 ADDRESS CHECK: ${loc?.address}");
// //       // print("📍 VALID: ${loc?.address.trim().isNotEmpty}");
// //
// //       // ✅ VALID LOCATION CHECK
// //       final isValidLocation = loc != null && loc.address.trim().isNotEmpty;
// //
// //       if (isValidLocation) {
// //         setState(() {
// //           _currentLocation = loc.address;
// //           _locationCategory = loc.category;
// //         });
// //
// //         // ✅ Reset dialog flag (important if user later deletes address)
// //         _hasShownLocationDialog = false;
// //       } else {
// //         _handleInvalidLocation();
// //       }
// //     } catch (e) {
// //       //       debugPrint("❌ Location API Error: $e");
// //       if (!mounted) return;
// //
// //       _handleInvalidLocation();
// //     }
// //   }
// //
// //   void _handleInvalidLocation() {
// //     // ❌ Don't immediately show popup
// //     Future.delayed(const Duration(milliseconds: 500), () {
// //       if (!mounted) return;
// //
// //       if (_currentLocation == 'Fetching location...') {
// //         if (!_hasShownLocationDialog) {
// //           _hasShownLocationDialog = true;
// //
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             if (mounted) {
// //               _showUpdateLocationDialog();
// //             }
// //           });
// //         }
// //       }
// //     });
// //   }
// //
// //   void _showUpdateLocationDialog() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16.r),
// //         ),
// //         title: Row(
// //           children: [
// //             const Icon(Icons.location_off, color: Colors.red),
// //             SizedBox(width: 8.w),
// //             Text('Location Required', style: TextStyle(fontSize: 16.sp)),
// //           ],
// //         ),
// //         content: Text(
// //           "We couldn't detect your location. Please update to continue.",
// //           style: TextStyle(fontSize: 13.sp),
// //         ),
// //         actions: [
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               _changeLocation();
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: restaurentsnewcolour.primary,
// //               foregroundColor: Colors.white,
// //             ),
// //             child: const Text('Update Location'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _changeLocation() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => SavedAddress(
// //           onAddressSelected: (address) async {
// //             setState(() {
// //               // _currentLocation =
// //               //     '${address.},${address.city}, ${address.state} - ${address.pincode}';
// //               // _locationCategory = address.category;
// //               _currentLocation = address.fullAddress;
// //
// //               // print("Category: ${address.category}");
// //             });
// //             _hasShownLocationDialog = false;
// //             await _refreshAll();
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Data ───────────────────────────────────────────────────────────────────
// //   Future<void> _fetchCategories() async {
// //     setState(() => isCategoriesLoading = true);
// //     try {
// //       final res = await Authservice.fetchFoodCategories();
// //       if (!mounted) return;
// //       setState(() {
// //         categories = res;
// //         selectedCategoryIndex = 0;
// //         selectedCategoryVendorIds = null;
// //       });
// //     } catch (e) {
// //       //       debugPrint('Category error: $e');
// //       if (mounted) setState(() => categories = []);
// //     } finally {
// //       if (mounted) setState(() => isCategoriesLoading = false);
// //     }
// //   }
// //
// //   Future<void> _loadAds() async {
// //     try {
// //       final result = await promotion_Authservice.fetchcampaign();
// //       final filtered = result
// //           .where(
// //             (c) =>
// //         c.addDisplayPosition == AddDisplayPosition.HOMEPAGE_BANNER &&
// //             c.medium == Medium.APP,
// //       )
// //           .toList();
// //       if (mounted) setState(() => homepageAds = filtered);
// //     } catch (e) {
// //       //       debugPrint('Ads error: $e');
// //     }
// //   }
// //
// //   Future<void> _refreshAll() async {
// //     //     debugPrint("🔄 _refreshAll() STARTED");
// //
// //     try {
// //       await Future.wait([_fetchCategories(), _loadAds()]);
// //       //
// //       //       debugPrint("✅ APIs completed successfully");
// //     } catch (e) {
// //       //       debugPrint("❌ Error in _refreshAll(): $e");
// //     }
// //
// //     if (mounted) {
// //       setState(() {
// //         _refreshKey++;
// //       });
// //       //       debugPrint("🔁 UI refreshed, refreshKey: $_refreshKey");
// //     } else {
// //       //       debugPrint("⚠️ Widget not mounted, skipping setState");
// //     }
// //     //
// //     //     debugPrint("🏁 _refreshAll() FINISHED");
// //   }
// //
// //   // ── Update ─────────────────────────────────────────────────────────────────
// //   Future<void> _checkForUpdate() async {
// //     try {
// //       final info = await InAppUpdate.checkForUpdate();
// //       if (!mounted) return;
// //       setState(() {
// //         _updateInfo = info;
// //         _updateAvailable =
// //             info.updateAvailability == UpdateAvailability.updateAvailable;
// //       });
// //     } catch (e) {
// //       //       debugPrint('Update check failed: $e');
// //     }
// //   }
// //
// //   void _startFlexibleUpdate() async {
// //     if (_updateInfo != null) {
// //       try {
// //         await InAppUpdate.performImmediateUpdate();
// //       } catch (e) {
// //         //         debugPrint('Update error: $e');
// //       }
// //     }
// //   }
// //
// //   // ── Order type ─────────────────────────────────────────────────────────────
// //
// //   String? _getApiOrderType() {
// //     if (selectedOrderType == null) return null;
// //
// //     final raw = selectedOrderType!;
// //     final normalized = raw.toLowerCase().trim();
// //
// //     final mapped = RestaurentsHelper.typeMapping[normalized];
// //     //
// //     //     debugPrint("📦 API Type: $mapped");
// //
// //     return mapped;
// //   }
// //
// //   Future<void> _handleOrderTypeSelection(String type) async {
// //     final cleanType = type.toLowerCase().trim();
// //
// //     /// ✅ 👉 HANDLE CATERING LOCALLY
// //     if (cleanType == "catering") {
// //       if (!mounted) return;
// //
// //       setState(() {
// //         selectedOrderType = cleanType;
// //       });
// //
// //       selectedOrderTypeNotifier.value = cleanType;
// //
// //       // print("🎯 Catering selected → No API call");
// //       return; // 🚫 STOP HERE
// //     }
// //
// //     /// ✅ OTHER TYPES → CALL API
// //     final api = RestaurentsHelper.typeMapping[cleanType];
// //
// //     if (api == null) {
// //       //       debugPrint("❌ Mapping failed for: $cleanType");
// //       return;
// //     }
// //
// //     // print("🚀 Trying to create cart for: $cleanType");
// //
// //     final result = await food_Authservice.createCart(api);
// //
// //     if (result["success"] == true) {
// //       if (!mounted) return;
// //
// //       setState(() {
// //         selectedOrderType = cleanType;
// //       });
// //
// //       selectedOrderTypeNotifier.value = cleanType;
// //     } else {
// //       final message = result["message"] ?? "Something went wrong";
// //
// //       if (!mounted) return;
// //       AppAlert.error(context, message);
// //     }
// //   }
// //
// //   void _focusOrderTypeSelection() {
// //     final context = _orderTypeKey.currentContext;
// //
// //     if (context != null) {
// //       Scrollable.ensureVisible(
// //         context,
// //         duration: const Duration(milliseconds: 500),
// //         curve: Curves.easeInOut,
// //         alignment: 0.1, // 👈 keeps it slightly below top
// //       );
// //     }
// //
// //     setState(() {
// //       _highlightOrderTabs = true;
// //       _showOrderTypeHint = true;
// //     });
// //
// //     Future.delayed(const Duration(seconds: 2), () {
// //       if (mounted) setState(() => _highlightOrderTabs = false);
// //     });
// //
// //     Future.delayed(const Duration(seconds: 3), () {
// //       if (mounted) setState(() => _showOrderTypeHint = false);
// //     });
// //   }
// //
// //   // ── Debounce search ────────────────────────────────────────────────────────
// //   void _onSearchChanged(String value) {
// //     _debounce?.cancel();
// //     _debounce = Timer(const Duration(milliseconds: 400), () {
// //       if (mounted) setState(() => searchText = value);
// //     });
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // BUILD
// //   // ══════════════════════════════════════════════════════════════════════════
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // backgroundColor: restaurentsnewcolour.bg,
// //       backgroundColor: Colors.white,
// //       extendBodyBehindAppBar: false,
// //       body: RefreshIndicator(
// //         strokeWidth: 2,
// //         color: restaurentsnewcolour.primary,
// //         backgroundColor: restaurentsnewcolour.surface,
// //         onRefresh: _refreshAll,
// //         child: Stack(
// //           children: [
// //             CustomScrollView(
// //               controller: widget.scrollController,
// //               physics: const AlwaysScrollableScrollPhysics(),
// //               slivers: [
// //                 SliverToBoxAdapter(child: _topNavTabs()),
// //                 SliverAppBar(
// //                   expandedHeight: _bannerHeight,
// //                   collapsedHeight: kToolbarHeight,
// //                   pinned: true,
// //                   elevation: 0,
// //                   scrolledUnderElevation: 0,
// //
// //                   backgroundColor: _isBannerCollapsed
// //                       ? restaurentsnewcolour.surface
// //                       : Colors.transparent,
// //
// //                   systemOverlayStyle: _isBannerCollapsed
// //                       ? SystemUiOverlayStyle.dark
// //                       : SystemUiOverlayStyle.light,
// //
// //                   automaticallyImplyLeading: false,
// //
// //                   title: _isBannerCollapsed ? _buildCollapsedBar() : null,
// //                   flexibleSpace: FlexibleSpaceBar(
// //                     collapseMode: CollapseMode.pin,
// //                     background: _buildHeroBanner(),
// //                   ),
// //                 ),
// //
// //                 // ── 2. Sticky search bar ────────────────────────────────
// //                 if (selectedOrderType != 'catering')
// //                   SliverPersistentHeader(
// //                     pinned: true,
// //                     delegate: _StickyDelegate(
// //                       height: 70.h, // ✅ FIXED
// //                       child: Container(
// //                         color: restaurentsnewcolour.surface,
// //                         child: Column(
// //                           children: [
// //                             Padding(
// //                               padding: EdgeInsets.symmetric(
// //                                 horizontal: 16.w,
// //                                 vertical: 10.h,
// //                               ),
// //                               child: SizedBox(
// //                                 width: double.infinity,
// //                                 child: _SearchBar(onChanged: _onSearchChanged),
// //                               ),
// //                             ),
// //                             // Divider(height: 1, color: restaurentsnewcolour.border),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
// //
// //                 // ── 3. Coupon offers ────────────────────────────────────
// //                 SliverToBoxAdapter(child: CouponsOffersSection()),
// //
// //                 // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
// //
// //                 // ── 4. Divider ──────────────────────────────────────────
// //                 // SliverToBoxAdapter(child: _Divider()),
// //
// //                 // ── 5. Food categories ──────────────────────────────────
// //                 if (selectedOrderType != 'catering')
// //                   SliverPersistentHeader(
// //                     pinned: true,
// //                     delegate: _StickyDelegate(
// //                       height: 120.h,
// //                       // height: 95.h,
// //                       child: Container(
// //                         color: restaurentsnewcolour.surface,
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Padding(
// //                               // padding: EdgeInsets.fromLTRB(16.w, 10.h, 0, 6.h),
// //                               padding: EdgeInsets.fromLTRB(
// //                                 16.w,
// //                                 4.h, // reduced from 10.h
// //                                 0,
// //                                 4.h, // reduced from 6.h
// //                               ),
// //                               child: Text(
// //                                 "What's on your mind?",
// //                                 style: TextStyle(
// //                                   fontSize: 16.sp,
// //                                   fontWeight: FontWeight.w700,
// //                                   color: restaurentsnewcolour.text,
// //                                 ),
// //                               ),
// //                             ),
// //                             Expanded(child: _buildFoodCategories()),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //
// //                 // SliverToBoxAdapter(child: _Divider()),
// //
// //                 // ── 6. Order type tabs (sticky) ─────────────────────────
// //                 SliverPersistentHeader(
// //                   key: _orderTypeKey,
// //                   pinned: false,
// //                   delegate: _StickyDelegate(
// //                     height: _showOrderTypeHint ? 88.h : 58.h,
// //
// //                     // height: _showOrderTypeHint ? 165.h : 115.h,
// //                     child: Container(
// //                       color: restaurentsnewcolour.surface,
// //                       child: Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Padding(
// //                             padding: EdgeInsets.symmetric(
// //                               horizontal: 16.w,
// //                               // vertical: 10.h,
// //                               vertical: 10.h,
// //                             ),
// //                             child: _buildOrderTypeTabs(),
// //                           ),
// //                           if (_showOrderTypeHint)
// //                             AnimatedOpacity(
// //                               duration: const Duration(milliseconds: 300),
// //                               opacity: _showOrderTypeHint ? 1 : 0,
// //                               child: Padding(
// //                                 padding: EdgeInsets.only(bottom: 6.h),
// //                                 child: Text(
// //                                   '👆 Please select an order type',
// //                                   style: TextStyle(
// //                                     fontSize: 16.sp,
// //                                     color: Colors.red.shade600,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           // Divider(height: 1, color: restaurentsnewcolour.border),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //
// //                 // ── 7. Filter chips ─────────────────────────────────────
// //                 SliverPersistentHeader(
// //                   pinned: false,
// //                   delegate: _StickyDelegate(
// //                     height: 50.h,
// //                     child: Container(
// //                       color: restaurentsnewcolour.surface,
// //                       child: _buildFilterChips(),
// //                     ),
// //                   ),
// //                 ),
// //
// //                 SliverToBoxAdapter(child: SizedBox(height: 4.h)),
// //                 //
// //                 // // ── 8. Offer filter strip ───────────────────────────────
// //                 SliverToBoxAdapter(child: _buildOfferStrip()),
// //
// //                 // ── 9. Restaurant list header ───────────────────────────
// //                 if (selectedOrderType != 'catering')
// //                   SliverToBoxAdapter(
// //                     child: Padding(
// //                       padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'Restaurants Near You',
// //                             style: TextStyle(
// //                               fontSize: 18.sp,
// //                               fontWeight: FontWeight.w700,
// //                               color: restaurentsnewcolour.text,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 SliverToBoxAdapter(child: SizedBox(height: 1.h)),
// //
// //                 // ── 10. Restaurant cards ────────────────────────────────
// //                 SliverToBoxAdapter(child: _buildRestaurantList()),
// //
// //                 SliverToBoxAdapter(child: SizedBox(height: 32.h)),
// //               ],
// //             ),
// //
// //             // ── Update banner ───────────────────────────────────────────
// //             if (_updateAvailable)
// //               Positioned(
// //                 left: 16.w,
// //                 right: 16.w,
// //                 bottom: 16.h,
// //                 child: SafeArea(child: _buildUpdateBanner()),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeroBanner() {
// //     return SizedBox.expand(
// //       child: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           /// 🔹 Background (Ad / Video)
// //           _isLoggedIn
// //               ? (homepageAds.isEmpty
// //               ? Container(color: const Color(0xFFCCCCCC))
// //               : BannerAdvertisement(
// //             ads: homepageAds,
// //             height: _bannerHeight,
// //           ))
// //               : const VideoPreviewContainer(),
// //
// //           /// 🔹 Gradient overlay
// //           IgnorePointer(
// //             child: const DecoratedBox(
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Color(0x99000000),
// //                     Color(0x33000000),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           /// 🔹 Top Content (SafeArea prevents notch overlap)
// //           // IgnorePointer(
// //           //   child:
// //           SafeArea(
// //             bottom: false,
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const SizedBox(height: 10),
// //
// //                   /// 📍 Location + Notification Row
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: _buildLocationContent(
// //                           isDark: false, // white text
// //                           isExpanded: true, // bigger UI
// //                         ),
// //                       ),
// //
// //                       /// 🔔 Notification Icon
// //                       GestureDetector(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (_) => NotificationScreen(),
// //                             ),
// //                           );
// //                         },
// //                         child: Container(
// //                           width: 36.w,
// //                           height: 36.w,
// //                           decoration: BoxDecoration(
// //                             // ignore: deprecated_member_use
// //                             color: Colors.white.withOpacity(0.2),
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: const Icon(
// //                             Icons.notifications_none_rounded,
// //                             color: Colors.white,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //
// //                   /// 🍔🚚 Food / Logistics top nav tabs
// //                   // _buildTopNavTabs(),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           // ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   /// 🔹 Top pill-style nav tabs (Food / Logistics) — mirrors the
// //   /// Food/Instamart/Dineout/Scenes tab strip pattern, trimmed to 2 tabs.
// //   Widget _buildTopNavTabs() {
// //     return Padding(
// //       padding: EdgeInsets.only(top: 14.h),
// //       child: Row(
// //         children: List.generate(_topNavTabs.length, (i) {
// //           final tab = _topNavTabs[i];
// //           final isSelected = _selectedTopNavIndex == i;
// //
// //           return GestureDetector(
// //             onTap: () {
// //               if (_selectedTopNavIndex == i) return;
// //               setState(() => _selectedTopNavIndex = i);
// //
// //               if (tab['label'] == 'Logistics') {
// //                 // TODO: hook this up to your Logistics flow, e.g.:
// //                 // Navigator.push(
// //                 //   context,
// //                 //   MaterialPageRoute(builder: (_) => const LogisticsScreen()),
// //                 // );
// //               }
// //             },
// //             child: AnimatedContainer(
// //               duration: const Duration(milliseconds: 200),
// //               curve: Curves.easeInOut,
// //               margin: EdgeInsets.only(right: 10.w),
// //               padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
// //               decoration: BoxDecoration(
// //                 // ignore: deprecated_member_use
// //                 color: isSelected ? Colors.white : Colors.white.withOpacity(0.16),
// //                 borderRadius: BorderRadius.only(
// //                   topLeft: Radius.circular(16.r),
// //                   topRight: Radius.circular(16.r),
// //                   bottomLeft: Radius.circular(4.r),
// //                   bottomRight: Radius.circular(4.r),
// //                 ),
// //                 boxShadow: isSelected
// //                     ? [
// //                   BoxShadow(
// //                     // ignore: deprecated_member_use
// //                     color: Colors.black.withOpacity(0.15),
// //                     blurRadius: 10,
// //                     offset: const Offset(0, 4),
// //                   ),
// //                 ]
// //                     : [],
// //               ),
// //               child: Column(
// //                 mainAxisSize: MainAxisSize.min,
// //                 children: [
// //                   Icon(
// //                     tab['icon'] as IconData,
// //                     size: 22.sp,
// //                     color: isSelected
// //                         ? restaurentsnewcolour.primary
// //                         : Colors.white,
// //                   ),
// //                   SizedBox(height: 4.h),
// //                   Text(
// //                     tab['label'] as String,
// //                     style: TextStyle(
// //                       fontSize: 12.sp,
// //                       fontWeight: FontWeight.w700,
// //                       color: isSelected
// //                           ? restaurentsnewcolour.primary
// //                           : Colors.white,
// //                     ),
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           );
// //         }),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCollapsedBar() {
// //     return Row(
// //       children: [
// //         /// 📍 Location Section
// //         Expanded(
// //           child: _buildLocationContent(
// //             isDark: true, // dark text
// //             isExpanded: false, // compact UI
// //           ),
// //         ),
// //
// //         SizedBox(width: 8.w),
// //
// //         /// 🔔 Notification Icon
// //         GestureDetector(
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (_) => NotificationScreen()),
// //             );
// //           },
// //           child: Container(
// //             width: 36.w,
// //             height: 36.w,
// //             decoration: BoxDecoration(
// //               // ignore: deprecated_member_use
// //               color: restaurentsnewcolour.primary.withOpacity(
// //                 0.1,
// //               ), // better visibility
// //               shape: BoxShape.circle,
// //             ),
// //             child: const Icon(
// //               Icons.notifications_none_rounded,
// //               color: restaurentsnewcolour.primary,
// //               size: 20,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildLocationContent({
// //     required bool isDark,
// //     required bool isExpanded,
// //   }) {
// //     return _isLoggedIn
// //         ? _buildAppBarContent(isDark: isDark, isExpanded: isExpanded)
// //         : _buildGuestAppBar(isDark: isDark, isExpanded: isExpanded);
// //   }
// //
// //   IconData _getCategoryIcon() {
// //     final cat = (_locationCategory ?? '').toLowerCase();
// //
// //     switch (cat) {
// //       case 'home':
// //         return Icons.home_rounded;
// //       case 'office':
// //         return Icons.work_rounded;
// //       case 'others':
// //         return Icons.work_rounded;
// //       default:
// //         return Icons.location_on_rounded;
// //     }
// //   }
// //
// //   Widget _buildAppBarContent({required bool isDark, required bool isExpanded}) {
// //     final color = isDark ? restaurentsnewcolour.text : Colors.white;
// //
// //     return GestureDetector(
// //       onTap: _changeLocation,
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Icon(_getCategoryIcon(), color: color, size: isExpanded ? 18 : 16),
// //           SizedBox(width: isExpanded ? 6.w : 4.w),
// //
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 /// 👇 Show only in expanded (Hero)
// //                 if (isExpanded)
// //                   Text(
// //                     (_locationCategory ?? 'Delivering to').replaceFirstMapped(
// //                       RegExp(r'^[a-z]'),
// //                           (m) => m.group(0)!.toUpperCase(),
// //                     ),
// //                     style: TextStyle(fontSize: 10.sp, color: Colors.grey),
// //                   ),
// //                 Text(
// //                   _currentLocation,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     fontSize: isExpanded ? 14.sp : 13.sp,
// //                     fontWeight: FontWeight.w700,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           Icon(
// //             Icons.keyboard_arrow_down_rounded,
// //             color: color,
// //             size: isExpanded ? 18 : 20,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildGuestAppBar({required bool isDark, required bool isExpanded}) {
// //     final color = isDark ? restaurentsnewcolour.text : Colors.white;
// //     final subColor = isDark ? restaurentsnewcolour.textMuted : Colors.white70;
// //
// //     return GestureDetector(
// //       onTap: () {
// //         // Navigate to login or location picker
// //       },
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           /// 👇 Show title only in expanded (banner)
// //           if (isExpanded)
// //             Text(
// //               "Current Location",
// //               style: TextStyle(
// //                 fontSize: 11.sp,
// //                 fontWeight: FontWeight.w800,
// //                 color: subColor,
// //               ),
// //             ),
// //
// //           if (isExpanded) SizedBox(height: 2.h),
// //
// //           /// 🔄 Loading State
// //           if (_isGuestLocationLoading)
// //             Row(
// //               children: [
// //                 Icon(
// //                   Icons.location_on_rounded,
// //                   color: color,
// //                   size: isExpanded ? 18 : 16,
// //                 ),
// //                 SizedBox(
// //                   width: isExpanded ? 14.w : 12.w,
// //                   height: isExpanded ? 14.w : 12.w,
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     color: color,
// //                   ),
// //                 ),
// //                 SizedBox(width: 6.w),
// //                 Text(
// //                   "Fetching location...",
// //                   style: TextStyle(
// //                     fontSize: isExpanded ? 12.sp : 11.sp,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             )
// //           /// 📍 Location State
// //           else
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                     _currentLocation.isNotEmpty
// //                         ? _currentLocation
// //                         : "Select Location",
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: TextStyle(
// //                       fontSize: isExpanded ? 13.sp : 12.sp,
// //                       fontWeight: FontWeight.w600,
// //                       color: color,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // FOOD CATEGORIES
// //   // ══════════════════════════════════════════════════════════════════════════
// //
// //   List<FoodCategory> get displayCategories {
// //     final list = List<FoodCategory>.from(categories);
// //
// //     final comboIndex = list.indexWhere(
// //           (e) => e.name.toLowerCase().contains('offers'),
// //     );
// //
// //     if (comboIndex > 0) {
// //       final comboItem = list.removeAt(comboIndex);
// //       list.insert(0, comboItem);
// //     }
// //
// //     return list;
// //   }
// //
// //   Widget _buildFoodCategories() {
// //     if (isCategoriesLoading) return const CategorySkeleton();
// //     if (categories.isEmpty) {
// //       return Center(
// //         child: Text(
// //           'No categories available',
// //           style: TextStyle(
// //             fontSize: 12.sp,
// //             color: restaurentsnewcolour.textMuted,
// //           ),
// //         ),
// //       );
// //     }
// //     //
// //     // final bool hasMore = categories.length > 10;
// //     // final int visibleCount = hasMore ? 10 : categories.length;
// //     final bool hasMore = displayCategories.length > 10;
// //     final int visibleCount = hasMore ? 10 : displayCategories.length;
// //     const double dia = 48.0;
// //
// //     return ListView.separated(
// //       scrollDirection: Axis.horizontal,
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// //       itemCount: visibleCount + 1 + (hasMore ? 1 : 0),
// //       separatorBuilder: (_, __) => SizedBox(width: 14.w),
// //       itemBuilder: (context, index) {
// //         final isAll = index == 0;
// //         final isViewAll = hasMore && index == visibleCount + 1;
// //         final isSelected = selectedCategoryIndex == index;
// //
// //         // final item = isAll ? null : categories[index -
// //         final item = isAll ? null : displayCategories[index - 1];
// //         if (isViewAll) {
// //           return _CategoryItem(
// //             dia: dia,
// //             isSelected: false,
// //             label: 'More',
// //             onTap: _showAllCategoriesBottomSheet,
// //             child: const Icon(
// //               Icons.grid_view_rounded,
// //               size: 22,
// //               color: restaurentsnewcolour.textMuted,
// //             ),
// //           );
// //         }
// //
// //         return _CategoryItem(
// //           dia: dia,
// //           isSelected: isSelected,
// //           label: isAll ? 'All' : item!.name,
// //           child: isAll
// //               ? Icon(
// //             Icons.grid_view_rounded,
// //             size: 22,
// //             color: isSelected
// //                 ? AppColors.primary
// //                 : restaurentsnewcolour.textMuted,
// //           )
// //               : (item!.image != null
// //           // ? Image.network(
// //           //     item.image!,
// //           //     // fit: BoxFit.cover,
// //           //     fit: BoxFit.fill,
// //           //     errorBuilder: (_, __, ___) =>
// //           //         const Icon(Icons.fastfood, size: 22),
// //           //   )
// //           // : const Icon(Icons.fastfood, size: 22)),
// //               ? CustomCachedImage(
// //             imageUrl: item.image,
// //             fit: BoxFit.fill,
// //             width: double.infinity,
// //             height: double.infinity,
// //             borderRadius: 0,
// //             isProfile: false,
// //           )
// //               : const Icon(Icons.fastfood, size: 22)),
// //           onTap: () => setState(() {
// //             selectedCategoryIndex = index;
// //             selectedCategoryVendorIds = isAll ? null : item!.vendorIds;
// //             selectedCategoryName = isAll ? null : item!.name;
// //           }),
// //         );
// //       },
// //     );
// //   }
// //
// //   void _showAllCategoriesBottomSheet() {
// //     showModalBottomSheet(
// //       backgroundColor: restaurentsnewcolour.surface,
// //       context: context,
// //       isScrollControlled: true,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //       ),
// //       builder: (ctx) {
// //         // final remaining = categories.skip(10).toList();
// //         final remaining = displayCategories.skip(10).toList();
// //         final sheetH = MediaQuery.of(ctx).size.height * 0.6;
// //         return PlatformSafeArea(
// //           child: Container(
// //             height: sheetH,
// //             padding: EdgeInsets.all(16.w),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Text(
// //                       'All Categories',
// //                       style: TextStyle(
// //                         fontSize: 16.sp,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     const Spacer(),
// //                     InkWell(
// //                       onTap: () => Navigator.pop(ctx),
// //                       borderRadius: BorderRadius.circular(20.r),
// //                       child: Container(
// //                         padding: EdgeInsets.all(6.w),
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           // color: restaurentsnewcolour.bg,
// //                           color: Colors.white,
// //                         ),
// //                         child: Icon(
// //                           Icons.close,
// //                           size: 20.sp,
// //                           color: restaurentsnewcolour.text,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 16.h),
// //                 Expanded(
// //                   child: GridView.builder(
// //                     itemCount: remaining.length,
// //                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                       crossAxisCount: 4,
// //                       crossAxisSpacing: 12.w,
// //                       mainAxisSpacing: 12.h,
// //                       childAspectRatio: 0.75,
// //                     ),
// //                     itemBuilder: (_, i) {
// //                       final item = remaining[i];
// //                       return InkWell(
// //                         onTap: () {
// //                           Navigator.pop(ctx);
// //                           setState(() {
// //                             // selectedCategoryIndex =
// //                             //     categories.indexOf(item) + 1;
// //                             selectedCategoryIndex =
// //                                 displayCategories.indexOf(item) + 1;
// //                             selectedCategoryVendorIds = item.vendorIds;
// //                             selectedCategoryName = item.name;
// //                           });
// //                         },
// //                         child: Column(
// //                           children: [
// //                             Container(
// //                               width: 56.h,
// //                               height: 56.h,
// //                               decoration: BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 color: restaurentsnewcolour.bg,
// //                               ),
// //                               child: ClipOval(
// //                                 child: item.image != null
// //                                     ? Image.network(
// //                                   item.image!,
// //                                   fit: BoxFit.cover,
// //                                   errorBuilder: (_, __, ___) =>
// //                                   const Icon(Icons.fastfood),
// //                                 )
// //                                     : const Icon(Icons.fastfood),
// //                               ),
// //                             ),
// //                             SizedBox(height: 6.h),
// //                             Text(
// //                               item.name,
// //                               textAlign: TextAlign.center,
// //                               maxLines: 2,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: TextStyle(
// //                                 fontSize: 10.sp,
// //                                 fontWeight: FontWeight.w600,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ORDER TYPE TABS
// //   // ══════════════════════════════════════════════════════════════════════════
// //
// //   Widget _buildOrderTypeTabs() {
// //     return ValueListenableBuilder<String?>(
// //       valueListenable: selectedOrderTypeNotifier,
// //       builder: (_, selected, __) {
// //         return AnimatedContainer(
// //           duration: const Duration(milliseconds: 200),
// //
// //           child: SingleChildScrollView(
// //             scrollDirection: Axis.horizontal,
// //             child: Row(
// //               children: RestaurentsHelper.orderTabs.map((tab) {
// //                 final type = tab['type'] as String;
// //                 final isSelected = selected == type;
// //
// //                 return GestureDetector(
// //                   onTap: () => _handleOrderTypeSelection(type),
// //                   child: AnimatedContainer(
// //                     duration: const Duration(milliseconds: 220),
// //                     curve: Curves.easeInOut,
// //                     margin: EdgeInsets.only(right: 8.w),
// //                     padding: EdgeInsets.symmetric(
// //                       horizontal: 14.w, // 👈 important for scroll look
// //                       vertical: 10.h,
// //                     ),
// //                     decoration: BoxDecoration(
// //                       // color: isSelected ? AppColors.primary : restaurentsnewcolour.surface,
// //                       color: isSelected ? Colors.green : AppColors.primary,
// //
// //                       borderRadius: BorderRadius.circular(10.r),
// //
// //                       boxShadow: isSelected
// //                           ? [
// //                         BoxShadow(
// //                           color: restaurentsnewcolour.green.withOpacity(
// //                             0.28,
// //                           ),
// //                           blurRadius: 12,
// //                           offset: const Offset(0, 4),
// //                         ),
// //                       ]
// //                           : [],
// //                     ),
// //                     child: Row(
// //                       mainAxisSize: MainAxisSize.min, // 👈 important
// //                       children: [
// //                         Icon(
// //                           tab['icon'] as IconData,
// //                           size: 16.sp,
// //                           color: isSelected ? Colors.white : Colors.white,
// //                         ),
// //                         SizedBox(width: 6.w),
// //                         Text(
// //                           tab['label'] as String,
// //                           style: TextStyle(
// //                             fontSize: 13.sp,
// //                             fontWeight: FontWeight.bold,
// //                             color: isSelected ? Colors.white : Colors.white,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ),
// //                 );
// //               }).toList(),
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // Widget _buildOrderTypeTabs() {
// //   //   return ValueListenableBuilder<String?>(
// //   //     valueListenable: selectedOrderTypeNotifier,
// //   //     builder: (_, selected, __) {
// //   //       final itemWidth = (MediaQuery.of(context).size.width - 48.w) / 3;
// //   //
// //   //       return Wrap(
// //   //         alignment: WrapAlignment.center, // 👈 add this
// //   //         spacing: 8.w,
// //   //         runSpacing: 10.h,
// //   //         children: RestaurentsHelper.orderTabs.map((tab) {
// //   //           final type = tab['type'] as String;
// //   //           final isSelected = selected == type;
// //   //
// //   //           return GestureDetector(
// //   //             onTap: () => _handleOrderTypeSelection(type),
// //   //             child: AnimatedContainer(
// //   //               duration: const Duration(milliseconds: 220),
// //   //               curve: Curves.easeInOut,
// //   //               width: itemWidth,
// //   //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
// //   //               decoration: BoxDecoration(
// //   //                 color: isSelected ? Colors.green : AppColors.primary,
// //   //                 borderRadius: BorderRadius.circular(12.r),
// //   //                 boxShadow: isSelected
// //   //                     ? [
// //   //                         BoxShadow(
// //   //                           color: restaurentsnewcolour.green.withOpacity(0.25),
// //   //                           blurRadius: 10,
// //   //                           offset: const Offset(0, 4),
// //   //                         ),
// //   //                       ]
// //   //                     : [],
// //   //               ),
// //   //               child: Row(
// //   //                 mainAxisAlignment: MainAxisAlignment.center,
// //   //                 children: [
// //   //                   Icon(
// //   //                     tab['icon'] as IconData,
// //   //                     size: 18.sp,
// //   //                     color: Colors.white,
// //   //                   ),
// //   //
// //   //                   SizedBox(width: 6.w),
// //   //
// //   //                   Flexible(
// //   //                     child: Text(
// //   //                       tab['label'] as String,
// //   //                       overflow: TextOverflow.ellipsis,
// //   //                       textAlign: TextAlign.center,
// //   //                       style: TextStyle(
// //   //                         fontSize: 12.sp,
// //   //                         fontWeight: FontWeight.bold,
// //   //                         color: Colors.white,
// //   //                       ),
// //   //                     ),
// //   //                   ),
// //   //                 ],
// //   //               ),
// //   //             ),
// //   //           );
// //   //         }).toList(),
// //   //       );
// //   //     },
// //   //   );
// //   // }
// //
// //   // ═══════════════════════════════════_handleOrderTypeSelection═══════════════════════════════════════
// //   // FILTER CHIPS
// //   // ══════════════════════════════════════════════════════════════════════════
// //
// //   Widget _buildFilterChips() {
// //     return ListView.separated(
// //       scrollDirection: Axis.horizontal,
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //       itemCount: RestaurentsHelper.filters.length,
// //       separatorBuilder: (_, __) => SizedBox(width: 8.w),
// //       itemBuilder: (_, i) {
// //         final f = RestaurentsHelper.filters[i];
// //         final isSelected = _activeFilterIndex == i;
// //         return GestureDetector(
// //           onTap: () {
// //             setState(() => _activeFilterIndex = isSelected ? -1 : i);
// //             if (f['label'] == 'Filters') _openFilterBottomSheet();
// //           },
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 180),
// //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //             decoration: BoxDecoration(
// //               color: isSelected
// //                   ? restaurentsnewcolour.text
// //                   : restaurentsnewcolour.surface,
// //               borderRadius: BorderRadius.circular(8.r),
// //               border: Border.all(
// //                 color: isSelected
// //                     ? restaurentsnewcolour.text
// //                     : restaurentsnewcolour.border,
// //                 width: 1.5,
// //               ),
// //             ),
// //             child: Row(
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 Icon(
// //                   f['icon'] as IconData,
// //                   size: 14.sp,
// //                   color: isSelected
// //                       ? Colors.white
// //                       : restaurentsnewcolour.textMuted,
// //                 ),
// //                 SizedBox(width: 5.w),
// //                 Text(
// //                   f['label'] as String,
// //                   style: TextStyle(
// //                     fontSize: 12.sp,
// //                     fontWeight: FontWeight.w600,
// //                     color: isSelected
// //                         ? Colors.white
// //                         : restaurentsnewcolour.textMuted,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // ── Offer strip ───────────────────────────────────────────────────────────
// //   Widget _buildOfferStrip() {
// //     return SizedBox(
// //       height: 68.h,
// //       child: ListView.separated(
// //         scrollDirection: Axis.horizontal,
// //         padding: EdgeInsets.symmetric(horizontal: 16.w),
// //         itemCount: RestaurentsHelper.offers.length,
// //         separatorBuilder: (_, __) => SizedBox(width: 10.w),
// //         itemBuilder: (_, i) {
// //           final o = RestaurentsHelper.offers[i];
// //           return Container(
// //             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [Color(o['c1'] as int), Color(o['c2'] as int)],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //               borderRadius: BorderRadius.circular(12.r),
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   o['title'] as String,
// //                   style: TextStyle(
// //                     fontSize: 13.sp,
// //                     fontWeight: FontWeight.w800,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //                 Text(
// //                   o['sub'] as String,
// //                   style: TextStyle(
// //                     fontSize: 10.sp,
// //                     color: Colors.white70,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   // ── Restaurant list ───────────────────────────────────────────────────────
// //   Widget _buildRestaurantList() {
// //     return AnimatedSwitcher(
// //       duration: const Duration(milliseconds: 250),
// //       child: selectedOrderType == 'catering'
// //           ? CateringsPage(key: const ValueKey('catering'))
// //           : NearbyRestaurentBannersWidget(
// //         key: ValueKey(
// //           '${_getApiOrderType()}-${selectedCategoryVendorIds?.join(',')}-$searchText-$_refreshKey',
// //         ),
// //         orderType: _getApiOrderType(),
// //         categoryVendorIds: selectedCategoryVendorIds,
// //         searchQuery: searchText,
// //         onOrderTypeRequired: _focusOrderTypeSelection,
// //         selectedCategoryName: selectedCategoryName,
// //       ),
// //     );
// //   }
// //
// //   // ── Update banner ─────────────────────────────────────────────────────────
// //   Widget _buildUpdateBanner() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: restaurentsnewcolour.surface,
// //         borderRadius: BorderRadius.circular(16.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 20.r,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //         border: Border.all(color: restaurentsnewcolour.border),
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.all(14.w),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 44.r,
// //                   height: 44.r,
// //                   decoration: BoxDecoration(
// //                     color: Colors.red.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(12.r),
// //                   ),
// //                   child: const Icon(
// //                     Icons.system_update_rounded,
// //                     color: Colors.red,
// //                     size: 24,
// //                   ),
// //                 ),
// //                 SizedBox(width: 12.w),
// //                 Expanded(
// //                   child: Text(
// //                     'New Update Available',
// //                     style: TextStyle(
// //                       fontSize: 15.sp,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Divider(height: 1, color: restaurentsnewcolour.border),
// //           TextButton(
// //             onPressed: _startFlexibleUpdate,
// //             style: TextButton.styleFrom(
// //               minimumSize: Size.fromHeight(48.h),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.only(
// //                   bottomLeft: Radius.circular(16.r),
// //                   bottomRight: Radius.circular(16.r),
// //                 ),
// //               ),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text(
// //                   'UPDATE NOW',
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     fontWeight: FontWeight.w700,
// //                     color: Colors.red,
// //                   ),
// //                 ),
// //                 SizedBox(width: 8.w),
// //                 const Icon(Icons.download_rounded, color: Colors.red, size: 18),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Filter bottom sheet ───────────────────────────────────────────────────
// //   void _openFilterBottomSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => FractionallySizedBox(
// //         heightFactor: 0.92,
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: restaurentsnewcolour.surface,
// //             borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //           ),
// //           child: const FilterBottomSheet(),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // CATEGORY ITEM  (small, reusable)
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _CategoryItem extends StatelessWidget {
// //   final double dia;
// //   final bool isSelected;
// //   final String label;
// //   final Widget child;
// //   final VoidCallback onTap;
// //
// //   const _CategoryItem({
// //     required this.dia,
// //     required this.isSelected,
// //     required this.label,
// //     required this.child,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           AnimatedContainer(
// //             duration: const Duration(milliseconds: 220),
// //             width: dia,
// //             height: dia,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: isSelected
// //                   ? restaurentsnewcolour.primaryLight
// //                   : restaurentsnewcolour.bg,
// //               border: isSelected
// //                   ? Border.all(color: AppColors.primary, width: 2)
// //                   : null,
// //             ),
// //             child: ClipOval(child: child),
// //           ),
// //           SizedBox(height: 4.h),
// //           SizedBox(
// //             width: dia + 8,
// //             child: Text(
// //               label,
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 10.sp,
// //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
// //                 color: isSelected
// //                     ? AppColors.primary
// //                     : restaurentsnewcolour.textMuted,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // SEARCH BAR  (white, used inside the sticky header)
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _SearchBar extends StatelessWidget {
// //   final ValueChanged<String> onChanged;
// //
// //   const _SearchBar({required this.onChanged});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       height: 44.h,
// //       width: double.infinity,
// //       child: TextField(
// //         onChanged: onChanged,
// //         textInputAction: TextInputAction.search,
// //         style: TextStyle(
// //           fontSize: 14.sp,
// //           color: restaurentsnewcolour.text,
// //           fontWeight: FontWeight.w500,
// //         ),
// //         cursorColor: restaurentsnewcolour.primary,
// //
// //         decoration: InputDecoration(
// //           hintText: 'Search restaurants, cuisines...',
// //
// //           // ✅ Makes it look like a container
// //           filled: true,
// //           fillColor: restaurentsnewcolour.bg,
// //
// //           // ✅ Rounded border like container
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: restaurentsnewcolour.border,
// //               width: 1.5,
// //             ),
// //           ),
// //
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: restaurentsnewcolour.border,
// //               width: 1.5,
// //             ),
// //           ),
// //
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: restaurentsnewcolour.primary,
// //               width: 1.5,
// //             ),
// //           ),
// //
// //           // ✅ Icon inside field
// //           prefixIcon: Icon(
// //             Icons.search_rounded,
// //             color: restaurentsnewcolour.textLight,
// //             size: 20.sp,
// //           ),
// //
// //           // spacing fix
// //           contentPadding: EdgeInsets.symmetric(vertical: 0),
// //
// //           hintStyle: TextStyle(
// //             color: restaurentsnewcolour.textLight,
// //             fontSize: 13.sp,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // NEARBY RESTAURANTS WIDGET
// // // ══════════════════════════════════════════════════════════════════════════════
// // class NearbyRestaurentBannersWidget extends StatefulWidget {
// //   final String? orderType;
// //   final List<int>? categoryVendorIds;
// //   final String? searchQuery;
// //   final VoidCallback? onOrderTypeRequired;
// //   final String? selectedCategoryName;
// //
// //   const NearbyRestaurentBannersWidget({
// //     super.key,
// //     this.orderType,
// //     this.categoryVendorIds,
// //     this.searchQuery,
// //     this.onOrderTypeRequired,
// //     this.selectedCategoryName,
// //   });
// //
// //   @override
// //   State<NearbyRestaurentBannersWidget> createState() =>
// //       _NearbyRestaurentBannersWidgetState();
// // }
// //
// // class _NearbyRestaurentBannersWidgetState
// //     extends State<NearbyRestaurentBannersWidget> {
// //   late Future<List<Restaurent_Banner>> _future;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _future = Authservice.fetchnearbyresturents();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<Restaurent_Banner>>(
// //       future: _future,
// //       builder: (_, snap) {
// //         if (snap.connectionState == ConnectionState.waiting) {
// //           return const RestaurantsSkeleton();
// //         }
// //         if (snap.hasError) {
// //           return _state(Icons.error_outline, 'Error loading restaurants');
// //         }
// //         if (!snap.hasData || snap.data!.isEmpty) {
// //           return _state(Icons.location_off, 'No nearby restaurants');
// //         }
// //
// //         final filtered = snap.data!.where((b) {
// //           final matchType =
// //               widget.orderType == null ||
// //                   b.orderTypes.contains(widget.orderType);
// //           final matchCat =
// //               widget.categoryVendorIds == null ||
// //                   widget.categoryVendorIds!.contains(b.vendorId);
// //           final matchSearch =
// //               (widget.searchQuery ?? '').trim().isEmpty ||
// //                   b.companyName.toLowerCase().contains(
// //                     widget.searchQuery!.toLowerCase(),
// //                   );
// //           return matchType && matchCat && matchSearch;
// //         }).toList();
// //         filtered.sort((a, b) {
// //           // Open restaurants first
// //           if (a.restaurantStatus != b.restaurantStatus) {
// //             return a.restaurantStatus ? -1 : 1;
// //           }
// //
// //           // Then top-rated restaurants
// //           final aRating = double.tryParse(a.ratings.toString()) ?? 0.0;
// //           final bRating = double.tryParse(b.ratings.toString()) ?? 0.0;
// //
// //           final aTopRated = aRating >= 4.0;
// //           final bTopRated = bRating >= 4.0;
// //
// //           if (aTopRated != bTopRated) {
// //             return bTopRated ? 1 : -1;
// //           }
// //
// //           // Finally by rating (highest first)
// //           return b.ratings.compareTo(a.ratings);
// //         });
// //         for (final r in filtered) {
// //           debugPrint("${r.companyName} -> ${r.ratings}");
// //         }
// //
// //         if (filtered.isEmpty) {
// //           return _state(Icons.search_off, 'No restaurants match your filter');
// //         }
// //
// //         return ListView.separated(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           padding: EdgeInsets.symmetric(horizontal: 16.w),
// //           itemCount: filtered.length,
// //           separatorBuilder: (_, __) => SizedBox(height: 14.h),
// //           itemBuilder: (_, i) => _RestaurantCard(
// //             banner: filtered[i],
// //             orderType: widget.orderType,
// //             onOrderTypeRequired: widget.onOrderTypeRequired,
// //             selectedCategoryName: widget.selectedCategoryName,
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _state(IconData icon, String msg) {
// //     return SizedBox(
// //       height: 200.h,
// //       child: Center(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(icon, size: 38.sp, color: restaurentsnewcolour.textLight),
// //             SizedBox(height: 10.h),
// //             Text(
// //               msg,
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 color: restaurentsnewcolour.textMuted,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // RESTAURANT CARD
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _RestaurantCard extends StatelessWidget {
// //   final Restaurent_Banner banner;
// //   final String? orderType;
// //   final VoidCallback? onOrderTypeRequired;
// //   final String? selectedCategoryName;
// //
// //   const _RestaurantCard({
// //     required this.banner,
// //     this.orderType,
// //     this.onOrderTypeRequired,
// //     this.selectedCategoryName,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenH = MediaQuery.of(context).size.height;
// //     // final double cardH = (screenH * 0.28).clamp(200.0, 260.0);
// //     final double cardH = (screenH * 0.30).clamp(220.0, 280.0);
// //     final double imgH = cardH * 0.58;
// //
// //     return GestureDetector(
// //       onTap:
// //       // banner.restaurantStatus
// //       //     ?
// //           () {
// //         if (orderType == null) {
// //           onOrderTypeRequired?.call();
// //           return;
// //         }
// //
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => MenuScreen(
// //               vendorId: banner.vendorId,
// //               initialCategoryName: selectedCategoryName,
// //               restaurantStatus: banner.restaurantStatus,
// //             ),
// //           ),
// //         );
// //       },
// //       // : null,
// //       child: IntrinsicHeight(
// //         child: ColorFiltered(
// //           colorFilter: banner.restaurantStatus
// //               ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
// //               : const ColorFilter.matrix(<double>[
// //             // Grayscale matrix
// //             0.2126, 0.7152, 0.0722, 0, 0,
// //             0.2126, 0.7152, 0.0722, 0, 0,
// //             0.2126, 0.7152, 0.0722, 0, 0,
// //             0, 0, 0, 1, 0,
// //           ]),
// //           child: Container(
// //             decoration: BoxDecoration(
// //               color: restaurentsnewcolour.surface,
// //               borderRadius: BorderRadius.circular(
// //                 restaurentsnewcolour.cardRadius.r,
// //               ),
// //               boxShadow: [
// //                 BoxShadow(
// //                   color: Colors.black.withOpacity(0.07),
// //                   blurRadius: 12,
// //                   offset: const Offset(0, 4),
// //                 ),
// //               ],
// //             ),
// //
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 // IMAGE
// //                 AspectRatio(
// //                   aspectRatio: 10 / 4,
// //                   child: Stack(
// //                     fit: StackFit.expand,
// //                     children: [
// //                       ClipRRect(
// //                         borderRadius: BorderRadius.vertical(
// //                           top: Radius.circular(
// //                             restaurentsnewcolour.cardRadius.r,
// //                           ),
// //                         ),
// //                         // child: banner.companyBanner.isNotEmpty
// //                         //     ? Image.network(
// //                         //         banner.companyBanner,
// //                         //         // fit: BoxFit.cover,
// //                         //         fit: BoxFit.fill,
// //                         //
// //                         //         errorBuilder: (_, __, ___) => _placeholder(),
// //                         //       )
// //                         //     : _placeholder(),
// //                         child: banner.companyBanner.isNotEmpty
// //                             ? CustomCachedImage(
// //                           imageUrl: banner.companyBanner,
// //                           fit: BoxFit.fill,
// //                           width: double.infinity,
// //                           height: double.infinity,
// //                           borderRadius: 0,
// //                           isProfile: false,
// //                         )
// //                             : _placeholder(),
// //                       ),
// //                       if (!banner.restaurantStatus)
// //                         Positioned.fill(
// //                           child: Container(
// //                             color: Colors.black.withOpacity(0.35),
// //                           ),
// //                         ),
// //
// //                       if (!banner.restaurantStatus)
// //                         const Center(
// //                           child: Text(
// //                             "Currently Closed",
// //                             style: TextStyle(
// //                               color: Colors.white,
// //                               fontWeight: FontWeight.bold,
// //                               fontSize: 22,
// //                               letterSpacing: 2,
// //                             ),
// //                           ),
// //                         ),
// //
// //                       Positioned(
// //                         bottom: 0,
// //                         left: 0,
// //                         right: 0,
// //                         height: 60,
// //                         child: const DecoratedBox(
// //                           decoration: BoxDecoration(
// //                             gradient: LinearGradient(
// //                               begin: Alignment.topCenter,
// //                               end: Alignment.bottomCenter,
// //                               colors: [Colors.transparent, Color(0x66000000)],
// //                             ),
// //                           ),
// //                         ),
// //                       ),
// //
// //                       if ((banner.ratings) >= 4.0)
// //                         Positioned(
// //                           top: 8,
// //                           left: 10,
// //                           child: Container(
// //                             padding: const EdgeInsets.symmetric(
// //                               horizontal: 8,
// //                               vertical: 3,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: Colors.white,
// //                               borderRadius: BorderRadius.circular(6),
// //                             ),
// //                             child: Row(
// //                               mainAxisSize: MainAxisSize.min,
// //                               children: [
// //                                 Icon(
// //                                   Icons.star_rounded,
// //                                   color: restaurentsnewcolour.primary,
// //                                   size: 11,
// //                                 ),
// //                                 SizedBox(width: 3),
// //                                 Text(
// //                                   'Top Rated',
// //                                   style: TextStyle(
// //                                     fontSize: 10,
// //                                     fontWeight: FontWeight.w700,
// //                                     color: restaurentsnewcolour.primary,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ),
// //                     ],
// //                   ),
// //                 ),
// //
// //                 // INFO
// //                 Padding(
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: 12.w,
// //                     vertical: 10.h,
// //                   ),
// //                   child: Column(
// //                     crossAxisAlignment: CrossAxisAlignment.start,
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Row(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Expanded(
// //                             child: Wrap(
// //                               crossAxisAlignment: WrapCrossAlignment.center,
// //                               children: [
// //                                 Text(
// //                                   banner.companyName.toUpperCase(),
// //                                   maxLines: 2,
// //                                   overflow: TextOverflow.ellipsis,
// //                                   style: TextStyle(
// //                                     fontSize: 14.sp,
// //                                     fontWeight: FontWeight.w700,
// //                                     color: restaurentsnewcolour.text,
// //                                   ),
// //                                 ),
// //
// //                                 _dot(),
// //
// //                                 Text(
// //                                   banner.type,
// //                                   style: TextStyle(
// //                                     fontSize: 14.sp,
// //                                     fontWeight: FontWeight.w600,
// //                                     color: restaurentsnewcolour.text,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //
// //                           if ((banner.ratings) > 0) ...[
// //                             SizedBox(width: 8.w),
// //
// //                             Container(
// //                               padding: EdgeInsets.symmetric(
// //                                 horizontal: 6.w,
// //                                 vertical: 3.h,
// //                               ),
// //                               decoration: BoxDecoration(
// //                                 color: restaurentsnewcolour.green,
// //                                 borderRadius: BorderRadius.circular(6.r),
// //                               ),
// //                               child: Row(
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   const Icon(
// //                                     Icons.star_rounded,
// //                                     color: Colors.white,
// //                                     size: 11,
// //                                   ),
// //                                   SizedBox(width: 2.w),
// //                                   Text(
// //                                     banner.ratings.toString(),
// //                                     style: TextStyle(
// //                                       color: Colors.white,
// //                                       fontSize: 11.sp,
// //                                       fontWeight: FontWeight.w700,
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ],
// //                         ],
// //                       ),
// //
// //                       SizedBox(height: 4.h),
// //
// //                       if (banner.position.isNotEmpty)
// //                         Text(
// //                           '${banner.position[0].toUpperCase()}${banner.position.substring(1).toLowerCase()}',
// //                           maxLines: 1,
// //                           overflow: TextOverflow.ellipsis,
// //                           style: TextStyle(
// //                             fontSize: 11.sp,
// //                             color: const Color(0xFF6C63FF),
// //                             fontWeight: FontWeight.w600,
// //                           ),
// //                         ),
// //
// //                       SizedBox(height: 6.h),
// //
// //                       Row(
// //                         crossAxisAlignment: CrossAxisAlignment.start,
// //                         children: [
// //                           Expanded(
// //                             child: Text(
// //                               '${banner.addressLine}, ${banner.city}',
// //                               maxLines: 2,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: TextStyle(
// //                                 fontSize: 11.sp,
// //                                 color: restaurentsnewcolour.textLight,
// //                               ),
// //                             ),
// //                           ),
// //
// //                           SizedBox(width: 8.w),
// //
// //                           Text(
// //                             Distancehelpermethod.formatDistance(
// //                               banner.distance,
// //                             ),
// //                             style: TextStyle(
// //                               fontSize: 12.sp,
// //                               fontWeight: FontWeight.w600,
// //                               color: restaurentsnewcolour.textMuted,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _dot() => Padding(
// //     padding: EdgeInsets.symmetric(horizontal: 5.w),
// //     child: Container(
// //       width: 3,
// //       height: 3,
// //       decoration: const BoxDecoration(
// //         color: restaurentsnewcolour.textLight,
// //         shape: BoxShape.circle,
// //       ),
// //     ),
// //   );
// //
// //   Widget _placeholder() => Container(
// //     color: restaurentsnewcolour.bg,
// //     child: Center(
// //       child: Icon(
// //         Icons.restaurant_rounded,
// //         size: 32.sp,
// //         color: restaurentsnewcolour.textLight,
// //       ),
// //     ),
// //   );
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // STICKY SLIVER DELEGATE
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _StickyDelegate extends SliverPersistentHeaderDelegate {
// //   final double height;
// //   final Widget child;
// //
// //   const _StickyDelegate({required this.height, required this.child});
// //
// //   @override
// //   double get minExtent => height;
// //   @override
// //   double get maxExtent => height;
// //
// //   @override
// //   Widget build(BuildContext ctx, double shrink, bool overlaps) =>
// //       SizedBox.expand(child: child);
// //
// //   @override
// //   bool shouldRebuild(covariant _StickyDelegate old) =>
// //       height != old.height || child != old.child;
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // FILTER BOTTOM SHEET
// // // ══════════════════════════════════════════════════════════════════════════════
// // class FilterBottomSheet extends StatefulWidget {
// //   final int initialTab;
// //   const FilterBottomSheet({super.key, this.initialTab = 0});
// //
// //   @override
// //   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// // }
// //
// // class _FilterBottomSheetState extends State<FilterBottomSheet> {
// //   int _sel = 0;
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         _header(),
// //         Expanded(
// //           child: Row(
// //             children: [
// //               _leftMenu(),
// //               Expanded(child: _rightContent()),
// //             ],
// //           ),
// //         ),
// //         _footer(),
// //       ],
// //     );
// //   }
// //
// //   Widget _header() => Padding(
// //     padding: EdgeInsets.all(16.w),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           'Filters & Sorting',
// //           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
// //         ),
// //         GestureDetector(
// //           onTap: () => setState(() => _sel = 0),
// //           child: Text(
// //             'Clear all',
// //             style: TextStyle(
// //               fontSize: 13.sp,
// //               color: restaurentsnewcolour.green,
// //               fontWeight: FontWeight.w600,
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   Widget _leftMenu() => Container(
// //     width: 90.w,
// //     color: restaurentsnewcolour.bg,
// //     child: ListView.builder(
// //       itemCount: RestaurentsHelper.menu.length,
// //       itemBuilder: (_, i) {
// //         final sel = _sel == i;
// //         return InkWell(
// //           onTap: () => setState(() => _sel = i),
// //           child: Container(
// //             padding: EdgeInsets.all(14.w),
// //             decoration: BoxDecoration(
// //               color: sel ? restaurentsnewcolour.surface : Colors.transparent,
// //               border: Border(
// //                 left: BorderSide(
// //                   color: sel
// //                       ? restaurentsnewcolour.primary
// //                       : Colors.transparent,
// //                   width: 3,
// //                 ),
// //               ),
// //             ),
// //             child: Text(
// //               RestaurentsHelper.menu[i],
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
// //                 color: sel
// //                     ? restaurentsnewcolour.text
// //                     : restaurentsnewcolour.textMuted,
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     ),
// //   );
// //
// //   Widget _rightContent() {
// //     switch (_sel) {
// //       case 0:
// //         return _panel('Time', [
// //           _chip(Icons.schedule_rounded, 'Schedule'),
// //           _chip(Icons.flash_on_rounded, 'Near & Fast'),
// //         ]);
// //       case 1:
// //         return _panel('Restaurant Rating', [
// //           _chip(Icons.star_rounded, 'Rated 3.5+'),
// //           _chip(Icons.star_rounded, 'Rated 4.0+'),
// //         ]);
// //       case 2:
// //         return _panel('Offers', [
// //           _chip(Icons.local_offer_rounded, 'Buy 1 Get 1'),
// //           _chip(Icons.percent_rounded, 'Deals of the Day'),
// //         ]);
// //       case 3:
// //         return _panel('Dish Price', [
// //           _chip(Icons.currency_rupee_rounded, 'Under ₹150'),
// //           _chip(Icons.currency_rupee_rounded, 'Under ₹250'),
// //           _chip(Icons.currency_rupee_rounded, 'Under ₹500'),
// //         ]);
// //       case 4:
// //         return _panel('Trust Markers', [
// //           _chip(Icons.verified_rounded, 'Hygiene Rated'),
// //           _chip(Icons.verified_user_rounded, 'Trusted Seller'),
// //         ]);
// //       default:
// //         return const SizedBox.shrink();
// //     }
// //   }
// //
// //   Widget _panel(String title, List<Widget> chips) => Padding(
// //     padding: EdgeInsets.all(16.w),
// //     child: Column(
// //       crossAxisAlignment: CrossAxisAlignment.start,
// //       children: [
// //         Text(
// //           title,
// //           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
// //         ),
// //         SizedBox(height: 14.h),
// //         Wrap(spacing: 10.w, runSpacing: 10.h, children: chips),
// //       ],
// //     ),
// //   );
// //
// //   Widget _chip(IconData icon, String label) => Container(
// //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
// //     decoration: BoxDecoration(
// //       border: Border.all(color: restaurentsnewcolour.border, width: 1.5),
// //       borderRadius: BorderRadius.circular(10.r),
// //       color: restaurentsnewcolour.surface,
// //     ),
// //     child: Row(
// //       mainAxisSize: MainAxisSize.min,
// //       children: [
// //         Icon(icon, size: 14.sp, color: restaurentsnewcolour.green),
// //         SizedBox(width: 6.w),
// //         Text(
// //           label,
// //           style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
// //         ),
// //       ],
// //     ),
// //   );
// //
// //   Widget _footer() => Padding(
// //     padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
// //     child: Row(
// //       children: [
// //         Expanded(
// //           child: OutlinedButton(
// //             onPressed: () => Navigator.pop(context),
// //             style: OutlinedButton.styleFrom(
// //               side: BorderSide(color: restaurentsnewcolour.border),
// //               padding: EdgeInsets.symmetric(vertical: 12.h),
// //             ),
// //             child: const Text('Close'),
// //           ),
// //         ),
// //         SizedBox(width: 12.w),
// //         Expanded(
// //           child: ElevatedButton(
// //             onPressed: () => Navigator.pop(context),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: restaurentsnewcolour.primary,
// //               foregroundColor: Colors.white,
// //               padding: EdgeInsets.symmetric(vertical: 12.h),
// //             ),
// //             child: const Text('Show results'),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // SEARCH BAR HEADER DELEGATE  (kept for external compatibility)
// // // ══════════════════════════════════════════════════════════════════════════════
// // class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
// //   final ValueChanged<String> onSearchChanged;
// //   final VoidCallback? onFilterPressed;
// //   final double height;
// //
// //   const SearchBarHeaderDelegate({
// //     required this.onSearchChanged,
// //     required this.height,
// //     this.onFilterPressed,
// //   });
// //
// //   @override
// //   double get minExtent => height;
// //   @override
// //   double get maxExtent => height;
// //
// //   @override
// //   Widget build(BuildContext ctx, double shrink, bool overlaps) {
// //     return Container(
// //       color: restaurentsnewcolour.surface,
// //       padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
// //       child: _SearchBar(onChanged: onSearchChanged),
// //     );
// //   }
// //
// //   @override
// //   bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
// // }
//
// // import 'dart:async';
// // import '../../../Services/appconfigurations/app_configurtion_service.dart';
// // import '../../../widgets/widgets/couponcards.dart';
// // import '../Menu/menu_screen.dart';
// // import '../Menu/menuscreen.dart';
// // import '../distancehelpermethod.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart';
// // import 'package:flutter/foundation.dart';
// // import '../../screens/notifications.dart';
// // import '../../screens/saved_address.dart';
// // import '../../skeleton/Restaurents_screen.dart';
// // import '../../Catering&Services/Caterings.dart';
// // import 'package:in_app_update/in_app_update.dart';
// // import '../../screens/advertisements/Advideo.dart';
// // import '../../../Models/food/food_categries_model.dart';
// // import '../../../Models/food/restaurent_banner_model.dart';
// // import 'package:flutter_screenutil/flutter_screenutil.dart';
// // import '../../../Services/App_color_service/app_colours.dart';
// // import '../../../Services/Auth_service/food_authservice.dart';
// // import '../../screens/advertisements/banneradvertisement.dart';
// // import '../../../Services/googleservices/Location_servces.dart';
// // import '../../../Models/promotions_model/promotions_model.dart';
// // import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// // import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
// // import '../../../Services/Auth_service/Subscription_authservice.dart';
// // import '../../../Services/Auth_service/promotion_services_Authservice.dart';
// // import 'package:maamaas/screens/Food&beverages/RestaurentsScreen/RestaurentsHelper.dart';
// //
// // class Restaurents extends StatefulWidget {
// //   final ScrollController scrollController;
// //   const Restaurents({super.key, required this.scrollController});
// //
// //   @override
// //   // ignore: library_private_types_in_public_api
// //   _RestaurentsState createState() => _RestaurentsState();
// // }
// //
// // class _RestaurentsState extends State<Restaurents> {
// //   // ── State ──────────────────────────────────────────────────────────────────
// //   String _currentLocation = 'Fetching location...';
// //   bool _updateAvailable = false;
// //   AppUpdateInfo? _updateInfo;
// //   String? selectedOrderType;
// //   bool _isBannerCollapsed = false;
// //   List<FoodCategory> categories = [];
// //   bool isCategoriesLoading = true;
// //   int selectedCategoryIndex = 0;
// //   List<int>? selectedCategoryVendorIds;
// //   String? selectedCategoryName;
// //   String searchText = '';
// //   Timer? _debounce;
// //   bool _isLoggedIn = false;
// //   bool _isGuestLocationLoading = false;
// //   int _activeFilterIndex = -1;
// //   List<Campaign> homepageAds = [];
// //   bool _highlightOrderTabs = false;
// //   bool _showOrderTypeHint = false;
// //   final ValueNotifier<String?> selectedOrderTypeNotifier = ValueNotifier(null);
// //
// //   final GlobalKey _orderTypeKey = GlobalKey();
// //   bool _hasShownLocationDialog = false;
// //
// //   int _refreshKey = 0;
// //   String? _locationCategory;
// //
// //   // ── Banner height ──────────────────────────────────────────────────────────
// //   double get _bannerHeight {
// //     final h = MediaQuery.of(context).size.height;
// //     return (h * 0.70).clamp(250.0, 350.0);
// //   }
// //
// //   // ── Lifecycle ──────────────────────────────────────────────────────────────
// //   @override
// //   void initState() {
// //     super.initState();
// //     widget.scrollController.addListener(_onScroll);
// //     _checkLogin().then((_) {
// //       if (_isLoggedIn) {
// //         _loadLocationFromAPI();
// //       } else {
// //         _loadGuestLocation();
// //       }
// //     });
// //     if (kReleaseMode) {
// //       _checkForUpdate();
// //     }
// //     _fetchCategories();
// //     _checkLogin();
// //     _loadAds();
// //   }
// //
// //   @override
// //   void dispose() {
// //     _debounce?.cancel();
// //     widget.scrollController.removeListener(_onScroll);
// //     selectedOrderTypeNotifier.dispose();
// //     super.dispose();
// //   }
// //
// //   // ── Scroll listener ────────────────────────────────────────────────────────
// //   void _onScroll() {
// //     final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
// //     final collapsed = widget.scrollController.offset > collapseThreshold;
// //     if (collapsed != _isBannerCollapsed && mounted) {
// //       setState(() => _isBannerCollapsed = collapsed);
// //     }
// //   }
// //
// //   // ── Auth / Location ────────────────────────────────────────────────────────
// //   Future<void> _checkLogin() async {
// //     final v = await subscription_AuthService.isLoggedIn();
// //     if (mounted) setState(() => _isLoggedIn = v);
// //   }
// //
// //   Future<void> _loadGuestLocation() async {
// //     setState(() => _isGuestLocationLoading = true);
// //     try {
// //       final r = await LocationService.getCurrentLocationWithAddress();
// //       if (!mounted) return;
// //       if (r != null) {
// //         final parts = [
// //           r.area,
// //           r.adminArea,
// //           r.city,
// //           r.state,
// //         ].where((e) => e != null && e.isNotEmpty).toList();
// //         final addr = parts.join(', ');
// //         setState(() {
// //           _currentLocation = (r.pincode != null && r.pincode!.isNotEmpty)
// //               ? '$addr - ${r.pincode}'
// //               : addr;
// //         });
// //       } else {
// //         setState(() => _currentLocation = 'Enable location');
// //       }
// //     } catch (e) {
// //       //       debugPrint('Guest location error: $e');
// //       if (mounted) setState(() => _currentLocation = 'Location unavailable');
// //     } finally {
// //       if (mounted) setState(() => _isGuestLocationLoading = false);
// //     }
// //   }
// //
// //   Future<void> _loadLocationFromAPI() async {
// //     try {
// //       final loc = await subscription_AuthService.fetchCurrentLocation();
// //
// //       if (!mounted) return;
// //
// //       // print("📍 RAW LOC: $loc");
// //       // print("📍 ADDRESS CHECK: ${loc?.address}");
// //       // print("📍 VALID: ${loc?.address.trim().isNotEmpty}");
// //
// //       // ✅ VALID LOCATION CHECK
// //       final isValidLocation = loc != null && loc.address.trim().isNotEmpty;
// //
// //       if (isValidLocation) {
// //         setState(() {
// //           _currentLocation = loc.address;
// //           _locationCategory = loc.category;
// //         });
// //
// //         // ✅ Reset dialog flag (important if user later deletes address)
// //         _hasShownLocationDialog = false;
// //       } else {
// //         _handleInvalidLocation();
// //       }
// //     } catch (e) {
// //       //       debugPrint("❌ Location API Error: $e");
// //       if (!mounted) return;
// //
// //       _handleInvalidLocation();
// //     }
// //   }
// //
// //   void _handleInvalidLocation() {
// //     // ❌ Don't immediately show popup
// //     Future.delayed(const Duration(milliseconds: 500), () {
// //       if (!mounted) return;
// //
// //       if (_currentLocation == 'Fetching location...') {
// //         if (!_hasShownLocationDialog) {
// //           _hasShownLocationDialog = true;
// //
// //           WidgetsBinding.instance.addPostFrameCallback((_) {
// //             if (mounted) {
// //               _showUpdateLocationDialog();
// //             }
// //           });
// //         }
// //       }
// //     });
// //   }
// //
// //   void _showUpdateLocationDialog() {
// //     showDialog(
// //       context: context,
// //       barrierDismissible: false,
// //       builder: (_) => AlertDialog(
// //         shape: RoundedRectangleBorder(
// //           borderRadius: BorderRadius.circular(16.r),
// //         ),
// //         title: Row(
// //           children: [
// //             const Icon(Icons.location_off, color: Colors.red),
// //             SizedBox(width: 8.w),
// //             Text('Location Required', style: TextStyle(fontSize: 16.sp)),
// //           ],
// //         ),
// //         content: Text(
// //           "We couldn't detect your location. Please update to continue.",
// //           style: TextStyle(fontSize: 13.sp),
// //         ),
// //         actions: [
// //           ElevatedButton(
// //             onPressed: () {
// //               Navigator.pop(context);
// //               _changeLocation();
// //             },
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: restaurentsnewcolour.primary,
// //               foregroundColor: Colors.white,
// //             ),
// //             child: const Text('Update Location'),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   void _changeLocation() {
// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => SavedAddress(
// //           onAddressSelected: (address) async {
// //             setState(() {
// //               // _currentLocation =
// //               //     '${address.},${address.city}, ${address.state} - ${address.pincode}';
// //               // _locationCategory = address.category;
// //               _currentLocation = address.fullAddress;
// //
// //               // print("Category: ${address.category}");
// //             });
// //             _hasShownLocationDialog = false;
// //             await _refreshAll();
// //           },
// //         ),
// //       ),
// //     );
// //   }
// //
// //   // ── Data ───────────────────────────────────────────────────────────────────
// //   Future<void> _fetchCategories() async {
// //     setState(() => isCategoriesLoading = true);
// //     try {
// //       final res = await Authservice.fetchFoodCategories();
// //       if (!mounted) return;
// //       setState(() {
// //         categories = res;
// //         selectedCategoryIndex = 0;
// //         selectedCategoryVendorIds = null;
// //       });
// //     } catch (e) {
// //       //       debugPrint('Category error: $e');
// //       if (mounted) setState(() => categories = []);
// //     } finally {
// //       if (mounted) setState(() => isCategoriesLoading = false);
// //     }
// //   }
// //
// //   Future<void> _loadAds() async {
// //     try {
// //       final result = await promotion_Authservice.fetchcampaign();
// //       final filtered = result
// //           .where(
// //             (c) =>
// //                 c.addDisplayPosition == AddDisplayPosition.HOMEPAGE_BANNER &&
// //                 c.medium == Medium.APP,
// //           )
// //           .toList();
// //       if (mounted) setState(() => homepageAds = filtered);
// //     } catch (e) {
// //       //       debugPrint('Ads error: $e');
// //     }
// //   }
// //
// //   Future<void> _refreshAll() async {
// //     //     debugPrint("🔄 _refreshAll() STARTED");
// //
// //     try {
// //       await Future.wait([_fetchCategories(), _loadAds()]);
// //       //
// //       //       debugPrint("✅ APIs completed successfully");
// //     } catch (e) {
// //       //       debugPrint("❌ Error in _refreshAll(): $e");
// //     }
// //
// //     if (mounted) {
// //       setState(() {
// //         _refreshKey++;
// //       });
// //       //       debugPrint("🔁 UI refreshed, refreshKey: $_refreshKey");
// //     } else {
// //       //       debugPrint("⚠️ Widget not mounted, skipping setState");
// //     }
// //     //
// //     //     debugPrint("🏁 _refreshAll() FINISHED");
// //   }
// //
// //   // ── Update ─────────────────────────────────────────────────────────────────
// //   Future<void> _checkForUpdate() async {
// //     try {
// //       final info = await InAppUpdate.checkForUpdate();
// //       if (!mounted) return;
// //       setState(() {
// //         _updateInfo = info;
// //         _updateAvailable =
// //             info.updateAvailability == UpdateAvailability.updateAvailable;
// //       });
// //     } catch (e) {
// //       //       debugPrint('Update check failed: $e');
// //     }
// //   }
// //
// //   void _startFlexibleUpdate() async {
// //     if (_updateInfo != null) {
// //       try {
// //         await InAppUpdate.performImmediateUpdate();
// //       } catch (e) {
// //         //         debugPrint('Update error: $e');
// //       }
// //     }
// //   }
// //
// //   // ── Order type ─────────────────────────────────────────────────────────────
// //
// //   String? _getApiOrderType() {
// //     if (selectedOrderType == null) return null;
// //
// //     final raw = selectedOrderType!;
// //     final normalized = raw.toLowerCase().trim();
// //
// //     final mapped = RestaurentsHelper.typeMapping[normalized];
// //     //
// //     //     debugPrint("📦 API Type: $mapped");
// //
// //     return mapped;
// //   }
// //
// //   Future<void> _handleOrderTypeSelection(String type) async {
// //     final cleanType = type.toLowerCase().trim();
// //
// //     /// ✅ 👉 HANDLE CATERING LOCALLY
// //     if (cleanType == "catering") {
// //       if (!mounted) return;
// //
// //       setState(() {
// //         selectedOrderType = cleanType;
// //       });
// //
// //       selectedOrderTypeNotifier.value = cleanType;
// //
// //       // print("🎯 Catering selected → No API call");
// //       return; // 🚫 STOP HERE
// //     }
// //
// //     /// ✅ OTHER TYPES → CALL API
// //     final api = RestaurentsHelper.typeMapping[cleanType];
// //
// //     if (api == null) {
// //       //       debugPrint("❌ Mapping failed for: $cleanType");
// //       return;
// //     }
// //
// //     // print("🚀 Trying to create cart for: $cleanType");
// //
// //     final result = await food_Authservice.createCart(api);
// //
// //     if (result["success"] == true) {
// //       if (!mounted) return;
// //
// //       setState(() {
// //         selectedOrderType = cleanType;
// //       });
// //
// //       selectedOrderTypeNotifier.value = cleanType;
// //     } else {
// //       final message = result["message"] ?? "Something went wrong";
// //
// //       if (!mounted) return;
// //       AppAlert.error(context, message);
// //     }
// //   }
// //
// //   void _focusOrderTypeSelection() {
// //     final context = _orderTypeKey.currentContext;
// //
// //     if (context != null) {
// //       Scrollable.ensureVisible(
// //         context,
// //         duration: const Duration(milliseconds: 500),
// //         curve: Curves.easeInOut,
// //         alignment: 0.1, // 👈 keeps it slightly below top
// //       );
// //     }
// //
// //     setState(() {
// //       _highlightOrderTabs = true;
// //       _showOrderTypeHint = true;
// //     });
// //
// //     Future.delayed(const Duration(seconds: 2), () {
// //       if (mounted) setState(() => _highlightOrderTabs = false);
// //     });
// //
// //     Future.delayed(const Duration(seconds: 3), () {
// //       if (mounted) setState(() => _showOrderTypeHint = false);
// //     });
// //   }
// //
// //   // ── Debounce search ────────────────────────────────────────────────────────
// //   void _onSearchChanged(String value) {
// //     _debounce?.cancel();
// //     _debounce = Timer(const Duration(milliseconds: 400), () {
// //       if (mounted) setState(() => searchText = value);
// //     });
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // BUILD
// //   // ══════════════════════════════════════════════════════════════════════════
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       // backgroundColor: restaurentsnewcolour.bg,
// //       backgroundColor: Colors.white,
// //       extendBodyBehindAppBar: false,
// //       body: RefreshIndicator(
// //         strokeWidth: 2,
// //         color: restaurentsnewcolour.primary,
// //         backgroundColor: restaurentsnewcolour.surface,
// //         onRefresh: _refreshAll,
// //         child: Stack(
// //           children: [
// //             CustomScrollView(
// //               controller: widget.scrollController,
// //               physics: const AlwaysScrollableScrollPhysics(),
// //               slivers: [
// //                 SliverAppBar(
// //                   expandedHeight: _bannerHeight,
// //                   collapsedHeight: kToolbarHeight,
// //                   pinned: true,
// //                   elevation: 0,
// //                   scrolledUnderElevation: 0,
// //
// //                   backgroundColor: _isBannerCollapsed
// //                       ? restaurentsnewcolour.surface
// //                       : Colors.transparent,
// //
// //                   systemOverlayStyle: _isBannerCollapsed
// //                       ? SystemUiOverlayStyle.dark
// //                       : SystemUiOverlayStyle.light,
// //
// //                   automaticallyImplyLeading: false,
// //
// //                   title: _isBannerCollapsed ? _buildCollapsedBar() : null,
// //                   flexibleSpace: FlexibleSpaceBar(
// //                     collapseMode: CollapseMode.pin,
// //                     background: _buildHeroBanner(),
// //                   ),
// //                 ),
// //
// //                 // ── 2. Sticky search bar ────────────────────────────────
// //                 if (selectedOrderType != 'catering')
// //                   SliverPersistentHeader(
// //                     pinned: true,
// //                     delegate: _StickyDelegate(
// //                       height: 70.h, // ✅ FIXED
// //                       child: Container(
// //                         color: restaurentsnewcolour.surface,
// //                         child: Column(
// //                           children: [
// //                             Padding(
// //                               padding: EdgeInsets.symmetric(
// //                                 horizontal: 16.w,
// //                                 vertical: 10.h,
// //                               ),
// //                               child: SizedBox(
// //                                 width: double.infinity,
// //                                 child: _SearchBar(onChanged: _onSearchChanged),
// //                               ),
// //                             ),
// //                             // Divider(height: 1, color: restaurentsnewcolour.border),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //                 // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
// //
// //                 // ── 3. Coupon offers ────────────────────────────────────
// //                 SliverToBoxAdapter(child: CouponsOffersSection()),
// //
// //                 // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
// //
// //                 // ── 4. Divider ──────────────────────────────────────────
// //                 // SliverToBoxAdapter(child: _Divider()),
// //
// //                 // ── 5. Food categories ──────────────────────────────────
// //                 if (selectedOrderType != 'catering')
// //                   SliverPersistentHeader(
// //                     pinned: true,
// //                     delegate: _StickyDelegate(
// //                       height: 120.h,
// //                       // height: 95.h,
// //                       child: Container(
// //                         color: restaurentsnewcolour.surface,
// //                         child: Column(
// //                           crossAxisAlignment: CrossAxisAlignment.start,
// //                           children: [
// //                             Padding(
// //                               // padding: EdgeInsets.fromLTRB(16.w, 10.h, 0, 6.h),
// //                               padding: EdgeInsets.fromLTRB(
// //                                 16.w,
// //                                 4.h, // reduced from 10.h
// //                                 0,
// //                                 4.h, // reduced from 6.h
// //                               ),
// //                               child: Text(
// //                                 "What's on your mind?",
// //                                 style: TextStyle(
// //                                   fontSize: 16.sp,
// //                                   fontWeight: FontWeight.w700,
// //                                   color: restaurentsnewcolour.text,
// //                                 ),
// //                               ),
// //                             ),
// //                             Expanded(child: _buildFoodCategories()),
// //                           ],
// //                         ),
// //                       ),
// //                     ),
// //                   ),
// //
// //                 // SliverToBoxAdapter(child: _Divider()),
// //
// //                 // ── 6. Order type tabs (sticky) ─────────────────────────
// //                 SliverPersistentHeader(
// //                   key: _orderTypeKey,
// //                   pinned: false,
// //                   delegate: _StickyDelegate(
// //                     height: _showOrderTypeHint ? 88.h : 65.h,
// //
// //                     // height: _showOrderTypeHint ? 165.h : 115.h,
// //                     child: Container(
// //                       color: restaurentsnewcolour.surface,
// //                       child: Column(
// //                         mainAxisSize: MainAxisSize.min,
// //                         children: [
// //                           Padding(
// //                             padding: EdgeInsets.symmetric(
// //                               horizontal: 16.w,
// //                               // vertical: 10.h,
// //                               vertical: 10.h,
// //                             ),
// //                             child: _buildOrderTypeTabs(),
// //                           ),
// //                           if (_showOrderTypeHint)
// //                             AnimatedOpacity(
// //                               duration: const Duration(milliseconds: 300),
// //                               opacity: _showOrderTypeHint ? 1 : 0,
// //                               child: Padding(
// //                                 padding: EdgeInsets.only(bottom: 6.h),
// //                                 child: Text(
// //                                   '👆 Please select an order type',
// //                                   style: TextStyle(
// //                                     fontSize: 16.sp,
// //                                     color: Colors.red.shade600,
// //                                     fontWeight: FontWeight.w500,
// //                                   ),
// //                                 ),
// //                               ),
// //                             ),
// //                           // Divider(height: 1, color: restaurentsnewcolour.border),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 ),
// //
// //                 // ── 7. Filter chips ─────────────────────────────────────
// //                 SliverPersistentHeader(
// //                   pinned: false,
// //                   delegate: _StickyDelegate(
// //                     height: 50.h,
// //                     child: Container(
// //                       color: restaurentsnewcolour.surface,
// //                       // child: _buildFilterChips(),
// //                       child: FilterChipsBar(),
// //                     ),
// //                   ),
// //                 ),
// //
// //                 SliverToBoxAdapter(child: SizedBox(height: 4.h)),
// //
// //                 // ── 8. Offer filter strip ───────────────────────────────
// //                 SliverToBoxAdapter(child: _buildOfferStrip()),
// //
// //                 // ── 9. Restaurant list header ───────────────────────────
// //                 if (selectedOrderType != 'catering')
// //                   SliverToBoxAdapter(
// //                     child: Padding(
// //                       padding: EdgeInsets.fromLTRB(16.w, 20.h, 16.w, 4.h),
// //                       child: Row(
// //                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //                         children: [
// //                           Text(
// //                             'Restaurants Near You',
// //                             style: TextStyle(
// //                               fontSize: 18.sp,
// //                               fontWeight: FontWeight.w700,
// //                               color: restaurentsnewcolour.text,
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     ),
// //                   ),
// //                 SliverToBoxAdapter(child: SizedBox(height: 1.h)),
// //
// //                 // ── 10. Restaurant cards ────────────────────────────────
// //                 SliverToBoxAdapter(child: _buildRestaurantList()),
// //
// //                 SliverToBoxAdapter(child: SizedBox(height: 32.h)),
// //               ],
// //             ),
// //
// //             // ── Update banner ───────────────────────────────────────────
// //             if (_updateAvailable)
// //               Positioned(
// //                 left: 16.w,
// //                 right: 16.w,
// //                 bottom: 16.h,
// //                 child: SafeArea(child: _buildUpdateBanner()),
// //               ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _buildHeroBanner() {
// //     return SizedBox.expand(
// //       child: Stack(
// //         fit: StackFit.expand,
// //         children: [
// //           /// 🔹 Background (Ad / Video)
// //           _isLoggedIn
// //               ? (homepageAds.isEmpty
// //                     ? Container(color: const Color(0xFFCCCCCC))
// //                     : BannerAdvertisement(
// //                         ads: homepageAds,
// //                         height: _bannerHeight,
// //                       ))
// //               : const VideoPreviewContainer(),
// //
// //           /// 🔹 Gradient overlay
// //           IgnorePointer(
// //             child: const DecoratedBox(
// //               decoration: BoxDecoration(
// //                 gradient: LinearGradient(
// //                   begin: Alignment.topCenter,
// //                   end: Alignment.bottomCenter,
// //                   colors: [
// //                     Color(0x99000000),
// //                     Color(0x33000000),
// //                     Colors.transparent,
// //                   ],
// //                 ),
// //               ),
// //             ),
// //           ),
// //
// //           /// 🔹 Top Content (SafeArea prevents notch overlap)
// //           // IgnorePointer(
// //           //   child:
// //           SafeArea(
// //             bottom: false,
// //             child: Padding(
// //               padding: const EdgeInsets.symmetric(horizontal: 16),
// //               child: Column(
// //                 crossAxisAlignment: CrossAxisAlignment.start,
// //                 children: [
// //                   const SizedBox(height: 10),
// //
// //                   /// 📍 Location + Notification Row
// //                   Row(
// //                     children: [
// //                       Expanded(
// //                         child: _buildLocationContent(
// //                           isDark: false, // white text
// //                           isExpanded: true, // bigger UI
// //                         ),
// //                       ),
// //
// //                       /// 🔔 Notification Icon
// //                       GestureDetector(
// //                         onTap: () {
// //                           Navigator.push(
// //                             context,
// //                             MaterialPageRoute(
// //                               builder: (_) => NotificationScreen(),
// //                             ),
// //                           );
// //                         },
// //                         child: Container(
// //                           width: 36.w,
// //                           height: 36.w,
// //                           decoration: BoxDecoration(
// //                             // ignore: deprecated_member_use
// //                             color: Colors.white.withOpacity(0.2),
// //                             shape: BoxShape.circle,
// //                           ),
// //                           child: const Icon(
// //                             Icons.notifications_none_rounded,
// //                             color: Colors.white,
// //                             size: 20,
// //                           ),
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ],
// //               ),
// //             ),
// //           ),
// //           // ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildCollapsedBar() {
// //     return Row(
// //       children: [
// //         /// 📍 Location Section
// //         Expanded(
// //           child: _buildLocationContent(
// //             isDark: true, // dark text
// //             isExpanded: false, // compact UI
// //           ),
// //         ),
// //
// //         SizedBox(width: 8.w),
// //
// //         /// 🔔 Notification Icon
// //         GestureDetector(
// //           onTap: () {
// //             Navigator.push(
// //               context,
// //               MaterialPageRoute(builder: (_) => NotificationScreen()),
// //             );
// //           },
// //           child: Container(
// //             width: 36.w,
// //             height: 36.w,
// //             decoration: BoxDecoration(
// //               // ignore: deprecated_member_use
// //               color: restaurentsnewcolour.primary.withOpacity(
// //                 0.1,
// //               ), // better visibility
// //               shape: BoxShape.circle,
// //             ),
// //             child: const Icon(
// //               Icons.notifications_none_rounded,
// //               color: restaurentsnewcolour.primary,
// //               size: 20,
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// //
// //   Widget _buildLocationContent({
// //     required bool isDark,
// //     required bool isExpanded,
// //   }) {
// //     return _isLoggedIn
// //         ? _buildAppBarContent(isDark: isDark, isExpanded: isExpanded)
// //         : _buildGuestAppBar(isDark: isDark, isExpanded: isExpanded);
// //   }
// //
// //   IconData _getCategoryIcon() {
// //     final cat = (_locationCategory ?? '').toLowerCase();
// //
// //     switch (cat) {
// //       case 'home':
// //         return Icons.home_rounded;
// //       case 'office':
// //         return Icons.work_rounded;
// //       case 'others':
// //         return Icons.work_rounded;
// //       default:
// //         return Icons.location_on_rounded;
// //     }
// //   }
// //
// //   Widget _buildAppBarContent({required bool isDark, required bool isExpanded}) {
// //     final color = isDark ? restaurentsnewcolour.text : Colors.white;
// //
// //     return GestureDetector(
// //       onTap: _changeLocation,
// //       child: Row(
// //         crossAxisAlignment: CrossAxisAlignment.center,
// //         children: [
// //           Icon(_getCategoryIcon(), color: color, size: isExpanded ? 18 : 16),
// //           SizedBox(width: isExpanded ? 6.w : 4.w),
// //
// //           Expanded(
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               mainAxisSize: MainAxisSize.min,
// //               children: [
// //                 /// 👇 Show only in expanded (Hero)
// //                 if (isExpanded)
// //                   Text(
// //                     (_locationCategory ?? 'Delivering to').replaceFirstMapped(
// //                       RegExp(r'^[a-z]'),
// //                       (m) => m.group(0)!.toUpperCase(),
// //                     ),
// //                     style: TextStyle(fontSize: 10.sp, color: Colors.grey),
// //                   ),
// //                 Text(
// //                   _currentLocation,
// //                   maxLines: 1,
// //                   overflow: TextOverflow.ellipsis,
// //                   style: TextStyle(
// //                     fontSize: isExpanded ? 14.sp : 13.sp,
// //                     fontWeight: FontWeight.w700,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //
// //           Icon(
// //             Icons.keyboard_arrow_down_rounded,
// //             color: color,
// //             size: isExpanded ? 18 : 20,
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   Widget _buildGuestAppBar({required bool isDark, required bool isExpanded}) {
// //     final color = isDark ? restaurentsnewcolour.text : Colors.white;
// //     final subColor = isDark ? restaurentsnewcolour.textMuted : Colors.white70;
// //
// //     return GestureDetector(
// //       onTap: () {
// //         // Navigate to login or location picker
// //       },
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           /// 👇 Show title only in expanded (banner)
// //           if (isExpanded)
// //             Text(
// //               "Current Location",
// //               style: TextStyle(
// //                 fontSize: 11.sp,
// //                 fontWeight: FontWeight.w800,
// //                 color: subColor,
// //               ),
// //             ),
// //
// //           if (isExpanded) SizedBox(height: 2.h),
// //
// //           /// 🔄 Loading State
// //           if (_isGuestLocationLoading)
// //             Row(
// //               children: [
// //                 Icon(
// //                   Icons.location_on_rounded,
// //                   color: color,
// //                   size: isExpanded ? 18 : 16,
// //                 ),
// //                 SizedBox(
// //                   width: isExpanded ? 14.w : 12.w,
// //                   height: isExpanded ? 14.w : 12.w,
// //                   child: CircularProgressIndicator(
// //                     strokeWidth: 2,
// //                     color: color,
// //                   ),
// //                 ),
// //                 SizedBox(width: 6.w),
// //                 Text(
// //                   "Fetching location...",
// //                   style: TextStyle(
// //                     fontSize: isExpanded ? 12.sp : 11.sp,
// //                     color: color,
// //                   ),
// //                 ),
// //               ],
// //             )
// //           /// 📍 Location State
// //           else
// //             Row(
// //               children: [
// //                 Expanded(
// //                   child: Text(
// //                     _currentLocation.isNotEmpty
// //                         ? _currentLocation
// //                         : "Select Location",
// //                     maxLines: 1,
// //                     overflow: TextOverflow.ellipsis,
// //                     style: TextStyle(
// //                       fontSize: isExpanded ? 13.sp : 12.sp,
// //                       fontWeight: FontWeight.w600,
// //                       color: color,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // FOOD CATEGORIES
// //   // ══════════════════════════════════════════════════════════════════════════
// //
// //   List<FoodCategory> get displayCategories {
// //     final list = List<FoodCategory>.from(categories);
// //
// //     final comboIndex = list.indexWhere(
// //       (e) => e.name.toLowerCase().contains('offers'),
// //     );
// //
// //     if (comboIndex > 0) {
// //       final comboItem = list.removeAt(comboIndex);
// //       list.insert(0, comboItem);
// //     }
// //
// //     return list;
// //   }
// //
// //   Widget _buildFoodCategories() {
// //     if (isCategoriesLoading) return const CategorySkeleton();
// //     if (categories.isEmpty) {
// //       return Center(
// //         child: Text(
// //           'No categories available',
// //           style: TextStyle(
// //             fontSize: 12.sp,
// //             color: restaurentsnewcolour.textMuted,
// //           ),
// //         ),
// //       );
// //     }
// //     //
// //     // final bool hasMore = categories.length > 10;
// //     // final int visibleCount = hasMore ? 10 : categories.length;
// //     final bool hasMore = displayCategories.length > 10;
// //     final int visibleCount = hasMore ? 10 : displayCategories.length;
// //     const double dia = 48.0;
// //
// //     return ListView.separated(
// //       scrollDirection: Axis.horizontal,
// //       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
// //       itemCount: visibleCount + 1 + (hasMore ? 1 : 0),
// //       separatorBuilder: (_, __) => SizedBox(width: 14.w),
// //       itemBuilder: (context, index) {
// //         final isAll = index == 0;
// //         final isViewAll = hasMore && index == visibleCount + 1;
// //         final isSelected = selectedCategoryIndex == index;
// //
// //         // final item = isAll ? null : categories[index -
// //         final item = isAll ? null : displayCategories[index - 1];
// //         if (isViewAll) {
// //           return _CategoryItem(
// //             dia: dia,
// //             isSelected: false,
// //             label: 'More',
// //             onTap: _showAllCategoriesBottomSheet,
// //             child: const Icon(
// //               Icons.grid_view_rounded,
// //               size: 22,
// //               color: restaurentsnewcolour.textMuted,
// //             ),
// //           );
// //         }
// //
// //         return _CategoryItem(
// //           dia: dia,
// //           isSelected: isSelected,
// //           label: isAll ? 'All' : item!.name,
// //           child: isAll
// //               ? Icon(
// //                   Icons.grid_view_rounded,
// //                   size: 22,
// //                   color: isSelected
// //                       ? AppColors.primary
// //                       : restaurentsnewcolour.textMuted,
// //                 )
// //               : (item!.image != null
// //                     ? Image.network(
// //                         item.image!,
// //                         fit: BoxFit.cover,
// //                         errorBuilder: (_, __, ___) =>
// //                             const Icon(Icons.fastfood, size: 22),
// //                       )
// //                     : const Icon(Icons.fastfood, size: 22)),
// //           onTap: () => setState(() {
// //             selectedCategoryIndex = index;
// //             selectedCategoryVendorIds = isAll ? null : item!.vendorIds;
// //             selectedCategoryName = isAll ? null : item!.name;
// //           }),
// //         );
// //       },
// //     );
// //   }
// //
// //   void _showAllCategoriesBottomSheet() {
// //     showModalBottomSheet(
// //       backgroundColor: restaurentsnewcolour.surface,
// //       context: context,
// //       isScrollControlled: true,
// //       shape: RoundedRectangleBorder(
// //         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //       ),
// //       builder: (ctx) {
// //         // final remaining = categories.skip(10).toList();
// //         final remaining = displayCategories.skip(10).toList();
// //         final sheetH = MediaQuery.of(ctx).size.height * 0.6;
// //         return SafeArea(
// //           child: Container(
// //             height: sheetH,
// //             padding: EdgeInsets.all(16.w),
// //             child: Column(
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Row(
// //                   children: [
// //                     Text(
// //                       'All Categories',
// //                       style: TextStyle(
// //                         fontSize: 16.sp,
// //                         fontWeight: FontWeight.bold,
// //                       ),
// //                     ),
// //                     const Spacer(),
// //                     InkWell(
// //                       onTap: () => Navigator.pop(ctx),
// //                       borderRadius: BorderRadius.circular(20.r),
// //                       child: Container(
// //                         padding: EdgeInsets.all(6.w),
// //                         decoration: BoxDecoration(
// //                           shape: BoxShape.circle,
// //                           // color: restaurentsnewcolour.bg,
// //                           color: Colors.white,
// //                         ),
// //                         child: Icon(
// //                           Icons.close,
// //                           size: 20.sp,
// //                           color: restaurentsnewcolour.text,
// //                         ),
// //                       ),
// //                     ),
// //                   ],
// //                 ),
// //                 SizedBox(height: 16.h),
// //                 Expanded(
// //                   child: GridView.builder(
// //                     itemCount: remaining.length,
// //                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
// //                       crossAxisCount: 4,
// //                       crossAxisSpacing: 12.w,
// //                       mainAxisSpacing: 12.h,
// //                       childAspectRatio: 0.75,
// //                     ),
// //                     itemBuilder: (_, i) {
// //                       final item = remaining[i];
// //                       return InkWell(
// //                         onTap: () {
// //                           Navigator.pop(ctx);
// //                           setState(() {
// //                             // selectedCategoryIndex =
// //                             //     categories.indexOf(item) + 1;
// //                             selectedCategoryIndex =
// //                                 displayCategories.indexOf(item) + 1;
// //                             selectedCategoryVendorIds = item.vendorIds;
// //                             selectedCategoryName = item.name;
// //                           });
// //                         },
// //                         child: Column(
// //                           children: [
// //                             Container(
// //                               width: 56.h,
// //                               height: 56.h,
// //                               decoration: BoxDecoration(
// //                                 shape: BoxShape.circle,
// //                                 color: restaurentsnewcolour.bg,
// //                               ),
// //                               child: ClipOval(
// //                                 child: item.image != null
// //                                     ? Image.network(
// //                                         item.image!,
// //                                         fit: BoxFit.cover,
// //                                         errorBuilder: (_, __, ___) =>
// //                                             const Icon(Icons.fastfood),
// //                                       )
// //                                     : const Icon(Icons.fastfood),
// //                               ),
// //                             ),
// //                             SizedBox(height: 6.h),
// //                             Text(
// //                               item.name,
// //                               textAlign: TextAlign.center,
// //                               maxLines: 2,
// //                               overflow: TextOverflow.ellipsis,
// //                               style: TextStyle(
// //                                 fontSize: 10.sp,
// //                                 fontWeight: FontWeight.w600,
// //                               ),
// //                             ),
// //                           ],
// //                         ),
// //                       );
// //                     },
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // ══════════════════════════════════════════════════════════════════════════
// //   // ORDER TYPE TABS
// //   // ══════════════════════════════════════════════════════════════════════════
// //
// //   Widget _buildOrderTypeTabs() {
// //     return ValueListenableBuilder<String?>(
// //       valueListenable: selectedOrderTypeNotifier,
// //       builder: (_, selected, __) {
// //         final visibleTabs = RestaurentsHelper.orderTabs.where((tab) {
// //           final configKey = tab['configKey'] as String;
// //           return AppConfigService.instance.isEnabled(configKey);
// //         }).toList();
// //
// //         return SingleChildScrollView(
// //           scrollDirection: Axis.horizontal,
// //           child: Row(
// //             children: visibleTabs.map((tab) {
// //               final type = tab['type'] as String;
// //               final isSelected = selected == type;
// //
// //               return GestureDetector(
// //                 onTap: () => _handleOrderTypeSelection(type),
// //                 child: AnimatedContainer(
// //                   duration: const Duration(milliseconds: 220),
// //                   margin: EdgeInsets.only(right: 8.w),
// //                   padding: EdgeInsets.symmetric(
// //                     horizontal: 14.w,
// //                     vertical: 10.h,
// //                   ),
// //                   decoration: BoxDecoration(
// //                     color: isSelected ? Colors.green : AppColors.primary,
// //                     borderRadius: BorderRadius.circular(10.r),
// //                   ),
// //                   child: Row(
// //                     mainAxisSize: MainAxisSize.min,
// //                     children: [
// //                       Icon(tab['icon'] as IconData, color: Colors.white),
// //                       SizedBox(width: 6.w),
// //                       Text(
// //                         tab['label'] as String,
// //                         style: TextStyle(
// //                           color: Colors.white,
// //                           fontWeight: FontWeight.bold,
// //                         ),
// //                       ),
// //                     ],
// //                   ),
// //                 ),
// //               );
// //             }).toList(),
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   // Widget _buildOrderTypeTabs() {
// //   //   return ValueListenableBuilder<String?>(
// //   //     valueListenable: selectedOrderTypeNotifier,
// //   //     builder: (_, selected, __) {
// //   //       final itemWidth = (MediaQuery.of(context).size.width - 48.w) / 3;
// //   //
// //   //       return Wrap(
// //   //         alignment: WrapAlignment.center, // 👈 add this
// //   //         spacing: 8.w,
// //   //         runSpacing: 10.h,
// //   //         children: RestaurentsHelper.orderTabs.map((tab) {
// //   //           final type = tab['type'] as String;
// //   //           final isSelected = selected == type;
// //   //
// //   //           return GestureDetector(
// //   //             onTap: () => _handleOrderTypeSelection(type),
// //   //             child: AnimatedContainer(
// //   //               duration: const Duration(milliseconds: 220),
// //   //               curve: Curves.easeInOut,
// //   //               width: itemWidth,
// //   //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
// //   //               decoration: BoxDecoration(
// //   //                 color: isSelected ? Colors.green : AppColors.primary,
// //   //                 borderRadius: BorderRadius.circular(12.r),
// //   //                 boxShadow: isSelected
// //   //                     ? [
// //   //                         BoxShadow(
// //   //                           color: restaurentsnewcolour.green.withOpacity(0.25),
// //   //                           blurRadius: 10,
// //   //                           offset: const Offset(0, 4),
// //   //                         ),
// //   //                       ]
// //   //                     : [],
// //   //               ),
// //   //               child: Row(
// //   //                 mainAxisAlignment: MainAxisAlignment.center,
// //   //                 children: [
// //   //                   Icon(
// //   //                     tab['icon'] as IconData,
// //   //                     size: 18.sp,
// //   //                     color: Colors.white,
// //   //                   ),
// //   //
// //   //                   SizedBox(width: 6.w),
// //   //
// //   //                   Flexible(
// //   //                     child: Text(
// //   //                       tab['label'] as String,
// //   //                       overflow: TextOverflow.ellipsis,
// //   //                       textAlign: TextAlign.center,
// //   //                       style: TextStyle(
// //   //                         fontSize: 12.sp,
// //   //                         fontWeight: FontWeight.bold,
// //   //                         color: Colors.white,
// //   //                       ),
// //   //                     ),
// //   //                   ),
// //   //                 ],
// //   //               ),
// //   //             ),
// //   //           );
// //   //         }).toList(),
// //   //       );
// //   //     },
// //   //   );
// //   // }
// //
// //   // ═══════════════════════════════════_handleOrderTypeSelection═══════════════════════════════════════
// //   // FILTER CHIPS
// //   // ══════════════════════════════════════════════════════════════════════════
// //
// //   // Widget _buildFilterChips() {
// //   //   return ListView.separated(
// //   //     scrollDirection: Axis.horizontal,
// //   //     padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
// //   //     itemCount: RestaurentsHelper.filters.length,
// //   //     separatorBuilder: (_, __) => SizedBox(width: 8.w),
// //   //     itemBuilder: (_, i) {
// //   //       final f = RestaurentsHelper.filters[i];
// //   //       final isSelected = _activeFilterIndex == i;
// //   //       return GestureDetector(
// //   //         onTap: () {
// //   //           setState(() => _activeFilterIndex = isSelected ? -1 : i);
// //   //           if (f['label'] == 'Filters') _openFilterBottomSheet();
// //   //         },
// //   //         child: AnimatedContainer(
// //   //           duration: const Duration(milliseconds: 180),
// //   //           padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //   //           decoration: BoxDecoration(
// //   //             color: isSelected
// //   //                 ? restaurentsnewcolour.text
// //   //                 : restaurentsnewcolour.surface,
// //   //             borderRadius: BorderRadius.circular(8.r),
// //   //             border: Border.all(
// //   //               color: isSelected
// //   //                   ? restaurentsnewcolour.text
// //   //                   : restaurentsnewcolour.border,
// //   //               width: 1.5,
// //   //             ),
// //   //           ),
// //   //           child: Row(
// //   //             mainAxisSize: MainAxisSize.min,
// //   //             children: [
// //   //               Icon(
// //   //                 f['icon'] as IconData,
// //   //                 size: 14.sp,
// //   //                 color: isSelected
// //   //                     ? Colors.white
// //   //                     : restaurentsnewcolour.textMuted,
// //   //               ),
// //   //               SizedBox(width: 5.w),
// //   //               Text(
// //   //                 f['label'] as String,
// //   //                 style: TextStyle(
// //   //                   fontSize: 12.sp,
// //   //                   fontWeight: FontWeight.w600,
// //   //                   color: isSelected
// //   //                       ? Colors.white
// //   //                       : restaurentsnewcolour.textMuted,
// //   //                 ),
// //   //               ),
// //   //             ],
// //   //           ),
// //   //         ),
// //   //       );
// //   //     },
// //   //   );
// //   // }
// //
// //   // ── Offer strip ───────────────────────────────────────────────────────────
// //   Widget _buildOfferStrip() {
// //     return SizedBox(
// //       height: 68.h,
// //       child: ListView.separated(
// //         scrollDirection: Axis.horizontal,
// //         padding: EdgeInsets.symmetric(horizontal: 16.w),
// //         itemCount: RestaurentsHelper.offers.length,
// //         separatorBuilder: (_, __) => SizedBox(width: 10.w),
// //         itemBuilder: (_, i) {
// //           final o = RestaurentsHelper.offers[i];
// //           return Container(
// //             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
// //             decoration: BoxDecoration(
// //               gradient: LinearGradient(
// //                 colors: [Color(o['c1'] as int), Color(o['c2'] as int)],
// //                 begin: Alignment.topLeft,
// //                 end: Alignment.bottomRight,
// //               ),
// //               borderRadius: BorderRadius.circular(12.r),
// //             ),
// //             child: Column(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               crossAxisAlignment: CrossAxisAlignment.start,
// //               children: [
// //                 Text(
// //                   o['title'] as String,
// //                   style: TextStyle(
// //                     fontSize: 13.sp,
// //                     fontWeight: FontWeight.w800,
// //                     color: Colors.white,
// //                   ),
// //                 ),
// //                 Text(
// //                   o['sub'] as String,
// //                   style: TextStyle(
// //                     fontSize: 10.sp,
// //                     color: Colors.white70,
// //                     fontWeight: FontWeight.w500,
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           );
// //         },
// //       ),
// //     );
// //   }
// //
// //   // ── Restaurant list ───────────────────────────────────────────────────────
// //   Widget _buildRestaurantList() {
// //     return AnimatedSwitcher(
// //       duration: const Duration(milliseconds: 250),
// //       child: selectedOrderType == 'catering'
// //           ? CateringsPage(key: const ValueKey('catering'))
// //           : NearbyRestaurentBannersWidget(
// //               key: ValueKey(
// //                 '${_getApiOrderType()}-${selectedCategoryVendorIds?.join(',')}-$searchText-$_refreshKey',
// //               ),
// //               orderType: _getApiOrderType(),
// //               categoryVendorIds: selectedCategoryVendorIds,
// //               searchQuery: searchText,
// //               onOrderTypeRequired: _focusOrderTypeSelection,
// //               selectedCategoryName: selectedCategoryName,
// //             ),
// //     );
// //   }
// //
// //   // ── Update banner ─────────────────────────────────────────────────────────
// //   Widget _buildUpdateBanner() {
// //     return Container(
// //       decoration: BoxDecoration(
// //         color: restaurentsnewcolour.surface,
// //         borderRadius: BorderRadius.circular(16.r),
// //         boxShadow: [
// //           BoxShadow(
// //             color: Colors.black.withOpacity(0.1),
// //             blurRadius: 20.r,
// //             offset: const Offset(0, 4),
// //           ),
// //         ],
// //         border: Border.all(color: restaurentsnewcolour.border),
// //       ),
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         children: [
// //           Padding(
// //             padding: EdgeInsets.all(14.w),
// //             child: Row(
// //               children: [
// //                 Container(
// //                   width: 44.r,
// //                   height: 44.r,
// //                   decoration: BoxDecoration(
// //                     color: Colors.red.withOpacity(0.1),
// //                     borderRadius: BorderRadius.circular(12.r),
// //                   ),
// //                   child: const Icon(
// //                     Icons.system_update_rounded,
// //                     color: Colors.red,
// //                     size: 24,
// //                   ),
// //                 ),
// //                 SizedBox(width: 12.w),
// //                 Expanded(
// //                   child: Text(
// //                     'New Update Available',
// //                     style: TextStyle(
// //                       fontSize: 15.sp,
// //                       fontWeight: FontWeight.w700,
// //                     ),
// //                   ),
// //                 ),
// //               ],
// //             ),
// //           ),
// //           Divider(height: 1, color: restaurentsnewcolour.border),
// //           TextButton(
// //             onPressed: _startFlexibleUpdate,
// //             style: TextButton.styleFrom(
// //               minimumSize: Size.fromHeight(48.h),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.only(
// //                   bottomLeft: Radius.circular(16.r),
// //                   bottomRight: Radius.circular(16.r),
// //                 ),
// //               ),
// //             ),
// //             child: Row(
// //               mainAxisAlignment: MainAxisAlignment.center,
// //               children: [
// //                 Text(
// //                   'UPDATE NOW',
// //                   style: TextStyle(
// //                     fontSize: 14.sp,
// //                     fontWeight: FontWeight.w700,
// //                     color: Colors.red,
// //                   ),
// //                 ),
// //                 SizedBox(width: 8.w),
// //                 const Icon(Icons.download_rounded, color: Colors.red, size: 18),
// //               ],
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// //
// //   // ── Filter bottom sheet ───────────────────────────────────────────────────
// //   // void _openFilterBottomSheet() {
// //   //   showModalBottomSheet(
// //   //     context: context,
// //   //     isScrollControlled: true,
// //   //     backgroundColor: Colors.transparent,
// //   //     builder: (_) => FractionallySizedBox(
// //   //       heightFactor: 0.92,
// //   //       child: Container(
// //   //         decoration: BoxDecoration(
// //   //           color: restaurentsnewcolour.surface,
// //   //           borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //   //         ),
// //   //         child: const FilterBottomSheet(),
// //   //       ),
// //   //     ),
// //   //   );
// //   // }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // CATEGORY ITEM  (small, reusable)
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _CategoryItem extends StatelessWidget {
// //   final double dia;
// //   final bool isSelected;
// //   final String label;
// //   final Widget child;
// //   final VoidCallback onTap;
// //
// //   const _CategoryItem({
// //     required this.dia,
// //     required this.isSelected,
// //     required this.label,
// //     required this.child,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: Column(
// //         mainAxisSize: MainAxisSize.min,
// //         mainAxisAlignment: MainAxisAlignment.center,
// //         children: [
// //           AnimatedContainer(
// //             duration: const Duration(milliseconds: 220),
// //             width: dia,
// //             height: dia,
// //             decoration: BoxDecoration(
// //               shape: BoxShape.circle,
// //               color: isSelected
// //                   ? restaurentsnewcolour.primaryLight
// //                   : restaurentsnewcolour.bg,
// //               border: isSelected
// //                   ? Border.all(color: AppColors.primary, width: 2)
// //                   : null,
// //             ),
// //             child: ClipOval(child: child),
// //           ),
// //           SizedBox(height: 4.h),
// //           SizedBox(
// //             width: dia + 8,
// //             child: Text(
// //               label,
// //               maxLines: 1,
// //               overflow: TextOverflow.ellipsis,
// //               textAlign: TextAlign.center,
// //               style: TextStyle(
// //                 fontSize: 10.sp,
// //                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
// //                 color: isSelected
// //                     ? AppColors.primary
// //                     : restaurentsnewcolour.textMuted,
// //               ),
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // SEARCH BAR  (white, used inside the sticky header)
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _SearchBar extends StatelessWidget {
// //   final ValueChanged<String> onChanged;
// //
// //   const _SearchBar({required this.onChanged});
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       height: 44.h,
// //       width: double.infinity,
// //       child: TextField(
// //         onChanged: onChanged,
// //         textInputAction: TextInputAction.search,
// //         style: TextStyle(
// //           fontSize: 14.sp,
// //           color: restaurentsnewcolour.text,
// //           fontWeight: FontWeight.w500,
// //         ),
// //         cursorColor: restaurentsnewcolour.primary,
// //
// //         decoration: InputDecoration(
// //           hintText: 'Search restaurants, cuisines...',
// //
// //           // ✅ Makes it look like a container
// //           filled: true,
// //           fillColor: restaurentsnewcolour.bg,
// //
// //           // ✅ Rounded border like container
// //           border: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: restaurentsnewcolour.border,
// //               width: 1.5,
// //             ),
// //           ),
// //
// //           enabledBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: restaurentsnewcolour.border,
// //               width: 1.5,
// //             ),
// //           ),
// //
// //           focusedBorder: OutlineInputBorder(
// //             borderRadius: BorderRadius.circular(12.r),
// //             borderSide: BorderSide(
// //               color: restaurentsnewcolour.primary,
// //               width: 1.5,
// //             ),
// //           ),
// //
// //           // ✅ Icon inside field
// //           prefixIcon: Icon(
// //             Icons.search_rounded,
// //             color: restaurentsnewcolour.textLight,
// //             size: 20.sp,
// //           ),
// //
// //           // spacing fix
// //           contentPadding: EdgeInsets.symmetric(vertical: 0),
// //
// //           hintStyle: TextStyle(
// //             color: restaurentsnewcolour.textLight,
// //             fontSize: 13.sp,
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // NEARBY RESTAURANTS WIDGET
// // // ══════════════════════════════════════════════════════════════════════════════
// // class NearbyRestaurentBannersWidget extends StatefulWidget {
// //   final String? orderType;
// //   final List<int>? categoryVendorIds;
// //   final String? searchQuery;
// //   final VoidCallback? onOrderTypeRequired;
// //   final String? selectedCategoryName;
// //
// //   const NearbyRestaurentBannersWidget({
// //     super.key,
// //     this.orderType,
// //     this.categoryVendorIds,
// //     this.searchQuery,
// //     this.onOrderTypeRequired,
// //     this.selectedCategoryName,
// //   });
// //
// //   @override
// //   State<NearbyRestaurentBannersWidget> createState() =>
// //       _NearbyRestaurentBannersWidgetState();
// // }
// //
// // class _NearbyRestaurentBannersWidgetState
// //     extends State<NearbyRestaurentBannersWidget> {
// //   late Future<List<Restaurent_Banner>> _future;
// //
// //   @override
// //   void initState() {
// //     super.initState();
// //     _future = Authservice.fetchnearbyresturents();
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return FutureBuilder<List<Restaurent_Banner>>(
// //       future: _future,
// //       builder: (_, snap) {
// //         if (snap.connectionState == ConnectionState.waiting) {
// //           return const RestaurantsSkeleton();
// //         }
// //         if (snap.hasError) {
// //           return _state(Icons.error_outline, 'Error loading restaurants');
// //         }
// //         if (!snap.hasData || snap.data!.isEmpty) {
// //           return _state(Icons.location_off, 'No nearby restaurants');
// //         }
// //
// //         final filtered = snap.data!.where((b) {
// //           final matchType =
// //               widget.orderType == null ||
// //               b.orderTypes.contains(widget.orderType);
// //           final matchCat =
// //               widget.categoryVendorIds == null ||
// //               widget.categoryVendorIds!.contains(b.vendorId);
// //           final matchSearch =
// //               (widget.searchQuery ?? '').trim().isEmpty ||
// //               b.companyName.toLowerCase().contains(
// //                 widget.searchQuery!.toLowerCase(),
// //               );
// //           return matchType && matchCat && matchSearch;
// //         }).toList();
// //
// //         if (filtered.isEmpty) {
// //           return _state(Icons.search_off, 'No restaurants match your filter');
// //         }
// //
// //         return ListView.separated(
// //           shrinkWrap: true,
// //           physics: const NeverScrollableScrollPhysics(),
// //           padding: EdgeInsets.symmetric(horizontal: 16.w),
// //           itemCount: filtered.length,
// //           separatorBuilder: (_, __) => SizedBox(height: 14.h),
// //           itemBuilder: (_, i) => _RestaurantCard(
// //             banner: filtered[i],
// //             orderType: widget.orderType,
// //             onOrderTypeRequired: widget.onOrderTypeRequired,
// //             selectedCategoryName: widget.selectedCategoryName,
// //           ),
// //         );
// //       },
// //     );
// //   }
// //
// //   Widget _state(IconData icon, String msg) {
// //     return SizedBox(
// //       height: 200.h,
// //       child: Center(
// //         child: Column(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(icon, size: 38.sp, color: restaurentsnewcolour.textLight),
// //             SizedBox(height: 10.h),
// //             Text(
// //               msg,
// //               style: TextStyle(
// //                 fontSize: 13.sp,
// //                 color: restaurentsnewcolour.textMuted,
// //               ),
// //               textAlign: TextAlign.center,
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // RESTAURANT CARD
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _RestaurantCard extends StatelessWidget {
// //   final Restaurent_Banner banner;
// //   final String? orderType;
// //   final VoidCallback? onOrderTypeRequired;
// //   final String? selectedCategoryName;
// //
// //   const _RestaurantCard({
// //     required this.banner,
// //     this.orderType,
// //     this.onOrderTypeRequired,
// //     this.selectedCategoryName,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final double screenH = MediaQuery.of(context).size.height;
// //     // final double cardH = (screenH * 0.28).clamp(200.0, 260.0);
// //     final double cardH = (screenH * 0.30).clamp(220.0, 280.0);
// //     final double imgH = cardH * 0.58;
// //
// //     return GestureDetector(
// //       onTap: () {
// //         if (orderType == null) {
// //           onOrderTypeRequired?.call();
// //           return;
// //         }
// //
// //         Navigator.push(
// //           context,
// //           MaterialPageRoute(
// //             builder: (_) => MenuScreen(
// //               vendorId: banner.vendorId,
// //               initialCategoryName: selectedCategoryName,
// //             ),
// //           ),
// //         );
// //       },
// //       child: IntrinsicHeight(
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: restaurentsnewcolour.surface,
// //             borderRadius: BorderRadius.circular(
// //               restaurentsnewcolour.cardRadius.r,
// //             ),
// //             boxShadow: [
// //               BoxShadow(
// //                 color: Colors.black.withOpacity(0.07),
// //                 blurRadius: 12,
// //                 offset: const Offset(0, 4),
// //               ),
// //             ],
// //           ),
// //
// //           child: Column(
// //             crossAxisAlignment: CrossAxisAlignment.start,
// //             children: [
// //               // IMAGE
// //               AspectRatio(
// //                 aspectRatio: 10 / 4,
// //                 child: Stack(
// //                   fit: StackFit.expand,
// //                   children: [
// //                     ClipRRect(
// //                       borderRadius: BorderRadius.vertical(
// //                         top: Radius.circular(restaurentsnewcolour.cardRadius.r),
// //                       ),
// //                       child: banner.companyBanner.isNotEmpty
// //                           ? Image.network(
// //                               banner.companyBanner,
// //                               fit: BoxFit.cover,
// //                               errorBuilder: (_, __, ___) => _placeholder(),
// //                             )
// //                           : _placeholder(),
// //                     ),
// //
// //                     Positioned(
// //                       bottom: 0,
// //                       left: 0,
// //                       right: 0,
// //                       height: 60,
// //                       child: const DecoratedBox(
// //                         decoration: BoxDecoration(
// //                           gradient: LinearGradient(
// //                             begin: Alignment.topCenter,
// //                             end: Alignment.bottomCenter,
// //                             colors: [Colors.transparent, Color(0x66000000)],
// //                           ),
// //                         ),
// //                       ),
// //                     ),
// //
// //                     if ((banner.ratings) >= 4.0)
// //                       Positioned(
// //                         top: 8,
// //                         left: 10,
// //                         child: Container(
// //                           padding: const EdgeInsets.symmetric(
// //                             horizontal: 8,
// //                             vertical: 3,
// //                           ),
// //                           decoration: BoxDecoration(
// //                             color: Colors.white,
// //                             borderRadius: BorderRadius.circular(6),
// //                           ),
// //                           child: Row(
// //                             mainAxisSize: MainAxisSize.min,
// //                             children: [
// //                               Icon(
// //                                 Icons.star_rounded,
// //                                 color: restaurentsnewcolour.primary,
// //                                 size: 11,
// //                               ),
// //                               SizedBox(width: 3),
// //                               Text(
// //                                 'Top Rated',
// //                                 style: TextStyle(
// //                                   fontSize: 10,
// //                                   fontWeight: FontWeight.w700,
// //                                   color: restaurentsnewcolour.primary,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //                       ),
// //                   ],
// //                 ),
// //               ),
// //
// //               // INFO
// //               Padding(
// //                 padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
// //                 child: Column(
// //                   crossAxisAlignment: CrossAxisAlignment.start,
// //                   mainAxisSize: MainAxisSize.min,
// //                   children: [
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Expanded(
// //                           child: Wrap(
// //                             crossAxisAlignment: WrapCrossAlignment.center,
// //                             children: [
// //                               Text(
// //                                 banner.companyName.toUpperCase(),
// //                                 maxLines: 2,
// //                                 overflow: TextOverflow.ellipsis,
// //                                 style: TextStyle(
// //                                   fontSize: 14.sp,
// //                                   fontWeight: FontWeight.w700,
// //                                   color: restaurentsnewcolour.text,
// //                                 ),
// //                               ),
// //
// //                               _dot(),
// //
// //                               Text(
// //                                 banner.type,
// //                                 style: TextStyle(
// //                                   fontSize: 14.sp,
// //                                   fontWeight: FontWeight.w600,
// //                                   color: restaurentsnewcolour.text,
// //                                 ),
// //                               ),
// //                             ],
// //                           ),
// //                         ),
// //
// //                         if ((banner.ratings) > 0) ...[
// //                           SizedBox(width: 8.w),
// //
// //                           Container(
// //                             padding: EdgeInsets.symmetric(
// //                               horizontal: 6.w,
// //                               vertical: 3.h,
// //                             ),
// //                             decoration: BoxDecoration(
// //                               color: restaurentsnewcolour.green,
// //                               borderRadius: BorderRadius.circular(6.r),
// //                             ),
// //                             child: Row(
// //                               mainAxisSize: MainAxisSize.min,
// //                               children: [
// //                                 const Icon(
// //                                   Icons.star_rounded,
// //                                   color: Colors.white,
// //                                   size: 11,
// //                                 ),
// //                                 SizedBox(width: 2.w),
// //                                 Text(
// //                                   banner.ratings.toString(),
// //                                   style: TextStyle(
// //                                     color: Colors.white,
// //                                     fontSize: 11.sp,
// //                                     fontWeight: FontWeight.w700,
// //                                   ),
// //                                 ),
// //                               ],
// //                             ),
// //                           ),
// //                         ],
// //                       ],
// //                     ),
// //
// //                     SizedBox(height: 4.h),
// //
// //                     if (banner.position.isNotEmpty)
// //                       Text(
// //                         '${banner.position[0].toUpperCase()}${banner.position.substring(1).toLowerCase()}',
// //                         maxLines: 1,
// //                         overflow: TextOverflow.ellipsis,
// //                         style: TextStyle(
// //                           fontSize: 11.sp,
// //                           color: const Color(0xFF6C63FF),
// //                           fontWeight: FontWeight.w600,
// //                         ),
// //                       ),
// //
// //                     SizedBox(height: 6.h),
// //
// //                     Row(
// //                       crossAxisAlignment: CrossAxisAlignment.start,
// //                       children: [
// //                         Expanded(
// //                           child: Text(
// //                             '${banner.addressLine}, ${banner.city}',
// //                             maxLines: 2,
// //                             overflow: TextOverflow.ellipsis,
// //                             style: TextStyle(
// //                               fontSize: 11.sp,
// //                               color: restaurentsnewcolour.textLight,
// //                             ),
// //                           ),
// //                         ),
// //
// //                         SizedBox(width: 8.w),
// //
// //                         Text(
// //                           Distancehelpermethod.formatDistance(banner.distance),
// //                           style: TextStyle(
// //                             fontSize: 12.sp,
// //                             fontWeight: FontWeight.w600,
// //                             color: restaurentsnewcolour.textMuted,
// //                           ),
// //                         ),
// //                       ],
// //                     ),
// //                   ],
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   Widget _dot() => Padding(
// //     padding: EdgeInsets.symmetric(horizontal: 5.w),
// //     child: Container(
// //       width: 3,
// //       height: 3,
// //       decoration: const BoxDecoration(
// //         color: restaurentsnewcolour.textLight,
// //         shape: BoxShape.circle,
// //       ),
// //     ),
// //   );
// //
// //   Widget _placeholder() => Container(
// //     color: restaurentsnewcolour.bg,
// //     child: Center(
// //       child: Icon(
// //         Icons.restaurant_rounded,
// //         size: 32.sp,
// //         color: restaurentsnewcolour.textLight,
// //       ),
// //     ),
// //   );
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // STICKY SLIVER DELEGATE
// // // ══════════════════════════════════════════════════════════════════════════════
// // class _StickyDelegate extends SliverPersistentHeaderDelegate {
// //   final double height;
// //   final Widget child;
// //
// //   const _StickyDelegate({required this.height, required this.child});
// //
// //   @override
// //   double get minExtent => height;
// //   @override
// //   double get maxExtent => height;
// //
// //   @override
// //   Widget build(BuildContext ctx, double shrink, bool overlaps) =>
// //       SizedBox.expand(child: child);
// //
// //   @override
// //   bool shouldRebuild(covariant _StickyDelegate old) =>
// //       height != old.height || child != old.child;
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // FILTER BOTTOM SHEET
// // // ══════════════════════════════════════════════════════════════════════════════
// // // class FilterBottomSheet extends StatefulWidget {
// // //   final int initialTab;
// // //   const FilterBottomSheet({super.key, this.initialTab = 0});
// // //
// // //   @override
// // //   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// // // }
// // //
// // // class _FilterBottomSheetState extends State<FilterBottomSheet> {
// // //   int _sel = 0;
// // //
// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Column(
// // //       children: [
// // //         _header(),
// // //         Expanded(
// // //           child: Row(
// // //             children: [
// // //               _leftMenu(),
// // //               Expanded(child: _rightContent()),
// // //             ],
// // //           ),
// // //         ),
// // //         _footer(),
// // //       ],
// // //     );
// // //   }
// // //
// // //   Widget _header() => Column(
// // //     children: [
// // //       SizedBox(height: 10.h),
// // //       Container(
// // //         width: 45.w,
// // //         height: 5.h,
// // //         decoration: BoxDecoration(
// // //           color: Colors.grey.shade300,
// // //           borderRadius: BorderRadius.circular(20),
// // //         ),
// // //       ),
// // //       SizedBox(height: 18.h),
// // //       Padding(
// // //         padding: EdgeInsets.symmetric(horizontal: 18.w),
// // //         child: Row(
// // //           children: [
// // //             Text(
// // //               "Filters",
// // //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
// // //             ),
// // //             const Spacer(),
// // //             TextButton(
// // //               onPressed: () {},
// // //               child: Text(
// // //                 "Clear all",
// // //                 style: TextStyle(
// // //                   color: restaurentsnewcolour.primary,
// // //                   fontWeight: FontWeight.w600,
// // //                 ),
// // //               ),
// // //             ),
// // //           ],
// // //         ),
// // //       ),
// // //       Divider(height: 1),
// // //     ],
// // //   );
// // //   Widget _leftMenu() => Container(
// // //     width: 90.w,
// // //     color: restaurentsnewcolour.bg,
// // //     child: ListView.builder(
// // //       itemCount: RestaurentsHelper.menu.length,
// // //       itemBuilder: (_, i) {
// // //         final sel = _sel == i;
// // //         return InkWell(
// // //           onTap: () => setState(() => _sel = i),
// // //           child: Container(
// // //             padding: EdgeInsets.all(14.w),
// // //             decoration: BoxDecoration(
// // //               color: sel ? restaurentsnewcolour.surface : Colors.transparent,
// // //               border: Border(
// // //                 left: BorderSide(
// // //                   color: sel
// // //                       ? restaurentsnewcolour.primary
// // //                       : Colors.transparent,
// // //                   width: 3,
// // //                 ),
// // //               ),
// // //             ),
// // //             child: Text(
// // //               RestaurentsHelper.menu[i],
// // //               style: TextStyle(
// // //                 fontSize: 12.sp,
// // //                 fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
// // //                 color: sel
// // //                     ? restaurentsnewcolour.text
// // //                     : restaurentsnewcolour.textMuted,
// // //               ),
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     ),
// // //   );
// // //
// // //   Widget _rightContent() {
// // //     switch (_sel) {
// // //       case 0:
// // //         return _panel('Time', [
// // //           _chip(Icons.schedule_rounded, 'Schedule'),
// // //           _chip(Icons.flash_on_rounded, 'Near & Fast'),
// // //         ]);
// // //       case 1:
// // //         return _panel('Restaurant Rating', [
// // //           _chip(Icons.star_rounded, 'Rated 3.5+'),
// // //           _chip(Icons.star_rounded, 'Rated 4.0+'),
// // //         ]);
// // //       case 2:
// // //         return _panel('Offers', [
// // //           _chip(Icons.local_offer_rounded, 'Buy 1 Get 1'),
// // //           _chip(Icons.percent_rounded, 'Deals of the Day'),
// // //         ]);
// // //       case 3:
// // //         return _panel('Dish Price', [
// // //           _chip(Icons.currency_rupee_rounded, 'Under ₹150'),
// // //           _chip(Icons.currency_rupee_rounded, 'Under ₹250'),
// // //           _chip(Icons.currency_rupee_rounded, 'Under ₹500'),
// // //         ]);
// // //       case 4:
// // //         return _panel('Trust Markers', [
// // //           _chip(Icons.verified_rounded, 'Hygiene Rated'),
// // //           _chip(Icons.verified_user_rounded, 'Trusted Seller'),
// // //         ]);
// // //       default:
// // //         return const SizedBox.shrink();
// // //     }
// // //   }
// // //
// // //   Widget _panel(String title, List<Widget> chips) => Padding(
// // //     padding: EdgeInsets.all(16.w),
// // //     child: Column(
// // //       crossAxisAlignment: CrossAxisAlignment.start,
// // //       children: [
// // //         Text(
// // //           title,
// // //           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
// // //         ),
// // //         SizedBox(height: 14.h),
// // //         Wrap(spacing: 10.w, runSpacing: 10.h, children: chips),
// // //       ],
// // //     ),
// // //   );
// // //
// // //   Widget _chip(IconData icon, String label) => Container(
// // //     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
// // //     decoration: BoxDecoration(
// // //       border: Border.all(color: restaurentsnewcolour.border, width: 1.5),
// // //       borderRadius: BorderRadius.circular(10.r),
// // //       color: restaurentsnewcolour.surface,
// // //     ),
// // //     child: Row(
// // //       mainAxisSize: MainAxisSize.min,
// // //       children: [
// // //         Icon(icon, size: 14.sp, color: restaurentsnewcolour.green),
// // //         SizedBox(width: 6.w),
// // //         Text(
// // //           label,
// // //           style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // //
// // //   Widget _footer() => Padding(
// // //     padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
// // //     child: Row(
// // //       children: [
// // //         Expanded(
// // //           child: OutlinedButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             style: OutlinedButton.styleFrom(
// // //               side: BorderSide(color: restaurentsnewcolour.border),
// // //               padding: EdgeInsets.symmetric(vertical: 12.h),
// // //             ),
// // //             child: const Text('Close'),
// // //           ),
// // //         ),
// // //         SizedBox(width: 12.w),
// // //         Expanded(
// // //           child: ElevatedButton(
// // //             onPressed: () => Navigator.pop(context),
// // //             style: ElevatedButton.styleFrom(
// // //               backgroundColor: restaurentsnewcolour.primary,
// // //               foregroundColor: Colors.white,
// // //               padding: EdgeInsets.symmetric(vertical: 12.h),
// // //             ),
// // //             child: const Text('Show results'),
// // //           ),
// // //         ),
// // //       ],
// // //     ),
// // //   );
// // // }
// //
// // class FilterChipsBar extends StatefulWidget {
// //   const FilterChipsBar({super.key});
// //
// //   @override
// //   State<FilterChipsBar> createState() => _FilterChipsBarState();
// // }
// //
// // class _FilterChipsBarState extends State<FilterChipsBar> {
// //   int _activeIndex = -1;
// //
// //   void _onChipTap(int i) {
// //     final label = RestaurentsHelper.filters[i]['label'] as String;
// //     setState(() => _activeIndex = (_activeIndex == i) ? -1 : i);
// //     if (label == 'Filters') _openFilterSheet();
// //   }
// //
// //   void _openFilterSheet() {
// //     showModalBottomSheet(
// //       context: context,
// //       isScrollControlled: true,
// //       backgroundColor: Colors.transparent,
// //       builder: (_) => FractionallySizedBox(
// //         heightFactor: 0.92,
// //         child: Container(
// //           decoration: BoxDecoration(
// //             color: AppColors.surface,
// //             borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
// //           ),
// //           child: const FilterBottomSheet(),
// //         ),
// //       ),
// //     );
// //   }
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return SizedBox(
// //       height: 44.h,
// //       child: ListView.separated(
// //         scrollDirection: Axis.horizontal,
// //         padding: EdgeInsets.symmetric(horizontal: 16.w),
// //         itemCount: RestaurentsHelper.filters.length,
// //         separatorBuilder: (_, __) => SizedBox(width: 8.w),
// //         itemBuilder: (_, i) {
// //           final f = RestaurentsHelper.filters[i];
// //           final active = _activeIndex == i;
// //           return _FilterChip(
// //             icon: f['icon'] as IconData,
// //             label: f['label'] as String,
// //             isActive: active,
// //             onTap: () => _onChipTap(i),
// //           );
// //         },
// //       ),
// //     );
// //   }
// // }
// //
// // class _FilterChip extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final bool isActive;
// //   final VoidCallback onTap;
// //
// //   const _FilterChip({
// //     required this.icon,
// //     required this.label,
// //     required this.isActive,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 160),
// //         curve: Curves.easeOut,
// //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
// //         decoration: BoxDecoration(
// //           color: isActive ? restaurentsnewcolour.text : AppColors.surface,
// //           borderRadius: BorderRadius.circular(8.r),
// //           border: Border.all(
// //             color: isActive ? restaurentsnewcolour.text : AppColors.border,
// //             width: 1.5,
// //           ),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(
// //               icon,
// //               size: 14.sp,
// //               color: isActive ? Colors.white : restaurentsnewcolour.textMuted,
// //             ),
// //             SizedBox(width: 5.w),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 fontWeight: FontWeight.w600,
// //                 color: isActive ? Colors.white : restaurentsnewcolour.textMuted,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // // ─── Filter bottom sheet ──────────────────────────────────────────────────────
// //
// // class FilterBottomSheet extends StatefulWidget {
// //   const FilterBottomSheet({super.key});
// //
// //   @override
// //   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// // }
// //
// // class _FilterBottomSheetState extends State<FilterBottomSheet> {
// //   int _tab = 0;
// //   // selected[tabIndex] = Set of option indices
// //   final Map<int, Set<int>> _selected = {};
// //
// //   Set<int> _opts(int tab) => _selected.putIfAbsent(tab, () => {});
// //
// //   void _toggleOpt(int tab, int opt) {
// //     setState(() {
// //       final s = _opts(tab);
// //       s.contains(opt) ? s.remove(opt) : s.add(opt);
// //     });
// //   }
// //
// //   void _clearAll() => setState(() => _selected.clear());
// //
// //   int get _totalSelected =>
// //       _selected.values.fold(0, (sum, s) => sum + s.length);
// //
// //   int get _resultCount => (24 - _totalSelected * 3).clamp(2, 24);
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Column(
// //       children: [
// //         _Handle(),
// //         _Header(onClear: _clearAll),
// //         Expanded(
// //           child: Row(
// //             children: [
// //               _LeftNav(
// //                 selected: _tab,
// //                 onSelect: (i) => setState(() => _tab = i),
// //               ),
// //               Expanded(
// //                 child: _RightPanel(
// //                   tab: _tab,
// //                   selectedOpts: _opts(_tab),
// //                   onToggle: (opt) => _toggleOpt(_tab, opt),
// //                 ),
// //               ),
// //             ],
// //           ),
// //         ),
// //         _ResultCount(count: _resultCount),
// //         _Footer(),
// //       ],
// //     );
// //   }
// // }
// //
// // // ── Sub-widgets ──────────────────────────────────────────────────────────────
// //
// // class _Handle extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Center(
// //     child: Container(
// //       margin: EdgeInsets.symmetric(vertical: 10.h),
// //       width: 36.w,
// //       height: 4.h,
// //       decoration: BoxDecoration(
// //         color: AppColors.border,
// //         borderRadius: BorderRadius.circular(2.r),
// //       ),
// //     ),
// //   );
// // }
// //
// // class _Header extends StatelessWidget {
// //   final VoidCallback onClear;
// //   const _Header({required this.onClear});
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 12.h),
// //     decoration: BoxDecoration(
// //       border: Border(bottom: BorderSide(color: AppColors.border)),
// //     ),
// //     child: Row(
// //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
// //       children: [
// //         Text(
// //           'Filters & sorting',
// //           style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600),
// //         ),
// //         GestureDetector(
// //           onTap: onClear,
// //           child: Text(
// //             'Clear all',
// //             style: TextStyle(
// //               fontSize: 12.sp,
// //               fontWeight: FontWeight.w500,
// //               color: AppColors.primary,
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // class _LeftNav extends StatelessWidget {
// //   final int selected;
// //   final ValueChanged<int> onSelect;
// //
// //   const _LeftNav({required this.selected, required this.onSelect});
// //
// //   @override
// //   Widget build(BuildContext context) => Container(
// //     width: 88.w,
// //     decoration: BoxDecoration(
// //       color: restaurentsnewcolour.bg,
// //       border: Border(right: BorderSide(color: AppColors.border)),
// //     ),
// //     child: ListView.builder(
// //       itemCount: RestaurentsHelper.menu.length,
// //       itemBuilder: (_, i) {
// //         final active = selected == i;
// //         return InkWell(
// //           onTap: () => onSelect(i),
// //           child: AnimatedContainer(
// //             duration: const Duration(milliseconds: 140),
// //             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
// //             decoration: BoxDecoration(
// //               color: active ? AppColors.surface : Colors.transparent,
// //               border: Border(
// //                 left: BorderSide(
// //                   color: active ? AppColors.primary : Colors.transparent,
// //                   width: 3,
// //                 ),
// //               ),
// //             ),
// //             child: Text(
// //               RestaurentsHelper.menu[i],
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 fontWeight: active ? FontWeight.w600 : FontWeight.w400,
// //                 color: active
// //                     ? restaurentsnewcolour.text
// //                     : restaurentsnewcolour.textMuted,
// //               ),
// //             ),
// //           ),
// //         );
// //       },
// //     ),
// //   );
// // }
// //
// // class _RightPanel extends StatelessWidget {
// //   final int tab;
// //   final Set<int> selectedOpts;
// //   final ValueChanged<int> onToggle;
// //
// //   const _RightPanel({
// //     required this.tab,
// //     required this.selectedOpts,
// //     required this.onToggle,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     final data = RestaurentsHelper.panelData[tab];
// //     final title = data['title'] as String;
// //     final opts = data['opts'] as List<Map<String, Object>>;
// //
// //     return SingleChildScrollView(
// //       padding: EdgeInsets.all(16.w),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
// //           Text(
// //             title.toUpperCase(),
// //             style: TextStyle(
// //               fontSize: 10.sp,
// //               fontWeight: FontWeight.w600,
// //               color: restaurentsnewcolour.textMuted,
// //               letterSpacing: 0.6,
// //             ),
// //           ),
// //           SizedBox(height: 12.h),
// //           Wrap(
// //             spacing: 8.w,
// //             runSpacing: 8.h,
// //             children: List.generate(opts.length, (i) {
// //               final o = opts[i];
// //               final sel = selectedOpts.contains(i);
// //               return _OptionChip(
// //                 icon: o['icon'] as IconData,
// //                 label: o['label'] as String,
// //                 isSelected: sel,
// //                 onTap: () => onToggle(i),
// //               );
// //             }),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }
// //
// // class _OptionChip extends StatelessWidget {
// //   final IconData icon;
// //   final String label;
// //   final bool isSelected;
// //   final VoidCallback onTap;
// //
// //   const _OptionChip({
// //     required this.icon,
// //     required this.label,
// //     required this.isSelected,
// //     required this.onTap,
// //   });
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return GestureDetector(
// //       onTap: onTap,
// //       child: AnimatedContainer(
// //         duration: const Duration(milliseconds: 140),
// //         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
// //         decoration: BoxDecoration(
// //           color: isSelected
// //               ? AppColors.primary.withOpacity(0.08)
// //               : AppColors.surface,
// //           border: Border.all(
// //             color: isSelected ? AppColors.primary : AppColors.border,
// //             width: isSelected ? 1.5 : 1,
// //           ),
// //           borderRadius: BorderRadius.circular(10.r),
// //         ),
// //         child: Row(
// //           mainAxisSize: MainAxisSize.min,
// //           children: [
// //             Icon(
// //               icon,
// //               size: 14.sp,
// //               color: isSelected
// //                   ? AppColors.primary
// //                   : restaurentsnewcolour.green,
// //             ),
// //             SizedBox(width: 6.w),
// //             Text(
// //               label,
// //               style: TextStyle(
// //                 fontSize: 12.sp,
// //                 fontWeight: FontWeight.w500,
// //                 color: isSelected
// //                     ? AppColors.primary
// //                     : restaurentsnewcolour.text,
// //               ),
// //             ),
// //           ],
// //         ),
// //       ),
// //     );
// //   }
// // }
// //
// // class _ResultCount extends StatelessWidget {
// //   final int count;
// //   const _ResultCount({required this.count});
// //
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //     padding: EdgeInsets.symmetric(vertical: 6.h),
// //     child: Text(
// //       '$count restaurants match your filters',
// //       style: TextStyle(fontSize: 11.sp, color: restaurentsnewcolour.textMuted),
// //       textAlign: TextAlign.center,
// //     ),
// //   );
// // }
// //
// // class _Footer extends StatelessWidget {
// //   @override
// //   Widget build(BuildContext context) => Padding(
// //     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 20.h),
// //     child: Row(
// //       children: [
// //         Expanded(
// //           child: OutlinedButton(
// //             onPressed: () => Navigator.pop(context),
// //             style: OutlinedButton.styleFrom(
// //               side: BorderSide(color: AppColors.border),
// //               padding: EdgeInsets.symmetric(vertical: 12.h),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8.r),
// //               ),
// //               foregroundColor: restaurentsnewcolour.textMuted,
// //             ),
// //             child: Text(
// //               'Close',
// //               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
// //             ),
// //           ),
// //         ),
// //         SizedBox(width: 10.w),
// //         Expanded(
// //           flex: 2,
// //           child: ElevatedButton(
// //             onPressed: () => Navigator.pop(context),
// //             style: ElevatedButton.styleFrom(
// //               backgroundColor: AppColors.primary,
// //               foregroundColor: Colors.white,
// //               elevation: 0,
// //               padding: EdgeInsets.symmetric(vertical: 12.h),
// //               shape: RoundedRectangleBorder(
// //                 borderRadius: BorderRadius.circular(8.r),
// //               ),
// //             ),
// //             child: Text(
// //               'Show results',
// //               style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
// //             ),
// //           ),
// //         ),
// //       ],
// //     ),
// //   );
// // }
// //
// // // ══════════════════════════════════════════════════════════════════════════════
// // // SEARCH BAR HEADER DELEGATE  (kept for external compatibility)
// // // ══════════════════════════════════════════════════════════════════════════════
// // class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
// //   final ValueChanged<String> onSearchChanged;
// //   final VoidCallback? onFilterPressed;
// //   final double height;
// //
// //   const SearchBarHeaderDelegate({
// //     required this.onSearchChanged,
// //     required this.height,
// //     this.onFilterPressed,
// //   });
// //
// //   @override
// //   double get minExtent => height;
// //   @override
// //   double get maxExtent => height;
// //
// //   @override
// //   Widget build(BuildContext ctx, double shrink, bool overlaps) {
// //     return Container(
// //       color: restaurentsnewcolour.surface,
// //       padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
// //       child: _SearchBar(onChanged: onSearchChanged),
// //     );
// //   }
// //
// //   @override
// //   bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
// // }
//
// import 'dart:async';
// import 'package:custom_cached_image/custom_cached_image.dart';
//
// import '../../../widgets/safearea.dart';
// import '../../../widgets/widgets/couponcards.dart';
// import '../../Logistics&supply/logistics_homepage.dart';
// import '../../Logistics&supply/logistiscscreen.dart';
// import '../Menu/menu_screen.dart';
// import '../distancehelpermethod.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter/foundation.dart';
// import '../../screens/notifications.dart';
// import '../../screens/saved_address.dart';
// import '../../skeleton/Restaurents_screen.dart';
// import '../../Catering&Services/Caterings.dart';
// import 'package:in_app_update/in_app_update.dart';
// import '../../screens/advertisements/Advideo.dart';
// import '../../../Models/food/food_categries_model.dart';
// import '../../../Models/food/restaurent_banner_model.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../../../Services/App_color_service/app_colours.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import '../../screens/advertisements/banneradvertisement.dart';
// import '../../../Services/googleservices/Location_servces.dart';
// import '../../../Models/promotions_model/promotions_model.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
// import '../../../Services/Auth_service/Subscription_authservice.dart';
// import '../../../Services/Auth_service/promotion_services_Authservice.dart';
// import 'package:maamaas/screens/Food&beverages/RestaurentsScreen/RestaurentsHelper.dart';
//
// class Restaurentshmepage extends StatefulWidget {
//   final ScrollController scrollController;
//   const Restaurentshmepage({super.key, required this.scrollController});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _RestaurentsState createState() => _RestaurentsState();
// }
//
// class _RestaurentsState extends State<Restaurentshmepage> {
//   // ── State ──────────────────────────────────────────────────────────────────
//   String _currentLocation = 'Fetching location...';
//   bool _updateAvailable = false;
//   AppUpdateInfo? _updateInfo;
//   String? selectedOrderType;
//   bool _isBannerCollapsed = false;
//   List<FoodCategory> categories = [];
//   bool isCategoriesLoading = true;
//   int selectedCategoryIndex = 0;
//   List<int>? selectedCategoryVendorIds;
//   String? selectedCategoryName;
//   String searchText = '';
//   Timer? _debounce;
//   bool _isLoggedIn = false;
//   bool _isGuestLocationLoading = false;
//   int _activeFilterIndex = -1;
//   List<Campaign> homepageAds = [];
//   bool _highlightOrderTabs = false;
//   bool _showOrderTypeHint = false;
//   final ValueNotifier<String?> selectedOrderTypeNotifier = ValueNotifier(null);
//
//   final GlobalKey _orderTypeKey = GlobalKey();
//   bool _hasShownLocationDialog = false;
//
//   // ── Top nav tabs (Food / Logistics) ──────────────────────────────────────
//   int _selectedTopNavIndex = 0;
//   final List<Map<String, dynamic>> _topNavTabItems = [
//     {'icon': Icons.restaurant_rounded, 'label': 'Food'},
//     {'icon': Icons.local_shipping_rounded, 'label': 'Logistics'},
//   ];
//
//   int _refreshKey = 0;
//   String? _locationCategory;
//
//   // ── Banner height ──────────────────────────────────────────────────────────
//   double get _bannerHeight {
//     final h = MediaQuery.of(context).size.height;
//     return (h * 0.70).clamp(250.0, 350.0);
//   }
//
//   // ── Lifecycle ──────────────────────────────────────────────────────────────
//   @override
//   void initState() {
//     super.initState();
//     widget.scrollController.addListener(_onScroll);
//     _checkLogin().then((_) {
//       if (_isLoggedIn) {
//         _loadLocationFromAPI();
//       } else {
//         _loadGuestLocation();
//       }
//     });
//     if (kReleaseMode) {
//       _checkForUpdate();
//     }
//     _fetchCategories();
//     _checkLogin();
//     _loadAds();
//   }
//
//   @override
//   void dispose() {
//     _debounce?.cancel();
//     widget.scrollController.removeListener(_onScroll);
//     selectedOrderTypeNotifier.dispose();
//     super.dispose();
//   }
//
//   // ── Scroll listener ────────────────────────────────────────────────────────
//   void _onScroll() {
//     final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
//     final collapsed = widget.scrollController.offset > collapseThreshold;
//     if (collapsed != _isBannerCollapsed && mounted) {
//       setState(() => _isBannerCollapsed = collapsed);
//     }
//   }
//
//   // ── Auth / Location ────────────────────────────────────────────────────────
//   Future<void> _checkLogin() async {
//     final v = await subscription_AuthService.isLoggedIn();
//     if (mounted) setState(() => _isLoggedIn = v);
//   }
//
//   Future<void> _loadGuestLocation() async {
//     setState(() => _isGuestLocationLoading = true);
//     try {
//       final r = await LocationService.getCurrentLocationWithAddress();
//       if (!mounted) return;
//       if (r != null) {
//         final parts = [
//           r.area,
//           r.adminArea,
//           r.city,
//           r.state,
//         ].where((e) => e != null && e.isNotEmpty).toList();
//         final addr = parts.join(', ');
//         setState(() {
//           _currentLocation = (r.pincode != null && r.pincode!.isNotEmpty)
//               ? '$addr - ${r.pincode}'
//               : addr;
//         });
//       } else {
//         setState(() => _currentLocation = 'Enable location');
//       }
//     } catch (e) {
//       //       debugPrint('Guest location error: $e');
//       if (mounted) setState(() => _currentLocation = 'Location unavailable');
//     } finally {
//       if (mounted) setState(() => _isGuestLocationLoading = false);
//     }
//   }
//
//   Future<void> _loadLocationFromAPI() async {
//     try {
//       final loc = await subscription_AuthService.fetchCurrentLocation();
//
//       if (!mounted) return;
//
//       // print("📍 RAW LOC: $loc");
//       // print("📍 ADDRESS CHECK: ${loc?.address}");
//       // print("📍 VALID: ${loc?.address.trim().isNotEmpty}");
//
//       // ✅ VALID LOCATION CHECK
//       final isValidLocation = loc != null && loc.address.trim().isNotEmpty;
//
//       if (isValidLocation) {
//         setState(() {
//           _currentLocation = loc.address;
//           _locationCategory = loc.category;
//         });
//
//         // ✅ Reset dialog flag (important if user later deletes address)
//         _hasShownLocationDialog = false;
//       } else {
//         _handleInvalidLocation();
//       }
//     } catch (e) {
//       //       debugPrint("❌ Location API Error: $e");
//       if (!mounted) return;
//
//       _handleInvalidLocation();
//     }
//   }
//
//   void _handleInvalidLocation() {
//     // ❌ Don't immediately show popup
//     Future.delayed(const Duration(milliseconds: 500), () {
//       if (!mounted) return;
//
//       if (_currentLocation == 'Fetching location...') {
//         if (!_hasShownLocationDialog) {
//           _hasShownLocationDialog = true;
//
//           WidgetsBinding.instance.addPostFrameCallback((_) {
//             if (mounted) {
//               _showUpdateLocationDialog();
//             }
//           });
//         }
//       }
//     });
//   }
//
//   void _showUpdateLocationDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(16.r),
//         ),
//         title: Row(
//           children: [
//             const Icon(Icons.location_off, color: Colors.red),
//             SizedBox(width: 8.w),
//             Text('Location Required', style: TextStyle(fontSize: 16.sp)),
//           ],
//         ),
//         content: Text(
//           "We couldn't detect your location. Please update to continue.",
//           style: TextStyle(fontSize: 13.sp),
//         ),
//         actions: [
//           ElevatedButton(
//             onPressed: () {
//               Navigator.pop(context);
//               _changeLocation();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: restaurentsnewcolour.primary,
//               foregroundColor: Colors.white,
//             ),
//             child: const Text('Update Location'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _changeLocation() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SavedAddress(
//           onAddressSelected: (address) async {
//             setState(() {
//               // _currentLocation =
//               //     '${address.},${address.city}, ${address.state} - ${address.pincode}';
//               // _locationCategory = address.category;
//               _currentLocation = address.fullAddress;
//
//               // print("Category: ${address.category}");
//             });
//             _hasShownLocationDialog = false;
//             await _refreshAll();
//           },
//         ),
//       ),
//     );
//   }
//
//   // ── Data ───────────────────────────────────────────────────────────────────
//   Future<void> _fetchCategories() async {
//     setState(() => isCategoriesLoading = true);
//     try {
//       final res = await Authservice.fetchFoodCategories();
//       if (!mounted) return;
//       setState(() {
//         categories = res;
//         selectedCategoryIndex = 0;
//         selectedCategoryVendorIds = null;
//       });
//     } catch (e) {
//       //       debugPrint('Category error: $e');
//       if (mounted) setState(() => categories = []);
//     } finally {
//       if (mounted) setState(() => isCategoriesLoading = false);
//     }
//   }
//
//   Future<void> _loadAds() async {
//     try {
//       final result = await promotion_Authservice.fetchcampaign();
//       final filtered = result
//           .where(
//             (c) =>
//                 c.addDisplayPosition == AddDisplayPosition.HOMEPAGE_BANNER &&
//                 c.medium == Medium.APP,
//           )
//           .toList();
//       if (mounted) setState(() => homepageAds = filtered);
//     } catch (e) {
//       //       debugPrint('Ads error: $e');
//     }
//   }
//
//   Future<void> _refreshAll() async {
//     //     debugPrint("🔄 _refreshAll() STARTED");
//
//     try {
//       await Future.wait([_fetchCategories(), _loadAds()]);
//       //
//       //       debugPrint("✅ APIs completed successfully");
//     } catch (e) {
//       //       debugPrint("❌ Error in _refreshAll(): $e");
//     }
//
//     if (mounted) {
//       setState(() {
//         _refreshKey++;
//       });
//       //       debugPrint("🔁 UI refreshed, refreshKey: $_refreshKey");
//     } else {
//       //       debugPrint("⚠️ Widget not mounted, skipping setState");
//     }
//     //
//     //     debugPrint("🏁 _refreshAll() FINISHED");
//   }
//
//   // ── Update ─────────────────────────────────────────────────────────────────
//   Future<void> _checkForUpdate() async {
//     try {
//       final info = await InAppUpdate.checkForUpdate();
//       if (!mounted) return;
//       setState(() {
//         _updateInfo = info;
//         _updateAvailable =
//             info.updateAvailability == UpdateAvailability.updateAvailable;
//       });
//     } catch (e) {
//       //       debugPrint('Update check failed: $e');
//     }
//   }
//
//   void _startFlexibleUpdate() async {
//     if (_updateInfo != null) {
//       try {
//         await InAppUpdate.performImmediateUpdate();
//       } catch (e) {
//         //         debugPrint('Update error: $e');
//       }
//     }
//   }
//
//   // ── Order type ─────────────────────────────────────────────────────────────
//
//   String? _getApiOrderType() {
//     if (selectedOrderType == null) return null;
//
//     final raw = selectedOrderType!;
//     final normalized = raw.toLowerCase().trim();
//
//     final mapped = RestaurentsHelper.typeMapping[normalized];
//     //
//     //     debugPrint("📦 API Type: $mapped");
//
//     return mapped;
//   }
//
//   Future<void> _handleOrderTypeSelection(String type) async {
//     final cleanType = type.toLowerCase().trim();
//
//     /// ✅ 👉 HANDLE CATERING LOCALLY
//     if (cleanType == "catering") {
//       if (!mounted) return;
//
//       setState(() {
//         selectedOrderType = cleanType;
//       });
//
//       selectedOrderTypeNotifier.value = cleanType;
//
//       // print("🎯 Catering selected → No API call");
//       return; // 🚫 STOP HERE
//     }
//
//     /// ✅ OTHER TYPES → CALL API
//     final api = RestaurentsHelper.typeMapping[cleanType];
//
//     if (api == null) {
//       //       debugPrint("❌ Mapping failed for: $cleanType");
//       return;
//     }
//
//     // print("🚀 Trying to create cart for: $cleanType");
//
//     final result = await food_Authservice.createCart(api);
//
//     if (result["success"] == true) {
//       if (!mounted) return;
//
//       setState(() {
//         selectedOrderType = cleanType;
//       });
//
//       selectedOrderTypeNotifier.value = cleanType;
//     } else {
//       final message = result["message"] ?? "Something went wrong";
//
//       if (!mounted) return;
//       AppAlert.error(context, message);
//     }
//   }
//
//   void _focusOrderTypeSelection() {
//     final context = _orderTypeKey.currentContext;
//
//     if (context != null) {
//       Scrollable.ensureVisible(
//         context,
//         duration: const Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//         alignment: 0.1, // 👈 keeps it slightly below top
//       );
//     }
//
//     setState(() {
//       _highlightOrderTabs = true;
//       _showOrderTypeHint = true;
//     });
//
//     Future.delayed(const Duration(seconds: 2), () {
//       if (mounted) setState(() => _highlightOrderTabs = false);
//     });
//
//     Future.delayed(const Duration(seconds: 3), () {
//       if (mounted) setState(() => _showOrderTypeHint = false);
//     });
//   }
//
//   // ── Debounce search ────────────────────────────────────────────────────────
//   void _onSearchChanged(String value) {
//     _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 400), () {
//       if (mounted) setState(() => searchText = value);
//     });
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   // BUILD
//   // ══════════════════════════════════════════════════════════════════════════
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // backgroundColor: restaurentsnewcolour.bg,
//       backgroundColor: Colors.white,
//       extendBodyBehindAppBar: false,
//       body: SafeArea(
//         top: false,
//         bottom: false,
//         child: Column(
//           children: [
//             SizedBox(height: 10),
//             // ── Persistent Food / Logistics switch ──────────────────────
//             _topNavTabs(),
//             Expanded(
//               child: _selectedTopNavIndex == 0
//                   ? _buildFoodBody()
//                   // : _buildLogisticsBody(),
//                   : LogisticsScreen(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   // FOOD BODY — everything that used to be the whole screen
//   // ══════════════════════════════════════════════════════════════════════════
//   Widget _buildFoodBody() {
//     return RefreshIndicator(
//       strokeWidth: 2,
//       color: restaurentsnewcolour.primary,
//       backgroundColor: restaurentsnewcolour.surface,
//       onRefresh: _refreshAll,
//       child: Stack(
//         children: [
//           CustomScrollView(
//             controller: widget.scrollController,
//             physics: const AlwaysScrollableScrollPhysics(),
//             slivers: [
//               SliverAppBar(
//                 expandedHeight: _bannerHeight,
//                 collapsedHeight: kToolbarHeight,
//                 pinned: true,
//                 elevation: 0,
//                 scrolledUnderElevation: 0,
//
//                 backgroundColor: _isBannerCollapsed
//                     ? restaurentsnewcolour.surface
//                     : Colors.transparent,
//
//                 systemOverlayStyle: _isBannerCollapsed
//                     ? SystemUiOverlayStyle.dark
//                     : SystemUiOverlayStyle.light,
//
//                 automaticallyImplyLeading: false,
//
//                 title: _isBannerCollapsed ? _buildCollapsedBar() : null,
//                 flexibleSpace: FlexibleSpaceBar(
//                   collapseMode: CollapseMode.pin,
//                   background: _buildHeroBanner(),
//                 ),
//               ),
//
//               // ── 2. Sticky search bar ────────────────────────────────
//               if (selectedOrderType != 'catering')
//                 SliverPersistentHeader(
//                   pinned: true,
//                   delegate: _StickyDelegate(
//                     height: 70.h, // ✅ FIXED
//                     child: Container(
//                       color: restaurentsnewcolour.surface,
//                       child: Column(
//                         children: [
//                           Padding(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 16.w,
//                               vertical: 10.h,
//                             ),
//                             child: SizedBox(
//                               width: double.infinity,
//                               child: _SearchBar(onChanged: _onSearchChanged),
//                             ),
//                           ),
//                           // Divider(height: 1, color: restaurentsnewcolour.border),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//               // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
//
//               // ── 3. Coupon offers ────────────────────────────────────
//               SliverToBoxAdapter(child: CouponsOffersSection()),
//
//               // SliverToBoxAdapter(child: SizedBox(height: 8.h)),
//
//               // ── 4. Divider ──────────────────────────────────────────
//               // SliverToBoxAdapter(child: _Divider()),
//
//               // ── 5. Food categories ──────────────────────────────────
//               if (selectedOrderType != 'catering')
//                 SliverPersistentHeader(
//                   pinned: true,
//                   delegate: _StickyDelegate(
//                     height: 120.h,
//                     // height: 95.h,
//                     child: Container(
//                       color: restaurentsnewcolour.surface,
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Padding(
//                             // padding: EdgeInsets.fromLTRB(16.w, 10.h, 0, 6.h),
//                             padding: EdgeInsets.fromLTRB(
//                               16.w,
//                               4.h, // reduced from 10.h
//                               0,
//                               4.h, // reduced from 6.h
//                             ),
//                             child: Text(
//                               "What's on your mind?",
//                               style: TextStyle(
//                                 fontSize: 16.sp,
//                                 fontWeight: FontWeight.w700,
//                                 color: restaurentsnewcolour.text,
//                               ),
//                             ),
//                           ),
//                           Expanded(child: _buildFoodCategories()),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//
//               // SliverToBoxAdapter(child: _Divider()),
//
//               // ── 6. Order type tabs (sticky) ─────────────────────────
//               SliverPersistentHeader(
//                 key: _orderTypeKey,
//                 pinned: false,
//                 delegate: _StickyDelegate(
//                   height: _showOrderTypeHint ? 88.h : 58.h,
//
//                   // height: _showOrderTypeHint ? 165.h : 115.h,
//                   child: Container(
//                     color: restaurentsnewcolour.surface,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Padding(
//                           padding: EdgeInsets.symmetric(
//                             horizontal: 16.w,
//                             // vertical: 10.h,
//                             vertical: 10.h,
//                           ),
//                           child: _buildOrderTypeTabs(),
//                         ),
//                         if (_showOrderTypeHint)
//                           AnimatedOpacity(
//                             duration: const Duration(milliseconds: 300),
//                             opacity: _showOrderTypeHint ? 1 : 0,
//                             child: Padding(
//                               padding: EdgeInsets.only(bottom: 6.h),
//                               child: Text(
//                                 '👆 Please select an order type',
//                                 style: TextStyle(
//                                   fontSize: 16.sp,
//                                   color: Colors.red.shade600,
//                                   fontWeight: FontWeight.w500,
//                                 ),
//                               ),
//                             ),
//                           ),
//                         // Divider(height: 1, color: restaurentsnewcolour.border),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//
//               // ── 7. Filter chips ─────────────────────────────────────
//               SliverPersistentHeader(
//                 pinned: false,
//                 delegate: _StickyDelegate(
//                   height: 50.h,
//                   child: Container(
//                     color: restaurentsnewcolour.surface,
//                     child: _buildFilterChips(),
//                   ),
//                 ),
//               ),
//
//               SliverToBoxAdapter(child: SizedBox(height: 4.h)),
//               //
//               // // ── 8. Offer filter strip ───────────────────────────────
//               SliverToBoxAdapter(child: _buildOfferStrip()),
//
//               // ── 9. Restaurant list header ───────────────────────────
//               if (selectedOrderType != 'catering')
//                 SliverToBoxAdapter(
//                   child: Padding(
//                     padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 4.h),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           'Restaurants Near You',
//                           style: TextStyle(
//                             fontSize: 18.sp,
//                             fontWeight: FontWeight.w700,
//                             color: restaurentsnewcolour.text,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               SliverToBoxAdapter(child: SizedBox(height: 1.h)),
//
//               // ── 10. Restaurant cards ────────────────────────────────
//               SliverToBoxAdapter(child: _buildRestaurantList()),
//
//               SliverToBoxAdapter(child: SizedBox(height: 32.h)),
//             ],
//           ),
//
//           // ── Update banner ───────────────────────────────────────────
//           if (_updateAvailable)
//             Positioned(
//               left: 16.w,
//               right: 16.w,
//               bottom: 16.h,
//               child: SafeArea(child: _buildUpdateBanner()),
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   // LOGISTICS BODY — placeholder for the fully separate Logistics experience
//   // ══════════════════════════════════════════════════════════════════════════
//   Widget _buildLogisticsBody() {
//     return Container(
//       width: double.infinity,
//       color: Colors.white,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Spacer(),
//           Icon(
//             Icons.local_shipping_rounded,
//             size: 64.sp,
//             color: restaurentsnewcolour.primary,
//           ),
//           SizedBox(height: 16.h),
//           Text(
//             'Logistics',
//             style: TextStyle(
//               fontSize: 20.sp,
//               fontWeight: FontWeight.w700,
//               color: restaurentsnewcolour.text,
//             ),
//           ),
//           SizedBox(height: 8.h),
//           Padding(
//             padding: EdgeInsets.symmetric(horizontal: 32.w),
//             child: Text(
//               'Your Logistics screen goes here — replace this placeholder '
//               'with the real Logistics UI/flow.',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: restaurentsnewcolour.textMuted,
//               ),
//             ),
//           ),
//           const Spacer(),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildHeroBanner() {
//     return SizedBox.expand(
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           /// 🔹 Background (Ad / Video)
//           _isLoggedIn
//               ? (homepageAds.isEmpty
//                     ? Container(color: const Color(0xFFCCCCCC))
//                     : BannerAdvertisement(
//                         ads: homepageAds,
//                         height: _bannerHeight,
//                       ))
//               : const VideoPreviewContainer(),
//
//           /// 🔹 Gradient overlay
//           IgnorePointer(
//             child: const DecoratedBox(
//               decoration: BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topCenter,
//                   end: Alignment.bottomCenter,
//                   colors: [
//                     Color(0x99000000),
//                     Color(0x33000000),
//                     Colors.transparent,
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//           /// 🔹 Top Content (SafeArea prevents notch overlap)
//           // IgnorePointer(
//           //   child:
//           SafeArea(
//             bottom: false,
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 10),
//
//                   /// 📍 Location + Notification Row
//                   Row(
//                     children: [
//                       Expanded(
//                         child: _buildLocationContent(
//                           isDark: false, // white text
//                           isExpanded: true, // bigger UI
//                         ),
//                       ),
//
//                       /// 🔔 Notification Icon
//                       GestureDetector(
//                         onTap: () {
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => NotificationScreen(),
//                             ),
//                           );
//                         },
//                         child: Container(
//                           width: 36.w,
//                           height: 36.w,
//                           decoration: BoxDecoration(
//                             // ignore: deprecated_member_use
//                             color: Colors.white.withOpacity(0.2),
//                             shape: BoxShape.circle,
//                           ),
//                           child: const Icon(
//                             Icons.notifications_none_rounded,
//                             color: Colors.white,
//                             size: 20,
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           // ),
//         ],
//       ),
//     );
//   }
//
//   Widget _topNavTabs() {
//     return Container(
//       width: double.infinity,
//       color: Colors.white,
//       padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 6.h),
//       child: Row(
//         children: List.generate(_topNavTabItems.length, (i) {
//           final tab = _topNavTabItems[i];
//           final isSelected = _selectedTopNavIndex == i;
//
//           return Expanded(
//             child: GestureDetector(
//               onTap: () {
//                 if (_selectedTopNavIndex == i) return;
//                 setState(() => _selectedTopNavIndex = i);
//               },
//               child: AnimatedContainer(
//                 duration: const Duration(milliseconds: 200),
//                 curve: Curves.easeInOut,
//                 margin: EdgeInsets.only(
//                   right: i == _topNavTabItems.length - 1 ? 0 : 10.w,
//                 ),
//                 padding: EdgeInsets.symmetric(vertical: 10.h),
//                 decoration: BoxDecoration(
//                   color: isSelected
//                       ? AppColors.primary
//                       : restaurentsnewcolour.bg,
//                   borderRadius: BorderRadius.circular(12.r),
//                   border: Border.all(
//                     color: isSelected
//                         ? AppColors.primary
//                         : restaurentsnewcolour.border,
//                     width: 1.2,
//                   ),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     Icon(
//                       tab['icon'] as IconData,
//                       size: 18.sp,
//                       color: isSelected
//                           ? Colors.white
//                           : restaurentsnewcolour.text,
//                     ),
//                     SizedBox(width: 6.w),
//                     Text(
//                       tab['label'] as String,
//                       style: TextStyle(
//                         fontSize: 13.sp,
//                         fontWeight: FontWeight.w700,
//                         color: isSelected
//                             ? Colors.white
//                             : restaurentsnewcolour.text,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
//
//   Widget _buildCollapsedBar() {
//     return Row(
//       children: [
//         /// 📍 Location Section
//         Expanded(
//           child: _buildLocationContent(
//             isDark: true, // dark text
//             isExpanded: false, // compact UI
//           ),
//         ),
//
//         SizedBox(width: 8.w),
//
//         /// 🔔 Notification Icon
//         GestureDetector(
//           onTap: () {
//             Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => NotificationScreen()),
//             );
//           },
//           child: Container(
//             width: 36.w,
//             height: 36.w,
//             decoration: BoxDecoration(
//               // ignore: deprecated_member_use
//               color: restaurentsnewcolour.primary.withOpacity(
//                 0.1,
//               ), // better visibility
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.notifications_none_rounded,
//               color: restaurentsnewcolour.primary,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildLocationContent({
//     required bool isDark,
//     required bool isExpanded,
//   }) {
//     return _isLoggedIn
//         ? _buildAppBarContent(isDark: isDark, isExpanded: isExpanded)
//         : _buildGuestAppBar(isDark: isDark, isExpanded: isExpanded);
//   }
//
//   IconData _getCategoryIcon() {
//     final cat = (_locationCategory ?? '').toLowerCase();
//
//     switch (cat) {
//       case 'home':
//         return Icons.home_rounded;
//       case 'office':
//         return Icons.work_rounded;
//       case 'others':
//         return Icons.work_rounded;
//       default:
//         return Icons.location_on_rounded;
//     }
//   }
//
//   Widget _buildAppBarContent({required bool isDark, required bool isExpanded}) {
//     final color = isDark ? restaurentsnewcolour.text : Colors.white;
//
//     return GestureDetector(
//       onTap: _changeLocation,
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Icon(_getCategoryIcon(), color: color, size: isExpanded ? 18 : 16),
//           SizedBox(width: isExpanded ? 6.w : 4.w),
//
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 /// 👇 Show only in expanded (Hero)
//                 if (isExpanded)
//                   Text(
//                     (_locationCategory ?? 'Delivering to').replaceFirstMapped(
//                       RegExp(r'^[a-z]'),
//                       (m) => m.group(0)!.toUpperCase(),
//                     ),
//                     style: TextStyle(fontSize: 10.sp, color: Colors.grey),
//                   ),
//                 Text(
//                   _currentLocation,
//                   maxLines: 1,
//                   overflow: TextOverflow.ellipsis,
//                   style: TextStyle(
//                     fontSize: isExpanded ? 14.sp : 13.sp,
//                     fontWeight: FontWeight.w700,
//                     color: color,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//
//           Icon(
//             Icons.keyboard_arrow_down_rounded,
//             color: color,
//             size: isExpanded ? 18 : 20,
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildGuestAppBar({required bool isDark, required bool isExpanded}) {
//     final color = isDark ? restaurentsnewcolour.text : Colors.white;
//     final subColor = isDark ? restaurentsnewcolour.textMuted : Colors.white70;
//
//     return GestureDetector(
//       onTap: () {
//         // Navigate to login or location picker
//       },
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           /// 👇 Show title only in expanded (banner)
//           if (isExpanded)
//             Text(
//               "Current Location",
//               style: TextStyle(
//                 fontSize: 11.sp,
//                 fontWeight: FontWeight.w800,
//                 color: subColor,
//               ),
//             ),
//
//           if (isExpanded) SizedBox(height: 2.h),
//
//           /// 🔄 Loading State
//           if (_isGuestLocationLoading)
//             Row(
//               children: [
//                 Icon(
//                   Icons.location_on_rounded,
//                   color: color,
//                   size: isExpanded ? 18 : 16,
//                 ),
//                 SizedBox(
//                   width: isExpanded ? 14.w : 12.w,
//                   height: isExpanded ? 14.w : 12.w,
//                   child: CircularProgressIndicator(
//                     strokeWidth: 2,
//                     color: color,
//                   ),
//                 ),
//                 SizedBox(width: 6.w),
//                 Text(
//                   "Fetching location...",
//                   style: TextStyle(
//                     fontSize: isExpanded ? 12.sp : 11.sp,
//                     color: color,
//                   ),
//                 ),
//               ],
//             )
//           /// 📍 Location State
//           else
//             Row(
//               children: [
//                 Expanded(
//                   child: Text(
//                     _currentLocation.isNotEmpty
//                         ? _currentLocation
//                         : "Select Location",
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: isExpanded ? 13.sp : 12.sp,
//                       fontWeight: FontWeight.w600,
//                       color: color,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//         ],
//       ),
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   // FOOD CATEGORIES
//   // ══════════════════════════════════════════════════════════════════════════
//
//   List<FoodCategory> get displayCategories {
//     final list = List<FoodCategory>.from(categories);
//
//     final comboIndex = list.indexWhere(
//       (e) => e.name.toLowerCase().contains('offers'),
//     );
//
//     if (comboIndex > 0) {
//       final comboItem = list.removeAt(comboIndex);
//       list.insert(0, comboItem);
//     }
//
//     return list;
//   }
//
//   Widget _buildFoodCategories() {
//     if (isCategoriesLoading) return const CategorySkeleton();
//     if (categories.isEmpty) {
//       return Center(
//         child: Text(
//           'No categories available',
//           style: TextStyle(
//             fontSize: 12.sp,
//             color: restaurentsnewcolour.textMuted,
//           ),
//         ),
//       );
//     }
//     //
//     // final bool hasMore = categories.length > 10;
//     // final int visibleCount = hasMore ? 10 : categories.length;
//     final bool hasMore = displayCategories.length > 10;
//     final int visibleCount = hasMore ? 10 : displayCategories.length;
//     const double dia = 48.0;
//
//     return ListView.separated(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
//       itemCount: visibleCount + 1 + (hasMore ? 1 : 0),
//       separatorBuilder: (_, __) => SizedBox(width: 14.w),
//       itemBuilder: (context, index) {
//         final isAll = index == 0;
//         final isViewAll = hasMore && index == visibleCount + 1;
//         final isSelected = selectedCategoryIndex == index;
//
//         // final item = isAll ? null : categories[index -
//         final item = isAll ? null : displayCategories[index - 1];
//         if (isViewAll) {
//           return _CategoryItem(
//             dia: dia,
//             isSelected: false,
//             label: 'More',
//             onTap: _showAllCategoriesBottomSheet,
//             child: const Icon(
//               Icons.grid_view_rounded,
//               size: 22,
//               color: restaurentsnewcolour.textMuted,
//             ),
//           );
//         }
//
//         return _CategoryItem(
//           dia: dia,
//           isSelected: isSelected,
//           label: isAll ? 'All' : item!.name,
//           child: isAll
//               ? Icon(
//                   Icons.grid_view_rounded,
//                   size: 22,
//                   color: isSelected
//                       ? AppColors.primary
//                       : restaurentsnewcolour.textMuted,
//                 )
//               : (item!.image != null
//                     // ? Image.network(
//                     //     item.image!,
//                     //     // fit: BoxFit.cover,
//                     //     fit: BoxFit.fill,
//                     //     errorBuilder: (_, __, ___) =>
//                     //         const Icon(Icons.fastfood, size: 22),
//                     //   )
//                     // : const Icon(Icons.fastfood, size: 22)),
//                     ? CustomCachedImage(
//                         imageUrl: item.image,
//                         fit: BoxFit.fill,
//                         width: double.infinity,
//                         height: double.infinity,
//                         borderRadius: 0,
//                         isProfile: false,
//                       )
//                     : const Icon(Icons.fastfood, size: 22)),
//           onTap: () => setState(() {
//             selectedCategoryIndex = index;
//             selectedCategoryVendorIds = isAll ? null : item!.vendorIds;
//             selectedCategoryName = isAll ? null : item!.name;
//           }),
//         );
//       },
//     );
//   }
//
//   void _showAllCategoriesBottomSheet() {
//     showModalBottomSheet(
//       backgroundColor: restaurentsnewcolour.surface,
//       context: context,
//       isScrollControlled: true,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//       ),
//       builder: (ctx) {
//         // final remaining = categories.skip(10).toList();
//         final remaining = displayCategories.skip(10).toList();
//         final sheetH = MediaQuery.of(ctx).size.height * 0.6;
//         return PlatformSafeArea(
//           child: Container(
//             height: sheetH,
//             padding: EdgeInsets.all(16.w),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   children: [
//                     Text(
//                       'All Categories',
//                       style: TextStyle(
//                         fontSize: 16.sp,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const Spacer(),
//                     InkWell(
//                       onTap: () => Navigator.pop(ctx),
//                       borderRadius: BorderRadius.circular(20.r),
//                       child: Container(
//                         padding: EdgeInsets.all(6.w),
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//                           // color: restaurentsnewcolour.bg,
//                           color: Colors.white,
//                         ),
//                         child: Icon(
//                           Icons.close,
//                           size: 20.sp,
//                           color: restaurentsnewcolour.text,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 16.h),
//                 Expanded(
//                   child: GridView.builder(
//                     itemCount: remaining.length,
//                     gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                       crossAxisCount: 4,
//                       crossAxisSpacing: 12.w,
//                       mainAxisSpacing: 12.h,
//                       childAspectRatio: 0.75,
//                     ),
//                     itemBuilder: (_, i) {
//                       final item = remaining[i];
//                       return InkWell(
//                         onTap: () {
//                           Navigator.pop(ctx);
//                           setState(() {
//                             // selectedCategoryIndex =
//                             //     categories.indexOf(item) + 1;
//                             selectedCategoryIndex =
//                                 displayCategories.indexOf(item) + 1;
//                             selectedCategoryVendorIds = item.vendorIds;
//                             selectedCategoryName = item.name;
//                           });
//                         },
//                         child: Column(
//                           children: [
//                             Container(
//                               width: 56.h,
//                               height: 56.h,
//                               decoration: BoxDecoration(
//                                 shape: BoxShape.circle,
//                                 color: restaurentsnewcolour.bg,
//                               ),
//                               child: ClipOval(
//                                 child: item.image != null
//                                     ? Image.network(
//                                         item.image!,
//                                         fit: BoxFit.cover,
//                                         errorBuilder: (_, __, ___) =>
//                                             const Icon(Icons.fastfood),
//                                       )
//                                     : const Icon(Icons.fastfood),
//                               ),
//                             ),
//                             SizedBox(height: 6.h),
//                             Text(
//                               item.name,
//                               textAlign: TextAlign.center,
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 10.sp,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // ══════════════════════════════════════════════════════════════════════════
//   // ORDER TYPE TABS
//   // ══════════════════════════════════════════════════════════════════════════
//
//   Widget _buildOrderTypeTabs() {
//     return ValueListenableBuilder<String?>(
//       valueListenable: selectedOrderTypeNotifier,
//       builder: (_, selected, __) {
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 200),
//
//           child: SingleChildScrollView(
//             scrollDirection: Axis.horizontal,
//             child: Row(
//               children: RestaurentsHelper.orderTabs.map((tab) {
//                 final type = tab['type'] as String;
//                 final isSelected = selected == type;
//
//                 return GestureDetector(
//                   onTap: () => _handleOrderTypeSelection(type),
//                   child: AnimatedContainer(
//                     duration: const Duration(milliseconds: 220),
//                     curve: Curves.easeInOut,
//                     margin: EdgeInsets.only(right: 8.w),
//                     padding: EdgeInsets.symmetric(
//                       horizontal: 14.w, // 👈 important for scroll look
//                       vertical: 10.h,
//                     ),
//                     decoration: BoxDecoration(
//                       // color: isSelected ? AppColors.primary : restaurentsnewcolour.surface,
//                       color: isSelected ? Colors.green : AppColors.primary,
//
//                       borderRadius: BorderRadius.circular(10.r),
//
//                       boxShadow: isSelected
//                           ? [
//                               BoxShadow(
//                                 color: restaurentsnewcolour.green.withOpacity(
//                                   0.28,
//                                 ),
//                                 blurRadius: 12,
//                                 offset: const Offset(0, 4),
//                               ),
//                             ]
//                           : [],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min, // 👈 important
//                       children: [
//                         Icon(
//                           tab['icon'] as IconData,
//                           size: 16.sp,
//                           color: isSelected ? Colors.white : Colors.white,
//                         ),
//                         SizedBox(width: 6.w),
//                         Text(
//                           tab['label'] as String,
//                           style: TextStyle(
//                             fontSize: 13.sp,
//                             fontWeight: FontWeight.bold,
//                             color: isSelected ? Colors.white : Colors.white,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // Widget _buildOrderTypeTabs() {
//   //   return ValueListenableBuilder<String?>(
//   //     valueListenable: selectedOrderTypeNotifier,
//   //     builder: (_, selected, __) {
//   //       final itemWidth = (MediaQuery.of(context).size.width - 48.w) / 3;
//   //
//   //       return Wrap(
//   //         alignment: WrapAlignment.center, // 👈 add this
//   //         spacing: 8.w,
//   //         runSpacing: 10.h,
//   //         children: RestaurentsHelper.orderTabs.map((tab) {
//   //           final type = tab['type'] as String;
//   //           final isSelected = selected == type;
//   //
//   //           return GestureDetector(
//   //             onTap: () => _handleOrderTypeSelection(type),
//   //             child: AnimatedContainer(
//   //               duration: const Duration(milliseconds: 220),
//   //               curve: Curves.easeInOut,
//   //               width: itemWidth,
//   //               padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 12.h),
//   //               decoration: BoxDecoration(
//   //                 color: isSelected ? Colors.green : AppColors.primary,
//   //                 borderRadius: BorderRadius.circular(12.r),
//   //                 boxShadow: isSelected
//   //                     ? [
//   //                         BoxShadow(
//   //                           color: restaurentsnewcolour.green.withOpacity(0.25),
//   //                           blurRadius: 10,
//   //                           offset: const Offset(0, 4),
//   //                         ),
//   //                       ]
//   //                     : [],
//   //               ),
//   //               child: Row(
//   //                 mainAxisAlignment: MainAxisAlignment.center,
//   //                 children: [
//   //                   Icon(
//   //                     tab['icon'] as IconData,
//   //                     size: 18.sp,
//   //                     color: Colors.white,
//   //                   ),
//   //
//   //                   SizedBox(width: 6.w),
//   //
//   //                   Flexible(
//   //                     child: Text(
//   //                       tab['label'] as String,
//   //                       overflow: TextOverflow.ellipsis,
//   //                       textAlign: TextAlign.center,
//   //                       style: TextStyle(
//   //                         fontSize: 12.sp,
//   //                         fontWeight: FontWeight.bold,
//   //                         color: Colors.white,
//   //                       ),
//   //                     ),
//   //                   ),
//   //                 ],
//   //               ),
//   //             ),
//   //           );
//   //         }).toList(),
//   //       );
//   //     },
//   //   );
//   // }
//
//   // ═══════════════════════════════════_handleOrderTypeSelection═══════════════════════════════════════
//   // FILTER CHIPS
//   // ══════════════════════════════════════════════════════════════════════════
//
//   Widget _buildFilterChips() {
//     return ListView.separated(
//       scrollDirection: Axis.horizontal,
//       padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
//       itemCount: RestaurentsHelper.filters.length,
//       separatorBuilder: (_, __) => SizedBox(width: 8.w),
//       itemBuilder: (_, i) {
//         final f = RestaurentsHelper.filters[i];
//         final isSelected = _activeFilterIndex == i;
//         return GestureDetector(
//           onTap: () {
//             setState(() => _activeFilterIndex = isSelected ? -1 : i);
//             if (f['label'] == 'Filters') _openFilterBottomSheet();
//           },
//           child: AnimatedContainer(
//             duration: const Duration(milliseconds: 180),
//             padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? restaurentsnewcolour.text
//                   : restaurentsnewcolour.surface,
//               borderRadius: BorderRadius.circular(8.r),
//               border: Border.all(
//                 color: isSelected
//                     ? restaurentsnewcolour.text
//                     : restaurentsnewcolour.border,
//                 width: 1.5,
//               ),
//             ),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Icon(
//                   f['icon'] as IconData,
//                   size: 14.sp,
//                   color: isSelected
//                       ? Colors.white
//                       : restaurentsnewcolour.textMuted,
//                 ),
//                 SizedBox(width: 5.w),
//                 Text(
//                   f['label'] as String,
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w600,
//                     color: isSelected
//                         ? Colors.white
//                         : restaurentsnewcolour.textMuted,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
//
//   // ── Offer strip ───────────────────────────────────────────────────────────
//   Widget _buildOfferStrip() {
//     return SizedBox(
//       height: 68.h,
//       child: ListView.separated(
//         scrollDirection: Axis.horizontal,
//         padding: EdgeInsets.symmetric(horizontal: 16.w),
//         itemCount: RestaurentsHelper.offers.length,
//         separatorBuilder: (_, __) => SizedBox(width: 10.w),
//         itemBuilder: (_, i) {
//           final o = RestaurentsHelper.offers[i];
//           return Container(
//             padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 colors: [Color(o['c1'] as int), Color(o['c2'] as int)],
//                 begin: Alignment.topLeft,
//                 end: Alignment.bottomRight,
//               ),
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   o['title'] as String,
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w800,
//                     color: Colors.white,
//                   ),
//                 ),
//                 Text(
//                   o['sub'] as String,
//                   style: TextStyle(
//                     fontSize: 10.sp,
//                     color: Colors.white70,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   // ── Restaurant list ───────────────────────────────────────────────────────
//   Widget _buildRestaurantList() {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 250),
//       child: selectedOrderType == 'catering'
//           ? CateringsPage(key: const ValueKey('catering'))
//           : NearbyRestaurentBannersWidget(
//               key: ValueKey(
//                 '${_getApiOrderType()}-${selectedCategoryVendorIds?.join(',')}-$searchText-$_refreshKey',
//               ),
//               orderType: _getApiOrderType(),
//               categoryVendorIds: selectedCategoryVendorIds,
//               searchQuery: searchText,
//               onOrderTypeRequired: _focusOrderTypeSelection,
//               selectedCategoryName: selectedCategoryName,
//             ),
//     );
//   }
//
//   // ── Update banner ─────────────────────────────────────────────────────────
//   Widget _buildUpdateBanner() {
//     return Container(
//       decoration: BoxDecoration(
//         color: restaurentsnewcolour.surface,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.1),
//             blurRadius: 20.r,
//             offset: const Offset(0, 4),
//           ),
//         ],
//         border: Border.all(color: restaurentsnewcolour.border),
//       ),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Padding(
//             padding: EdgeInsets.all(14.w),
//             child: Row(
//               children: [
//                 Container(
//                   width: 44.r,
//                   height: 44.r,
//                   decoration: BoxDecoration(
//                     color: Colors.red.withOpacity(0.1),
//                     borderRadius: BorderRadius.circular(12.r),
//                   ),
//                   child: const Icon(
//                     Icons.system_update_rounded,
//                     color: Colors.red,
//                     size: 24,
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Text(
//                     'New Update Available',
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w700,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Divider(height: 1, color: restaurentsnewcolour.border),
//           TextButton(
//             onPressed: _startFlexibleUpdate,
//             style: TextButton.styleFrom(
//               minimumSize: Size.fromHeight(48.h),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.only(
//                   bottomLeft: Radius.circular(16.r),
//                   bottomRight: Radius.circular(16.r),
//                 ),
//               ),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                   'UPDATE NOW',
//                   style: TextStyle(
//                     fontSize: 14.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.red,
//                   ),
//                 ),
//                 SizedBox(width: 8.w),
//                 const Icon(Icons.download_rounded, color: Colors.red, size: 18),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Filter bottom sheet ───────────────────────────────────────────────────
//   void _openFilterBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => FractionallySizedBox(
//         heightFactor: 0.92,
//         child: Container(
//           decoration: BoxDecoration(
//             color: restaurentsnewcolour.surface,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
//           ),
//           child: const FilterBottomSheet(),
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // CATEGORY ITEM  (small, reusable)
// // ══════════════════════════════════════════════════════════════════════════════
// class _CategoryItem extends StatelessWidget {
//   final double dia;
//   final bool isSelected;
//   final String label;
//   final Widget child;
//   final VoidCallback onTap;
//
//   const _CategoryItem({
//     required this.dia,
//     required this.isSelected,
//     required this.label,
//     required this.child,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 220),
//             width: dia,
//             height: dia,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               color: isSelected
//                   ? restaurentsnewcolour.primaryLight
//                   : restaurentsnewcolour.bg,
//               border: isSelected
//                   ? Border.all(color: AppColors.primary, width: 2)
//                   : null,
//             ),
//             child: ClipOval(child: child),
//           ),
//           SizedBox(height: 4.h),
//           SizedBox(
//             width: dia + 8,
//             child: Text(
//               label,
//               maxLines: 1,
//               overflow: TextOverflow.ellipsis,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 fontSize: 10.sp,
//                 fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
//                 color: isSelected
//                     ? AppColors.primary
//                     : restaurentsnewcolour.textMuted,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // SEARCH BAR  (white, used inside the sticky header)
// // ══════════════════════════════════════════════════════════════════════════════
// class _SearchBar extends StatelessWidget {
//   final ValueChanged<String> onChanged;
//
//   const _SearchBar({required this.onChanged});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 44.h,
//       width: double.infinity,
//       child: TextField(
//         onChanged: onChanged,
//         textInputAction: TextInputAction.search,
//         style: TextStyle(
//           fontSize: 14.sp,
//           color: restaurentsnewcolour.text,
//           fontWeight: FontWeight.w500,
//         ),
//         cursorColor: restaurentsnewcolour.primary,
//
//         decoration: InputDecoration(
//           hintText: 'Search restaurants, cuisines...',
//
//           // ✅ Makes it look like a container
//           filled: true,
//           fillColor: restaurentsnewcolour.bg,
//
//           // ✅ Rounded border like container
//           border: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: restaurentsnewcolour.border,
//               width: 1.5,
//             ),
//           ),
//
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: restaurentsnewcolour.border,
//               width: 1.5,
//             ),
//           ),
//
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(12.r),
//             borderSide: BorderSide(
//               color: restaurentsnewcolour.primary,
//               width: 1.5,
//             ),
//           ),
//
//           // ✅ Icon inside field
//           prefixIcon: Icon(
//             Icons.search_rounded,
//             color: restaurentsnewcolour.textLight,
//             size: 20.sp,
//           ),
//
//           // spacing fix
//           contentPadding: EdgeInsets.symmetric(vertical: 0),
//
//           hintStyle: TextStyle(
//             color: restaurentsnewcolour.textLight,
//             fontSize: 13.sp,
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // NEARBY RESTAURANTS WIDGET
// // ══════════════════════════════════════════════════════════════════════════════
// class NearbyRestaurentBannersWidget extends StatefulWidget {
//   final String? orderType;
//   final List<int>? categoryVendorIds;
//   final String? searchQuery;
//   final VoidCallback? onOrderTypeRequired;
//   final String? selectedCategoryName;
//
//   const NearbyRestaurentBannersWidget({
//     super.key,
//     this.orderType,
//     this.categoryVendorIds,
//     this.searchQuery,
//     this.onOrderTypeRequired,
//     this.selectedCategoryName,
//   });
//
//   @override
//   State<NearbyRestaurentBannersWidget> createState() =>
//       _NearbyRestaurentBannersWidgetState();
// }
//
// class _NearbyRestaurentBannersWidgetState
//     extends State<NearbyRestaurentBannersWidget> {
//   late Future<List<Restaurent_Banner>> _future;
//
//   @override
//   void initState() {
//     super.initState();
//     _future = Authservice.fetchnearbyresturents();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Restaurent_Banner>>(
//       future: _future,
//       builder: (_, snap) {
//         if (snap.connectionState == ConnectionState.waiting) {
//           return const RestaurantsSkeleton();
//         }
//         if (snap.hasError) {
//           return _state(Icons.error_outline, 'Error loading restaurants');
//         }
//         if (!snap.hasData || snap.data!.isEmpty) {
//           return _state(Icons.location_off, 'No nearby restaurants');
//         }
//
//         final filtered = snap.data!.where((b) {
//           final matchType =
//               widget.orderType == null ||
//               b.orderTypes.contains(widget.orderType);
//           final matchCat =
//               widget.categoryVendorIds == null ||
//               widget.categoryVendorIds!.contains(b.vendorId);
//           final matchSearch =
//               (widget.searchQuery ?? '').trim().isEmpty ||
//               b.companyName.toLowerCase().contains(
//                 widget.searchQuery!.toLowerCase(),
//               );
//           return matchType && matchCat && matchSearch;
//         }).toList();
//         filtered.sort((a, b) {
//           // Open restaurants first
//           if (a.restaurantStatus != b.restaurantStatus) {
//             return a.restaurantStatus ? -1 : 1;
//           }
//
//           // Then top-rated restaurants
//           final aRating = double.tryParse(a.ratings.toString()) ?? 0.0;
//           final bRating = double.tryParse(b.ratings.toString()) ?? 0.0;
//
//           final aTopRated = aRating >= 4.0;
//           final bTopRated = bRating >= 4.0;
//
//           if (aTopRated != bTopRated) {
//             return bTopRated ? 1 : -1;
//           }
//
//           // Finally by rating (highest first)
//           return b.ratings.compareTo(a.ratings);
//         });
//         for (final r in filtered) {
//           debugPrint("${r.companyName} -> ${r.ratings}");
//         }
//
//         if (filtered.isEmpty) {
//           return _state(Icons.search_off, 'No restaurants match your filter');
//         }
//
//         return ListView.separated(
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           padding: EdgeInsets.symmetric(horizontal: 16.w),
//           itemCount: filtered.length,
//           separatorBuilder: (_, __) => SizedBox(height: 14.h),
//           itemBuilder: (_, i) => _RestaurantCard(
//             banner: filtered[i],
//             orderType: widget.orderType,
//             onOrderTypeRequired: widget.onOrderTypeRequired,
//             selectedCategoryName: widget.selectedCategoryName,
//           ),
//         );
//       },
//     );
//   }
//
//   Widget _state(IconData icon, String msg) {
//     return SizedBox(
//       height: 200.h,
//       child: Center(
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Icon(icon, size: 38.sp, color: restaurentsnewcolour.textLight),
//             SizedBox(height: 10.h),
//             Text(
//               msg,
//               style: TextStyle(
//                 fontSize: 13.sp,
//                 color: restaurentsnewcolour.textMuted,
//               ),
//               textAlign: TextAlign.center,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // RESTAURANT CARD
// // ══════════════════════════════════════════════════════════════════════════════
// class _RestaurantCard extends StatelessWidget {
//   final Restaurent_Banner banner;
//   final String? orderType;
//   final VoidCallback? onOrderTypeRequired;
//   final String? selectedCategoryName;
//
//   const _RestaurantCard({
//     required this.banner,
//     this.orderType,
//     this.onOrderTypeRequired,
//     this.selectedCategoryName,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final double screenH = MediaQuery.of(context).size.height;
//     // final double cardH = (screenH * 0.28).clamp(200.0, 260.0);
//     final double cardH = (screenH * 0.30).clamp(220.0, 280.0);
//     final double imgH = cardH * 0.58;
//
//     return GestureDetector(
//       onTap:
//           // banner.restaurantStatus
//           //     ?
//           () {
//             if (orderType == null) {
//               onOrderTypeRequired?.call();
//               return;
//             }
//
//             Navigator.push(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => MenuScreen(
//                   vendorId: banner.vendorId,
//                   initialCategoryName: selectedCategoryName,
//                   restaurantStatus: banner.restaurantStatus,
//                 ),
//               ),
//             );
//           },
//       // : null,
//       child: IntrinsicHeight(
//         child: ColorFiltered(
//           colorFilter: banner.restaurantStatus
//               ? const ColorFilter.mode(Colors.transparent, BlendMode.dst)
//               : const ColorFilter.matrix(<double>[
//                   // Grayscale matrix
//                   0.2126, 0.7152, 0.0722, 0, 0,
//                   0.2126, 0.7152, 0.0722, 0, 0,
//                   0.2126, 0.7152, 0.0722, 0, 0,
//                   0, 0, 0, 1, 0,
//                 ]),
//           child: Container(
//             decoration: BoxDecoration(
//               color: restaurentsnewcolour.surface,
//               borderRadius: BorderRadius.circular(
//                 restaurentsnewcolour.cardRadius.r,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.07),
//                   blurRadius: 12,
//                   offset: const Offset(0, 4),
//                 ),
//               ],
//             ),
//
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // IMAGE
//                 AspectRatio(
//                   aspectRatio: 10 / 4,
//                   child: Stack(
//                     fit: StackFit.expand,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.vertical(
//                           top: Radius.circular(
//                             restaurentsnewcolour.cardRadius.r,
//                           ),
//                         ),
//                         // child: banner.companyBanner.isNotEmpty
//                         //     ? Image.network(
//                         //         banner.companyBanner,
//                         //         // fit: BoxFit.cover,
//                         //         fit: BoxFit.fill,
//                         //
//                         //         errorBuilder: (_, __, ___) => _placeholder(),
//                         //       )
//                         //     : _placeholder(),
//                         child: banner.companyBanner.isNotEmpty
//                             ? CustomCachedImage(
//                                 imageUrl: banner.companyBanner,
//                                 fit: BoxFit.fill,
//                                 width: double.infinity,
//                                 height: double.infinity,
//                                 borderRadius: 0,
//                                 isProfile: false,
//                               )
//                             : _placeholder(),
//                       ),
//                       if (!banner.restaurantStatus)
//                         Positioned.fill(
//                           child: Container(
//                             color: Colors.black.withOpacity(0.35),
//                           ),
//                         ),
//
//                       if (!banner.restaurantStatus)
//                         const Center(
//                           child: Text(
//                             "Currently Closed",
//                             style: TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 22,
//                               letterSpacing: 2,
//                             ),
//                           ),
//                         ),
//
//                       Positioned(
//                         bottom: 0,
//                         left: 0,
//                         right: 0,
//                         height: 60,
//                         child: const DecoratedBox(
//                           decoration: BoxDecoration(
//                             gradient: LinearGradient(
//                               begin: Alignment.topCenter,
//                               end: Alignment.bottomCenter,
//                               colors: [Colors.transparent, Color(0x66000000)],
//                             ),
//                           ),
//                         ),
//                       ),
//
//                       if ((banner.ratings) >= 4.0)
//                         Positioned(
//                           top: 8,
//                           left: 10,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                               horizontal: 8,
//                               vertical: 3,
//                             ),
//                             decoration: BoxDecoration(
//                               color: Colors.white,
//                               borderRadius: BorderRadius.circular(6),
//                             ),
//                             child: Row(
//                               mainAxisSize: MainAxisSize.min,
//                               children: [
//                                 Icon(
//                                   Icons.star_rounded,
//                                   color: restaurentsnewcolour.primary,
//                                   size: 11,
//                                 ),
//                                 SizedBox(width: 3),
//                                 Text(
//                                   'Top Rated',
//                                   style: TextStyle(
//                                     fontSize: 10,
//                                     fontWeight: FontWeight.w700,
//                                     color: restaurentsnewcolour.primary,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//
//                 // INFO
//                 Padding(
//                   padding: EdgeInsets.symmetric(
//                     horizontal: 12.w,
//                     vertical: 10.h,
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Wrap(
//                               crossAxisAlignment: WrapCrossAlignment.center,
//                               children: [
//                                 Text(
//                                   banner.companyName.toUpperCase(),
//                                   maxLines: 2,
//                                   overflow: TextOverflow.ellipsis,
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w700,
//                                     color: restaurentsnewcolour.text,
//                                   ),
//                                 ),
//
//                                 _dot(),
//
//                                 Text(
//                                   banner.type,
//                                   style: TextStyle(
//                                     fontSize: 14.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: restaurentsnewcolour.text,
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ),
//
//                           if ((banner.ratings) > 0) ...[
//                             SizedBox(width: 8.w),
//
//                             Container(
//                               padding: EdgeInsets.symmetric(
//                                 horizontal: 6.w,
//                                 vertical: 3.h,
//                               ),
//                               decoration: BoxDecoration(
//                                 color: restaurentsnewcolour.green,
//                                 borderRadius: BorderRadius.circular(6.r),
//                               ),
//                               child: Row(
//                                 mainAxisSize: MainAxisSize.min,
//                                 children: [
//                                   const Icon(
//                                     Icons.star_rounded,
//                                     color: Colors.white,
//                                     size: 11,
//                                   ),
//                                   SizedBox(width: 2.w),
//                                   Text(
//                                     banner.ratings.toString(),
//                                     style: TextStyle(
//                                       color: Colors.white,
//                                       fontSize: 11.sp,
//                                       fontWeight: FontWeight.w700,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//
//                       SizedBox(height: 4.h),
//
//                       if (banner.position.isNotEmpty)
//                         Text(
//                           '${banner.position[0].toUpperCase()}${banner.position.substring(1).toLowerCase()}',
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                           style: TextStyle(
//                             fontSize: 11.sp,
//                             color: const Color(0xFF6C63FF),
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//
//                       SizedBox(height: 6.h),
//
//                       Row(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Expanded(
//                             child: Text(
//                               '${banner.addressLine}, ${banner.city}',
//                               maxLines: 2,
//                               overflow: TextOverflow.ellipsis,
//                               style: TextStyle(
//                                 fontSize: 11.sp,
//                                 color: restaurentsnewcolour.textLight,
//                               ),
//                             ),
//                           ),
//
//                           SizedBox(width: 8.w),
//
//                           Text(
//                             Distancehelpermethod.formatDistance(
//                               banner.distance,
//                             ),
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               fontWeight: FontWeight.w600,
//                               color: restaurentsnewcolour.textMuted,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _dot() => Padding(
//     padding: EdgeInsets.symmetric(horizontal: 5.w),
//     child: Container(
//       width: 3,
//       height: 3,
//       decoration: const BoxDecoration(
//         color: restaurentsnewcolour.textLight,
//         shape: BoxShape.circle,
//       ),
//     ),
//   );
//
//   Widget _placeholder() => Container(
//     color: restaurentsnewcolour.bg,
//     child: Center(
//       child: Icon(
//         Icons.restaurant_rounded,
//         size: 32.sp,
//         color: restaurentsnewcolour.textLight,
//       ),
//     ),
//   );
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // STICKY SLIVER DELEGATE
// // ══════════════════════════════════════════════════════════════════════════════
// class _StickyDelegate extends SliverPersistentHeaderDelegate {
//   final double height;
//   final Widget child;
//
//   const _StickyDelegate({required this.height, required this.child});
//
//   @override
//   double get minExtent => height;
//   @override
//   double get maxExtent => height;
//
//   @override
//   Widget build(BuildContext ctx, double shrink, bool overlaps) =>
//       SizedBox.expand(child: child);
//
//   @override
//   bool shouldRebuild(covariant _StickyDelegate old) =>
//       height != old.height || child != old.child;
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // FILTER BOTTOM SHEET
// // ══════════════════════════════════════════════════════════════════════════════
// class FilterBottomSheet extends StatefulWidget {
//   final int initialTab;
//   const FilterBottomSheet({super.key, this.initialTab = 0});
//
//   @override
//   State<FilterBottomSheet> createState() => _FilterBottomSheetState();
// }
//
// class _FilterBottomSheetState extends State<FilterBottomSheet> {
//   int _sel = 0;
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _header(),
//         Expanded(
//           child: Row(
//             children: [
//               _leftMenu(),
//               Expanded(child: _rightContent()),
//             ],
//           ),
//         ),
//         _footer(),
//       ],
//     );
//   }
//
//   Widget _header() => Padding(
//     padding: EdgeInsets.all(16.w),
//     child: Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           'Filters & Sorting',
//           style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
//         ),
//         GestureDetector(
//           onTap: () => setState(() => _sel = 0),
//           child: Text(
//             'Clear all',
//             style: TextStyle(
//               fontSize: 13.sp,
//               color: restaurentsnewcolour.green,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//       ],
//     ),
//   );
//
//   Widget _leftMenu() => Container(
//     width: 90.w,
//     color: restaurentsnewcolour.bg,
//     child: ListView.builder(
//       itemCount: RestaurentsHelper.menu.length,
//       itemBuilder: (_, i) {
//         final sel = _sel == i;
//         return InkWell(
//           onTap: () => setState(() => _sel = i),
//           child: Container(
//             padding: EdgeInsets.all(14.w),
//             decoration: BoxDecoration(
//               color: sel ? restaurentsnewcolour.surface : Colors.transparent,
//               border: Border(
//                 left: BorderSide(
//                   color: sel
//                       ? restaurentsnewcolour.primary
//                       : Colors.transparent,
//                   width: 3,
//                 ),
//               ),
//             ),
//             child: Text(
//               RestaurentsHelper.menu[i],
//               style: TextStyle(
//                 fontSize: 12.sp,
//                 fontWeight: sel ? FontWeight.w700 : FontWeight.w400,
//                 color: sel
//                     ? restaurentsnewcolour.text
//                     : restaurentsnewcolour.textMuted,
//               ),
//             ),
//           ),
//         );
//       },
//     ),
//   );
//
//   Widget _rightContent() {
//     switch (_sel) {
//       case 0:
//         return _panel('Time', [
//           _chip(Icons.schedule_rounded, 'Schedule'),
//           _chip(Icons.flash_on_rounded, 'Near & Fast'),
//         ]);
//       case 1:
//         return _panel('Restaurant Rating', [
//           _chip(Icons.star_rounded, 'Rated 3.5+'),
//           _chip(Icons.star_rounded, 'Rated 4.0+'),
//         ]);
//       case 2:
//         return _panel('Offers', [
//           _chip(Icons.local_offer_rounded, 'Buy 1 Get 1'),
//           _chip(Icons.percent_rounded, 'Deals of the Day'),
//         ]);
//       case 3:
//         return _panel('Dish Price', [
//           _chip(Icons.currency_rupee_rounded, 'Under ₹150'),
//           _chip(Icons.currency_rupee_rounded, 'Under ₹250'),
//           _chip(Icons.currency_rupee_rounded, 'Under ₹500'),
//         ]);
//       case 4:
//         return _panel('Trust Markers', [
//           _chip(Icons.verified_rounded, 'Hygiene Rated'),
//           _chip(Icons.verified_user_rounded, 'Trusted Seller'),
//         ]);
//       default:
//         return const SizedBox.shrink();
//     }
//   }
//
//   Widget _panel(String title, List<Widget> chips) => Padding(
//     padding: EdgeInsets.all(16.w),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           title,
//           style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700),
//         ),
//         SizedBox(height: 14.h),
//         Wrap(spacing: 10.w, runSpacing: 10.h, children: chips),
//       ],
//     ),
//   );
//
//   Widget _chip(IconData icon, String label) => Container(
//     padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
//     decoration: BoxDecoration(
//       border: Border.all(color: restaurentsnewcolour.border, width: 1.5),
//       borderRadius: BorderRadius.circular(10.r),
//       color: restaurentsnewcolour.surface,
//     ),
//     child: Row(
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Icon(icon, size: 14.sp, color: restaurentsnewcolour.green),
//         SizedBox(width: 6.w),
//         Text(
//           label,
//           style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
//         ),
//       ],
//     ),
//   );
//
//   Widget _footer() => Padding(
//     padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 20.h),
//     child: Row(
//       children: [
//         Expanded(
//           child: OutlinedButton(
//             onPressed: () => Navigator.pop(context),
//             style: OutlinedButton.styleFrom(
//               side: BorderSide(color: restaurentsnewcolour.border),
//               padding: EdgeInsets.symmetric(vertical: 12.h),
//             ),
//             child: const Text('Close'),
//           ),
//         ),
//         SizedBox(width: 12.w),
//         Expanded(
//           child: ElevatedButton(
//             onPressed: () => Navigator.pop(context),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: restaurentsnewcolour.primary,
//               foregroundColor: Colors.white,
//               padding: EdgeInsets.symmetric(vertical: 12.h),
//             ),
//             child: const Text('Show results'),
//           ),
//         ),
//       ],
//     ),
//   );
// }
//
// // ══════════════════════════════════════════════════════════════════════════════
// // SEARCH BAR HEADER DELEGATE  (kept for external compatibility)
// // ══════════════════════════════════════════════════════════════════════════════
// class SearchBarHeaderDelegate extends SliverPersistentHeaderDelegate {
//   final ValueChanged<String> onSearchChanged;
//   final VoidCallback? onFilterPressed;
//   final double height;
//
//   const SearchBarHeaderDelegate({
//     required this.onSearchChanged,
//     required this.height,
//     this.onFilterPressed,
//   });
//
//   @override
//   double get minExtent => height;
//   @override
//   double get maxExtent => height;
//
//   @override
//   Widget build(BuildContext ctx, double shrink, bool overlaps) {
//     return Container(
//       color: restaurentsnewcolour.surface,
//       padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 10.h),
//       child: _SearchBar(onChanged: onSearchChanged),
//     );
//   }
//
//   @override
//   bool shouldRebuild(covariant SliverPersistentHeaderDelegate old) => true;
// }
