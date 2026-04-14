import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/notifications.dart';
import '../screens/saved_address.dart';
import 'common_location.dart';

// ─── Design tokens (shared) ───────────────────────────────────────────────────
class AppBarTokens {
  static const primary = Color(0xFFE23744);
  static const text = Color(0xFF1C1C1C);
  static const textMuted = Color(0xFF7C7C7C);
}

/// A ready-to-use [SliverAppBar] that reads location from [LocationProvider].
/// Drop this into any screen's [CustomScrollView] as the first sliver.
///
/// Parameters:
///   [scrollController]  – same controller your screen passes to the sliver.
///   [bannerChild]       – the hero content shown below the location row
///                         when the bar is expanded (e.g. image banner).
///   [expandedHeight]    – height of the fully expanded bar (default ~70 % screen).
///   [collapsedBarColor] – AppBar colour when collapsed (default white).
///   [primaryColor]      – accent colour used for collapsed icons (default red).
class SharedSliverAppBar extends StatefulWidget {
  final ScrollController scrollController;
  final Widget? bannerChild;
  final double? expandedHeight;
  final Color collapsedBarColor;
  final Color primaryColor;

  const SharedSliverAppBar({
    super.key,
    required this.scrollController,
    this.bannerChild,
    this.expandedHeight,
    this.collapsedBarColor = Colors.white,
    this.primaryColor = AppBarTokens.primary,
  });

  @override
  State<SharedSliverAppBar> createState() => _SharedSliverAppBarState();
}

class _SharedSliverAppBarState extends State<SharedSliverAppBar> {
  bool _isBannerCollapsed = false;

  double get _bannerHeight {
    if (widget.expandedHeight != null) return widget.expandedHeight!;
    final h = MediaQuery.of(context).size.height;
    return (h * 0.70).clamp(250.0, 350.0);
  }

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
    // Register the location-change callback once
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final loc = LocationProvider.of(context);
      loc.onChangeLocationRequested = _openSavedAddress;
    });
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
    final collapsed = widget.scrollController.offset > collapseThreshold;
    if (collapsed != _isBannerCollapsed && mounted) {
      setState(() => _isBannerCollapsed = collapsed);
    }
  }

  void _openSavedAddress() {
    final loc = LocationProvider.of(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedAddress(
          onAddressSelected: (address) {
            loc.updateLocationFromAddress(
              address.fullAddress,
              address.category,
            );
          },
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NotificationScreen()),
    );
  }

  // ─── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: _bannerHeight,
      floating: false,
      pinned: true,
      snap: false,
      elevation: _isBannerCollapsed ? 2 : 0,
      backgroundColor: _isBannerCollapsed
          ? widget.collapsedBarColor
          : Colors.transparent,
      systemOverlayStyle: _isBannerCollapsed
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      title: _isBannerCollapsed ? _buildCollapsedBar() : null,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _buildExpandedBanner(),
      ),
    );
  }

  // ─── Expanded banner (hero image + location row) ───────────────────────────
  Widget _buildExpandedBanner() {
    return SizedBox(
      height: _bannerHeight,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero content (image / custom widget)
          if (widget.bannerChild != null) widget.bannerChild!,

          // Gradient overlay
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0x99000000),
                  Color(0x33000000),
                  Colors.transparent,
                ],
              ),
            ),
          ),

          // Location + notification row
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _LocationContent(
                          isDark: false,
                          isExpanded: true,
                          onTap: _openSavedAddress,
                        ),
                      ),
                      _NotificationButton(
                        onTap: _openNotifications,
                        useDarkStyle: false,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Collapsed bar (white background) ─────────────────────────────────────
  Widget _buildCollapsedBar() {
    return Row(
      children: [
        Expanded(
          child: _LocationContent(
            isDark: true,
            isExpanded: false,
            onTap: _openSavedAddress,
          ),
        ),
        SizedBox(width: 8.w),
        _NotificationButton(
          onTap: _openNotifications,
          useDarkStyle: true,
          primaryColor: widget.primaryColor,
        ),
      ],
    );
  }
}

// ─── Location content widget ──────────────────────────────────────────────────
class _LocationContent extends StatelessWidget {
  final bool isDark;
  final bool isExpanded;
  final VoidCallback onTap;

  const _LocationContent({
    required this.isDark,
    required this.isExpanded,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final loc = LocationProvider.of(context);
    return loc.isLoggedIn
        ? _LoggedInLocation(
            isDark: isDark,
            isExpanded: isExpanded,
            onTap: onTap,
            location: loc.currentLocation,
            category: loc.locationCategory,
          )
        : _GuestLocation(
            isDark: isDark,
            isExpanded: isExpanded,
            location: loc.currentLocation,
            isLoading: loc.isGuestLocationLoading,
          );
  }
}

// ─── Logged-in location row ───────────────────────────────────────────────────
class _LoggedInLocation extends StatelessWidget {
  final bool isDark, isExpanded;
  final VoidCallback onTap;
  final String location;
  final String? category;

  const _LoggedInLocation({
    required this.isDark,
    required this.isExpanded,
    required this.onTap,
    required this.location,
    required this.category,
  });

  IconData get _categoryIcon {
    switch ((category ?? '').toLowerCase()) {
      case 'home':
        return Icons.home_rounded;
      case 'office':
        return Icons.work_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppBarTokens.text : Colors.white;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(_categoryIcon, color: color, size: isExpanded ? 18 : 16),
          SizedBox(width: isExpanded ? 6.w : 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isExpanded)
                  Text(
                    (category ?? 'Delivering to').replaceFirstMapped(
                      RegExp(r'^[a-z]'),
                      (m) => m.group(0)!.toUpperCase(),
                    ),
                    style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                  ),
                Text(
                  location,
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
}

// ─── Guest location row ───────────────────────────────────────────────────────
class _GuestLocation extends StatelessWidget {
  final bool isDark, isExpanded, isLoading;
  final String location;

  const _GuestLocation({
    required this.isDark,
    required this.isExpanded,
    required this.location,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDark ? AppBarTokens.text : Colors.white;
    final subColor = isDark ? AppBarTokens.textMuted : Colors.white70;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isExpanded)
          Text(
            'Current Location',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w800,
              color: subColor,
            ),
          ),
        if (isExpanded) SizedBox(height: 2.h),
        if (isLoading)
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
                child: CircularProgressIndicator(strokeWidth: 2, color: color),
              ),
              SizedBox(width: 6.w),
              Text(
                'Fetching location...',
                style: TextStyle(
                  fontSize: isExpanded ? 12.sp : 11.sp,
                  color: color,
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              Expanded(
                child: Text(
                  location.isNotEmpty ? location : 'Select Location',
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
    );
  }
}

// ─── Notification button ──────────────────────────────────────────────────────
class _NotificationButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool useDarkStyle;
  final Color primaryColor;

  const _NotificationButton({
    required this.onTap,
    required this.useDarkStyle,
    this.primaryColor = AppBarTokens.primary,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: useDarkStyle
              ? primaryColor.withOpacity(0.1)
              : Colors.white.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.notifications_none_rounded,
          color: useDarkStyle ? primaryColor : Colors.white,
          size: 20,
        ),
      ),
    );
  }
}
