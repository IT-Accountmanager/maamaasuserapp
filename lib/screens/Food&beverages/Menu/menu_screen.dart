import 'package:maamaas/Services/App_color_service/app_colours.dart';
import 'package:maamaas/Services/Auth_service/guest_Authservice.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../Models/food/aboutus_model.dart';
import '../../../Models/food/team_model.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../widgets/widgets/food/favorite_button.dart';
import '../../../Models/food/restaurent_banner_model.dart';
import 'Menuhelper.dart';
import 'cart_button.dart';
import 'cart_footer_button.dart';
import '../../skeleton/menu_skeleton.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../Models/food/dish.dart';
import '../../foodmainscreen.dart';
import 'dart:convert';
import 'dart:async';
import '../table/Table.dart';
import 'Top_banner.dart';
import 'colours.dart';
import 'fullscreen.dart';

class MenuResponse {
  final List<Dish> categories;
  final List<Dish> dishes;
  final String? errorMessage;
  final bool hasError;

  MenuResponse({
    required this.categories,
    required this.dishes,
    this.errorMessage,
    this.hasError = false,
  });
}

class MenuScreen extends StatefulWidget {
  final int vendorId;
  final String? initialCategoryName;
  // final Restaurent_Banner? banner;

  const MenuScreen({
    super.key,
    required this.vendorId,
    this.initialCategoryName,
    // this.banner,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  Timer? _scrollTimer;

  bool _isCollapsed = false;
  bool? isVeg;
  int selectedTabIndex = 0;
  int? selectedCategoryId;
  List<Dish> categories = [];
  String orderType = "";
  String searchQuery = "";
  Restaurent_Banner? _bannerItem;
  AboutUsModel? _aboutus;
  List<vendorteam> _team = [];
  Map<int, int> favoriteMap = {};

  late Future<void> _screenFuture;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;
  BannerContentType selectedContent = BannerContentType.none;
  static const double _expandedHeight = 400.0;

  String get normalizedOrderType => orderType.trim().toUpperCase();
  bool get showMenuTab =>
      ["DINE_IN", "TAKEAWAY", "DELIVERY"].contains(normalizedOrderType);
  bool get showTableTab => normalizedOrderType == "TABLE_DINE_IN";

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeController, curve: Curves.easeOut);

    // Single future — FutureBuilder waits on this, no separate call
    _screenFuture = _initializeScreen();
    // _bannerItem = widget.banner;

    _scrollController.addListener(() {
      final collapsed =
          _scrollController.offset > (_expandedHeight - kToolbarHeight);
      if (collapsed != _isCollapsed) {
        setState(() => _isCollapsed = collapsed);
      }
    });
  }

  Future<void> _initializeScreen() async {
    await _loadPrefs();
    await Future.wait([
      _loadBannerData(),
      _loadMenu(),
      _loadaboutus(),
      _loadteam(),
      _loadFavorites(),
    ]);
    if (mounted) _fadeController.forward();
  }

