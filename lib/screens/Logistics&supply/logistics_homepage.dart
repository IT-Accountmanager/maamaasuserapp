// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:intl/intl.dart';
// import '../../Models/logistics/locationmodel.dart';
// import '../../Models/logistics/vechilemodel.dart';
// import '../../Services/Auth_service/logisticsservice.dart';
// import '../../Services/Auth_service/promotion_services_Authservice.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Models/promotions_model/promotions_model.dart';
// import '../../Services/googleservices/Location_servces.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import '../screens/advertisements/banneradvertisement.dart';
// import 'package:in_app_update/in_app_update.dart';
// import '../screens/advertisements/Advideo.dart';
// import 'package:flutter/foundation.dart';
// import '../screens/notifications.dart';
// import '../screens/saved_address.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'finding_driver_screen.dart';
// import 'location.dart';
//
// // ─── Design Tokens ────────────────────────────────────────────────────────────
// const _kPrimary = Color(0xFF6C3CE1); // deep violet
// const _kPrimaryLight = Color(0xFFF0EAFB); // lavender tint
// const _kAccent = Color(0xFF00C896); // mint green
// const _kBg = Color(0xFFF7F8FC); // off-white background
// const _kSurface = Colors.white;
// const _kText = Color(0xFF1A1A2E); // near-black
// const _kTextSub = Color(0xFF8A8FAB); // muted label
// const _kBorder = Color(0xFFE8EAF2);
// const _kRadius = 16.0;
// const _kRadiusLg = 24.0;
// const primary = Color(0xFFE23744);
// const surface = Colors.white;
// const text = Color(0xFF1C1C1C);
// const textMuted = Color(0xFF7C7C7C);
//
// class logistic_HomePage extends StatefulWidget {
//   final ScrollController scrollController;
//   const logistic_HomePage({super.key, required this.scrollController});
//   @override
//   // ignore: library_private_types_in_public_api
//   _HomePageState createState() => _HomePageState();
// }
//
// class _HomePageState extends State<logistic_HomePage>
//     with TickerProviderStateMixin {
//   String selectedTab = "";
//   int _currentIndex = 0;
//   String _currentLocation = "Fetching location...";
//   AppUpdateInfo? _updateInfo;
//   bool _hasShownLocationDialog = false;
//   bool _isBannerCollapsed = false;
//   bool _isLoggedIn = false;
//   List<Campaign> homepageAds = [];
//   bool _isGuestLocationLoading = false;
//   String? _locationCategory;
//
//   String selectedService = "Travel";
//   late AnimationController _animationController;
//
//   void initState() {
//     super.initState();
//
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//
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
//     _checkLogin();
//     _loadAds();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
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
//   Future<void> _loadAds() async {
//     try {
//       final result = await promotion_Authservice.fetchcampaign();
//       final filtered = result
//           .where(
//             (c) =>
//                 c.medium == Medium.APP &&
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
//   void _showUpdateLocationDialog() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16.r),
//           ),
//           title: Row(
//             children: [
//               Icon(Icons.location_off, color: Colors.red),
//               SizedBox(width: 8.w),
//               Text("Location Required"),
//             ],
//           ),
//           content: const Text(
//             "We couldn't detect your location. Please update your location to continue.",
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: const Text("Later"),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.pop(context);
//                 _changeLocation();
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFFB15DC6),
//               ),
//               child: const Text("Update Location"),
//             ),
//           ],
//         );
//       },
//     );
//   }
//
//   Future<void> _checkForUpdate() async {
//     try {
//       _updateInfo = await InAppUpdate.checkForUpdate();
//
//       if (_updateInfo?.updateAvailability ==
//           UpdateAvailability.updateAvailable) {
//         setState(() {});
//       }
//     } catch (e) {
//       //       debugPrint("Update check failed: $e");
//     }
//   }
//
//   void _changeLocation() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SavedAddress(
//           onAddressSelected: (address) async {
//             setState(() {
//               _currentLocation = address.fullAddress;
//             });
//             _hasShownLocationDialog = false;
//             // await _refreshAll();
//           },
//         ),
//       ),
//     );
//   }
//
//   double get _bannerHeight {
//     final h = MediaQuery.of(context).size.height;
//     return (h * 0.70).clamp(250.0, 350.0);
//   }
//
//   void _onScroll() {
//     // ✅ Guard: don't access MediaQuery before layout
//     if (!mounted) return;
//     final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
//     final collapsed = widget.scrollController.offset > collapseThreshold;
//     if (collapsed != _isBannerCollapsed && mounted) {
//       setState(() => _isBannerCollapsed = collapsed);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // ignore: deprecated_member_use
//     return WillPopScope(
//       onWillPop: () async {
//         if (_currentIndex != 0) {
//           setState(() {
//             _currentIndex = 0;
//           });
//           return false;
//         }
//         return false;
//       },
//       child: Scaffold(
//         backgroundColor: Colors.white,
//         body: RefreshIndicator(
//           onRefresh: () async {
//             await Future.delayed(const Duration(seconds: 1));
//             setState(() {});
//           },
//           child: CustomScrollView(
//             controller: widget.scrollController,
//             slivers: [
//               _buildSliverAppBar(),
//
//               SliverToBoxAdapter(
//                 child: LogisticsScreen(
//                   selectedService: selectedService,
//                 ), // now only forms/content
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSliverAppBar() {
//     return SliverAppBar(
//       expandedHeight: _bannerHeight,
//       collapsedHeight: kToolbarHeight,
//       pinned: true,
//       elevation: 0,
//       scrolledUnderElevation: 0,
//       backgroundColor: _isBannerCollapsed ? surface : Colors.transparent,
//       systemOverlayStyle: _isBannerCollapsed
//           ? SystemUiOverlayStyle.dark
//           : SystemUiOverlayStyle.light,
//       leading: _isBannerCollapsed
//           ? IconButton(
//               icon: const Icon(Icons.arrow_back_ios),
//               color: Colors.black,
//               onPressed: () => Navigator.pop(context),
//             )
//           : null,
//       automaticallyImplyLeading: false,
//       // ✅ Always provide a non-null title
//       title: _isBannerCollapsed
//           ? _buildCollapsedBar()
//           : const SizedBox.shrink(),
//       flexibleSpace: FlexibleSpaceBar(
//         collapseMode: CollapseMode.pin,
//         background: _buildHeroBanner(),
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
//           const DecoratedBox(
//             decoration: BoxDecoration(
//               gradient: LinearGradient(
//                 begin: Alignment.topCenter,
//                 end: Alignment.bottomCenter,
//                 colors: [
//                   Color(0x99000000), // slightly stronger for readability
//                   Color(0x33000000),
//                   Colors.transparent,
//                 ],
//               ),
//             ),
//           ),
//
//           /// 🔹 Top Content (SafeArea prevents notch overlap)
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
//         ],
//       ),
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
//     final color = isDark ? text : Colors.white;
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
//     final color = isDark ? text : Colors.white;
//     final subColor = isDark ? textMuted : Colors.white70;
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
//               color: primary.withOpacity(0.1), // better visibility
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.notifications_none_rounded,
//               color: primary,
//               size: 20,
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── Main Screen ──────────────────────────────────────────────────────────────
// class LogisticsScreen extends StatefulWidget {
//   final String selectedService; // ← add this
//   const LogisticsScreen({
//     super.key,
//     required this.selectedService,
//   }); // ← add const + required
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _LogisticsScreenState createState() => _LogisticsScreenState();
// }
//
// class _LogisticsScreenState extends State<LogisticsScreen>
//     with SingleTickerProviderStateMixin {
//   // String selectedService = "Travel";
//   late AnimationController _animationController;
//   Map<String, Set<String>> tempFilters = {};
//   String? selectedVertical;
//   String? selectedSubCategory;
//   String? selectedSubCat;
//   Map<String, Set<String>> appliedFilters = {};
//
//   @override
//   void initState() {
//     super.initState();
//     _animationController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 350),
//     );
//     _animationController.forward();
//   }
//
//   @override
//   void dispose() {
//     _animationController.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Container(
//           decoration: const BoxDecoration(
//             color: _kSurface,
//             borderRadius: BorderRadius.vertical(
//               top: Radius.circular(_kRadiusLg),
//             ),
//             boxShadow: [
//               BoxShadow(
//                 color: Color(0x0A000000),
//                 blurRadius: 20,
//                 offset: Offset(0, -4),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: const BorderRadius.vertical(
//               top: Radius.circular(_kRadiusLg),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
//               child: AnimatedSwitcher(
//                 duration: const Duration(milliseconds: 300),
//                 transitionBuilder: (child, anim) => FadeTransition(
//                   opacity: anim,
//                   child: SlideTransition(
//                     position: Tween<Offset>(
//                       begin: const Offset(0.04, 0),
//                       end: Offset.zero,
//                     ).animate(anim),
//                     child: child,
//                   ),
//                 ),
//                 child: PassengerForm(),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// // ─── Shared Form Shell ────────────────────────────────────────────────────────
// Widget buildForm(
//   BuildContext context, {
//   required IconData icon,
//   required List<Widget> children,
// }) {
//   return SingleChildScrollView(
//     physics: const BouncingScrollPhysics(),
//     child: Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         ...children,
//         const SizedBox(height: 32),
//         SizedBox(
//           width: double.infinity,
//           child: ElevatedButton(
//             onPressed: () => Navigator.push(
//               context,
//               MaterialPageRoute(builder: (_) => const FindingDriverScreen()),
//             ),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: _kPrimary,
//               foregroundColor: Colors.white,
//               elevation: 0,
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(_kRadius),
//               ),
//               padding: const EdgeInsets.symmetric(vertical: 16),
//             ),
//             child: const Text(
//               'Book Now',
//               style: TextStyle(
//                 fontSize: 16,
//                 fontWeight: FontWeight.w700,
//                 letterSpacing: 0.3,
//               ),
//             ),
//           ),
//         ),
//         const SizedBox(height: 20),
//       ],
//     ),
//   );
// }
//
// // ─── Shared Section Header ────────────────────────────────────────────────────
// Widget _sectionLabel(String text) => Padding(
//   padding: const EdgeInsets.only(bottom: 10),
//   child: Text(
//     text,
//     style: const TextStyle(
//       fontSize: 14,
//       fontWeight: FontWeight.w700,
//       color: _kText,
//       letterSpacing: 0.2,
//     ),
//   ),
// );
//
// class LocationField extends StatefulWidget {
//   final String label;
//   final TextEditingController controller;
//   final IconData icon;
//   final Function(SelectedLocation location)? onLocationSelected;
//   final List<String> Function()? recentLocationsProvider;
//
//   const LocationField({
//     super.key,
//     required this.label,
//     required this.controller,
//     required this.icon,
//     this.recentLocationsProvider,
//     this.onLocationSelected,
//   });
//
//   @override
//   State<LocationField> createState() => _LocationFieldState();
// }
//
// class _LocationFieldState extends State<LocationField> {
//   bool get _isPickup => widget.label.toLowerCase().contains('pickup');
//
//   Color get _dotColor => _isPickup ? _kAccent : _kPrimary;
//
//   void _openLocationPicker() {
//     FocusScope.of(context).unfocus();
//
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (context) => LocationEntryScreen(
//         type: _isPickup ? 'pickup' : 'drop',
//         recentLocations: const ["Home", "Office", "Airport"],
//
//         onLocationSelected: (location) {
//           setState(() {
//             widget.controller.text = location.address;
//           });
//
//           widget.onLocationSelected?.call(location);
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: _openLocationPicker,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//         decoration: BoxDecoration(
//           color: _kBg,
//           borderRadius: BorderRadius.circular(_kRadius),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 34,
//               height: 34,
//               decoration: BoxDecoration(
//                 color: _dotColor.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(widget.icon, size: 16, color: _dotColor),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.label,
//                     style: const TextStyle(
//                       fontSize: 11,
//                       color: _kTextSub,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     widget.controller.text.isEmpty
//                         ? 'Tap to search location'
//                         : widget.controller.text,
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: widget.controller.text.isEmpty
//                           ? _kTextSub
//                           : _kText,
//                       fontWeight: widget.controller.text.isEmpty
//                           ? FontWeight.w400
//                           : FontWeight.w600,
//                     ),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                 ],
//               ),
//             ),
//             if (widget.controller.text.isNotEmpty)
//               GestureDetector(
//                 onTap: () => setState(() => widget.controller.clear()),
//                 child: const Icon(
//                   Icons.close_rounded,
//                   size: 18,
//                   color: _kTextSub,
//                 ),
//               )
//             else
//               const Icon(Icons.search_rounded, size: 18, color: _kTextSub),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Vehicle Row Card ─────────────────────────────────────────────────────────
// Widget _vehicleRowCard({
//   required String symbol,
//   required String label,
//   required String price,
//   required bool isSelected,
//   required VoidCallback onTap,
// }) {
//   return GestureDetector(
//     onTap: onTap,
//     child: AnimatedContainer(
//       duration: const Duration(milliseconds: 180),
//       margin: const EdgeInsets.symmetric(vertical: 5),
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//       decoration: BoxDecoration(
//         color: isSelected ? _kPrimary : _kBg,
//         borderRadius: BorderRadius.circular(_kRadius),
//         border: Border.all(
//           color: isSelected ? _kPrimary : _kBorder,
//           width: 1.5,
//         ),
//       ),
//       child: Row(
//         children: [
//           Text(symbol, style: const TextStyle(fontSize: 22)),
//           const SizedBox(width: 14),
//           Expanded(
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w600,
//                 fontSize: 15,
//                 color: isSelected ? Colors.white : _kText,
//               ),
//             ),
//           ),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//             decoration: BoxDecoration(
//               color: isSelected
//                   ? Colors.white.withOpacity(0.2)
//                   : _kPrimaryLight,
//               borderRadius: BorderRadius.circular(8),
//             ),
//             child: Text(
//               '₹$price',
//               style: TextStyle(
//                 fontWeight: FontWeight.w700,
//                 fontSize: 14,
//                 color: isSelected ? Colors.white : _kPrimary,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//   );
// }
//
// // ─── Passenger Form ───────────────────────────────────────────────────────────
// class PassengerForm extends StatefulWidget {
//   const PassengerForm({super.key});
//   @override
//   // ignore: library_private_types_in_public_api
//   _PassengerFormState createState() => _PassengerFormState();
// }
//
// class _PassengerFormState extends State<PassengerForm> {
//   final pickupController = TextEditingController();
//   final dropController = TextEditingController();
//   String? selectedCategory;
//   int noOfPeople = 0;
//   final noofpeopleController = TextEditingController();
//   SelectedLocation? pickupLocation;
//   SelectedLocation? dropLocation;
//   List<VehicleModel> availableVehicles = [];
//
//   bool loadingVehicles = false;
//
//   @override
//   void dispose() {
//     pickupController.dispose();
//     dropController.dispose();
//     noofpeopleController.dispose();
//     super.dispose();
//   }
//
//   Future<void> fetchAvailableVehicles() async {
//     if (pickupLocation == null || dropLocation == null || noOfPeople == 0) {
//       return;
//     }
//
//     setState(() {
//       loadingVehicles = true;
//     });
//
//     try {
//       final vehicles = await LogisticsService.getVehicles(
//         pickupLatitude: pickupLocation!.latitude,
//
//         pickupLongitude: pickupLocation!.longitude,
//
//         dropLatitude: dropLocation!.latitude,
//
//         dropLongitude: dropLocation!.longitude,
//
//         passengers: noOfPeople,
//       );
//
//       setState(() {
//         availableVehicles = vehicles;
//       });
//     } catch (e) {
//       print(e);
//     } finally {
//       setState(() {
//         loadingVehicles = false;
//       });
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return buildForm(
//       context,
//       icon: Icons.directions_car_rounded,
//       children: [
//         _sectionLabel('Passengers'),
//         _modernTextField(
//           controller: noofpeopleController,
//           hint: 'Number of passengers',
//           icon: Icons.person_outline_rounded,
//           keyboardType: TextInputType.number,
//           onChanged: (v) {
//             setState(() {
//               noOfPeople = int.tryParse(v) ?? 0;
//             });
//
//             print("Passengers $noOfPeople");
//
//             fetchAvailableVehicles();
//           },
//         ),
//         const SizedBox(height: 16),
//         _sectionLabel('Pickup & Drop'),
//
//         LocationField(
//           label: 'Pickup Location',
//           controller: pickupController,
//           icon: Icons.trip_origin_rounded,
//
//           onLocationSelected: (location) {
//             setState(() {
//               pickupLocation = location;
//               print("Pickup ${pickupLocation?.latitude}");
//               print("Pickup ${pickupLocation?.longitude}");
//             });
//             fetchAvailableVehicles();
//
//             print("Pickup Address : ${location.address}");
//
//             print("Pickup Lat : ${location.latitude}");
//
//             print("Pickup Lng : ${location.longitude}");
//           },
//         ),
//         const SizedBox(height: 10),
//
//         LocationField(
//           label: 'Drop Location',
//           controller: dropController,
//           icon: Icons.location_on_rounded,
//
//           onLocationSelected: (location) {
//             setState(() {
//               dropLocation = location;
//             });
//             print("Drop ${dropLocation?.latitude}");
//             print("Drop ${dropLocation?.longitude}");
//             fetchAvailableVehicles();
//
//             print("Drop Address : ${location.address}");
//
//             print("Drop Lat : ${location.latitude}");
//
//             print("Drop Lng : ${location.longitude}");
//           },
//         ),
//         const SizedBox(height: 16),
//         const DateTimePickerField(),
//         const SizedBox(height: 16),
//         _vehicleSection(),
//       ],
//     );
//   }
//
//   // Widget _vehicleSection() {
//   //   final allVehicles = [
//   //     {'symbol': '🏍️', 'label': 'Two Wheeler', 'price': '100', 'min': 1},
//   //     {'symbol': '🛺', 'label': 'Three Wheeler', 'price': '200', 'min': 1},
//   //     {'symbol': '🚗', 'label': 'Four Wheeler', 'price': '250', 'min': 1},
//   //   ];
//   //   final filtered = allVehicles.where((v) {
//   //     if (noOfPeople <= 1) return true;
//   //     if (noOfPeople <= 3) return v['label'] != 'Two Wheeler';
//   //     return v['label'] == 'Four Wheeler';
//   //   }).toList();
//   //
//   //   return StatefulBuilder(
//   //     builder: (context, setState) {
//   //       return Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           _sectionLabel('Choose Vehicle'),
//   //           ...filtered.map(
//   //             (v) => _vehicleRowCard(
//   //               symbol: v['symbol'] as String,
//   //               label: v['label'] as String,
//   //               price: v['price'] as String,
//   //               isSelected: selectedCategory == v['label'],
//   //               onTap: () =>
//   //                   setState(() => selectedCategory = v['label'] as String),
//   //             ),
//   //           ),
//   //         ],
//   //       );
//   //     },
//   //   );
//   // }
//   Widget _vehicleSection() {
//     if (loadingVehicles) {
//       return const Padding(
//         padding: EdgeInsets.symmetric(vertical: 20),
//         child: Center(child: CircularProgressIndicator(color: _kPrimary)),
//       );
//     }
//
//     if (availableVehicles.isEmpty) {
//       return const SizedBox();
//     }
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Choose Vehicle'),
//
//         const SizedBox(height: 6),
//
//         ...availableVehicles.map((vehicle) {
//           final isSelected = selectedCategory == vehicle.vehicleStatus;
//
//           return GestureDetector(
//             onTap: () {
//               setState(() {
//                 selectedCategory = vehicle.vehicleStatus;
//               });
//             },
//
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 250),
//
//               margin: const EdgeInsets.only(bottom: 12),
//
//               padding: const EdgeInsets.all(14),
//
//               decoration: BoxDecoration(
//                 color: isSelected ? _kPrimary.withOpacity(0.08) : Colors.white,
//
//                 borderRadius: BorderRadius.circular(18),
//
//                 border: Border.all(
//                   color: isSelected ? _kPrimary : _kBorder,
//
//                   width: isSelected ? 1.8 : 1,
//                 ),
//
//                 boxShadow: [
//                   if (isSelected)
//                     BoxShadow(
//                       color: _kPrimary.withOpacity(0.15),
//                       blurRadius: 12,
//                       offset: const Offset(0, 4),
//                     ),
//                 ],
//               ),
//
//               child: Row(
//                 children: [
//                   // Vehicle Icon
//                   Container(
//                     width: 52,
//                     height: 52,
//
//                     decoration: BoxDecoration(
//                       color: isSelected ? _kPrimary : _kPrimaryLight,
//
//                       shape: BoxShape.circle,
//                     ),
//
//                     child: Center(
//                       child: Text(
//                         vehicle.vehicleType == "BIKE"
//                             ? "🏍️"
//                             : vehicle.vehicleType == "AUTO"
//                             ? "🛺"
//                             : "🚗",
//
//                         style: const TextStyle(fontSize: 26),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 14),
//
//                   // Vehicle Details
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//
//                       children: [
//                         Text(
//                           vehicle.vehicleStatus.replaceAll("_", " "),
//                           style: TextStyle(
//                             fontSize: 15,
//                             fontWeight: FontWeight.w700,
//
//                             color: isSelected ? _kPrimary : _kText,
//                           ),
//                         ),
//
//                         const SizedBox(height: 6),
//
//                         Row(
//                           children: [
//                             const Icon(
//                               Icons.timer_outlined,
//                               size: 14,
//                               color: _kTextSub,
//                             ),
//
//                             const SizedBox(width: 4),
//
//                             Text(
//                               "${vehicle.etaMinutes} min",
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: _kTextSub,
//                               ),
//                             ),
//
//                             const SizedBox(width: 12),
//
//                             const Icon(
//                               Icons.route_outlined,
//                               size: 14,
//                               color: _kTextSub,
//                             ),
//
//                             const SizedBox(width: 4),
//
//                             Text(
//                               "${vehicle.distanceKm} km",
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: _kTextSub,
//                               ),
//                             ),
//                           ],
//                         ),
//
//                         const SizedBox(height: 5),
//
//                         Row(
//                           children: [
//                             Icon(Icons.person, size: 14, color: Colors.green),
//
//                             const SizedBox(width: 4),
//
//                             Text(
//                               "${vehicle.availablePartners} available",
//                               style: const TextStyle(
//                                 fontSize: 12,
//                                 color: Colors.green,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Fare
//                   Column(
//                     crossAxisAlignment: CrossAxisAlignment.end,
//
//                     children: [
//                       Text(
//                         "₹${vehicle.estimatedFare}",
//                         style: TextStyle(
//                           fontSize: 18,
//                           fontWeight: FontWeight.w800,
//
//                           color: isSelected ? _kPrimary : _kText,
//                         ),
//                       ),
//
//                       const SizedBox(height: 6),
//
//                       AnimatedContainer(
//                         duration: const Duration(milliseconds: 200),
//
//                         width: 22,
//                         height: 22,
//
//                         decoration: BoxDecoration(
//                           shape: BoxShape.circle,
//
//                           color: isSelected ? _kPrimary : Colors.transparent,
//
//                           border: Border.all(
//                             color: isSelected ? _kPrimary : _kBorder,
//                           ),
//                         ),
//
//                         child: isSelected
//                             ? const Icon(
//                                 Icons.check,
//                                 size: 15,
//                                 color: Colors.white,
//                               )
//                             : null,
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ],
//     );
//   }
//
//   Widget _modernTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     TextInputType keyboardType = TextInputType.text,
//     Function(String)? onChanged,
//   }) {
//     return TextField(
//       controller: controller,
//       keyboardType: keyboardType,
//       onChanged: onChanged,
//       style: const TextStyle(color: _kText, fontSize: 14),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: const TextStyle(color: _kTextSub, fontSize: 14),
//         prefixIcon: Icon(icon, color: _kTextSub, size: 20),
//         filled: true,
//         fillColor: _kBg,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(_kRadius),
//           borderSide: const BorderSide(color: _kBorder),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(_kRadius),
//           borderSide: const BorderSide(color: _kBorder),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(_kRadius),
//           borderSide: const BorderSide(color: _kPrimary, width: 1.5),
//         ),
//         contentPadding: const EdgeInsets.symmetric(
//           horizontal: 16,
//           vertical: 14,
//         ),
//       ),
//     );
//   }
//
//   Widget locationField(
//     String label,
//     TextEditingController controller,
//     IconData icon,
//   ) {
//     return LocationField(label: label, controller: controller, icon: icon);
//   }
// }
//
// class LocationEntryScreen extends StatefulWidget {
//   final String type;
//   final List<String> recentLocations;
//   final Function(SelectedLocation) onLocationSelected;
//
//   const LocationEntryScreen({
//     super.key,
//     required this.type,
//     required this.recentLocations,
//     required this.onLocationSelected,
//   });
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _LocationEntryScreenState createState() => _LocationEntryScreenState();
// }
//
// class _LocationEntryScreenState extends State<LocationEntryScreen> {
//   final TextEditingController _controller = TextEditingController();
//   List<String> _suggestions = [];
//   bool _showRecent = true;
//
//   @override
//   void initState() {
//     super.initState();
//     _suggestions = widget.recentLocations;
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   Future<void> _generateSuggestions(String query) async {
//     if (query.isEmpty) {
//       setState(() {
//         _showRecent = true;
//         _suggestions = widget.recentLocations;
//       });
//       return;
//     }
//
//     _showRecent = false;
//
//     final places = GoogleMapsPlaces(
//       apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
//       apiHeaders: await const GoogleApiHeaders().getHeaders(),
//     );
//
//     final response = await places.autocomplete(
//       query,
//       components: [Component(Component.country, "in")],
//     );
//
//     if (response.isOkay) {
//       setState(() {
//         _suggestions = response.predictions
//             .map((e) => e.description ?? '')
//             .toList();
//       });
//     } else {
//       setState(() {
//         _suggestions = [];
//       });
//     }
//
//     places.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final isPickup = widget.type == 'pickup';
//     final accentColor = isPickup ? _kAccent : _kPrimary;
//
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.75,
//       decoration: const BoxDecoration(
//         color: _kSurface,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(_kRadiusLg)),
//       ),
//       padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Center(
//             child: Container(
//               margin: const EdgeInsets.only(top: 12, bottom: 16),
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: _kBorder,
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//           ),
//           Row(
//             children: [
//               Container(
//                 width: 38,
//                 height: 38,
//                 decoration: BoxDecoration(
//                   color: accentColor.withOpacity(0.12),
//                   shape: BoxShape.circle,
//                 ),
//                 child: Icon(
//                   isPickup
//                       ? Icons.trip_origin_rounded
//                       : Icons.location_on_rounded,
//                   color: accentColor,
//                   size: 18,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Text(
//                 '${isPickup ? 'Pickup' : 'Drop'} Location',
//                 style: const TextStyle(
//                   fontSize: 18,
//                   fontWeight: FontWeight.w700,
//                   color: _kText,
//                 ),
//               ),
//               const Spacer(),
//               IconButton(
//                 icon: const Icon(Icons.close_rounded, color: _kTextSub),
//                 onPressed: () => Navigator.pop(context),
//               ),
//             ],
//           ),
//           const SizedBox(height: 14),
//
//           // Search field
//           Container(
//             decoration: BoxDecoration(
//               color: _kBg,
//               borderRadius: BorderRadius.circular(_kRadius),
//               border: Border.all(color: _kBorder),
//             ),
//             child: TextField(
//               controller: _controller,
//               autofocus: true,
//               decoration: InputDecoration(
//                 hintText: 'Search area, street or landmark',
//                 hintStyle: const TextStyle(color: _kTextSub, fontSize: 14),
//                 border: InputBorder.none,
//                 prefixIcon: const Icon(
//                   Icons.search_rounded,
//                   color: _kTextSub,
//                   size: 20,
//                 ),
//                 suffixIcon: IconButton(
//                   icon: Icon(Icons.my_location_rounded, color: accentColor),
//
//                   onPressed: () async {
//                     final result =
//                         await LocationService.getCurrentLocationWithAddress();
//
//                     if (result == null) return;
//
//                     widget.onLocationSelected(
//                       SelectedLocation(
//                         address: result.fullAddress,
//                         latitude: result.latitude,
//                         longitude: result.longitude,
//                       ),
//                     );
//
//                     Navigator.pop(context);
//                   },
//                 ),
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 14,
//                 ),
//               ),
//
//               onChanged: (v) {
//                 _generateSuggestions(v);
//               },
//             ),
//           ),
//           const SizedBox(height: 14),
//
//           // Map button
//           GestureDetector(
//             onTap: () async {
//               final SelectedLocation? loc = await Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) =>
//                       MapLocationSelector(onLocationSelected: (location) {}),
//                 ),
//               );
//
//               if (loc != null) {
//                 widget.onLocationSelected(loc);
//                 Navigator.pop(context); // closes only LocationEntryScreen
//               }
//             },
//             child: Container(
//               padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 16),
//               decoration: BoxDecoration(
//                 color: _kPrimaryLight,
//                 borderRadius: BorderRadius.circular(_kRadius),
//               ),
//               child: Row(
//                 children: [
//                   Icon(Icons.map_outlined, color: _kPrimary, size: 20),
//                   const SizedBox(width: 10),
//                   const Text(
//                     'Select from Map',
//                     style: TextStyle(
//                       color: _kPrimary,
//                       fontWeight: FontWeight.w600,
//                       fontSize: 14,
//                     ),
//                   ),
//                   const Spacer(),
//                   const Icon(
//                     Icons.chevron_right_rounded,
//                     color: _kPrimary,
//                     size: 20,
//                   ),
//                 ],
//               ),
//             ),
//           ),
//           const SizedBox(height: 20),
//
//           Text(
//             _showRecent ? 'Recent' : 'Results',
//             style: const TextStyle(
//               fontSize: 13,
//               fontWeight: FontWeight.w700,
//               color: _kTextSub,
//               letterSpacing: 0.5,
//             ),
//           ),
//           const SizedBox(height: 8),
//
//           Expanded(
//             child: _suggestions.isEmpty
//                 ? const Center(
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Icon(
//                           Icons.location_off_outlined,
//                           size: 48,
//                           color: _kBorder,
//                         ),
//                         SizedBox(height: 12),
//                         Text(
//                           'No locations found',
//                           style: TextStyle(color: _kTextSub),
//                         ),
//                       ],
//                     ),
//                   )
//                 : ListView.separated(
//                     itemCount: _suggestions.length,
//                     separatorBuilder: (_, __) =>
//                         const Divider(height: 1, color: _kBorder),
//                     itemBuilder: (context, i) {
//                       final loc = _suggestions[i];
//                       return ListTile(
//                         contentPadding: EdgeInsets.zero,
//                         dense: true,
//                         leading: Container(
//                           width: 36,
//                           height: 36,
//                           decoration: BoxDecoration(
//                             color: _kPrimaryLight,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(
//                             _showRecent
//                                 ? Icons.history_rounded
//                                 : Icons.location_on_rounded,
//                             color: _kPrimary,
//                             size: 16,
//                           ),
//                         ),
//                         title: Text(
//                           loc,
//                           style: const TextStyle(
//                             fontWeight: FontWeight.w500,
//                             color: _kText,
//                             fontSize: 14,
//                           ),
//                         ),
//                         trailing: const Icon(
//                           Icons.north_west_rounded,
//                           size: 14,
//                           color: _kTextSub,
//                         ),
//
//                         // onTap: () {
//                         //   widget.onLocationSelected(
//                         //     SelectedLocation(
//                         //       address: loc,
//                         //       latitude: 0,
//                         //       longitude: 0,
//                         //     ),
//                         //   );
//                         //
//                         //   Navigator.pop(context);
//                         // },
//                         onTap: () async {
//                           try {
//                             final locations = await locationFromAddress(loc);
//
//                             if (locations.isEmpty) return;
//
//                             final position = locations.first;
//
//                             final selectedLocation = SelectedLocation(
//                               address: loc,
//                               latitude: position.latitude,
//                               longitude: position.longitude,
//                             );
//
//                             widget.onLocationSelected(selectedLocation);
//
//                             Navigator.pop(context);
//                           } catch (e) {
//                             print("Location conversion error $e");
//                           }
//                         },
//                       );
//                     },
//                   ),
//           ),
//           SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
//         ],
//       ),
//     );
//   }
// }
//
// class DateTimePickerField extends StatefulWidget {
//   const DateTimePickerField({super.key});
//   @override
//   State<DateTimePickerField> createState() => _DateTimePickerFieldState();
// }
//
// class _DateTimePickerFieldState extends State<DateTimePickerField> {
//   DateTime? selectedDateTime;
//
//   Future<void> _pickCustomDateTime() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: const ColorScheme.light(primary: _kPrimary),
//         ),
//         child: child!,
//       ),
//     );
//     if (date == null) return;
//     final time = await showTimePicker(
//       // ignore: use_build_context_synchronously
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: const ColorScheme.light(primary: _kPrimary),
//         ),
//         child: child!,
//       ),
//     );
//     if (time == null) return;
//     setState(() {
//       selectedDateTime = DateTime(
//         date.year,
//         date.month,
//         date.day,
//         time.hour,
//         time.minute,
//       );
//     });
//   }
//
//   Future<void> _pickTimeForBaseDate(DateTime baseDate) async {
//     final time = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) => Theme(
//         data: ThemeData.light().copyWith(
//           colorScheme: const ColorScheme.light(primary: _kPrimary),
//         ),
//         child: child!,
//       ),
//     );
//     if (time == null) return;
//     setState(() {
//       selectedDateTime = DateTime(
//         baseDate.year,
//         baseDate.month,
//         baseDate.day,
//         time.hour,
//         time.minute,
//       );
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final today = DateTime.now();
//     final tomorrow = today.add(const Duration(days: 1));
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Schedule (Optional)'),
//         Container(
//           padding: const EdgeInsets.all(4),
//           decoration: BoxDecoration(
//             color: _kBg,
//             borderRadius: BorderRadius.circular(_kRadius),
//             border: Border.all(color: _kBorder),
//           ),
//           child: Row(
//             children: [
//               // Date/time display
//               Expanded(
//                 child: GestureDetector(
//                   onTap: _pickCustomDateTime,
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 12,
//                       vertical: 10,
//                     ),
//                     child: selectedDateTime == null
//                         ? Row(
//                             children: [
//                               Icon(
//                                 Icons.calendar_today_rounded,
//                                 size: 18,
//                                 color: _kTextSub,
//                               ),
//                               const SizedBox(width: 8),
//                               Text(
//                                 'Pick date & time',
//                                 style: TextStyle(
//                                   color: _kTextSub,
//                                   fontSize: 13,
//                                 ),
//                               ),
//                             ],
//                           )
//                         : Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.calendar_today_rounded,
//                                     size: 16,
//                                     color: _kPrimary,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     DateFormat(
//                                       'dd MMM yyyy',
//                                     ).format(selectedDateTime!),
//                                     style: const TextStyle(
//                                       color: _kText,
//                                       fontWeight: FontWeight.w600,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 4),
//                               Row(
//                                 children: [
//                                   const Icon(
//                                     Icons.access_time_rounded,
//                                     size: 16,
//                                     color: _kPrimary,
//                                   ),
//                                   const SizedBox(width: 6),
//                                   Text(
//                                     DateFormat(
//                                       'hh:mm a',
//                                     ).format(selectedDateTime!),
//                                     style: const TextStyle(
//                                       color: _kPrimary,
//                                       fontWeight: FontWeight.w500,
//                                       fontSize: 13,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                   ),
//                 ),
//               ),
//               // Quick buttons
//               _quickTimeButton('Today', () => _pickTimeForBaseDate(today)),
//               const SizedBox(width: 6),
//               _quickTimeButton(
//                 'Tomorrow',
//                 () => _pickTimeForBaseDate(tomorrow),
//               ),
//               const SizedBox(width: 4),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _quickTimeButton(String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
//         decoration: BoxDecoration(
//           color: _kPrimaryLight,
//           borderRadius: BorderRadius.circular(10),
//         ),
//         child: Text(
//           label,
//           style: const TextStyle(
//             color: _kPrimary,
//             fontSize: 12,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

import '../../Services/Auth_service/promotion_services_Authservice.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Models/promotions_model/promotions_model.dart';
import '../../Services/googleservices/Location_servces.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../screens/advertisements/banneradvertisement.dart';
import 'package:in_app_update/in_app_update.dart';
import '../screens/advertisements/Advideo.dart';
import 'package:flutter/foundation.dart';
import '../screens/notifications.dart';
import '../screens/saved_address.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'logistiscscreen.dart';

const _kPrimary = Color(0xFF6C3CE1); // deep violet
const _kBg = Color(0xFFF7F8FC); // off-white background
const _kSurface = Colors.white;
const _kText = Color(0xFF1A1A2E); // near-black
const _kTextSub = Color(0xFF8A8FAB); // muted label

const primary = Color(0xFFE23744);
const surface = Colors.white;
const text = Color(0xFF1C1C1C);
const textMuted = Color(0xFF7C7C7C);

class logistic_HomePage extends StatefulWidget {
  final ScrollController scrollController;
  const logistic_HomePage({super.key, required this.scrollController});
  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<logistic_HomePage>
    with TickerProviderStateMixin {
  String selectedTab = "";
  int _currentIndex = 0;
  String _currentLocation = "Fetching location...";
  AppUpdateInfo? _updateInfo;
  bool _hasShownLocationDialog = false;
  bool _isBannerCollapsed = false;
  bool _isLoggedIn = false;
  List<Campaign> homepageAds = [];
  bool _isGuestLocationLoading = false;
  String? _locationCategory;

  String selectedService = "Travel";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

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
    _loadAds();
  }

  @override
  void dispose() {
    _animationController.dispose();
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
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
      if (mounted) setState(() => _currentLocation = 'Location unavailable');
    } finally {
      if (mounted) setState(() => _isGuestLocationLoading = false);
    }
  }

  Future<void> _loadLocationFromAPI() async {
    try {
      final loc = await subscription_AuthService.fetchCurrentLocation();

      if (!mounted) return;

      final isValidLocation = loc != null && loc.address.trim().isNotEmpty;

      if (isValidLocation) {
        setState(() {
          _currentLocation = loc.address;
          _locationCategory = loc.category;
        });
        _hasShownLocationDialog = false;
      } else {
        _handleInvalidLocation();
      }
    } catch (e) {
      if (!mounted) return;
      _handleInvalidLocation();
    }
  }

  void _handleInvalidLocation() {
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
                c.medium == Medium.APP &&
                c.addDisplayPosition == AddDisplayPosition.HOMEPAGE_BANNER &&
                c.medium == Medium.APP,
          )
          .toList();
      if (mounted) setState(() => homepageAds = filtered);
    } catch (e) {
      // ignored
    }
  }

  void _showUpdateLocationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: _kSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.r),
          ),
          titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
          contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 12.h),
          actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_off_rounded,
                  color: Colors.red,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Location Required",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w700,
                    color: _kText,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            "We couldn't detect your location. Please update your location to continue.",
            style: TextStyle(fontSize: 13.5.sp, color: _kTextSub, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                foregroundColor: _kTextSub,
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
              ),
              child: Text("Later", style: TextStyle(fontSize: 13.5.sp)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _changeLocation();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
              ),
              child: Text(
                "Update Location",
                style: TextStyle(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
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
        setState(() {});
      }
    } catch (e) {
      // ignored
    }
  }

  void _changeLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SavedAddress(
          onAddressSelected: (address) async {
            setState(() {
              _currentLocation = address.fullAddress;
            });
            _hasShownLocationDialog = false;
          },
        ),
      ),
    );
  }

  /// Responsive banner height: scales with screen height but is clamped so
  /// it never gets awkwardly tall on tablets or awkwardly short on small
  /// phones / landscape.
  double get _bannerHeight {
    final size = MediaQuery.of(context).size;
    final h = size.height;
    final isLandscape = size.width > size.height;
    final base = isLandscape ? h * 0.55 : h * 0.34;
    return base.clamp(220.0, 340.0);
  }

  void _onScroll() {
    if (!mounted) return;
    final collapseThreshold = _bannerHeight - kToolbarHeight - 4;
    final collapsed = widget.scrollController.offset > collapseThreshold;
    if (collapsed != _isBannerCollapsed && mounted) {
      setState(() => _isBannerCollapsed = collapsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
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
        backgroundColor: _kBg,
        body: RefreshIndicator(
          color: _kPrimary,
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          child: CustomScrollView(
            controller: widget.scrollController,
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(child: LogisticsScreen()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: _bannerHeight,
      collapsedHeight: kToolbarHeight,
      toolbarHeight: kToolbarHeight,
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: _isBannerCollapsed ? surface : Colors.transparent,
      systemOverlayStyle: _isBannerCollapsed
          ? SystemUiOverlayStyle.dark
          : SystemUiOverlayStyle.light,
      leading: _isBannerCollapsed
          ? IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.sp),
              color: Colors.black87,
              onPressed: () => Navigator.pop(context),
            )
          : null,
      automaticallyImplyLeading: false,
      titleSpacing: 12.w,
      title: _isBannerCollapsed
          ? _buildCollapsedBar()
          : const SizedBox.shrink(),
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
          // Background (Ad / Video)
          _isLoggedIn
              ? (homepageAds.isEmpty
                    ? Container(color: const Color(0xFFCCCCCC))
                    : BannerAdvertisement(
                        ads: homepageAds,
                        height: _bannerHeight,
                      ))
              : const VideoPreviewContainer(),

          // Gradient overlay for legibility of top content
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB3000000),
                  Color(0x40000000),
                  Colors.transparent,
                ],
                stops: [0.0, 0.35, 0.7],
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: _buildLocationContent(
                          isDark: false,
                          isExpanded: true,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      _NotificationButton(
                        background: Colors.white.withOpacity(0.2),
                        iconColor: Colors.white,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => NotificationScreen(),
                            ),
                          );
                        },
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
    final color = isDark ? text : Colors.white;

    return GestureDetector(
      onTap: _changeLocation,
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            _getCategoryIcon(),
            color: color,
            size: isExpanded ? 18.sp : 16.sp,
          ),
          SizedBox(width: isExpanded ? 6.w : 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isExpanded)
                  Text(
                    (_locationCategory ?? 'Delivering to').replaceFirstMapped(
                      RegExp(r'^[a-z]'),
                      (m) => m.group(0)!.toUpperCase(),
                    ),
                    style: TextStyle(fontSize: 10.sp, color: Colors.white70),
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
            size: isExpanded ? 18.sp : 20.sp,
          ),
        ],
      ),
    );
  }

  Widget _buildGuestAppBar({required bool isDark, required bool isExpanded}) {
    final color = isDark ? text : Colors.white;
    final subColor = isDark ? textMuted : Colors.white70;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Navigate to login or location picker
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
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
          if (_isGuestLocationLoading)
            Row(
              children: [
                SizedBox(
                  width: isExpanded ? 14.w : 12.w,
                  height: isExpanded ? 14.w : 12.w,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: color,
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Text(
                    "Fetching location...",
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: isExpanded ? 12.sp : 11.sp,
                      color: color,
                    ),
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.location_on_rounded,
                  color: color,
                  size: isExpanded ? 16.sp : 14.sp,
                ),
                SizedBox(width: 6.w),
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
        Expanded(child: _buildLocationContent(isDark: true, isExpanded: false)),
        SizedBox(width: 8.w),
        _NotificationButton(
          background: primary.withOpacity(0.1),
          iconColor: primary,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => NotificationScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final Color background;
  final Color iconColor;
  final VoidCallback onTap;
  const _NotificationButton({
    required this.background,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: Icon(
          Icons.notifications_none_rounded,
          color: iconColor,
          size: 20.sp,
        ),
      ),
    );
  }
}

// ─── Main Screen ──────────────────────────────────────────────────────────────
