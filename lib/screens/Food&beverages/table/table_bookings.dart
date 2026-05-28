// import 'package:geolocator/geolocator.dart';
// import 'package:intl/intl.dart';
// import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
// import 'package:maamaas/widgets/datetimehelper.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../../Models/food/restaurent_banner_model.dart';
// import '../../../Services/Auth_service/food_authservice.dart';
// import '../../../Models/food/table_confirmedlist_model.dart';
// import '../../../Models/food/table_waitinglist_model.dart';
// import 'package:flutter/material.dart';
// import '../../../Services/Auth_service/guest_Authservice.dart';
// import 'table_menu.dart';
//
// class tablebcolours {
//   static const bg = Color(0xFFF7F8FC);
//   static const surface = Colors.white;
//   static const border = Color(0xFFEEEFF5);
//
//   static const ink = Color(0xFF111827);
//   static const inkSecondary = Color(0xFF6B7280);
//   static const inkMuted = Color(0xFF9CA3AF);
//
//   static const accent = Color(0xFF4F46E5);
//   static const accentLight = Color(0xFFEEF2FF);
//
//   static const waiting = Color(0xFFF59E0B);
//   static const waitingLight = Color(0xFFFFFBEB);
//
//   static const confirmed = Color(0xFF10B981);
//   static const confirmedLight = Color(0xFFECFDF5);
//
//   static const danger = Color(0xFFEF4444);
//   static const dangerLight = Color(0xFFFEF2F2);
//
//   static const completed = Color(0xFF9CA3AF);
//   static const completedLight = Color(0xFFF9FAFB);
//
//   static const complted = Color(0xFFEF4444);
//
//   static const radius = 14.0;
//   static const radiusSm = 8.0;
//
//   static const titleLg = TextStyle(
//     fontSize: 15,
//     fontWeight: FontWeight.w700,
//     color: ink,
//     letterSpacing: -0.2,
//   );
//   static const titleSm = TextStyle(
//     fontSize: 13,
//     fontWeight: FontWeight.w600,
//     color: ink,
//   );
//   static const bodyMd = TextStyle(
//     fontSize: 13,
//     color: inkSecondary,
//     height: 1.4,
//   );
//   static const bodySm = TextStyle(fontSize: 12, color: inkMuted);
//   static const label = TextStyle(
//     fontSize: 11,
//     fontWeight: FontWeight.w600,
//     letterSpacing: 0.4,
//   );
// }
//
// // ─── Screen ───────────────────────────────────────────────────────────────────
// class TableBookings extends StatefulWidget {
//   const TableBookings({super.key});
//
//   @override
//   State<TableBookings> createState() => _TableBookingsState();
// }
//
// class _TableBookingsState extends State<TableBookings> {
//   late Future<List<WaitingItem>> _waitingFuture;
//   late Future<List<ConfirmedList>> _confirmedFuture;
//
//   @override
//   void initState() {
//     super.initState();
//     _load();
//   }
//
//   void _load() {
//     _waitingFuture = food_Authservice.fetchWaitingList();
//     _confirmedFuture = food_Authservice.fetchConfirmedList();
//   }
//
//   void _refresh() => setState(() => _load());
//
//   // static Future<Restaurent_Banner?> fetchRestaurantBanner(
//   //     int vendorId,
//   //     ) async {
//   //   try {
//   //     final banner = await Authservice().fetchVendorBanner(widget.vendorId);
//   //
//   //   } catch (_) {}
//   // }
//   //
//   //
//   // Future<bool> _isUserNearRestaurant() async {
//   //   try {
//   //     // Permission
//   //     LocationPermission permission =
//   //     await Geolocator.checkPermission();
//   //
//   //     if (permission == LocationPermission.denied) {
//   //       permission = await Geolocator.requestPermission();
//   //     }
//   //
//   //     if (permission == LocationPermission.denied ||
//   //         permission == LocationPermission.deniedForever) {
//   //       AppAlert.error(context, 'Location permission denied');
//   //       return false;
//   //     }
//   //
//   //     // User current location
//   //     final Position position =
//   //     await Geolocator.getCurrentPosition(
//   //       desiredAccuracy: LocationAccuracy.high,
//   //     );
//   //
//   //     // Fetch restaurant banner using vendorId
//   //     final banner =
//   //     await food_Authservice.fetchRestaurantBanner(
//   //       widget.item.vendorId,
//   //     );
//   //
//   //     if (banner == null) {
//   //       AppAlert.error(
//   //         context,
//   //         'Failed to fetch restaurant location',
//   //       );
//   //       return false;
//   //     }
//   //
//   //     // Distance calculation
//   //     final distance = Geolocator.distanceBetween(
//   //       position.latitude,
//   //       position.longitude,
//   //       banner.latitude.toDouble(),
//   //       banner.longitude.toDouble(),
//   //     );
//   //
//   //     print("Distance: $distance");
//   //
//   //     return distance <= 200;
//   //   } catch (e) {
//   //     print("Location Error: $e");
//   //
//   //     AppAlert.error(
//   //       context,
//   //       'Failed to verify location',
//   //     );
//   //
//   //     return false;
//   //   }
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     final mq = MediaQuery.of(context);
//     final screenW = mq.size.width;
//     final hPad = screenW < 380 ? 12.0 : 16.0;
//
//     return Scaffold(
//       backgroundColor: tablebcolours.bg,
//       body: SafeArea(
//         child: FutureBuilder2(
//           waitingFuture: _waitingFuture,
//           confirmedFuture: _confirmedFuture,
//           hPad: hPad,
//           onRefresh: _refresh,
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Combined FutureBuilder ───────────────────────────────────────────────────
// class FutureBuilder2 extends StatelessWidget {
//   final Future<List<WaitingItem>> waitingFuture;
//   final Future<List<ConfirmedList>> confirmedFuture;
//   final double hPad;
//   final VoidCallback onRefresh;
//
//   const FutureBuilder2({
//     super.key,
//     required this.waitingFuture,
//     required this.confirmedFuture,
//     required this.hPad,
//     required this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<WaitingItem>>(
//       future: waitingFuture,
//       builder: (context, waitingSnap) {
//         return FutureBuilder<List<ConfirmedList>>(
//           future: confirmedFuture,
//           builder: (context, confirmedSnap) {
//             final bothDone =
//                 waitingSnap.connectionState == ConnectionState.done &&
//                 confirmedSnap.connectionState == ConnectionState.done;
//
//             if (!bothDone) return const _LoadingView();
//
//             if (waitingSnap.hasError || confirmedSnap.hasError) {
//               final err = (waitingSnap.error ?? confirmedSnap.error).toString();
//               return _ErrorView(error: err, onRetry: onRefresh);
//             }
//
//             final waitingItems = waitingSnap.data ?? [];
//             final confirmedItems = List<ConfirmedList>.from(
//               confirmedSnap.data ?? [],
//             );
//
//             confirmedItems.sort((a, b) {
//               final aDone =
//                   a.arrivalStatus.toUpperCase() == 'COMPLETED' ||
//                   a.arrivalStatus.toUpperCase() == 'CANCELLED';
//
//               final bDone =
//                   b.arrivalStatus.toUpperCase() == 'COMPLETED' ||
//                   b.arrivalStatus.toUpperCase() == 'CANCELLED';
//
//               if (aDone == bDone) return 0;
//
//               return aDone ? 1 : -1;
//             });
//
//             final hasWaiting = waitingItems.isNotEmpty;
//             final hasConfirmed = confirmedItems.isNotEmpty;
//
//             if (!hasWaiting && !hasConfirmed) {
//               return const _EmptyView(message: 'No bookings yet');
//             }
//
//             return RefreshIndicator(
//               color: tablebcolours.accent,
//               backgroundColor: tablebcolours.surface,
//               onRefresh: () async => onRefresh(),
//               child: CustomScrollView(
//                 physics: const AlwaysScrollableScrollPhysics(),
//                 slivers: [
//                   // ── Waiting Section ──────────────────────────────────────
//                   if (hasWaiting) ...[
//                     SliverToBoxAdapter(
//                       child: _SectionHeader(
//                         icon: Icons.access_time_rounded,
//                         label: 'Waiting',
//                         count: waitingItems.length,
//                         color: tablebcolours.waiting,
//                         bg: tablebcolours.waitingLight,
//                         hPad: hPad,
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (_, i) => _WaitingCard(
//                             item: waitingItems[waitingItems.length - 1 - i],
//                           ),
//                           childCount: waitingItems.length,
//                         ),
//                       ),
//                     ),
//                   ],
//
//                   // ── Confirmed Section ────────────────────────────────────
//                   if (hasConfirmed) ...[
//                     SliverToBoxAdapter(
//                       child: _SectionHeader(
//                         icon: Icons.check_circle_outline_rounded,
//                         label: 'Confirmed',
//                         count: confirmedItems.length,
//                         color: tablebcolours.confirmed,
//                         bg: tablebcolours.confirmedLight,
//                         hPad: hPad,
//                       ),
//                     ),
//                     SliverPadding(
//                       padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 24),
//                       sliver: SliverList(
//                         delegate: SliverChildBuilderDelegate(
//                           (_, i) => ConfirmedListCard(item: confirmedItems[i]),
//                           childCount: confirmedItems.length,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ],
//               ),
//             );
//           },
//         );
//       },
//     );
//   }
// }
//
// // ─── Section Header ───────────────────────────────────────────────────────────
// class _SectionHeader extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final int count;
//   final Color color;
//   final Color bg;
//   final double hPad;
//
//   const _SectionHeader({
//     required this.icon,
//     required this.label,
//     required this.count,
//     required this.color,
//     required this.bg,
//     required this.hPad,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 10),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(6),
//             decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
//             child: Icon(icon, size: 14, color: color),
//           ),
//           const SizedBox(width: 8),
//           Text(
//             label,
//             style: tablebcolours.titleSm.copyWith(color: tablebcolours.ink),
//           ),
//           const SizedBox(width: 6),
//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
//             decoration: BoxDecoration(
//               color: bg,
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '$count',
//               style: tablebcolours.label.copyWith(color: color),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── Waiting Card ─────────────────────────────────────────────────────────────
// class _WaitingCard extends StatelessWidget {
//   final WaitingItem item;
//   const _WaitingCard({required this.item});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 10),
//       decoration: BoxDecoration(
//         color: tablebcolours.surface,
//         borderRadius: BorderRadius.circular(tablebcolours.radius),
//         border: Border.all(color: tablebcolours.border),
//         boxShadow: [
//           BoxShadow(
//             // ignore: deprecated_member_use
//             color: Colors.black.withOpacity(0.04),
//             blurRadius: 8,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(tablebcolours.radius),
//         child: IntrinsicHeight(
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Container(width: 4, color: tablebcolours.waiting),
//               Expanded(
//                 child: Padding(
//                   padding: const EdgeInsets.all(14),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       _InfoRow(Icons.person_outline_rounded, item.guestName),
//                       _InfoRow(Icons.phone_outlined, item.phoneNumber),
//                       _InfoRow(
//                         Icons.calendar_today_outlined,
//                         DateTimeHelper.formatDateString(item.bookingDate),
//                       ),
//                       _InfoRow(
//                         Icons.schedule_outlined,
//                         DateTimeHelper.to12Hour(item.requestTime),
//                       ),
//                       const SizedBox(height: 8),
//                       Wrap(
//                         spacing: 8,
//                         children: [
//                           _Chip(
//                             Icons.group_outlined,
//                             '${item.capacity} guests',
//                           ),
//                           _Chip(
//                             Icons.timer_outlined,
//                             '${item.durationMinutes} min',
//                           ),
//                         ],
//                       ),
//                     ],
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
// // ─── Confirmed Card ───────────────────────────────────────────────────────────
// class ConfirmedListCard extends StatefulWidget {
//   final ConfirmedList item;
//   const ConfirmedListCard({super.key, required this.item});
//
//   @override
//   State<ConfirmedListCard> createState() => _ConfirmedListCardState();
// }
//
// class _ConfirmedListCardState extends State<ConfirmedListCard> {
//   late bool _arrived;
//   bool _loading = false;
//
//   late String _arrivalStatus;
//
//   @override
//   void initState() {
//     super.initState();
//     // _arrived = widget.item.arrivalStatus.toUpperCase() == 'ARRIVED';
//     _arrivalStatus = widget.item.arrivalStatus.toUpperCase();
//
//     _arrived = _arrivalStatus == 'ARRIVED';
//   }
//
//   bool get _isCompleted {
//     return _arrivalStatus == 'COMPLETED';
//   }
//
//   bool get _isCancelled {
//     return _arrivalStatus == 'CANCELLED';
//   }
//
//   bool get _isInactive => _isCompleted || _isCancelled;
//
//   /// Returns true if the booking time is more than 30 mins away (button disabled).
//   bool get _isArrivalLocked {
//     if (_arrived) return false; // already arrived → never lock
//     try {
//       final dateStr = widget.item.bookingDate; // e.g. "2025-07-20"
//       final timeStr = widget.item.startTime; // e.g. "14:30:00" or "14:30"
//       final dt = DateTime.parse('${dateStr}T$timeStr');
//       final diff = dt.difference(DateTime.now());
//       return diff.inMinutes > 30;
//     } catch (_) {
//       return false; // if parse fails, don't lock
//     }
//   }
//
//   Future<void> _markArrived() async {
//     setState(() => _loading = true);
//     final ok = await food_Authservice.sendArrivalStatus(
//       widget.item.id,
//       "ARRIVED",
//     );
//     if (!ok) {
//       if (mounted) AppAlert.error(context, 'Failed to update arrival status');
//       setState(() => _loading = false);
//       return;
//     }
//     if (mounted) {
//       setState(() {
//         _arrived = true;
//         _arrivalStatus = "ARRIVED";
//         _loading = false;
//       });
//     }
//   }
//
//   Future<void> _cancelArrival() async {
//     setState(() => _loading = true);
//     final ok = await food_Authservice.sendArrivalStatus(
//       widget.item.id,
//       "CANCELLED",
//     );
//     if (!ok) {
//       if (mounted) AppAlert.error(context, 'Failed to cancel arrival');
//       setState(() => _loading = false);
//       return;
//     }
//     if (mounted) {
//       setState(() {
//         _arrived = false;
//         _arrivalStatus = "CANCELLED";
//         _loading = false;
//       });
//     }
//   }
//
//   Future<void> _handleArrivalTap() async {
//     setState(() => _loading = true);
//
//     final distance = await _getDistanceFromRestaurant();
//
//     setState(() => _loading = false);
//
//     if (distance == null) {
//       if (mounted) {
//         AppAlert.error(context, 'Failed to fetch your location');
//       }
//       return;
//     }
//
//     final bool isNear = distance <= 200;
//
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//
//           title: Row(
//             children: [
//               Icon(
//                 isNear ? Icons.check_circle_rounded : Icons.location_on_rounded,
//                 color: isNear ? tablebcolours.confirmed : tablebcolours.danger,
//               ),
//               const SizedBox(width: 8),
//
//               Text(isNear ? 'You Are Near Restaurant' : 'Confirm Arrival'),
//             ],
//           ),
//
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 isNear
//                     ? 'Great! You are within the allowed restaurant range.'
//                     : 'You must be within 200 meters of the restaurant.',
//               ),
//
//               const SizedBox(height: 14),
//
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: BoxDecoration(
//                   color: isNear
//                       ? tablebcolours.confirmedLight
//                       : tablebcolours.dangerLight,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//
//                 child: Row(
//                   children: [
//                     Icon(
//                       isNear ? Icons.check_circle : Icons.warning_amber_rounded,
//                       color: isNear
//                           ? tablebcolours.confirmed
//                           : tablebcolours.danger,
//                     ),
//
//                     const SizedBox(width: 10),
//
//                     Expanded(
//                       child: Text(
//                         isNear
//                             ? 'You are only ${distance.toStringAsFixed(0)} meters away from restaurant'
//                             : 'Current Distance: ${distance.toStringAsFixed(0)} meters',
//                         style: TextStyle(
//                           fontWeight: FontWeight.w600,
//                           color: isNear
//                               ? tablebcolours.confirmed
//                               : tablebcolours.danger,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               if (isNear) ...[
//                 const SizedBox(height: 12),
//
//                 const Text(
//                   'You can now mark yourself as arrived.',
//                   style: TextStyle(
//                     color: Colors.green,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//
//               if (!isNear) ...[
//                 const SizedBox(height: 12),
//
//                 const Text(
//                   'You cannot mark arrived until you get nearer to the restaurant.',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               ],
//             ],
//           ),
//
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('Close'),
//             ),
//
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: isNear ? tablebcolours.confirmed : Colors.grey,
//                 foregroundColor: Colors.white,
//               ),
//
//               onPressed: isNear
//                   ? () {
//                       Navigator.pop(context, true);
//                     }
//                   : null,
//
//               child: Text(isNear ? 'Mark Arrived' : 'Too Far'),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirm == true) {
//       await _markArrived();
//     }
//   }
//
//   Future<void> _handleCancelTap() async {
//     final confirm = await showDialog<bool>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(18),
//           ),
//           title: const Row(
//             children: [
//               Icon(Icons.warning_amber_rounded, color: Colors.red),
//               SizedBox(width: 8),
//               Text('Cancel Booking'),
//             ],
//           ),
//           content: const Text('Are you sure you want to cancel this booking?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context, false);
//               },
//               child: const Text('No'),
//             ),
//             ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: tablebcolours.danger,
//                 foregroundColor: Colors.white,
//               ),
//               onPressed: () {
//                 Navigator.pop(context, true);
//               },
//               child: const Text('Yes, Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//
//     if (confirm == true) {
//       await _cancelArrival();
//     }
//   }
//
//   Future<double?> _getDistanceFromRestaurant() async {
//     try {
//       print("📍 Checking user location...");
//
//       LocationPermission permission = await Geolocator.checkPermission();
//
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         print("❌ Location permission denied");
//
//         if (mounted) {
//           AppAlert.error(context, 'Location permission denied');
//         }
//
//         return null;
//       }
//
//       final Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       print(
//         "📍 User Location => "
//         "${position.latitude}, ${position.longitude}",
//       );
//
//       final Restaurent_Banner banner = await Authservice().fetchVendorBanner(
//         widget.item.vendorId,
//       );
//
//       print(
//         "🏪 Restaurant Location => "
//         "${banner.latitude}, ${banner.longitude}",
//       );
//
//       final double mockLatitude = 17.4937;
//       final double mockLongitude = 78.3915;
//
//       final double distance = Geolocator.distanceBetween(
//         position.latitude,
//         position.longitude,
//         // mockLatitude,
//         // mockLongitude,
//         banner.latitude.toDouble(),
//         banner.longitude.toDouble(),
//       );
//
//       print("📏 Distance => $distance meters");
//
//       return distance;
//     } catch (e) {
//       print("❌ Distance Error => $e");
//
//       if (mounted) {
//         AppAlert.error(context, 'Failed to verify location');
//       }
//
//       return null;
//     }
//   }
//
//   Future<bool> _isUserNearRestaurant() async {
//     try {
//       LocationPermission permission = await Geolocator.checkPermission();
//
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//       }
//
//       if (permission == LocationPermission.denied ||
//           permission == LocationPermission.deniedForever) {
//         if (mounted) {
//           AppAlert.error(context, 'Location permission denied');
//         }
//         return false;
//       }
//
//       // User current location
//       final Position position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );
//
//       // Fetch restaurant banner
//       final Restaurent_Banner? banner = await Authservice().fetchVendorBanner(
//         widget.item.vendorId,
//       );
//
//       if (banner == null) {
//         if (mounted) {
//           AppAlert.error(context, 'Failed to fetch restaurant location');
//         }
//         return false;
//       }
//
//       // Calculate distance
//       final double distance = Geolocator.distanceBetween(
//         position.latitude,
//         position.longitude,
//         banner.latitude.toDouble(),
//         banner.longitude.toDouble(),
//       );
//
//       print("Distance: $distance");
//
//       return distance <= 200;
//     } catch (e) {
//       print("Location Error: $e");
//
//       if (mounted) {
//         AppAlert.error(context, 'Failed to verify location');
//       }
//
//       return false;
//     }
//   }
//
//   String _formatTime(String time) {
//     try {
//       final parsedTime = DateFormat("HH:mm:ss").parse(time);
//
//       return DateFormat("hh:mm a").format(parsedTime);
//     } catch (e) {
//       return time;
//     }
//   }
//
//   Future<void> _openGoogleMapsDirections() async {
//     try {
//       final Restaurent_Banner banner =
//       await Authservice().fetchVendorBanner(widget.item.vendorId);
//
//       final double lat = banner.latitude.toDouble();
//       final double lng = banner.longitude.toDouble();
//
//       // Google Maps directions URL
//       final Uri url = Uri.parse(
//         'https://www.google.com/maps/dir/?api=1'
//             '&destination=$lat,$lng'
//             '&travelmode=driving',
//       );
//
//       if (await canLaunchUrl(url)) {
//         await launchUrl(
//           url,
//           mode: LaunchMode.externalApplication,
//         );
//       } else {
//         if (mounted) {
//           AppAlert.error(context, 'Could not open Google Maps');
//         }
//       }
//     } catch (e) {
//       print("Maps Error => $e");
//
//       if (mounted) {
//         AppAlert.error(context, 'Failed to open directions');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     final item = widget.item;
//
//     return AnimatedOpacity(
//       duration: const Duration(milliseconds: 300),
//       // opacity: _isCompleted ? 0.55 : 1.0,
//       opacity: _isInactive ? 0.55 : 1.0,
//       child: IgnorePointer(
//         // ignoring: _isCompleted,
//         ignoring: _isInactive,
//         child: Container(
//           margin: const EdgeInsets.only(bottom: 10),
//           decoration: BoxDecoration(
//             color: tablebcolours.surface,
//             borderRadius: BorderRadius.circular(tablebcolours.radius),
//             border: Border.all(color: tablebcolours.border),
//             boxShadow: [
//               BoxShadow(
//                 // ignore: deprecated_member_use
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 8,
//                 offset: const Offset(0, 2),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.circular(tablebcolours.radius),
//             child: IntrinsicHeight(
//               child: Row(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   Container(
//                     width: 4,
//
//                     color: _isCompleted
//                         ? tablebcolours.completed
//                         : _isCancelled
//                         ? Colors.red
//                         : (_arrived
//                               ? tablebcolours.confirmed
//                               : tablebcolours.accent),
//                   ),
//                   Expanded(
//                     child: Padding(
//                       padding: const EdgeInsets.all(14),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Header
//                           Row(
//                             children: [
//                               Container(
//                                 width: 36,
//                                 height: 36,
//                                 decoration: BoxDecoration(
//                                   color: tablebcolours.accentLight,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: const Icon(
//                                   Icons.table_restaurant_rounded,
//                                   size: 18,
//                                   color: tablebcolours.accent,
//                                 ),
//                               ),
//                               const SizedBox(width: 10),
//                               Expanded(
//                                 child: Text(
//                                   'Table ${item.code}',
//                                   style: tablebcolours.bodySm.copyWith(
//                                     color: tablebcolours.accent,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                               ),
//                               if (_isCompleted)
//                                 _StatusBadge(
//                                   label: 'Compelted',
//                                   color: tablebcolours.completed,
//                                   bg: tablebcolours.completedLight,
//                                   icon: Icons.check_circle_outline_rounded,
//                                 ),
//                               if (_isCancelled)
//                                 _StatusBadge(
//                                   label: 'Cancelled',
//                                   color: tablebcolours.complted,
//                                   bg: tablebcolours.completedLight,
//                                   icon: Icons.check_circle_outline_rounded,
//                                 ),
//                               if (_arrived && !_isCompleted)
//                                 _StatusBadge(
//                                   label: 'Arrived',
//                                   color: tablebcolours.confirmed,
//                                   bg: tablebcolours.confirmedLight,
//                                   icon: Icons.check_circle_outline_rounded,
//                                 ),
//                             ],
//                           ),
//
//                           const SizedBox(height: 10),
//                           const Divider(height: 1, color: tablebcolours.border),
//                           const SizedBox(height: 10),
//
//                           _InfoRow(
//                             Icons.person_outline_rounded,
//                             item.guestName.toUpperCase(),
//                           ),
//                           _InfoRow(Icons.phone_outlined, item.phoneNumber),
//                           _InfoRow(
//                             Icons.calendar_today_outlined,
//                             DateTimeHelper.formatDateString(item.bookingDate),
//                           ),
//
//                           _InfoRow(Icons.timer, _formatTime(item.startTime)),
//
//                           const SizedBox(height: 8),
//                           Wrap(
//                             spacing: 8,
//                             children: [
//                               _Chip(
//                                 Icons.group_outlined,
//                                 '${item.capacity} guests',
//                               ),
//                               _Chip(
//                                 Icons.timer_outlined,
//                                 '${item.durationMinutes} min',
//                               ),
//                             ],
//                           ),
//
//                           if (!_isInactive) ...[
//                             const SizedBox(height: 12),
//                             _ActionButtons(
//                               arrived: _arrived,
//                               loading: _loading,
//                               locked: _isArrivalLocked,
//                               onArrived: _handleArrivalTap,
//                               onCancel: _handleCancelTap,
//                               onDirections: _openGoogleMapsDirections,
//                               onAddItems: () => Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (_) => tablemneuScreen(
//                                     vendorId: item.vendorId,
//                                     seatingId: item.seatingId,
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ],
//                         ],
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// // ─── Action Buttons ───────────────────────────────────────────────────────────
// class _ActionButtons extends StatelessWidget {
//   final bool arrived;
//   final bool loading;
//   final bool locked;
//
//   final VoidCallback onArrived;
//   final VoidCallback onCancel;
//   final VoidCallback onAddItems;
//   final VoidCallback onDirections;
//
//   const _ActionButtons({
//     required this.arrived,
//     required this.loading,
//     required this.locked,
//     required this.onArrived,
//     required this.onCancel,
//     required this.onAddItems,
//     required this.onDirections,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (loading) {
//       return const SizedBox(
//         height: 38,
//         child: Center(
//           child: SizedBox(
//             width: 18,
//             height: 18,
//             child: CircularProgressIndicator(
//               strokeWidth: 2,
//               color: tablebcolours.accent,
//             ),
//           ),
//         ),
//       );
//     }
//
//     // AFTER ARRIVED
//     if (arrived) {
//       return Row(
//         children: [
//           Expanded(
//             child: _PillButton(
//               label: 'Add Items',
//               icon: Icons.restaurant_menu_rounded,
//               color: tablebcolours.accent,
//               bg: tablebcolours.accentLight,
//               onTap: onAddItems,
//             ),
//           ),
//         ],
//       );
//     }
//
//     // BEFORE ARRIVED
//     // return Row(
//     //   children: [
//     //     Expanded(
//     //       child: _PillButton(
//     //         label: locked ? 'Arrived (30 min before)' : 'Arrived',
//     //         icon: Icons.check_rounded,
//     //         color: locked ? tablebcolours.inkMuted : tablebcolours.confirmed,
//     //         bg: locked
//     //             ? tablebcolours.completedLight
//     //             : tablebcolours.confirmedLight,
//     //         disabled: locked,
//     //         onTap: onArrived,
//     //       ),
//     //     ),
//     //
//     //     const SizedBox(width: 8),
//     //
//     //     _PillButton(
//     //       label: 'Cancel',
//     //       icon: Icons.close_rounded,
//     //       color: tablebcolours.danger,
//     //       bg: tablebcolours.dangerLight,
//     //       onTap: onCancel,
//     //     ),
//     //   ],
//     // );
//     return Column(
//       children: [
//         Row(
//           children: [
//             Expanded(
//               child: _PillButton(
//                 label: locked ? 'Arrived (30 min before)' : 'Arrived',
//                 icon: Icons.check_rounded,
//                 color: locked
//                     ? tablebcolours.inkMuted
//                     : tablebcolours.confirmed,
//                 bg: locked
//                     ? tablebcolours.completedLight
//                     : tablebcolours.confirmedLight,
//                 disabled: locked,
//                 onTap: onArrived,
//               ),
//             ),
//
//             const SizedBox(width: 8),
//
//             _PillButton(
//               label: 'Cancel',
//               icon: Icons.close_rounded,
//               color: tablebcolours.danger,
//               bg: tablebcolours.dangerLight,
//               onTap: onCancel,
//             ),
//           ],
//         ),
//
//         const SizedBox(height: 8),
//
//         SizedBox(
//           width: double.infinity,
//           child: _PillButton(
//             label: 'Get Directions',
//             icon: Icons.directions_rounded,
//             color: Colors.blue,
//             bg: Colors.blue.withOpacity(0.1),
//             onTap: onDirections,
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _PillButton extends StatelessWidget {
//   final String label;
//   final IconData icon;
//   final Color color;
//   final Color bg;
//   final VoidCallback onTap;
//   final bool disabled;
//
//   const _PillButton({
//     required this.label,
//     required this.icon,
//     required this.color,
//     required this.bg,
//     required this.onTap,
//     this.disabled = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: disabled ? null : onTap,
//       child: Opacity(
//         opacity: disabled ? 0.5 : 1.0,
//         child: Container(
//           height: 38,
//           padding: const EdgeInsets.symmetric(horizontal: 12),
//           decoration: BoxDecoration(
//             color: bg,
//             borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
//             border: Border.all(color: color.withOpacity(0.25)),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Icon(icon, size: 14, color: color),
//               const SizedBox(width: 5),
//               Flexible(
//                 child: Text(
//                   label,
//                   style: tablebcolours.label.copyWith(color: color),
//                   overflow: TextOverflow.ellipsis,
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
// // ─── Shared Small Widgets ─────────────────────────────────────────────────────
// class _InfoRow extends StatelessWidget {
//   final IconData icon;
//   final String value;
//   const _InfoRow(this.icon, this.value);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 4),
//       child: Row(
//         children: [
//           Icon(icon, size: 14, color: tablebcolours.inkMuted),
//           const SizedBox(width: 6),
//           Expanded(
//             child: Text(
//               value,
//               style: tablebcolours.bodyMd,
//               overflow: TextOverflow.ellipsis,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _Chip extends StatelessWidget {
//   final IconData icon;
//   final String text;
//   const _Chip(this.icon, this.text);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: tablebcolours.bg,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: tablebcolours.border),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 11, color: tablebcolours.inkMuted),
//           const SizedBox(width: 4),
//           Text(text, style: tablebcolours.bodySm),
//         ],
//       ),
//     );
//   }
// }
//
// class _StatusBadge extends StatelessWidget {
//   final String label;
//   final Color color;
//   final Color bg;
//   final IconData icon;
//   const _StatusBadge({
//     required this.label,
//     required this.color,
//     required this.bg,
//     required this.icon,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//       decoration: BoxDecoration(
//         color: bg,
//         borderRadius: BorderRadius.circular(20),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, size: 12, color: color),
//           const SizedBox(width: 4),
//           Text(label, style: tablebcolours.label.copyWith(color: color)),
//         ],
//       ),
//     );
//   }
// }
//
// // ─── State Views ──────────────────────────────────────────────────────────────
// class _LoadingView extends StatelessWidget {
//   const _LoadingView();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           CircularProgressIndicator(
//             strokeWidth: 2.5,
//             color: tablebcolours.accent,
//           ),
//           SizedBox(height: 14),
//           Text('Loading...', style: tablebcolours.bodyMd),
//         ],
//       ),
//     );
//   }
// }
//
// class _ErrorView extends StatelessWidget {
//   final String error;
//   final VoidCallback onRetry;
//   const _ErrorView({required this.error, required this.onRetry});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Icon(
//               Icons.wifi_off_rounded,
//               size: 48,
//               color: tablebcolours.inkMuted,
//             ),
//             const SizedBox(height: 12),
//             const Text('Something went wrong', style: tablebcolours.titleSm),
//             const SizedBox(height: 6),
//             Text(
//               error,
//               style: tablebcolours.bodyMd,
//               textAlign: TextAlign.center,
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: onRetry,
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: tablebcolours.accentLight,
//                   borderRadius: BorderRadius.circular(tablebcolours.radiusSm),
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.refresh_rounded,
//                       size: 16,
//                       color: tablebcolours.accent,
//                     ),
//                     const SizedBox(width: 6),
//                     Text(
//                       'Try Again',
//                       style: tablebcolours.label.copyWith(
//                         color: tablebcolours.accent,
//                       ),
//                     ),
//                   ],
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
// class _EmptyView extends StatelessWidget {
//   final String message;
//   const _EmptyView({required this.message});
//
//   @override
//   Widget build(BuildContext context) {
//     return Center(
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Icon(
//             Icons.table_restaurant_outlined,
//             size: 48,
//             color: tablebcolours.inkMuted,
//           ),
//           const SizedBox(height: 12),
//           Text(message, style: tablebcolours.bodyMd),
//         ],
//       ),
//     );
//   }
// }

import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/widgets/datetimehelper.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Models/food/restaurent_banner_model.dart';
import '../../../Models/food/tablecartmodel.dart';
import '../../../Services/Auth_service/food_authservice.dart';
import '../../../Models/food/table_confirmedlist_model.dart';
import '../../../Models/food/table_waitinglist_model.dart';
import 'package:flutter/material.dart';
import '../../../Services/Auth_service/guest_Authservice.dart';
import 'table_menu.dart';

// ─── Design Tokens ────────────────────────────────────────────────────────────
class _T {
  // Backgrounds
  static const bg = Color(0xFFF5F4F0);
  static const surface = Colors.white;
  static const border = Color(0xFFEDE9E3);

  // Text
  static const ink = Color(0xFF1C1917);
  static const inkSecondary = Color(0xFF78716C);
  static const inkMuted = Color(0xFFA8A29E);

  // Brand – warm amber
  static const brand = Color(0xFFD97706);
  static const brandDeep = Color(0xFFB45309);
  static const brandLight = Color(0xFFFEF3C7);
  static const brandSurface = Color(0xFFFFFBEB);

  // Status
  static const waiting = Color(0xFFEA580C);
  static const waitingLight = Color(0xFFFFF7ED);
  static const confirmed = Color(0xFF16A34A);
  static const confirmedLight = Color(0xFFF0FDF4);
  static const danger = Color(0xFFDC2626);
  static const dangerLight = Color(0xFFFEF2F2);
  static const completed = Color(0xFF78716C);
  static const completedLight = Color(0xFFF5F4F0);

  // Radii
  static const r = 16.0;
  static const rSm = 10.0;
  static const rXs = 6.0;

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF1C1917).withOpacity(0.06),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF1C1917).withOpacity(0.03),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];

  // Text styles
  static const titleLg = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.3,
    height: 1.2,
  );
  static const titleMd = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: ink,
    letterSpacing: -0.2,
  );
  static const titleSm = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: ink,
  );
  static const bodyMd = TextStyle(
    fontSize: 13,
    color: inkSecondary,
    height: 1.45,
  );
  static const bodySm = TextStyle(fontSize: 12, color: inkMuted, height: 1.4);
  static const label = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
    color: inkSecondary,
  );
  static const labelBold = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.5,
  );
}