  Future<void> _loadFavorites() async {
    try {
      final favs = await food_Authservice.getFavoritesByUserId();

      if (!mounted) return;

      setState(() {
        favoriteMap = {
          for (var f in favs)
            if (f.dishId != null && f.favId != null) f.dishId!: f.favId!,
        };
      });
    } catch (e) {
      debugPrint("Fav error: $e");
    }
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

  Future<void> _loadteam() async {
    try {
      final team = await food_Authservice.fetchteam(widget.vendorId);
      if (mounted) {
        setState(() {
          _team = team;
        });
      }
    } catch (_) {}
  }

  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        orderType =
            prefs.getString('orderType')?.trim().toUpperCase() ?? "DINE_IN";
      });
    }
  }

  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 500));
    await _loadMenu();
  }

  Future<void> _loadMenu() async {
    final menu = await Authservice.fetchMenu(widget.vendorId);
    if (!mounted) return;
    setState(() {
      categories = menu.categories.where((c) => c.parentId == 0).toList();

      // Auto-select the category passed from Restaurants screen
      if (widget.initialCategoryName != null && categories.isNotEmpty) {
        final match = categories.firstWhere(
          (c) =>
              c.dishName?.toLowerCase() ==
              widget.initialCategoryName!.toLowerCase(),
          orElse: () => categories.first,
        );
        selectedCategoryId = match.dishId;
      }
    });
  }

  @override
  void dispose() {
    _scrollTimer?.cancel();
    _scrollController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: _screenFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const MenuSkeletonScreen();
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

            // Floating cart bars
            if (showMenuTab)
              Positioned(
                left: 16,
                right: 16,
                bottom: 16,
                child: const food_Cart_count(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullError() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              color: Menucolours.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              size: 36.sp,
              color: Menucolours.textM,
            ),
          ),
          SizedBox(height: 16.h),
          Text('Failed to load menu', style: Menucolours.h2()),
          SizedBox(height: 6.h),
          Text(
            'Pull down to try again',
            style: Menucolours.body(color: Menucolours.textS),
          ),
        ],
      ),
    );
  }

  Widget _buildMainScreen() {
    return RefreshIndicator(
      color: Menucolours.primary,
      backgroundColor: Menucolours.surface,
      displacement: 80,
      strokeWidth: 2.5,
      onRefresh: _onRefresh,
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Banner AppBar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: _expandedHeight,
            collapsedHeight: 64,
            backgroundColor: Menucolours.surface,
            elevation: 0,
            scrolledUnderElevation: 1,
            shadowColor: Colors.black.withOpacity(0.08),
            automaticallyImplyLeading: true,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Colors.black,
              ),
              onPressed: () => Navigator.maybePop(context),
            ),
            title: _isCollapsed
                ? _CollapsedFilterBar(
                    isVeg: isVeg ?? false,
                    vendorId: widget.vendorId,
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
                isVeg: isVeg ?? false,
                vendorId: widget.vendorId,
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

          SliverToBoxAdapter(child: _buildBannerContent()),

          // ── Sticky category + table tabs ────────────────────────────
          SliverPersistentHeader(
            pinned: true,
            delegate: _StickyTabsDelegate(
              height: _headerHeight,
              child: _StickyTabsContent(
                categories: categories,
                showTableTab: !showMenuTab,
                vendorId: widget.vendorId,
                selectedCategoryId: selectedCategoryId,
                onCategorySelected: (id) =>
                    setState(() => selectedCategoryId = id),
              ),
            ),
          ),

          // ── Dish grid ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 100.h),
              child: MenuTabContent(
                isVeg: isVeg,
                vendorId: widget.vendorId,
                selectedVendorId: widget.vendorId,
                favoriteMap: favoriteMap,
                cartButton: (dish) => CartButton(
                  dishId: dish.dishId,
                  balanceQuantity: dish.balanceQuantity,
                ),
                // favoriteButton: favbutton(),
                isOutOfStock: (dish) => dish.stock?.toLowerCase() != 'in stock',
                selectedCategoryId: selectedCategoryId,
                searchQuery: searchQuery,
                showCartButton: !showTableTab,
              ),
            ),
          ),
        ],
      ),
    );
  }

  double get _headerHeight {
    double base = 88.h;
    double table = 52.h;
    return !showMenuTab ? base + table : base;
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
}

// ── Collapsed filter bar (shown in AppBar when scrolled) ─────────────────────
class _CollapsedFilterBar extends StatefulWidget {
  final bool isVeg;
  final int vendorId;
  final Function(bool) onToggle;
  final Function(String) onSearch;

  const _CollapsedFilterBar({
    required this.isVeg,
    required this.vendorId,
    required this.onToggle,
    required this.onSearch,
  });

  @override
  State<_CollapsedFilterBar> createState() => _CollapsedFilterBarState();
}

