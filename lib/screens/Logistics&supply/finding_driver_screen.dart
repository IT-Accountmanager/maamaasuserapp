// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// import '../../Models/logistics/orderdetails.dart';
// import '../../Services/Auth_service/logisticsservice.dart';
// import '../../Services/websockets/web_socket_manager.dart';
//
// class FindingDriverScreen extends StatefulWidget {
//   const FindingDriverScreen({super.key});
//
//   @override
//   State<FindingDriverScreen> createState() => _FindingDriverScreenState();
// }
//
// class _FindingDriverScreenState extends State<FindingDriverScreen> {
//   Timer? _timer;
//
//   String status = "SEARCHING_PARTNER";
//
//   OrderDetails? order;
//   int? userId;
//
//   @override
//   void initState() {
//     super.initState();
//     _listenForDriver();
//   }
//
//   @override
//   void dispose() {
//     if (userId != null) {
//       WebSocketManager().unsubscribeLogisticOrder(userId!);
//     }
//     super.dispose();
//   }
//
//   Future<void> _listenForDriver() async {
//     final userId = 1; // SharedPreferences
//
//     WebSocketManager().subscribeLogisticOrder(userId, (data) async {
//       debugPrint(data.toString());
//
//       if (data["orderId"] == null) return;
//
//       final order = await LogisticsService.getOrderById(data["orderId"]);
//
//       if (!mounted) return;
//
//       setState(() {
//         this.order = order;
//         status = order.status;
//       });
//
//       if (status == "PARTNER_ASSIGNED") {
//         debugPrint(order.partnerName);
//       }
//     });
//   }
//
//   String getStatusText(String status) {
//     switch (status) {
//       case "PENDING":
//         return "Preparing your booking";
//
//       case "SEARCHING_PARTNER":
//         return "Finding a captain nearby...";
//
//       case "PARTNER_ASSIGNED":
//         return "Captain assigned";
//
//       case "PARTNER_ACCEPTED":
//         return "Captain accepted your ride";
//
//       case "ARRIVED":
//         return "Captain has arrived";
//
//       case "PICKED_UP":
//         return "Trip started";
//
//       case "ONGOING":
//         return "Trip is in progress";
//
//       case "COMPLETED":
//         return "Trip completed";
//
//       case "CANCELLED":
//         return "Ride cancelled";
//
//       default:
//         return status;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // body: Center(
//       //   child: Column(
//       //     mainAxisAlignment: MainAxisAlignment.center,
//       //     children: [
//       //       // Animated searching effect
//       //       const CircularProgressIndicator(
//       //         strokeWidth: 6,
//       //         valueColor: AlwaysStoppedAnimation(Color(0xFFB15DC6)),
//       //       ),
//       //       const SizedBox(height: 10),
//       //       Text(
//       //         getStatusText(status),
//       //         style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//       //       ),
//       //       const SizedBox(height: 50),
//       //
//       //       // Cancel button
//       //       ElevatedButton(
//       //         onPressed: () {
//       //           Navigator.pop(context);
//       //         },
//       //         style: ElevatedButton.styleFrom(
//       //           backgroundColor: Colors.redAccent,
//       //           shape: RoundedRectangleBorder(
//       //             borderRadius: BorderRadius.circular(12),
//       //           ),
//       //         ),
//       //         child: const Padding(
//       //           padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//       //           child: Text(
//       //             "Cancel Ride",
//       //             style: TextStyle(color: Colors.white, fontSize: 16),
//       //           ),
//       //         ),
//       //       ),
//       //     ],
//       //   ),
//       // ),
//       body: SafeArea(child: _buildBody()),
//     );
//   }
//
//   Widget _buildBody() {
//     switch (status) {
//       case "SEARCHING_PARTNER":
//       case "PENDING":
//         return _searchingWidget();
//
//       case "PARTNER_ASSIGNED":
//       case "PARTNER_ACCEPTED":
//         return _driverAssignedWidget();
//
//       case "ARRIVED":
//         return _driverArrivedWidget();
//
//       case "PICKED_UP":
//       case "ONGOING":
//         return _tripWidget();
//
//       case "COMPLETED":
//         return _completedWidget();
//
//       case "CANCELLED":
//         return _cancelledWidget();
//
//       default:
//         return _searchingWidget();
//     }
//   }
//
//   Widget _searchingWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const CircularProgressIndicator(),
//           const SizedBox(height: 25),
//           Text(
//             getStatusText(status),
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           const Text("Looking for nearby drivers"),
//         ],
//       ),
//     );
//   }
//
//   Widget _driverAssignedWidget() {
//     return Column(
//       children: [
//         SizedBox(
//           height: 320,
//           child: GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: LatLng(order!.pickupLatitude, order!.pickupLongitude),
//               zoom: 14,
//             ),
//             markers: {
//               Marker(
//                 markerId: const MarkerId("pickup"),
//                 position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
//               ),
//
//               Marker(
//                 markerId: const MarkerId("driver"),
//                 position: LatLng(
//                   order!.partnerLatitude!,
//                   order!.partnerLongitude!,
//                 ),
//               ),
//             },
//           ),
//         ),
//
//         Expanded(
//           child: Padding(
//             padding: const EdgeInsets.all(16),
//             child: Card(
//               child: Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     const CircleAvatar(radius: 35, child: Icon(Icons.person)),
//
//                     const SizedBox(height: 15),
//
//                     Text(
//                       order!.partnerName ?? "",
//                       style: const TextStyle(
//                         fontSize: 22,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//
//                     const SizedBox(height: 8),
//
//                     Text(order!.partnerPhone ?? ""),
//
//                     const SizedBox(height: 20),
//
//                     ElevatedButton.icon(
//                       onPressed: () {
//                         // call driver
//                       },
//                       icon: const Icon(Icons.call),
//                       label: const Text("Call Driver"),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _driverArrivedWidget() {
//     return Column(
//       children: [
//         Expanded(child: _driverAssignedWidget()),
//
//         Container(
//           margin: const EdgeInsets.all(20),
//           padding: const EdgeInsets.all(20),
//           decoration: BoxDecoration(
//             color: Colors.green.shade50,
//             borderRadius: BorderRadius.circular(16),
//           ),
//           child: Column(
//             children: [
//               const Text(
//                 "Driver has arrived",
//                 style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//               ),
//
//               const SizedBox(height: 20),
//
//               const Text("Share this OTP with driver"),
//
//               const SizedBox(height: 15),
//
//               Text(
//                 "${order!.pickupOtp}",
//                 style: const TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   letterSpacing: 8,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _tripWidget() {
//     return Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.directions_car, size: 80, color: Colors.green),
//
//           const SizedBox(height: 20),
//
//           Text(
//             getStatusText(status),
//             style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//
//           const SizedBox(height: 15),
//
//           Text("Driver: ${order?.partnerName}"),
//         ],
//       ),
//     );
//   }
//
//   Widget _completedWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.check_circle, size: 90, color: Colors.green),
//           SizedBox(height: 20),
//           Text(
//             "Ride Completed",
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _cancelledWidget() {
//     return const Center(
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(Icons.cancel, size: 90, color: Colors.red),
//           SizedBox(height: 20),
//           Text(
//             "Ride Cancelled",
//             style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/logistics/orderdetails.dart';
import '../../Services/Auth_service/logisticsservice.dart';
import '../../Services/websockets/web_socket_manager.dart';

class _AppColors {
  static const primary = Color(0xFFB15DC6);
  static const primaryDark = Color(0xFF8A3FA0);
  static const success = Color(0xFF1FAA59);
  static const danger = Color(0xFFE0403F);
  static const surface = Colors.white;
  static const background = Color(0xFFF7F6FA);
  static const textPrimary = Color(0xFF1B1B23);
  static const textSecondary = Color(0xFF6B6B76);
  static const divider = Color(0xFFEDEBF2);
}

class FindingDriverScreen extends StatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  State<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends State<FindingDriverScreen>
    with SingleTickerProviderStateMixin {
  Timer? _timer;

  String status = "SEARCHING_PARTNER";

  OrderDetails? order;
  int? userId;

  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();
    _listenForDriver();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (userId != null) {
      WebSocketManager().unsubscribeLogisticOrder(userId!);
    }
    super.dispose();
  }

  Future<void> _listenForDriver() async {
    final userId = 1; // TODO: replace with SharedPreferences-backed user id
    this.userId = userId;

    WebSocketManager().subscribeLogisticOrder(userId, (data) async {
      debugPrint(data.toString());

      if (data["orderId"] == null) return;

      final order = await LogisticsService.getOrderById(data["orderId"]);

      if (!mounted) return;

      setState(() {
        this.order = order;
        status = order.status;
      });

      if (status == "PARTNER_ASSIGNED") {
        debugPrint(order.partnerName);
      }
    });
  }

  String getStatusText(String status) {
    switch (status) {
      case "PENDING":
        return "Preparing your booking";
      case "SEARCHING_PARTNER":
        return "Finding a captain nearby";
      case "PARTNER_ASSIGNED":
        return "Captain assigned";
      case "PARTNER_ACCEPTED":
        return "Captain is on the way";
      case "ARRIVED":
        return "Captain has arrived";
      case "PICKED_UP":
        return "Trip started";
      case "ONGOING":
        return "Trip in progress";
      case "COMPLETED":
        return "Trip completed";
      case "CANCELLED":
        return "Ride cancelled";
      default:
        return status;
    }
  }

  Future<void> _callDriver() async {
    final phone = order?.partnerPhone;
    if (phone == null || phone.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  void _cancelRide() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CancelRideSheet(
        onConfirm: () {
          Navigator.pop(ctx); // close sheet
          Navigator.pop(context); // leave screen
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.background,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _buildBody(),
        ),
      ),
    );
  }

  // Widget _buildBody() {
  //   switch (status) {
  //     case "SEARCHING_PARTNER":
  //     case "PENDING":
  //       return _SearchingView(
  //         key: const ValueKey('searching'),
  //         statusText: getStatusText(status),
  //         pulseController: _pulseController,
  //         onCancel: _cancelRide,
  //       );
  //
  //     case "PARTNER_ASSIGNED":
  //     case "PARTNER_ACCEPTED":
  //       return _DriverAssignedView(
  //         key: const ValueKey('assigned'),
  //         order: order,
  //         statusText: getStatusText(status),
  //         onCall: _callDriver,
  //         onCancel: _cancelRide,
  //       );
  //
  //     case "ARRIVED":
  //       return _DriverArrivedView(
  //         key: const ValueKey('arrived'),
  //         order: order,
  //         onCall: _callDriver,
  //       );
  //
  //     case "PICKED_UP":
  //     case "ONGOING":
  //       return _TripView(
  //         key: const ValueKey('trip'),
  //         order: order,
  //         statusText: getStatusText(status),
  //       );
  //
  //     case "COMPLETED":
  //       return const _ResultView(
  //         key: ValueKey('completed'),
  //         icon: Icons.check_circle_rounded,
  //         iconColor: _AppColors.success,
  //         title: "Ride completed",
  //         subtitle: "Thanks for riding with us!",
  //       );
  //
  //     case "CANCELLED":
  //       return const _ResultView(
  //         key: ValueKey('cancelled'),
  //         icon: Icons.cancel_rounded,
  //         iconColor: _AppColors.danger,
  //         title: "Ride cancelled",
  //         subtitle: "You can book another ride anytime.",
  //       );
  //
  //     default:
  //       return _SearchingView(
  //         key: const ValueKey('searching'),
  //         statusText: getStatusText(status),
  //         pulseController: _pulseController,
  //         onCancel: _cancelRide,
  //       );
  //   }
  // }
  Widget _buildBody() {
    if (status == "SEARCHING_PARTNER" || status == "PENDING") {
      return _SearchingView(
        key: const ValueKey('searching'),
        statusText: getStatusText(status),
        pulseController: _pulseController,
        onCancel: _cancelRide,
      );
    }

    if (status == "COMPLETED") {
      return const _ResultView(
        key: ValueKey('completed'),
        icon: Icons.check_circle_rounded,
        iconColor: _AppColors.success,
        title: "Ride completed",
        subtitle: "Thanks for riding with us!",
      );
    }

    if (status == "CANCELLED") {
      return const _ResultView(
        key: ValueKey('cancelled'),
        icon: Icons.cancel_rounded,
        iconColor: _AppColors.danger,
        title: "Ride cancelled",
        subtitle: "You can book another ride anytime.",
      );
    }

    // All remaining statuses use the same screen
    return _DriverAssignedView(
      key: const ValueKey("driver"),
      order: order,
      status: status,
      onCall: _callDriver,
      onCancel: _cancelRide,
    );
  }
}