// ─── Screen ───────────────────────────────────────────────────────────────────
class TableBookings extends StatefulWidget {
  const TableBookings({super.key});

  @override
  State<TableBookings> createState() => _TableBookingsState();
}

class _TableBookingsState extends State<TableBookings> {
  late Future<List<WaitingItem>> _waitingFuture;
  late Future<List<ConfirmedList>> _confirmedFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _waitingFuture = food_Authservice.fetchWaitingList();
    _confirmedFuture = food_Authservice.fetchConfirmedList();
  }

  void _refresh() => setState(() => _load());

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final hPad = mq.size.width < 380 ? 14.0 : 18.0;

    return Scaffold(
      // backgroundColor: _T.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // _AppHeader(onRefresh: _refresh),
            Expanded(
              child: FutureBuilder2(
                waitingFuture: _waitingFuture,
                confirmedFuture: _confirmedFuture,
                hPad: hPad,
                onRefresh: _refresh,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Combined FutureBuilder ───────────────────────────────────────────────────
class FutureBuilder2 extends StatelessWidget {
  final Future<List<WaitingItem>> waitingFuture;
  final Future<List<ConfirmedList>> confirmedFuture;
  final double hPad;
  final VoidCallback onRefresh;

  const FutureBuilder2({
    super.key,
    required this.waitingFuture,
    required this.confirmedFuture,
    required this.hPad,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<WaitingItem>>(
      future: waitingFuture,
      builder: (context, waitingSnap) {
        return FutureBuilder<List<ConfirmedList>>(
          future: confirmedFuture,
          builder: (context, confirmedSnap) {
            final bothDone =
                waitingSnap.connectionState == ConnectionState.done &&
                confirmedSnap.connectionState == ConnectionState.done;

            if (!bothDone) return const _LoadingView();

            if (waitingSnap.hasError || confirmedSnap.hasError) {
              final err = (waitingSnap.error ?? confirmedSnap.error).toString();
              return _ErrorView(error: err, onRetry: onRefresh);
            }

            final waitingItems = waitingSnap.data ?? [];
            final confirmedItems = List<ConfirmedList>.from(
              confirmedSnap.data ?? [],
            );

            confirmedItems.sort((a, b) {
              final aDone =
                  a.arrivalStatus.toUpperCase() == 'COMPLETED' ||
                  a.arrivalStatus.toUpperCase() == 'CANCELLED';
              final bDone =
                  b.arrivalStatus.toUpperCase() == 'COMPLETED' ||
                  b.arrivalStatus.toUpperCase() == 'CANCELLED';
              if (aDone == bDone) return 0;
              return aDone ? 1 : -1;
            });

            final hasWaiting = waitingItems.isNotEmpty;
            final hasConfirmed = confirmedItems.isNotEmpty;

            if (!hasWaiting && !hasConfirmed) {
              return const _EmptyView(message: 'No bookings yet');
            }

            return RefreshIndicator(
              color: _T.brand,
              backgroundColor: _T.surface,
              onRefresh: () async => onRefresh(),
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  if (hasWaiting) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        icon: Icons.hourglass_top_rounded,
                        label: 'Waiting for Confirmation',
                        count: waitingItems.length,
                        color: _T.waiting,
                        bg: _T.waitingLight,
                        hPad: hPad,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 8),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => _WaitingCard(
                            item: waitingItems[waitingItems.length - 1 - i],
                          ),
                          childCount: waitingItems.length,
                        ),
                      ),
                    ),
                  ],
                  if (hasConfirmed) ...[
                    SliverToBoxAdapter(
                      child: _SectionHeader(
                        icon: Icons.event_available_rounded,
                        label: 'Confirmed Bookings',
                        count: confirmedItems.length,
                        color: _T.confirmed,
                        bg: _T.confirmedLight,
                        hPad: hPad,
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 32),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) => ConfirmedListCard(item: confirmedItems[i]),
                          childCount: confirmedItems.length,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final Color color;
  final Color bg;
  final double hPad;

  const _SectionHeader({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
    required this.bg,
    required this.hPad,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 12),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(child: Text(label, style: _T.titleSm)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.2)),
            ),
            child: Text('$count', style: _T.labelBold.copyWith(color: color)),
          ),
        ],
      ),
    );
  }
}

