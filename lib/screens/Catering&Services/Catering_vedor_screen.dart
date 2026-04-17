// import '../../widgets/widgets/catering/catering_cart_count.dart';
// import '../../Services/Auth_service/catering_authservice.dart';
// import '../../widgets/widgets/catering/cartbutton.dart';
// import 'package:flutter_switch/flutter_switch.dart';
// import '../../Models/caterings/packages_model.dart';
// import '../../Models/caterings/aboutusmodel.dart';
// import '../../Models/caterings/banner_model.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'dart:convert';
//
// import '../Food&beverages/Menu/colours.dart';
//
// // ─────────────────────────────────────────────
// // Design Tokens
// // ─────────────────────────────────────────────
// class _AppColors {
//   static const background = Color(0xFFF8F9FA);
//   static const surface = Colors.white;
//   static const primary = Color(0xFF1A1A2E);
//   static const accent = Color(0xFFFF6B35);
//   static const vegGreen = Color(0xFF2ECC71);
//   static const nonVegRed = Color(0xFFE74C3C);
//   static const textPrimary = Color(0xFF1A1A2E);
//   static const textSecondary = Color(0xFF8A8FA8);
//   static const divider = Color(0xFFEEF0F5);
//   static const cardShadow = Color(0x0D000000);
// }
//
// // ─────────────────────────────────────────────
// // Main Screen
// // ─────────────────────────────────────────────
// class RestaurantDetailScreen extends StatefulWidget {
//   final String? vendorId;
//   const RestaurantDetailScreen({super.key, this.vendorId});
//
//   @override
//   State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
// }
//
// class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
//   bool isVeg = true;
//   bool isFilterApplied = false;
//   String searchQuery = "";
//
//   @override
//   Widget build(BuildContext context) {
//     SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
//     final safeTop = MediaQuery.of(context).padding.top;
//
//     return Scaffold(
//       backgroundColor: _AppColors.background,
//       body: Stack(
//         children: [
//           CustomScrollView(
//             physics: const BouncingScrollPhysics(),
//             slivers: [
//               // ── Hero banner sliver ──
//               SliverToBoxAdapter(
//                 child: TopRestaurantCard(vendorId: widget.vendorId!),
//               ),
//
//               // ── Sticky filter bar ──
//               SliverPersistentHeader(
//                 pinned: true,
//                 delegate: _StickyFilterDelegate(
//                   child: _FilterBar(
//                     isVeg: isVeg,
//                     onToggle: (v) => setState(() => isVeg = v!),
//                     onSearch: (v) => setState(() => searchQuery = v),
//                   ),
//                 ),
//               ),
//
//               // ── Menu content ──
//               SliverToBoxAdapter(
//                 child: MenuTabContent(
//                   isVeg: isVeg,
//                   isFilterApplied: isFilterApplied,
//                   vendorId: widget.vendorId!,
//                   searchQuery: searchQuery,
//                 ),
//               ),
//
//               // bottom padding so FAB doesn't overlap last card
//               const SliverToBoxAdapter(child: SizedBox(height: 100)),
//             ],
//           ),
//
//           // ── Back button ──
//           Positioned(
//             top: safeTop + 12,
//             left: 16,
//             child: _GlassIconButton(
//               icon: Icons.arrow_back_ios_new_rounded,
//               onTap: () => Navigator.maybePop(context),
//             ),
//           ),
//         ],
//       ),
//
//       // ── Cart FAB ──
//       floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
//       floatingActionButton: const _CartFab(),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Cart FAB
// // ─────────────────────────────────────────────
// class _CartFab extends StatelessWidget {
//   const _CartFab();
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 52,
//       constraints: const BoxConstraints(minWidth: 140),
//       child: Material(
//         color: Colors.transparent,
//         borderRadius: BorderRadius.circular(28),
//         child: InkWell(
//           borderRadius: BorderRadius.circular(28),
//           onTap: () {},
//           child: const Padding(
//             padding: EdgeInsets.symmetric(horizontal: 20),
//             child: catering_Cart_count(),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Glass back-button
// // ─────────────────────────────────────────────
// class _GlassIconButton extends StatelessWidget {
//   final IconData icon;
//   final VoidCallback onTap;
//   const _GlassIconButton({required this.icon, required this.onTap});
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         width: 40,
//         height: 40,
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.35),
//           shape: BoxShape.circle,
//         ),
//         child: Icon(icon, color: Colors.white, size: 18),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Hero Banner Card
// // ─────────────────────────────────────────────
// class TopRestaurantCard extends StatefulWidget {
//   final String vendorId;
//   const TopRestaurantCard({super.key, required this.vendorId});
//
//   @override
//   State<TopRestaurantCard> createState() => _TopRestaurantCardState();
// }
//
// class _TopRestaurantCardState extends State<TopRestaurantCard> {
//   bool _isLoading = true;
//   catering_BannerModel? _banner;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadBanner();
//   }
//
//   Future<void> _loadBanner() async {
//     try {
//       final banner = await catering_authservice.fetchBannerById(
//         widget.vendorId,
//       );
//       if (mounted)
//         setState(() {
//           _banner = banner;
//           _isLoading = false;
//         });
//     } catch (e) {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   ImageProvider _imageProvider(String s) =>
//       s.startsWith('http') ? NetworkImage(s) : MemoryImage(base64Decode(s));
//
//   @override
//   Widget build(BuildContext context) {
//     final screenW = MediaQuery.of(context).size.width;
//     final bannerH =
//         screenW * 0.58; // ~58 % aspect ratio – looks great on all sizes
//
//     if (_isLoading) {
//       return SizedBox(
//         height: bannerH,
//         child: const Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     return SizedBox(
//       height: bannerH,
//       width: double.infinity,
//       child: Stack(
//         fit: StackFit.expand,
//         children: [
//           // ── Background image ──
//           _banner != null && _banner!.companyBanner.isNotEmpty
//               ? Image(
//                   image: _imageProvider(_banner!.companyBanner),
//                   fit: BoxFit.cover,
//                 )
//               : Image.asset('assets/gallery-img-1.jpg', fit: BoxFit.cover),
//
//           // ── Gradient overlay ──
//           DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [Colors.transparent, Colors.black.withOpacity(0.75)],
//                 stops: const [0.4, 1.0],
//               ),
//             ),
//           ),
//
//           // ── Restaurant info ──
//           if (_banner != null)
//             Positioned(
//               bottom: 24,
//               left: 20,
//               right: 20,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Text(
//                     _banner!.companyName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 26,
//                       fontWeight: FontWeight.w800,
//                       letterSpacing: -0.5,
//                       height: 1.1,
//                     ),
//                   ),
//                   const SizedBox(height: 6),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.calendar_today_rounded,
//                         size: 13,
//                         color: Colors.white70,
//                       ),
//                       const SizedBox(width: 5),
//                       Text(
//                         'Est. ${_banner!.establishedYear}',
//                         style: const TextStyle(
//                           color: Colors.white70,
//                           fontSize: 13,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Sticky filter delegate
// // ─────────────────────────────────────────────
// class _StickyFilterDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;
//   const _StickyFilterDelegate({required this.child});
//
//   @override
//   double get minExtent => 72;
//   @override
//   double get maxExtent => 72;
//
//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlaps) =>
//       child;
//
//   @override
//   bool shouldRebuild(covariant _StickyFilterDelegate old) => old.child != child;
// }
//
// // ─────────────────────────────────────────────
// // Filter / Search Bar
// // ─────────────────────────────────────────────
// class _FilterBar extends StatefulWidget {
//   final bool? isVeg;
//   final ValueChanged<bool?> onToggle;
//   final ValueChanged<String> onSearch;
//
//   const _FilterBar({
//     required this.isVeg,
//     required this.onToggle,
//     required this.onSearch,
//   });
//
//   @override
//   State<_FilterBar> createState() => _FilterBarState();
// }
//
// class _FilterBarState extends State<_FilterBar> {
//   bool _isVeg = true;
//   final _ctrl = TextEditingController();
//
//   @override
//   void initState() {
//     super.initState();
//     _isVeg = widget.isVeg ?? true;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: 72,
//       color: _AppColors.surface,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _ctrl,
//               onChanged: widget.onSearch,
//               decoration: InputDecoration(
//                 hintText: 'Search dishes or packages…',
//                 prefixIcon: const Icon(Icons.search_rounded),
//               ),
//             ),
//           ),
//
//           const SizedBox(width: 12),
//
//           GestureDetector(
//             onTap: () {
//               setState(() {
//                 _isVeg = !_isVeg;
//               });
//
//               widget.onToggle(_isVeg); // ✅ send to parent
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//               padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
//               decoration: BoxDecoration(
//                 color: _isVeg
//                     ? _AppColors.vegGreen.withOpacity(0.12)
//                     : _AppColors.nonVegRed.withOpacity(0.12),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: _isVeg ? _AppColors.vegGreen : _AppColors.nonVegRed,
//                   width: 1.5,
//                 ),
//               ),
//               child: Row(
//                 children: [
//                   Container(
//                     width: 10,
//                     height: 10,
//                     decoration: BoxDecoration(
//                       color: _isVeg
//                           ? _AppColors.vegGreen
//                           : _AppColors.nonVegRed,
//                       shape: BoxShape.circle,
//                     ),
//                   ),
//                   const SizedBox(width: 6),
//                   Text(_isVeg ? 'Veg' : 'Non-Veg'),
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
// // ─────────────────────────────────────────────
// // Menu Tab Content
// // ─────────────────────────────────────────────
// class MenuTabContent extends StatefulWidget {
//   final String vendorId;
//   final bool isVeg;
//   final bool isFilterApplied;
//   final String searchQuery;
//
//   const MenuTabContent({
//     super.key,
//     required this.isVeg,
//     required this.isFilterApplied,
//     required this.vendorId,
//     required this.searchQuery,
//   });
//
//   @override
//   State<MenuTabContent> createState() => _MenuTabContentState();
// }
//
// class _MenuTabContentState extends State<MenuTabContent> {
//   List<Package> _packages = [];
//   bool _isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _loadPackage();
//   }
//
//   Future<void> _loadPackage() async {
//     final packages = await catering_authservice.fetchPackageById(
//       widget.vendorId,
//     );
//     if (mounted) {
//       setState(() {
//         _packages = packages;
//         _isLoading = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_isLoading) {
//       return const Padding(
//         padding: EdgeInsets.only(top: 60),
//         child: Center(child: CircularProgressIndicator()),
//       );
//     }
//
//     final filtered = _packages.where((pkg) {
//       final type = pkg.packageType.toLowerCase();
//       final isVegItem = type.contains('veg') && !type.contains('non');
//
//       final matchesVeg = widget.isFilterApplied
//           ? (widget.isVeg ? isVegItem : !isVegItem)
//           : true; // 👈 initially show ALL
//       final q = widget.searchQuery.toLowerCase();
//       final matchesName = pkg.packageName.toLowerCase().contains(q);
//       final matchesItem = pkg.items.any(
//         (i) => i.itemName.toLowerCase().contains(q),
//       );
//       return matchesVeg && (q.isEmpty || matchesName || matchesItem);
//     }).toList();
//
//     if (filtered.isEmpty) {
//       return Padding(
//         padding: const EdgeInsets.only(top: 72),
//         child: Center(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(
//                 Icons.no_food_rounded,
//                 size: 52,
//                 color: Colors.grey.shade300,
//               ),
//               const SizedBox(height: 12),
//               Text(
//                 widget.isVeg == null
//                     ? 'No packages found'
//                     : widget.isVeg!
//                     ? 'No Veg packages found'
//                     : 'No Non-Veg packages found',
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     return ListView.builder(
//       padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: filtered.length,
//       itemBuilder: (ctx, i) => _PackageCard(package: filtered[i]),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Package Card
// // ─────────────────────────────────────────────
// class _PackageCard extends StatefulWidget {
//   final Package package;
//   const _PackageCard({required this.package});
//
//   @override
//   State<_PackageCard> createState() => _PackageCardState();
// }
//
// class _PackageCardState extends State<_PackageCard> {
//   bool _expanded = false;
//
//   @override
//   Widget build(BuildContext context) {
//     final isVeg = widget.package.packageType.toLowerCase() == 'veg';
//     final dotColor = isVeg ? _AppColors.vegGreen : _AppColors.nonVegRed;
//     final items = widget.package.items;
//     final visibleItems = _expanded ? items : items.take(3).toList();
//
//     return Container(
//       margin: const EdgeInsets.only(bottom: 14),
//       decoration: BoxDecoration(
//         color: _AppColors.surface,
//         borderRadius: BorderRadius.circular(18),
//         boxShadow: const [
//           BoxShadow(
//             color: _AppColors.cardShadow,
//             blurRadius: 16,
//             offset: Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // ── Header row ──
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         widget.package.packageName,
//                         style: const TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w700,
//                           color: _AppColors.textPrimary,
//                           letterSpacing: -0.2,
//                         ),
//                       ),
//                       const SizedBox(height: 3),
//                       Text(
//                         '${items.length} item${items.length == 1 ? '' : 's'}',
//                         style: const TextStyle(
//                           fontSize: 12,
//                           color: _AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 vegNonVegIndicator(isVeg),
//               ],
//             ),
//
//             const SizedBox(height: 12),
//
//             // ── Divider ──
//             const Divider(color: _AppColors.divider, height: 1),
//             const SizedBox(height: 12),
//
//             // ── Item chips ──
//             Wrap(
//               spacing: 8,
//               runSpacing: 8,
//               children: visibleItems
//                   .map((item) => _ItemChip(label: item.itemName))
//                   .toList(),
//             ),
//
//             if (items.length > 3)
//               GestureDetector(
//                 onTap: () => setState(() => _expanded = !_expanded),
//                 child: Padding(
//                   padding: const EdgeInsets.only(top: 8),
//                   child: Text(
//                     _expanded ? 'Show less' : '+ ${items.length - 3} more',
//                     style: const TextStyle(
//                       fontSize: 12,
//                       fontWeight: FontWeight.w600,
//                       color: _AppColors.accent,
//                     ),
//                   ),
//                 ),
//               ),
//
//             const SizedBox(height: 14),
//
//             // ── Price + Add button ──
//             Row(
//               children: [
//                 Text(
//                   '₹${widget.package.totalPrice}',
//                   style: const TextStyle(
//                     fontSize: 20,
//                     fontWeight: FontWeight.w800,
//                     color: _AppColors.textPrimary,
//                     letterSpacing: -0.5,
//                   ),
//                 ),
//                 const Spacer(),
//                 CateringCartButton(package: widget.package),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget vegNonVegIndicator(bool isVeg) {
//     final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;
//
//     return Container(
//       padding: const EdgeInsets.all(2),
//       decoration: BoxDecoration(
//         border: Border.all(color: color, width: 1.5),
//         borderRadius: const BorderRadius.all(Radius.circular(3)),
//       ),
//       child: Container(
//         width: 7,
//         height: 7,
//         decoration: BoxDecoration(color: color, shape: BoxShape.circle),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────
// // Item Chip
// // ─────────────────────────────────────────────
// class _ItemChip extends StatelessWidget {
//   final String label;
//   const _ItemChip({required this.label});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//       decoration: BoxDecoration(
//         color: _AppColors.background,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: _AppColors.divider),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           fontSize: 12,
//           color: _AppColors.textSecondary,
//           fontWeight: FontWeight.w500,
//         ),
//       ),
//     );
//   }
// }

import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/food/aboutus_model.dart';
import '../../Models/food/restaurent_banner_model.dart';
import '../../Models/food/team_model.dart';
import '../../Services/Auth_service/food_authservice.dart';
import '../../Services/Auth_service/guest_Authservice.dart';
import '../../Services/Auth_service/catering_authservice.dart';
import '../../widgets/widgets/catering/cartbutton.dart';
import '../../Models/caterings/packages_model.dart';
import '../Food&beverages/Menu/Menuhelper.dart';
import '../Food&beverages/Menu/Top_banner.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import '../Food&beverages/Menu/fullscreen.dart';
import 'cateringcartfooter.dart';

// ─────────────────────────────────────────────
// Design Tokens (unchanged from original)
// ─────────────────────────────────────────────
class _AppColors {
  static const background = Color(0xFFF8F9FA);
  static const surface = Colors.white;
  static const primary = Color(0xFF1A1A2E);
  static const accent = Color(0xFFFF6B35);
  static const vegGreen = Color(0xFF2ECC71);
  static const nonVegRed = Color(0xFFE74C3C);
  static const textPrimary = Color(0xFF1A1A2E);
  static const textSecondary = Color(0xFF8A8FA8);
  static const divider = Color(0xFFEEF0F5);
  static const cardShadow = Color(0x0D000000);
  static const borderLight = Color(0xFFEEF0F5);
  static const surfaceAlt = Color(0xFFF0F2F8);
  static const primaryDim = Color(0xFFEAF4EC);
}

class CateringVendorScreen extends StatefulWidget {
  final int vendorId;

  const CateringVendorScreen({super.key, required this.vendorId});

  @override
  State<CateringVendorScreen> createState() => _CateringVendorScreenState();
}

class _CateringVendorScreenState extends State<CateringVendorScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();

  bool _isCollapsed = false;
  bool? isVeg;
  String searchQuery = "";

  Restaurent_Banner? _bannerItem;
  AboutUsModel? _aboutus;
  List<vendorteam> _team = [];
  BannerContentType selectedContent = BannerContentType.none;

  late Future<void> _screenFuture;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  static const double _expandedHeight = 380.0;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    _screenFuture = _initializeScreen();

    _scrollController.addListener(() {
      final collapsed =
          _scrollController.offset > (_expandedHeight - kToolbarHeight);
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  Future<void> _initializeScreen() async {
    await Future.wait([_loadBannerData(), _loadaboutus()]);
    if (mounted) _fadeController.forward();
  }

  Future<void> _loadBannerData() async {
    try {
      final banner = await Authservice().fetchVendorBanner(widget.vendorId);
      if (mounted) {
        setState(() {
          _bannerItem = banner;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadaboutus() async {
    try {
      final about = await food_Authservice.fetchAboutUsData(widget.vendorId);
      if (mounted) {
        setState(() {
          _aboutus = about;
        });
      }
    } catch (_) {}
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    await _initializeScreen();
  }



  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  // ── Build ──────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: _AppColors.background,
        body: Stack(
          children: [
            // ── Main scrollable content ──
            FutureBuilder<void>(
              future: _screenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _CateringSkeletonScreen();
                }
                if (snapshot.hasError) {
                  return _buildFullError();
                }
                return FadeTransition(
                  opacity: _fadeAnim,
                  child: _buildMainScreen(),
                );
              },
            ),

            // ── Floating cart bar (same pattern as food MenuScreen) ──

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: const catering_Cart_count(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error state ─────────────────────────────────────────────────────────────
  Widget _buildFullError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: const BoxDecoration(
              color: _AppColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 36.sp,
              color: _AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: _AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Pull down to try again',
            style: TextStyle(fontSize: 13.sp, color: _AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Main screen ─────────────────────────────────────────────────────────────
  Widget _buildMainScreen() {
    return RefreshIndicator(
      color: _AppColors.primary,
      backgroundColor: _AppColors.surface,
      displacement: 80,
      strokeWidth: 2.5,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Collapsing banner AppBar (mirrors MenuScreen SliverAppBar) ──
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            collapsedHeight: 64,
            backgroundColor: _AppColors.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black.withOpacity(0.08),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            // When collapsed: show search + veg toggle in AppBar title area
            title: _isCollapsed
                ? _CollapsedCateringFilterBar(
                    isVeg: isVeg ?? false,
                    onToggle: (v) => setState(() => isVeg = v),
                    onSearch: (v) => setState(() => searchQuery = v),
                  )
                : null,
            titleSpacing: 0,
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.parallax,
              background: BannerSection(
                bannerItem: _bannerItem,
                aboutus: _aboutus,
                team: _team,
                vendorId: widget.vendorId,
                isVeg: isVeg ?? false,
                onToggle: (v) => setState(() => isVeg = v),
                onSearch: (v) => setState(() => searchQuery = v),
                onContentSelected: (BannerContentType type) {
                  setState(() {
                    selectedContent = selectedContent == type
                        ? BannerContentType.none
                        : type;
                  });
                },
              ),
            ),
          ),

          // ── Expandable banner content (about / gallery) ──
          SliverToBoxAdapter(child: _buildBannerContent()),

          // ── Sticky filter bar ──
          // SliverPersistentHeader(
          //   pinned: true,
          //   delegate: _StickyFilterDelegate(
          //     child: _CateringFilterBar(
          //       isVeg: isVeg ?? false,
          //       onToggle: (v) => setState(() => isVeg = v),
          //       onSearch: (v) => setState(() => searchQuery = v),
          //     ),
          //   ),
          // ),

          // ── Package list ──
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: _CateringPackageContent(
                isVeg: isVeg,
                vendorId: widget.vendorId,
                searchQuery: searchQuery,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBannerContent() {
    if (selectedContent == BannerContentType.none) {
      return SizedBox();
    }

    final about = _aboutus;
    if (about == null) return SizedBox();

    // =======================
    // ✅ ABOUT SECTION
    // =======================
    if (selectedContent == BannerContentType.about) {
      return Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 Top Image
            if (about.image.isNotEmpty)
              Image.network(
                about.image,
                width: double.infinity,
                height: 160.h,
                fit: BoxFit.cover,
              ),

            Padding(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔹 ABOUT TEXT
                  Text(
                    "About Us",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 8.h),

                  Text(
                    about.aboutUs,
                    style: TextStyle(
                      fontSize: 13.sp,
                      height: 1.4,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  SizedBox(height: 20.h),

                  if (about.mission.isNotEmpty)
                    _infoCard(
                      title: "Our Mission",
                      description: about.mission,
                      image: about.missionImage,
                    ),

                  SizedBox(height: 12.h),

                  // 🔹 Vision Card
                  if (about.vision.isNotEmpty)
                    _infoCard(
                      title: "Our Vision",
                      description: about.vision,
                      image: about.visionImage,
                    ),

                  // 🔹 TEAM ONLY (NO GALLERY HERE)
                  if (_team.isNotEmpty) ...[
                    Text(
                      "Our Team",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 10.h),

                    SizedBox(
                      height: 140.h,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _team.length,
                        itemBuilder: (context, index) {
                          final member = _team[index];

                          return Container(
                            width: 120.w,
                            margin: EdgeInsets.only(right: 12.w),
                            padding: EdgeInsets.all(10.w),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(14.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 6,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 26.r,
                                  backgroundImage: NetworkImage(member.image),
                                ),
                                SizedBox(height: 8.h),

                                Text(
                                  member.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),

                                SizedBox(height: 2.h),

                                Text(
                                  member.designation,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: Colors.grey,
                                  ),
                                ),

                                Expanded(
                                  child: Text(
                                    member.description,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 9.sp,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      );
    }

    // =======================
    // ✅ GALLERY SECTION ONLY
    // =======================
    if (selectedContent == BannerContentType.gallery) {
      if (about.allImages.isEmpty) {
        return SizedBox();
      }

      return Container(
        color: Colors.white,
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Gallery",
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 12.h),

            SizedBox(
              height: 140.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: about.allImages.length,
                itemBuilder: (context, index) {
                  final img = about.allImages[index];

                  return GestureDetector(
                    onTap: () {
                      _openFullScreenGallery(index);
                    },
                    child: Container(
                      width: 140.w,
                      margin: EdgeInsets.only(right: 12.w),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.network(img, fit: BoxFit.cover),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox();
  }

  Widget _infoCard({
    required String title,
    required String description,
    required String image,
  }) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // 🔹 Image
          if (image.isNotEmpty)
            ClipRRect(
              borderRadius: BorderRadius.circular(10.r),
              child: Image.network(
                image,
                height: 60.h,
                width: 60.w,
                fit: BoxFit.cover,
              ),
            ),

          if (image.isNotEmpty) SizedBox(width: 10.w),

          // 🔹 Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  description,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade700,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openFullScreenGallery(int initialIndex) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FullScreenGallery(
          images: _aboutus!.allImages,
          initialIndex: initialIndex,
        ),
      ),
    );
  }
}

class _ExpandedBannerFilterBar extends StatefulWidget {
  final bool isVeg;
  final Function(bool) onToggle;
  final Function(String) onSearch;

  const _ExpandedBannerFilterBar({
    required this.isVeg,
    required this.onToggle,
    required this.onSearch,
  });

  @override
  State<_ExpandedBannerFilterBar> createState() =>
      _ExpandedBannerFilterBarState();
}

class _ExpandedBannerFilterBarState extends State<_ExpandedBannerFilterBar> {
  late bool _isVeg;

  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Search field
        Expanded(
          child: Container(
            height: 38.h,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: TextField(
              onChanged: widget.onSearch,
              style: TextStyle(fontSize: 13.sp, color: _AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search packages…',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: _AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 17.sp,
                  color: _AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                prefixIconConstraints: BoxConstraints(
                  minHeight: 20.h,
                  minWidth: 36.w,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // Veg toggle
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isVeg = !_isVeg);
            widget.onToggle(_isVeg);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _isVeg
                  ? _AppColors.vegGreen.withOpacity(0.85)
                  : _AppColors.nonVegRed.withOpacity(0.85),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  _isVeg ? 'Veg' : 'Non-Veg',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Collapsed filter bar (shown in AppBar when scrolled)
// ─────────────────────────────────────────────
class _CollapsedCateringFilterBar extends StatefulWidget {
  final bool isVeg;
  final Function(bool) onToggle;
  final Function(String) onSearch;

  const _CollapsedCateringFilterBar({
    required this.isVeg,
    required this.onToggle,
    required this.onSearch,
  });

  @override
  State<_CollapsedCateringFilterBar> createState() =>
      _CollapsedCateringFilterBarState();
}

class _CollapsedCateringFilterBarState
    extends State<_CollapsedCateringFilterBar> {
  late bool _isVeg;

  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 4.w),
        Expanded(
          child: Container(
            height: 36.h,
            decoration: BoxDecoration(
              color: _AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: _AppColors.borderLight),
            ),
            child: TextField(
              onChanged: widget.onSearch,
              style: TextStyle(fontSize: 13.sp, color: _AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'Search packages…',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: _AppColors.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 17.sp,
                  color: _AppColors.textSecondary,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 10.h),
                prefixIconConstraints: BoxConstraints(
                  minHeight: 20.h,
                  minWidth: 34.w,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),
        GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            setState(() => _isVeg = !_isVeg);
            widget.onToggle(_isVeg);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: _isVeg ? _AppColors.primaryDim : _AppColors.surfaceAlt,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _isVeg
                    ? _AppColors.vegGreen.withOpacity(0.5)
                    : _AppColors.borderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: _isVeg ? _AppColors.vegGreen : _AppColors.nonVegRed,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  _isVeg ? 'Veg' : 'Non-Veg',
                  style: TextStyle(
                    color: _isVeg ? _AppColors.vegGreen : _AppColors.nonVegRed,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 4.w),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Package content (filtered list)
// ─────────────────────────────────────────────
class _CateringPackageContent extends StatefulWidget {
  final int vendorId;
  final bool? isVeg;
  final String searchQuery;

  const _CateringPackageContent({
    required this.vendorId,
    required this.isVeg,
    required this.searchQuery,
  });

  @override
  State<_CateringPackageContent> createState() =>
      _CateringPackageContentState();
}

class _CateringPackageContentState extends State<_CateringPackageContent> {
  List<Package> _packages = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPackages();
  }

  Future<void> _loadPackages() async {
    final packages = await catering_authservice.fetchPackageById(
      widget.vendorId,
    );
    if (mounted) {
      setState(() {
        _packages = packages;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 60),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final filtered = _packages.where((pkg) {
      final type = pkg.packageType.toLowerCase();
      final isVegItem = type.contains('veg') && !type.contains('non');
      final matchesVeg = widget.isVeg == null
          ? true
          : (widget.isVeg! ? isVegItem : !isVegItem);
      final q = widget.searchQuery.toLowerCase();
      final matchesName = pkg.packageName.toLowerCase().contains(q);
      final matchesItem = pkg.items.any(
        (i) => i.itemName.toLowerCase().contains(q),
      );
      return matchesVeg && (q.isEmpty || matchesName || matchesItem);
    }).toList();

    if (filtered.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(top: 72),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.no_food_rounded,
                size: 52.sp,
                color: Colors.grey.shade300,
              ),
              SizedBox(height: 12.h),
              Text(
                widget.isVeg == null
                    ? 'No packages found'
                    : widget.isVeg!
                    ? 'No Veg packages found'
                    : 'No Non-Veg packages found',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      itemBuilder: (ctx, i) => _PackageCard(package: filtered[i]),
    );
  }
}

// ─────────────────────────────────────────────
// Package Card (unchanged logic, refined style)
// ─────────────────────────────────────────────
class _PackageCard extends StatefulWidget {
  final Package package;
  const _PackageCard({required this.package});

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isVeg = widget.package.packageType.toLowerCase() == 'veg';
    final items = widget.package.items;
    final visibleItems = _expanded ? items : items.take(3).toList();

    return Container(
      margin: EdgeInsets.only(bottom: 14.h),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: _AppColors.cardShadow,
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.package.packageName,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${items.length} item${items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _VegNonVegDot(isVeg: isVeg),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, color: _AppColors.divider),
            SizedBox(height: 12.h),

            // ── Item chips ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🔹 Items List
                Column(
                  children: visibleItems
                      .map(
                        (item) => Padding(
                          padding: EdgeInsets.only(bottom: 6.h),
                          child: Row(
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                margin: EdgeInsets.only(right: 8.w),
                                decoration: BoxDecoration(
                                  color: _AppColors.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: _AppColors.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),

                // 🔹 Show More / Less Button (Row aligned)
                if (items.length > 3)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => setState(() => _expanded = !_expanded),
                        child: Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(
                            _expanded
                                ? 'Show less'
                                : '+ ${items.length - 3} more',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _AppColors.accent,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),

            SizedBox(height: 14.h),

            // ── Price + cart button ──
            Row(
              children: [
                Text(
                  '₹${widget.package.totalPrice}',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const Spacer(),
                CateringCartButton(package: widget.package),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Veg / Non-veg dot indicator
// ─────────────────────────────────────────────
class _VegNonVegDot extends StatelessWidget {
  final bool isVeg;
  const _VegNonVegDot({required this.isVeg});

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? _AppColors.vegGreen : _AppColors.nonVegRed;
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        border: Border.all(color: color, width: 1.5),
        borderRadius: const BorderRadius.all(Radius.circular(3)),
      ),
      child: Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Skeleton screen (loading state)
// ─────────────────────────────────────────────
class _CateringSkeletonScreen extends StatelessWidget {
  const _CateringSkeletonScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        children: [
          // Banner skeleton
          Container(
            height: 380.h,
            color: _AppColors.surfaceAlt,
            child: const Center(child: CircularProgressIndicator()),
          ),
          // Filter bar skeleton
          Container(
            height: 64,
            color: _AppColors.surface,
            margin: EdgeInsets.only(top: 1.h),
          ),
          // Card skeletons
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: List.generate(
                3,
                (_) => Container(
                  height: 160.h,
                  margin: EdgeInsets.only(bottom: 14.h),
                  decoration: BoxDecoration(
                    color: _AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Full-screen gallery viewer
// ─────────────────────────────────────────────
class _CateringFullScreenGallery extends StatefulWidget {
  final List<String> images;
  final int initialIndex;

  const _CateringFullScreenGallery({
    required this.images,
    required this.initialIndex,
  });

  @override
  State<_CateringFullScreenGallery> createState() =>
      _CateringFullScreenGalleryState();
}

class _CateringFullScreenGalleryState
    extends State<_CateringFullScreenGallery> {
  late int _current;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          '${_current + 1} / ${widget.images.length}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        onPageChanged: (i) => setState(() => _current = i),
        itemCount: widget.images.length,
        itemBuilder: (ctx, i) => InteractiveViewer(
          child: Center(
            child: Image.network(widget.images[i], fit: BoxFit.contain),
          ),
        ),
      ),
    );
  }
}