/// ---------------------------------------------------------------------------
/// Responsive helpers
/// ---------------------------------------------------------------------------
class _Responsive {
  /// Scales a base size gracefully between phone and tablet/desktop widths.
  static double scale(BuildContext context, double base, {double max = 1.25}) {
    final width = MediaQuery.of(context).size.width;
    final factor = (width / 390).clamp(0.9, max); // 390 ~ standard phone width
    return base * factor;
  }

  static double horizontalPadding(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 900) return width * 0.18; // center content on tablets/desktop
    if (width >= 600) return 32;
    return 20;
  }

  static double contentMaxWidth(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 900 ? 640 : width;
  }
}

/// A simple wrapper that centers and caps content width on large screens,
/// so the layout doesn't stretch awkwardly on tablets/desktop/web.
class _ResponsiveContainer extends StatelessWidget {
  final Widget child;
  const _ResponsiveContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: _Responsive.contentMaxWidth(context),
        ),
        child: child,
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Searching state
/// ---------------------------------------------------------------------------
class _SearchingView extends StatelessWidget {
  final String statusText;
  final AnimationController pulseController;
  final VoidCallback onCancel;

  const _SearchingView({
    super.key,
    required this.statusText,
    required this.pulseController,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final hPad = _Responsive.horizontalPadding(context);

    return _ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hPad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            SizedBox(
              width: 160,
              height: 160,
              child: AnimatedBuilder(
                animation: pulseController,
                builder: (context, _) {
                  return Stack(
                    alignment: Alignment.center,
                    children:
                        List.generate(3, (i) {
                          final t = (pulseController.value + i / 3) % 1.0;
                          return Opacity(
                            opacity: (1 - t) * 0.5,
                            child: Container(
                              width: 90 + t * 70,
                              height: 90 + t * 70,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _AppColors.primary,
                              ),
                            ),
                          );
                        })..add(
                          Container(
                            width: 84,
                            height: 84,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: _AppColors.primary,
                            ),
                            child: const Icon(
                              Icons.local_taxi_rounded,
                              color: Colors.white,
                              size: 38,
                            ),
                          ),
                        ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Hang tight, this usually takes less than a minute",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: _AppColors.textSecondary),
            ),
            const Spacer(flex: 3),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: _AppColors.danger,
                  side: const BorderSide(color: _AppColors.danger, width: 1.4),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Cancel ride",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Driver assigned / accepted state
/// ---------------------------------------------------------------------------
class _DriverAssignedView extends StatelessWidget {
  final OrderDetails? order;
  final String status;
  final VoidCallback onCall;
  final VoidCallback onCancel;

  const _DriverAssignedView({
    super.key,
    required this.order,
    required this.status,
    required this.onCall,
    required this.onCancel,
  });

  @override
  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Full Screen Map
        Positioned.fill(
          child: GoogleMap(
            initialCameraPosition: CameraPosition(
              target: LatLng(order!.pickupLatitude, order!.pickupLongitude),
              zoom: 14,
            ),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            markers: {
              Marker(
                markerId: const MarkerId("pickup"),
                position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
              ),
              if (order!.partnerLatitude != null &&
                  order!.partnerLongitude != null)
                Marker(
                  markerId: const MarkerId("driver"),
                  position: LatLng(
                    order!.partnerLatitude!,
                    order!.partnerLongitude!,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueViolet,
                  ),
                ),
            },
          ),
        ),

        // Status Badge
        // Positioned(
        //   top: MediaQuery.of(context).padding.top + 16,
        //   left: 16,
        //   child: _StatusPill(text: statusText),
        // ),

        // Bottom Driver Card
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SafeArea(
            top: false,
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15,
                    offset: Offset(0, -3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: _DriverCard(
                  order: order!,
                  status: status,
                  onCall: onCall,
                  onCancel: onCancel,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  const _StatusPill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: _AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: _AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final OrderDetails order;
  final String status;
  final VoidCallback onCall;
  final VoidCallback onCancel;

  const _DriverCard({
    super.key,
    required this.order,
    required this.status,
    required this.onCall,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 32,
                backgroundColor: _AppColors.primary.withOpacity(0.12),
                child: const Icon(
                  Icons.person_rounded,
                  color: _AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.partnerName ?? "Captain",
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star_rounded,
                          size: 16,
                          color: Color(0xFFF5A623),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          order.partnerPhone ?? "",
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            color: _AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _CircleIconButton(
                icon: Icons.call_rounded,
                background: _AppColors.success,
                onTap: onCall,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // if (status == "PARTNER_ASSIGNED") ...[
          //   const Text(
          //     "Captain has been assigned.",
          //     style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          //   ),
          // ],
          if (status == "PARTNER_ACCEPTED") ...[
            const Text(
              "Captain is on the way.",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],

          _OtpBanner(otp: "${order.pickupOtp}"),

          if (status == "PICKED_UP" || status == "ONGOING") ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.directions_car, color: Colors.green),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      "Trip in progress",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (onCancel != null) ...[
            const SizedBox(height: 20),
            const Divider(color: _AppColors.divider, height: 1),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onCancel,
                style: TextButton.styleFrom(
                  foregroundColor: _AppColors.danger,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  "Cancel ride",
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  const _CircleIconButton({
    required this.icon,
    required this.background,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.white, size: 22),
        ),
      ),
    );
  }
}

// class _DriverArrivedView extends StatelessWidget {
//   final OrderDetails? order;
//   final VoidCallback onCall;
//
//   const _DriverArrivedView({
//     super.key,
//     required this.order,
//     required this.onCall,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     if (order == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return _ResponsiveContainer(
//       child: SingleChildScrollView(
//         padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
//         child: Column(
//           children: [
//             _DriverCard(
//               order: order!,
//               status: status,
//               onCall: onCall,
//               onCancel: onCancel,
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }

class _OtpBanner extends StatelessWidget {
  final String otp;
  const _OtpBanner({required this.otp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
      decoration: BoxDecoration(
        color: _AppColors.success.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _AppColors.success.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(
                Icons.check_circle_rounded,
                color: _AppColors.success,
                size: 18,
              ),
              SizedBox(width: 6),
              Text(
                "Captain has arrived",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            "Share this OTP with your captain",
            style: TextStyle(fontSize: 13, color: _AppColors.textSecondary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            alignment: WrapAlignment.center,
            children: otp.split('').map((digit) {
              return Container(
                width: 42,
                height: 52,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _AppColors.success.withOpacity(0.4),
                  ),
                ),
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.success,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Trip in progress state
/// ---------------------------------------------------------------------------
class _TripView extends StatelessWidget {
  final OrderDetails? order;
  final String statusText;

  const _TripView({super.key, required this.order, required this.statusText});

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _Responsive.horizontalPadding(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _AppColors.success.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.directions_car_filled_rounded,
                size: 48,
                color: _AppColors.success,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              statusText,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "with ${order?.partnerName ?? 'your captain'}",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Completed / Cancelled state
/// ---------------------------------------------------------------------------
class _ResultView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;

  const _ResultView({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return _ResponsiveContainer(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: _Responsive.horizontalPadding(context),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 60, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: _AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: _AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).maybePop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  "Done",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ---------------------------------------------------------------------------
/// Cancel confirmation sheet
/// ---------------------------------------------------------------------------
class _CancelRideSheet extends StatelessWidget {
  final VoidCallback onConfirm;
  const _CancelRideSheet({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: 20 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: _AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Icon(
                Icons.info_outline_rounded,
                color: _AppColors.danger,
                size: 36,
              ),
              const SizedBox(height: 12),
              const Text(
                "Cancel this ride?",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              const Text(
                "Cancellation charges may apply depending on how far your captain has traveled.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: _AppColors.textSecondary),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Keep ride"),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: onConfirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.danger,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Yes, cancel"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