class _CollapsedFilterBarState extends State<_CollapsedFilterBar> {
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
        SizedBox(width: 12.w),
        Expanded(
          child: SearchField(
            onSearch: widget.onSearch,
            fillColor: Menucolours.surfaceAlt,
          ),
        ),
        SizedBox(width: 8.w),
        VegToggle(
          isVeg: _isVeg,
          onToggle: (v) {
            setState(() => _isVeg = v);
            widget.onToggle(v);
          },
          compact: true,
        ),
        SizedBox(width: 12.w),
      ],
    );
  }
}

// ── Banner section with filter bar ───────────────────────────────────────────

// ── Shared search field ────────────────────────────────────────────────────────

// ── Sticky tabs delegate ───────────────────────────────────────────────────────
class _StickyTabsDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  const _StickyTabsDelegate({required this.child, required this.height});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: height, child: child);
  }

  @override
  bool shouldRebuild(covariant _StickyTabsDelegate old) =>
      old.child != child || old.height != height;
}

// ── Sticky tabs content ───────────────────────────────────────────────────────
class _StickyTabsContent extends StatelessWidget {
  final List<Dish> categories;
  final bool showTableTab;
  final int vendorId;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const _StickyTabsContent({
    required this.categories,
    required this.showTableTab,
    required this.vendorId,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Menucolours.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showTableTab) ...[
            TableTabContent(vendorId: vendorId),
            Divider(height: 1, thickness: 1, color: Menucolours.borderLight),
          ],
          Expanded(
            child: _CategoryTabStrip(
              categories: categories,
              selectedCategoryId: selectedCategoryId,
              onCategorySelected: onCategorySelected,
            ),
          ),
          Divider(height: 1, thickness: 1, color: Menucolours.borderLight),
        ],
      ),
    );
  }
}

// ── Category tab strip ────────────────────────────────────────────────────────
class _CategoryTabStrip extends StatelessWidget {
  final List<Dish> categories;
  final int? selectedCategoryId;
  final Function(int?) onCategorySelected;

  const _CategoryTabStrip({
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      itemCount: categories.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return _CategoryChip(
            title: 'All',
            image: const AssetImage('assets/allitems.jpg'),
            isSelected: selectedCategoryId == null,
            onTap: () => onCategorySelected(null),
          );
        }
        final cat = categories[index - 1];
        return _CategoryChip(
          title: cat.dishName ?? '',
          image: (cat.dishImage != null && cat.dishImage!.isNotEmpty)
              ? NetworkImage(cat.dishImage!)
              : null,
          isSelected: selectedCategoryId == cat.dishId,
          onTap: () => onCategorySelected(cat.dishId),
        );
      },
    );
  }
}

// ── Category chip ─────────────────────────────────────────────────────────────
class _CategoryChip extends StatelessWidget {
  final String title;
  final ImageProvider? image;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.title,
    this.image,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: EdgeInsets.only(right: 10.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              width: isSelected ? 52.r : 48.r,
              height: isSelected ? 52.r : 48.r,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColors.primary : Menucolours.surfaceAlt,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Menucolours.border,
                  width: isSelected ? 2.5 : 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: Menucolours.primary.withOpacity(0.18),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: ClipOval(
                child: image != null
                    ? Image(image: image!, fit: BoxFit.cover)
                    : Icon(
                        Icons.restaurant_rounded,
                        size: 20.sp,
                        color: isSelected
                            ? Menucolours.primary
                            : Menucolours.textM,
                      ),
              ),
            ),
            SizedBox(height: 4.h),
            SizedBox(
              width: 60.w,
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: Menucolours.label(
                  color: isSelected ? AppColors.primary : Menucolours.textS,
                  size: 10.sp,
                ),
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MenuFilterBar (public, used externally)
// ─────────────────────────────────────────────────────────────────────────────
class MenuFilterBar extends StatefulWidget {
  final bool isVeg;
  final Function(bool) onToggle;
  final int selectedFilterIndex;
  final int vendorId;
  final String? orderType;
  final Function(String) onSearch;
  final double searchWidth;
  final Color searchFillColor;

  const MenuFilterBar({
    super.key,
    required this.isVeg,
    required this.onToggle,
    required this.vendorId,
    this.orderType,
    this.selectedFilterIndex = 0,
    required this.onSearch,
    this.searchWidth = 180,
    this.searchFillColor = const Color(0xFFF0F2F8),
  });

  @override
  State<MenuFilterBar> createState() => _MenuFilterBarState();
}

class _MenuFilterBarState extends State<MenuFilterBar> {
  late bool _isVeg;

  @override
  void initState() {
    super.initState();
    _isVeg = widget.isVeg;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Menucolours.surface,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: widget.searchWidth,
            child: SearchField(
              onSearch: widget.onSearch,
              fillColor: widget.searchFillColor,
            ),
          ),
          SizedBox(width: 10.w),
          VegToggle(
            isVeg: _isVeg,
            onToggle: (v) {
              setState(() => _isVeg = v);
              widget.onToggle(v);
            },
          ),
        ],
      ),
    );
  }
}