// ─── Waiting Card ─────────────────────────────────────────────────────────────
class _WaitingCard extends StatelessWidget {
  final WaitingItem item;
  const _WaitingCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _T.surface,
        borderRadius: BorderRadius.circular(_T.r),
        border: Border.all(color: _T.border),
        boxShadow: _T.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_T.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 3,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_T.waiting, Color(0xFFFBBF24)],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Avatar(name: item.guestName),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.guestName,
                              style: _T.titleMd,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(item.phoneNumber, style: _T.bodySm),
                          ],
                        ),
                      ),
                      const _StatusPill(
                        label: 'Waiting',
                        color: _T.waiting,
                        bg: _T.waitingLight,
                        icon: Icons.hourglass_empty_rounded,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(height: 1, color: _T.border),
                  const SizedBox(height: 12),
                  _InfoGrid(
                    children: [
                      _InfoCell(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: DateTimeHelper.formatDateString(
                          item.bookingDate,
                        ),
                      ),
                      _InfoCell(
                        icon: Icons.schedule_rounded,
                        label: 'Time',
                        value: DateTimeHelper.to12Hour(item.requestTime),
                      ),
                      _InfoCell(
                        icon: Icons.group_rounded,
                        label: 'Guests',
                        value: '${item.capacity} people',
                      ),
                      _InfoCell(
                        icon: Icons.timer_rounded,
                        label: 'Duration',
                        value: '${item.durationMinutes} min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Confirmed Card ───────────────────────────────────────────────────────────
class ConfirmedListCard extends StatefulWidget {
  final ConfirmedList item;
  const ConfirmedListCard({super.key, required this.item});

  @override
  State<ConfirmedListCard> createState() => _ConfirmedListCardState();
}

class _ConfirmedListCardState extends State<ConfirmedListCard> {
  late bool _arrived;
  bool _loading = false;
  late String _arrivalStatus;

  @override
  void initState() {
    super.initState();
    _arrivalStatus = widget.item.arrivalStatus.toUpperCase();
    _arrived = _arrivalStatus == 'ARRIVED';
  }

  bool get _isCompleted => _arrivalStatus == 'COMPLETED';
  bool get _isCancelled => _arrivalStatus == 'CANCELLED';
  bool get _isInactive => _isCompleted || _isCancelled;

  bool get _isArrivalLocked {
    if (_arrived) return false;
    try {
      final dt = DateTime.parse(
        '${widget.item.bookingDate}T${widget.item.startTime}',
      );
      final diff = dt.difference(DateTime.now());
      return diff.inMinutes > 30;
    } catch (_) {
      return false;
    }
  }

  Future<void> _markArrived() async {
    setState(() => _loading = true);
    final ok = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      'ARRIVED',
    );
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to update arrival status');
      setState(() => _loading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _arrived = true;
        _arrivalStatus = 'ARRIVED';
        _loading = false;
      });
    }
  }

  Future<void> _cancelArrival() async {
    setState(() => _loading = true);
    final ok = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      'CANCELLED',
    );
    if (!ok) {
      if (mounted) AppAlert.error(context, 'Failed to cancel arrival');
      setState(() => _loading = false);
      return;
    }
    if (mounted) {
      setState(() {
        _arrived = false;
        _arrivalStatus = 'CANCELLED';
        _loading = false;
      });
    }
  }

  Future<void> _handleArrivalTap() async {
    setState(() => _loading = true);
    final distance = await _getDistanceFromRestaurant();
    setState(() => _loading = false);
    if (distance == null) {
      if (mounted) AppAlert.error(context, 'Failed to fetch your location');
      return;
    }
    final isNear = distance <= 200;
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => _ArrivalDialog(isNear: isNear, distance: distance),
    );
    if (confirm == true) await _markArrived();
  }

  Future<void> _handleCancelTap() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _CancelDialog(),
    );
    if (confirm == true) await _cancelArrival();
  }

  Future<void> _handleLeaveTable() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => const _LeaveTableDialog(),
    );

    if (confirm != true) return;

    setState(() => _loading = true);

    final canLeave = await _canLeaveTable();

    if (!canLeave) {
      setState(() => _loading = false);

      if (mounted) {
        AppAlert.error(
          context,
          'Cannot leave table while items are active/preparing',
        );
      }

      return;
    }

    // clear cart
    final cleared = await food_Authservice.deleteTableDineInCart();

    if (!cleared) {
      setState(() => _loading = false);

      if (mounted) {
        AppAlert.error(context, 'Failed to clear table cart');
      }

      return;
    }

    // cancel table
    final cancelled = await food_Authservice.sendArrivalStatus(
      widget.item.id,
      'CANCELLED',
    );

    setState(() => _loading = false);

    if (!cancelled) {
      if (mounted) {
        AppAlert.error(context, 'Failed to leave table');
      }
      return;
    }

    if (mounted) {
      setState(() {
        _arrivalStatus = 'CANCELLED';
        _arrived = false;
      });

      AppAlert.success(context, 'Table left successfully');
    }
  }

  Future<bool> _canLeaveTable() async {
    try {
      final List<TableCartModel> cartData = await food_Authservice
          .fetchTableCart();

      if (cartData.isEmpty) {
        return true;
      }

      for (final cart in cartData) {
        final items = cart.cartItems;

        for (final item in items) {
          final status = item.orderStatus;

          // active order exists
          if (status != null && status.toString().trim().isNotEmpty) {
            return false;
          }
        }
      }

      return true;
    } catch (e) {
      print("Validation Error => $e");
      return false;
    }
  }

  Future<double?> _getDistanceFromRestaurant() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        if (mounted) AppAlert.error(context, 'Location permission denied');
        return null;
      }
      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      final banner = await Authservice().fetchVendorBanner(
        widget.item.vendorId,
      );

      // final double mockLatitude = 17.4937;
      // final double mockLongitude = 78.3915;

      return Geolocator.distanceBetween(
        pos.latitude,
        pos.longitude,
        // mockLongitude,
        // mockLatitude,
        banner.latitude.toDouble(),
        banner.longitude.toDouble(),
      );
    } catch (_) {
      if (mounted) AppAlert.error(context, 'Failed to verify location');
      return null;
    }
  }

  Future<void> _openGoogleMapsDirections() async {
    try {
      final Restaurent_Banner banner = await Authservice().fetchVendorBanner(
        widget.item.vendorId,
      );

      final double lat = banner.latitude.toDouble();
      final double lng = banner.longitude.toDouble();

      // Google Maps directions URL
      final Uri url = Uri.parse(
        'https://www.google.com/maps/dir/?api=1'
        '&destination=$lat,$lng'
        '&travelmode=driving',
      );

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          AppAlert.error(context, 'Could not open Google Maps');
        }
      }
    } catch (e) {
      print("Maps Error => $e");

      if (mounted) {
        AppAlert.error(context, 'Failed to open directions');
      }
    }
  }

  String _formatTime(String t) {
    try {
      return DateFormat('hh:mm a').format(DateFormat('HH:mm:ss').parse(t));
    } catch (_) {
      return t;
    }
  }

  Color get _accentColor {
    if (_isCompleted) return _T.completed;
    if (_isCancelled) return _T.danger;
    if (_arrived) return _T.confirmed;
    return _T.brand;
  }

  Widget get _statusBadge {
    if (_isCompleted) {
      return const _StatusPill(
        label: 'Completed',
        color: _T.completed,
        bg: _T.completedLight,
        icon: Icons.check_circle_rounded,
      );
    }
    if (_isCancelled) {
      return const _StatusPill(
        label: 'Cancelled',
        color: _T.danger,
        bg: _T.dangerLight,
        icon: Icons.cancel_rounded,
      );
    }
    if (_arrived) {
      return const _StatusPill(
        label: 'Arrived',
        color: _T.confirmed,
        bg: _T.confirmedLight,
        icon: Icons.where_to_vote_rounded,
      );
    }
    return const _StatusPill(
      label: 'Confirmed',
      color: _T.brand,
      bg: _T.brandLight,
      icon: Icons.event_available_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _isInactive ? 0.5 : 1.0,
      child: IgnorePointer(
        ignoring: _isInactive,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: _T.surface,
            borderRadius: BorderRadius.circular(_T.r),
            border: Border.all(color: _T.border),
            boxShadow: _T.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_T.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top accent stripe
                Container(height: 3, color: _accentColor),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header row
                      Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: _T.brandSurface,
                              borderRadius: BorderRadius.circular(_T.rSm),
                              border: Border.all(color: _T.brandLight),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.table_restaurant_rounded,
                                  size: 16,
                                  color: _T.brand,
                                ),
                                const SizedBox(height: 1),
                                Text(
                                  item.code,
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: _T.brandDeep,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.guestName.toUpperCase(),
                                  style: _T.titleMd,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(item.phoneNumber, style: _T.bodySm),
                              ],
                            ),
                          ),
                          _statusBadge,
                        ],
                      ),

                      const SizedBox(height: 14),
                      const Divider(height: 1, color: _T.border),
                      const SizedBox(height: 12),

                      _InfoGrid(
                        children: [
                          _InfoCell(
                            icon: Icons.calendar_today_rounded,
                            label: 'Date',
                            value: DateTimeHelper.formatDateString(
                              item.bookingDate,
                            ),
                          ),
                          _InfoCell(
                            icon: Icons.schedule_rounded,
                            label: 'Start Time',
                            value: _formatTime(item.startTime),
                          ),
                          _InfoCell(
                            icon: Icons.group_rounded,
                            label: 'Guests',
                            value: '${item.capacity} people',
                          ),
                          // _InfoCell(
                          //   icon: Icons.timer_rounded,
                          //   label: 'Duration',
                          //   value: '${item.durationMinutes} min',
                          // ),
                        ],
                      ),

                      if (!_isInactive) ...[
                        const SizedBox(height: 14),
                        _ActionButtons(
                          arrived: _arrived,
                          loading: _loading,
                          locked: _isArrivalLocked,
                          onArrived: _handleArrivalTap,
                          onBeforeArrivalCancel: _handleCancelTap,

                          onAfterArrivalCancel: _handleLeaveTable,

                          onDirections: _openGoogleMapsDirections,
                          onAddItems: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => tablemneuScreen(
                                vendorId: item.vendorId,
                                seatingId: item.seatingId,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Info Grid ────────────────────────────────────────────────────────────────
class _InfoGrid extends StatelessWidget {
  final List<Widget> children;
  const _InfoGrid({required this.children});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 3.2,
      mainAxisSpacing: 6,
      crossAxisSpacing: 8,
      children: children,
    );
  }
}

class _InfoCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoCell({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: _T.bg,
            borderRadius: BorderRadius.circular(_T.rXs),
          ),
          child: Icon(icon, size: 13, color: _T.inkMuted),
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: _T.label),
              Text(
                value,
                style: _T.titleSm.copyWith(fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Avatar ───────────────────────────────────────────────────────────────────
class _Avatar extends StatelessWidget {
  final String name;
  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    final initials = name
        .trim()
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_T.brand, _T.brandDeep],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(_T.rSm),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

// ─── Status Pill ──────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  final String label;
  final Color color;
  final Color bg;
  final IconData icon;
  const _StatusPill({
    required this.label,
    required this.color,
    required this.bg,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 4),
          Text(label, style: _T.labelBold.copyWith(color: color)),
        ],
      ),
    );
  }
}

