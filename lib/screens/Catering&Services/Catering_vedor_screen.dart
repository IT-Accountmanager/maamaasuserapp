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
class catvndscreen {
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
        backgroundColor: catvndscreen.background,
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
              color: catvndscreen.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 36.sp,
              color: catvndscreen.textSecondary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Failed to load',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: catvndscreen.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Pull down to try again',
            style: TextStyle(
              fontSize: 13.sp,
              color: catvndscreen.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ── Main screen ─────────────────────────────────────────────────────────────
  Widget _buildMainScreen() {
    return RefreshIndicator(
      color: catvndscreen.primary,
      backgroundColor: catvndscreen.surface,
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
            backgroundColor: catvndscreen.surface,
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
              style: TextStyle(
                fontSize: 13.sp,
                color: catvndscreen.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search packages…',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: catvndscreen.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 17.sp,
                  color: catvndscreen.textSecondary,
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
                  ? catvndscreen.vegGreen.withOpacity(0.85)
                  : catvndscreen.nonVegRed.withOpacity(0.85),
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
              color: catvndscreen.surfaceAlt,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: catvndscreen.borderLight),
            ),
            child: TextField(
              onChanged: widget.onSearch,
              style: TextStyle(
                fontSize: 13.sp,
                color: catvndscreen.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'Search packages…',
                hintStyle: TextStyle(
                  fontSize: 13.sp,
                  color: catvndscreen.textSecondary,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  size: 17.sp,
                  color: catvndscreen.textSecondary,
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
              color: _isVeg ? catvndscreen.primaryDim : catvndscreen.surfaceAlt,
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: _isVeg
                    ? catvndscreen.vegGreen.withOpacity(0.5)
                    : catvndscreen.borderLight,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 10.r,
                  height: 10.r,
                  decoration: BoxDecoration(
                    color: _isVeg
                        ? catvndscreen.vegGreen
                        : catvndscreen.nonVegRed,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  _isVeg ? 'Veg' : 'Non-Veg',
                  style: TextStyle(
                    color: _isVeg
                        ? catvndscreen.vegGreen
                        : catvndscreen.nonVegRed,
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
                  color: catvndscreen.textSecondary,
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
        color: catvndscreen.surface,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: const [
          BoxShadow(
            color: catvndscreen.cardShadow,
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
                          color: catvndscreen.textPrimary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        '${items.length} item${items.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: catvndscreen.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _VegNonVegDot(isVeg: isVeg),
              ],
            ),

            SizedBox(height: 12.h),
            Divider(height: 1, color: catvndscreen.divider),
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
                                  color: catvndscreen.textSecondary,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  item.itemName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: catvndscreen.textSecondary,
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
                              color: catvndscreen.accent,
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
                    color: catvndscreen.textPrimary,
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
    final color = isVeg ? catvndscreen.vegGreen : catvndscreen.nonVegRed;
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
            color: catvndscreen.surfaceAlt,
            child: const Center(child: CircularProgressIndicator()),
          ),
          // Filter bar skeleton
          Container(
            height: 64,
            color: catvndscreen.surface,
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
                    color: catvndscreen.surfaceAlt,
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
