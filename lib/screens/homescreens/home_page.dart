import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:maamaas/screens/homescreens/vertical%20type2.dart';
import '../../Models/promotions_model/promotions_model.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../Services/googleservices/Location_servces.dart';
import '../screens/advertisements/Advideo.dart';
import '../screens/advertisements/banneradvertisement.dart';
import '../screens/notifications.dart';
import '../screens/saved_address.dart';

class _T {
  static const primary = Color(0xFFE23744);
  static const surface = Colors.white;
  static const text = Color(0xFF1C1C1C);
  static const textMuted = Color(0xFF7C7C7C);
}

class HomePage extends StatefulWidget {
  final ScrollController scrollController;
  const HomePage({super.key, required this.scrollController});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = "";
  int _currentIndex = 0;
  String _currentLocation = "Fetching location...";
  bool _updateAvailable = false;
  AppUpdateInfo? _updateInfo;
  bool _hasShownLocationDialog = false;
  bool _isBannerCollapsed = false;
  bool _isLoggedIn = false;
  List<Campaign> homepageAds = [];
  bool _isGuestLocationLoading = false;
  String? _locationCategory;

  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    _checkLogin().then((_) {
      if (_isLoggedIn) {
        _loadLocationFromAPI();
      } else {
        _loadGuestLocation();
      }
    });
    if (kReleaseMode) {
      _checkForUpdate();
    }
    _checkLogin();
    _loadAds();
  }

  Future<void> _checkLogin() async {
    final v = await subscription_AuthService.isLoggedIn();
    if (mounted) setState(() => _isLoggedIn = v);
  }

  Future<void> _loadGuestLocation() async {
    setState(() => _isGuestLocationLoading = true);
    try {
      final r = await LocationService.getCurrentLocationWithAddress();
      if (!mounted) return;
      if (r != null) {
        final parts = [
          r.area,
          r.adminArea,
          r.city,
          r.state,
        ].where((e) => e != null && e.isNotEmpty).toList();
        final addr = parts.join(', ');
        setState(() {
          _currentLocation = (r.pincode != null && r.pincode!.isNotEmpty)
              ? '$addr - ${r.pincode}'
              : addr;
        });
      } else {
        setState(() => _currentLocation = 'Enable location');
      }
    } catch (e) {
      debugPrint('Guest location error: $e');
      if (mounted) setState(() => _currentLocation = 'Location unavailable');
    } finally {
      if (mounted) setState(() => _isGuestLocationLoading = false);
    }
  }

  Future<void> _loadLocationFromAPI() async {
    try {
      final loc = await subscription_AuthService.fetchCurrentLocation();

      if (!mounted) return;

      print("📍 RAW LOC: $loc");
      print("📍 ADDRESS CHECK: ${loc?.address}");
      print("📍 VALID: ${loc?.address?.trim().isNotEmpty}");

      // ✅ VALID LOCATION CHECK
      final isValidLocation =
          loc != null &&
          loc.address != null &&
          loc.address!.trim().isNotEmpty &&
          loc.latitude != null &&
          loc.longitude != null;

      if (isValidLocation) {
        setState(() {
          _currentLocation = loc!.address!;
          _locationCategory = loc.category;
        });

        // ✅ Reset dialog flag (important if user later deletes address)
        _hasShownLocationDialog = false;
      } else {
        _handleInvalidLocation();
      }
    } catch (e) {
      debugPrint("❌ Location API Error: $e");
      if (!mounted) return;

      _handleInvalidLocation();
    }
  }

  void _handleInvalidLocation() {
    // ❌ Don't immediately show popup
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;

      if (_currentLocation == 'Fetching location...') {
        if (!_hasShownLocationDialog) {
          _hasShownLocationDialog = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showUpdateLocationDialog();
            }
          });
        }
      }
    });
  }

  Future<void> _loadAds() async {
    try {
      final result = await promotion_Authservice.fetchcampaign();
      final filtered = result
          .where(
            (c) =>
                c.addDisplayPosition == AddDisplayPosition.HOMEPAGE_BANNER &&
                c.medium == Medium.APP,
          )
          .toList();
      if (mounted) setState(() => homepageAds = filtered);
    } catch (e) {
      debugPrint('Ads error: $e');
    }
  }

  void _showUpdateLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          title: Row(
            children: [
              Icon(Icons.location_off, color: Colors.red),
              SizedBox(width: 8.w),
              Text("Location Required"),
            ],
          ),
          content: const Text(
            "We couldn't detect your location. Please update your location to continue.",
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Later"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFB15DC6),
              ),
              child: const Text("Update Location"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _checkForUpdate() async {
    try {
      _updateInfo = await InAppUpdate.checkForUpdate();

      if (_updateInfo?.updateAvailability ==
          UpdateAvailability.updateAvailable) {
        setState(() {
          _updateAvailable = true;
        });
      }
    } catch (e) {
      debugPrint("Update check failed: $e");
    }
  }

  void _changeLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedAddress(
          onAddressSelected: (address) async {
            setState(() {
              // _currentLocation =
              //     '${address.},${address.city}, ${address.state} - ${address.pincode}';
              // _locationCategory = address.category;
              _currentLocation = address.fullAddress;

              print("Category: ${address.category}");
              print("Full Address: ${address.fullAddress}");
            });
            _hasShownLocationDialog = false;
            // await _refreshAll();
          },
        ),
      ),
    );
  }

  double get _bannerHeight {
    final h = MediaQuery.of(context).size.height;
    return (h * 0.70).clamp(250.0, 350.0);
  }

  void _onScroll() {
    final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
    final collapsed = widget.scrollController.offset > collapseThreshold;
    if (collapsed != _isBannerCollapsed && mounted) {
      setState(() => _isBannerCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (_currentIndex != 0) {
          setState(() {
            _currentIndex = 0;
          });
          return false;
        }
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          child: CustomScrollView(
            slivers: [
              _buildSliverAppBar(),

              SliverToBoxAdapter(child: Column(children: [Vertical()])),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoSection() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(child: VideoPreviewContainer()),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _bannerHeight,
      collapsedHeight: kToolbarHeight,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,

      backgroundColor: _isBannerCollapsed ? _T.surface : Colors.transparent,

      systemOverlayStyle: _isBannerCollapsed
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      automaticallyImplyLeading: false,

      title: _isBannerCollapsed ? _buildCollapsedBar() : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildHeroBanner(),
      ),
    );
  }

  Widget _buildHeroBanner() {
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
        children: [
          /// 🔹 Background (Ad / Video)
          _isLoggedIn
              ? (homepageAds.isEmpty
                    ? Container(color: const Color(0xFFCCCCCC))
                    : BannerAdvertisement(
                        ads: homepageAds,
                        height: _bannerHeight,
                      ))
              : const VideoPreviewContainer(),

          /// 🔹 Gradient overlay
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000), // slightly stronger for readability
                  Color(0x33000000),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          /// 🔹 Top Content (SafeArea prevents notch overlap)
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),

                  /// 📍 Location + Notification Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildLocationContent(
                          isDark: false, // white text
                          isExpanded: true, // bigger UI
                        ),
                      ),

                      /// 🔔 Notification Icon
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationScreen(),
                            ),
                          );
                        },
                        child: Container(
                          width: 36.w,
                          height: 36.w,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // SizedBox(height: 14.h),
                  //
                  // /// 🔍 Search Bar
                  // _BannerSearchBar(onChanged: _onSearchChanged),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationContent({
    required bool isDark,
    required bool isExpanded,
  }) {
    return _isLoggedIn
        ? _buildAppBarContent(isDark: isDark, isExpanded: isExpanded)
        : _buildGuestAppBar(isDark: isDark, isExpanded: isExpanded);
  }

  IconData _getCategoryIcon() {
    final cat = (_locationCategory ?? '').toLowerCase();

    switch (cat) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.work_rounded;
      case 'others':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Widget _buildAppBarContent({required bool isDark, required bool isExpanded}) {
    final color = isDark ? _T.text : Colors.white;

    return GestureDetector(
      onTap: _changeLocation,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(_getCategoryIcon(), color: color, size: isExpanded ? 18 : 16),
          SizedBox(width: isExpanded ? 6.w : 4.w),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                /// 👇 Show only in expanded (Hero)
                if (isExpanded)
                  Text(
                    (_locationCategory ?? 'Delivering to').replaceFirstMapped(
                      RegExp(r'^[a-z]'),
                      (m) => m.group(0)!.toUpperCase(),
                    ),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                Text(
                  _currentLocation,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: isExpanded ? 14.sp : 13.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.keyboard_arrow_down_rounded,
            color: color,
            size: isExpanded ? 18 : 20,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestAppBar({required bool isDark, required bool isExpanded}) {
    final color = isDark ? _T.text : Colors.white;
    final subColor = isDark ? _T.textMuted : Colors.white70;

    return GestureDetector(
      onTap: () {
        // Navigate to login or location picker
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          /// 👇 Show title only in expanded (banner)
          if (isExpanded)
            Text(
              "Current Location",
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.w800,
                color: subColor,
              ),
            ),

          if (isExpanded) SizedBox(height: 2.h),

          /// 🔄 Loading State
          if (_isGuestLocationLoading)
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: color,
                  size: isExpanded ? 18 : 16,
                ),
                SizedBox(
                  width: isExpanded ? 14.w : 12.w,
                  height: isExpanded ? 14.w : 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  "Fetching location...",
                  style: TextStyle(
                    fontSize: isExpanded ? 12.sp : 11.sp,
                    color: color,
                  ),
                ),
              ],
            )
          /// 📍 Location State
          else
            Row(
              children: [
                Expanded(
                  child: Text(
                    _currentLocation.isNotEmpty
                        ? _currentLocation
                        : "Select Location",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isExpanded ? 13.sp : 12.sp,
                      fontWeight: FontWeight.w600,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildCollapsedBar() {
    return Row(
      children: [
        /// 📍 Location Section
        Expanded(
          child: _buildLocationContent(
            isDark: true, // dark text
            isExpanded: false, // compact UI
          ),
        ),

        SizedBox(width: 8.w),

        /// 🔔 Notification Icon
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen()),
            );
          },
          child: Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: _T.primary.withOpacity(0.1), // better visibility
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.notifications_none_rounded,
              color: _T.primary,
              size: 20,
            ),
          ),
        ),
      ],
    );
  }
}