// ─── Action Buttons ───────────────────────────────────────────────────────────
class _ActionButtons extends StatelessWidget {
  final bool arrived;
  final bool loading;
  final bool locked;
  final VoidCallback onArrived;
  final VoidCallback onBeforeArrivalCancel;
  final VoidCallback onAfterArrivalCancel;
  final VoidCallback onAddItems;
  final VoidCallback onDirections;

  const _ActionButtons({
    required this.arrived,
    required this.loading,
    required this.locked,
    required this.onArrived,
    required this.onBeforeArrivalCancel,
    required this.onAfterArrivalCancel,
    required this.onAddItems,
    required this.onDirections,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Container(
        height: 44,
        alignment: Alignment.center,
        child: const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: _T.brand),
        ),
      );
    }

    if (arrived) {
      return Row(
        children: [
          Expanded(
            child: _ActionButton(
              label: 'Add Items to Order',
              icon: Icons.restaurant_menu_rounded,
              color: Colors.white,
              bg: _T.brand,
              onTap: onAddItems,
            ),
          ),

          const SizedBox(width: 8),

          _ActionButton(
            label: 'Leave Table',
            icon: Icons.logout_rounded,
            color: Colors.white,
            bg: Colors.orange,
            onTap: onAfterArrivalCancel,
          ),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                label: locked ? 'Arrived (30 min before)' : "I've Arrived",
                icon: locked
                    ? Icons.lock_clock_rounded
                    : Icons.where_to_vote_rounded,
                color: locked ? _T.inkMuted : Colors.white,
                bg: locked ? _T.completedLight : _T.confirmed,
                disabled: locked,
                onTap: onArrived,
              ),
            ),

            const SizedBox(width: 8),

            _ActionButton(
              label: 'Cancel',
              icon: Icons.close_rounded,
              color: Colors.white,
              bg: _T.danger,
              onTap: onBeforeArrivalCancel,
            ),
          ],
        ),

        const SizedBox(height: 8),

        SizedBox(
          width: double.infinity,
          child: _ActionButton(
            label: 'Get Directions',
            icon: Icons.directions_rounded,
            color: Colors.white,
            bg: Colors.blue,
            onTap: onDirections,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bg;
  final VoidCallback onTap;
  final bool disabled;
  final bool fullWidth;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bg,
    required this.onTap,
    this.disabled = false,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? null : onTap,
      child: Opacity(
        opacity: disabled ? 0.45 : 1.0,
        child: Container(
          height: 44,
          width: fullWidth ? double.infinity : null,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(_T.rSm),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Icon(icon, size: 15, color: color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.2,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Dialogs ──────────────────────────────────────────────────────────────────
class _ArrivalDialog extends StatelessWidget {
  final bool isNear;
  final double distance;
  const _ArrivalDialog({required this.isNear, required this.distance});

  @override
  Widget build(BuildContext context) {
    final color = isNear ? _T.confirmed : _T.danger;
    final bg = isNear ? _T.confirmedLight : _T.dangerLight;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
                  child: Icon(
                    isNear
                        ? Icons.where_to_vote_rounded
                        : Icons.location_off_rounded,
                    color: color,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isNear ? "You're Nearby!" : 'Too Far Away',
                    style: _T.titleLg,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(_T.rSm),
                border: Border.all(color: color.withOpacity(0.15)),
              ),
              child: Row(
                children: [
                  Icon(
                    isNear
                        ? Icons.check_circle_rounded
                        : Icons.warning_amber_rounded,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      isNear
                          ? 'You are ${distance.toStringAsFixed(0)} m from the restaurant'
                          : 'Current distance: ${distance.toStringAsFixed(0)} m\nMust be within 200 m',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: color,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isNear
                  ? 'You can now mark yourself as arrived.'
                  : 'Please head to the restaurant before marking your arrival.',
              style: _T.bodyMd,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_T.rSm),
                        side: const BorderSide(color: _T.border),
                      ),
                    ),
                    child: Text(
                      'Close',
                      style: TextStyle(
                        color: _T.inkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                if (isNear) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _T.confirmed,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(_T.rSm),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Mark Arrived',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CancelDialog extends StatelessWidget {
  const _CancelDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: _T.dangerLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.cancel_rounded,
                    color: _T.danger,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text('Cancel Booking', style: _T.titleLg),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Are you sure you want to cancel this booking? This action cannot be undone.',
              style: _T.bodyMd,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_T.rSm),
                        side: const BorderSide(color: _T.border),
                      ),
                    ),
                    child: Text(
                      'Keep Booking',
                      style: TextStyle(
                        color: _T.inkSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _T.danger,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_T.rSm),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text(
                      'Yes, Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── State Views ──────────────────────────────────────────────────────────────
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _T.brandLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Padding(
              padding: EdgeInsets.all(14),
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: _T.brand,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const Text('Loading bookings…', style: _T.bodyMd),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _ErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _T.dangerLight,
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                size: 28,
                color: _T.danger,
              ),
            ),
            const SizedBox(height: 16),
            const Text('Something went wrong', style: _T.titleMd),
            const SizedBox(height: 6),
            Text(error, style: _T.bodyMd, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: _T.brand,
                  borderRadius: BorderRadius.circular(_T.rSm),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh_rounded, size: 16, color: Colors.white),
                    SizedBox(width: 8),
                    Text(
                      'Try Again',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;
  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: _T.brandLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.table_restaurant_outlined,
              size: 32,
              color: _T.brand,
            ),
          ),
          const SizedBox(height: 16),
          const Text('No Bookings Yet', style: _T.titleMd),
          const SizedBox(height: 6),
          Text(message, style: _T.bodyMd),
        ],
      ),
    );
  }
}

class _LeaveTableDialog extends StatelessWidget {
  const _LeaveTableDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, size: 40, color: Colors.orange),

            const SizedBox(height: 16),

            const Text(
              'Leave Table?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            const Text(
              'You can leave table only when all ordered items are inactive.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: const Text('No'),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text('Yes'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