class SearchField extends StatelessWidget {
  final Function(String) onSearch;
  final Color fillColor;

  const SearchField({required this.onSearch, required this.fillColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 38.h,
      decoration: BoxDecoration(
        color: fillColor,
        borderRadius: Menucolours.r12,
        border: Border.all(color: Menucolours.border),
      ),
      child: TextField(
        onChanged: onSearch,
        style: Menucolours.body(size: 13.sp),
        decoration: InputDecoration(
          hintText: 'Search dishes...',
          hintStyle: Menucolours.body(color: Menucolours.textM, size: 13.sp),

          prefixIcon: Icon(
            Icons.search_rounded,
            size: 17.sp,
            color: Menucolours.textM,
          ),

          border: InputBorder.none,
          isDense: true,

          // ✅ FIX: vertical centering
          contentPadding: EdgeInsets.symmetric(vertical: 10.h),

          // ✅ FIX: reduce prefixIcon extra space
          prefixIconConstraints: BoxConstraints(
            minHeight: 20.h,
            minWidth: 36.w,
          ),
        ),
      ),
    );
  }
}

// ── Veg toggle ────────────────────────────────────────────────────────────────
class VegToggle extends StatelessWidget {
  final bool isVeg;
  final Function(bool) onToggle;
  final bool compact;

  const VegToggle({
    required this.isVeg,
    required this.onToggle,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onToggle(!isVeg);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8.w : 10.w,
          vertical: 6.h,
        ),
        decoration: BoxDecoration(
          color: isVeg ? Menucolours.primaryDim : Menucolours.surfaceAlt,
          borderRadius: Menucolours.r8,
          border: Border.all(
            color: isVeg
                ? Menucolours.primary.withOpacity(0.4)
                : Menucolours.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10.r,
              height: 10.r,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            SizedBox(width: 5.w),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: Menucolours.label(
                color: color,
                size: compact ? 11.sp : 12.sp,
              ),
              child: Text(isVeg ? 'Veg' : 'Non veg'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// MenuTabContent
// ─────────────────────────────────────────────────────────────────────────────
class MenuTabContent extends StatefulWidget {
  final bool? isVeg;
  final Widget Function(Dish dish) cartButton;
  final bool Function(Dish) isOutOfStock;
  final int vendorId;
  final int selectedVendorId;
  // final favoriteButton;
  final int? selectedCategoryId;
  final String searchQuery;
  final bool showCartButton;
  final Map<int, int> favoriteMap;

  const MenuTabContent({
    super.key,
    required this.isVeg,
    required this.cartButton,
    required this.isOutOfStock,
    // required this.favoriteButton,
    required this.selectedVendorId,
    required this.vendorId,
    this.selectedCategoryId,
    required this.searchQuery,
    required this.showCartButton,
    required this.favoriteMap,
  });

  @override
  State<MenuTabContent> createState() => _MenuTabContentState();
}

class _MenuTabContentState extends State<MenuTabContent> {
  @override
  Widget build(BuildContext context) {
    return DishGridTab(
      parentId: widget.selectedCategoryId,
      vendorId: widget.vendorId,
      filterTag: widget.isVeg == null
          ? null
          : widget.isVeg!
          ? 'veg'
          : 'non_veg',
      emptyMessage: widget.isVeg == true
          ? 'No veg dishes found.'
          : widget.isVeg == false
          ? 'No non-veg dishes found.'
          : 'No dishes available.',
      searchQuery: widget.searchQuery,
      showCartButton: widget.showCartButton,
      favoriteMap: widget.favoriteMap,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DishGridTab
// ─────────────────────────────────────────────────────────────────────────────
class DishGridTab extends StatefulWidget {
  final int? parentId;
  final int vendorId;
  final String? filterTag;
  final String emptyMessage;
  final String searchQuery;
  final bool showCartButton;
  final Map<int, int> favoriteMap;

  const DishGridTab({
    super.key,
    this.parentId,
    required this.vendorId,
    required this.filterTag,
    required this.emptyMessage,
    required this.searchQuery,
    required this.showCartButton,
    required this.favoriteMap,
  });

  @override
  _DishGridTabState createState() => _DishGridTabState();
}

class _DishGridTabState extends State<DishGridTab> {
  bool _isLoading = true;
  List<Dish> _allDishes = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  @override
  void didUpdateWidget(DishGridTab old) {
    super.didUpdateWidget(old);
    if (widget.parentId != old.parentId || widget.filterTag != old.filterTag) {
      _loadMenu();
    }
  }

  Future<void> _loadMenu() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    final menu = await Authservice.fetchMenu(widget.vendorId);
    if (!mounted) return;

    if (menu.hasError) {
      setState(() {
        _isLoading = false;
        _errorMessage = menu.errorMessage ?? 'Something went wrong.';
      });
      return;
    }

    final dishes = (widget.parentId != null && widget.parentId! > 0)
        ? menu.dishes.where((d) => d.parentId == widget.parentId).toList()
        : menu.dishes;

    setState(() {
      _allDishes = dishes;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const MenuSkeletonScreen();
    if (_errorMessage != null) return _buildError();

    final filtered = _allDishes.where((dish) {
      final ok = dish.menuStatus == 'Enable';
      final veg =
          widget.filterTag == null ||
          dish.tag?.toLowerCase() == widget.filterTag!.toLowerCase();
      final q =
          widget.searchQuery.isEmpty ||
          dish.dishName!.toLowerCase().contains(
            widget.searchQuery.toLowerCase(),
          );
      return ok && veg && q;
    }).toList();

    filtered.sort((a, b) {
      final aOut =
          a.balanceQuantity <= 0 || a.stock?.toLowerCase() != 'in_stock';
      final bOut =
          b.balanceQuantity <= 0 || b.stock?.toLowerCase() != 'in_stock';
      if (aOut == bOut) return 0;
      return aOut ? 1 : -1;
    });

    if (filtered.isEmpty) {
      return _buildEmpty();
    }

    final crossAxis = Radiusc.crossAxis(context);
    final cardExtent = Radiusc.cardExtent(
      context,
      showCart: widget.showCartButton,
    );

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxis,
          crossAxisSpacing: 10.w,
          mainAxisSpacing: 12.h,
          mainAxisExtent: cardExtent,
        ),
        itemCount: filtered.length,
        itemBuilder: (_, i) {
          final dish = filtered[i];
          final isOut =
              dish.balanceQuantity <= 0 ||
              dish.stock?.toLowerCase() != 'in_stock';
          final isFav = widget.favoriteMap.containsKey(dish.dishId);
          return _AnimatedProductCard(
            index: i,
            child: ProductCard(
              dish: dish,
              imageWidget: _buildDishImage(dish.dishImage),
              name: dish.dishName ?? '',
              price: '₹${dish.price}',
              effectivePrice: '₹${dish.effectivePrice}',
              description: dish.description ?? '',
              favoriteButton: FavoriteButton(
                dish: dish,
                isInitiallyLiked: isFav,
                favId: widget.favoriteMap[dish.dishId],
                onChanged: (dishId, isLiked, favId) {
                  setState(() {
                    if (isLiked) {
                      if (favId != null) {
                        widget.favoriteMap[dishId] = favId;
                      }
                    } else {
                      widget.favoriteMap.remove(dishId);
                    }
                  });
                },
              ),
              cartButton: CartButton(
                dishId: dish.dishId,
                balanceQuantity: dish.balanceQuantity,
              ),
              isOutOfStock: isOut,
              balanceQuantity: dish.balanceQuantity,
              discount: dish.discount,
              tag: dish.tag,
              showCartButton: widget.showCartButton,
            ),
          );
        },
      ),
    );
  }

  Widget _buildDishImage(String? url) {
    if (url != null && url.isNotEmpty) {
      return Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _imagePlaceholder(),
      );
    }
    return _imagePlaceholder();
  }

  Widget _imagePlaceholder() {
    return Container(
      color: Menucolours.surfaceAlt,
      child: Center(
        child: Icon(
          Icons.fastfood_rounded,
          size: 32.sp,
          color: Menucolours.textM,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: BoxDecoration(
                color: Menucolours.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 32.sp,
                color: Menucolours.textM,
              ),
            ),
            SizedBox(height: 14.h),
            Text(
              'Nothing here',
              style: Menucolours.h2(color: Menucolours.textH),
            ),
            SizedBox(height: 6.h),
            Text(
              widget.emptyMessage,
              style: Menucolours.body(color: Menucolours.textS),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Padding(
      padding: EdgeInsets.all(20.w),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 360),
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Menucolours.surface,
            borderRadius: Menucolours.r20,
            border: Border.all(color: Menucolours.border),
            boxShadow: Menucolours.cardShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.r,
                height: 64.r,
                decoration: BoxDecoration(
                  color: Menucolours.nonVegRed.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.restaurant_menu_rounded,
                  color: Menucolours.nonVegRed,
                  size: 28.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Text(
                'Action Required',
                style: Menucolours.h2(),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),
              Text(
                _errorMessage!,
                style: Menucolours.body(color: Menucolours.textS),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => MainScreenfood()),
                    (r) => false,
                  ),
                  icon: Icon(Icons.swap_horiz_rounded, size: 18.sp),
                  label: Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Menucolours.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: Menucolours.r12,
                    ),
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

// ── Staggered card animation ──────────────────────────────────────────────────
class _AnimatedProductCard extends StatefulWidget {
  final int index;
  final Widget child;

  const _AnimatedProductCard({required this.index, required this.child});

  @override
  State<_AnimatedProductCard> createState() => _AnimatedProductCardState();
}

class _AnimatedProductCardState extends State<_AnimatedProductCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    final curved = CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic);
    _scale = Tween<double>(begin: 0.94, end: 1.0).animate(curved);
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(curved);

    Future.delayed(Duration(milliseconds: 40 * (widget.index % 8)), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ProductCard
// ─────────────────────────────────────────────────────────────────────────────
class ProductCard extends StatelessWidget {
  final Widget imageWidget;
  final String name;
  final String price;
  final String description;
  final String effectivePrice;
  final Widget favoriteButton;
  final Widget cartButton;
  final bool isOutOfStock;
  final int balanceQuantity;
  final num discount;
  final String? tag;
  final bool showCartButton;
  final Dish dish;

  const ProductCard({
    super.key,
    required this.imageWidget,
    required this.name,
    required this.price,
    required this.description,
    required this.effectivePrice,
    required this.favoriteButton,
    required this.cartButton,
    required this.isOutOfStock,
    required this.balanceQuantity,
    required this.discount,
    required this.tag,
    required this.showCartButton,
    required this.dish,
  });

  @override
  Widget build(BuildContext context) {
    final isPhone = Radiusc.isPhone(context);
    final imgH = isPhone ? 115.0 : 140.0;

    return Container(
      decoration: BoxDecoration(
        color: Menucolours.surface,
        borderRadius: Menucolours.r16,
        border: Border.all(color: Menucolours.borderLight),
        boxShadow: Menucolours.cardShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Image section ────────────────────────────────────────
          SizedBox(
            height: imgH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                imageWidget,

                // Scrim for readability
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.6, 1.0],
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.15),
                      ],
                    ),
                  ),
                ),

                // Discount badge
                if (discount > 0)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 7.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: Menucolours.accent,
                        borderRadius: Menucolours.r8,
                      ),
                      child: Text(
                        '${discount.toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ),

                // Favourite button
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    width: 30.r,
                    height: 30.r,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(child: favoriteButton),
                  ),
                ),



                // Out-of-stock overlay
                if (isOutOfStock)
                  Positioned.fill(
                    child: Container(
                      color: Colors.black.withOpacity(0.52),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 5.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: Menucolours.r20,
                          ),
                          child: Text(
                            'Out of Stock',
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: Menucolours.nonVegRed,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Details section ───────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.fromLTRB(10.w, 8.h, 10.w, 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 38.h, // 👈 FIXED HEIGHT (adjust if needed)
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                              height: 1.3,
                            ),
                          ),
                        ),

                        SizedBox(width: 6.w),

                        if (description.trim().isNotEmpty == true)
                          Padding(
                            padding: EdgeInsets.only(top: 2.h),
                            child: GestureDetector(
                              onTap: () => showDishBottomSheet(
                                context,
                                dish,
                                showCartButton,
                              ),
                              child: Container(
                                width: 20.r,
                                height: 20.r,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  'i',
                                  style: TextStyle(
                                    fontSize: 13.sp,

                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // Name
                  SizedBox(height: 4.h),

                  // Price row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (discount > 0) ...[
                        Text(
                          price,
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            decorationColor: Menucolours.textM,
                            fontSize: 10.sp,
                            color: Menucolours.textM,
                          ),
                        ),
                        SizedBox(width: 4.w),
                      ],
                      Text(effectivePrice, style: Menucolours.price()),
                      const Spacer(),
                      vegNonVegIndicator(tag),
                    ],
                  ),

                  if (showCartButton) ...[
                    const Spacer(),
                    Center(child: cartButton),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Veg/Non-veg dot indicator ─────────────────────────────────────────────────
Widget vegNonVegIndicator(String? tag) {
  final isVeg = tag?.toLowerCase() == 'veg';
  final color = isVeg ? Menucolours.vegGreen : Menucolours.nonVegRed;

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

// ── Dish detail bottom sheet ──────────────────────────────────────────────────
void showDishBottomSheet(BuildContext context, Dish dish, bool showCartButton) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return SafeArea(
        child: Container(
          decoration: BoxDecoration(
            color: Menucolours.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Menucolours.border,
                            borderRadius: Menucolours.r4,
                          ),
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // 🔥 Only Description
                      Text(
                        dish.description?.trim().isNotEmpty == true
                            ? dish.description!
                            : 'No description available.',
                        style: Menucolours.body(color: Menucolours.textS),
                      ),

                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ── Restaurant banner header (public, used externally) ────────────────────────
class RestaurantBannerHeader extends StatelessWidget {
  final String? bannerImage;
  final String title;
  final String subtitle;

  const RestaurantBannerHeader({
    super.key,
    required this.bannerImage,
    required this.title,
    required this.subtitle,
  });

  ImageProvider _getImage(String img) {
    if (img.startsWith('http')) return NetworkImage(img);
    return MemoryImage(base64Decode(img));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        bannerImage != null && bannerImage!.isNotEmpty
            ? Image(image: _getImage(bannerImage!), fit: BoxFit.cover)
            : Container(
                color: Menucolours.surfaceAlt,
                child: Center(
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 48.sp,
                    color: Menucolours.textM,
                  ),
                ),
              ),
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.bottomCenter,
              end: Alignment.topCenter,
              colors: [Colors.black.withOpacity(0.7), Colors.transparent],
            ),
          ),
        ),
      ],
    );
  }
}
