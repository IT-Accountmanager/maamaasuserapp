import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maamaas/Services/Auth_service/food_authservice.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/logistics/orderdetails.dart';
import '../../Services/Auth_service/delivery_service.dart';
import '../../Services/paymentservice/razorpayservice.dart';
import '../../Services/websockets/web_socket_manager.dart';

class _AppColors {
  static const primary = Color(0xFFB15DC6);
  static const success = Color(0xFF1FAA59);
  static const danger = Color(0xFFE0403F);
  static const surface = Colors.white;
  static const background = Color(0xFFF7F6FA);
  static const textPrimary = Color(0xFF1B1B23);
  static const textSecondary = Color(0xFF6B6B76);
  static const divider = Color(0xFFEDEBF2);
  static const accent = Color(0xFF276EF1);
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
  int? _orderId;
  GoogleMapController? _mapController;

  Marker? _driverMarker;
  Marker? _pickupMarker;

  int? _partnerId;
  late final AnimationController _pulseController;
  bool _paymentDialogShowing = false;

  bool _statusSocketSubscribed = false;

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
    if (_partnerId != null) {
      WebSocketManager().unsubscribePartnerLocation(_partnerId!);
    }

    if (userId != null) {
      WebSocketManager().unsubscribeLogisticOrder(userId!);
    }

    if (_orderId != null) {
      WebSocketManager().unsubscribeLogisticOrderStatus(_orderId!);
    }

    _pulseController.dispose();
    super.dispose();
  }

  // Future<void> _listenForDriver() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final int userId = prefs.getInt('userId') ?? 0;
  //
  //   WebSocketManager().subscribeLogisticOrder(userId, (data) async {
  //     debugPrint("WS DATA = $data");
  //
  //     if (data["orderId"] == null) return;
  //
  //     _orderId = data["orderId"];
  //
  //     final latestOrder = await DeliveryService.getOrderById(_orderId!);
  //
  //     debugPrint("API STATUS = ${latestOrder.status}");
  //     debugPrint("PARTNER ID = ${latestOrder.partnerId}");
  //     debugPrint("PARTNER NAME = ${latestOrder.partnerName}");
  //
  //     if (!mounted) return;
  //
  //     setState(() {
  //       order = latestOrder;
  //       status = latestOrder.status;
  //     });
  //
  //     debugPrint("CURRENT UI STATUS = $status");
  //   });
  // }

  Future<void> _listenForDriver() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('userId') ?? 0;

    WebSocketManager().subscribeLogisticOrder(userId!, (data) async {
      debugPrint("📦 USER WS DATA = $data");

      if (data["orderId"] == null) return;

      _orderId = data["orderId"];

      final latestOrder = await DeliveryService.getOrderById(_orderId!);
      final prefs = await SharedPreferences.getInstance();

      await prefs.setInt("activeLogisticsOrderId", latestOrder.orderId);

      if (!mounted) return;

      setState(() {
        order = latestOrder;
        status = latestOrder.status;
      });

      debugPrint("API STATUS = ${latestOrder.status}");

      // Subscribe to order-specific status updates only once
      if (!_statusSocketSubscribed) {
        _statusSocketSubscribed = true;

        debugPrint("Subscribing to order status for $_orderId");

        // WebSocketManager().subscribeLogisticOrderStatus(_orderId!, (
        //   statusData,
        // ) async {
        //
        //   debugPrint("========== STATUS WS ==========");
        //   debugPrint(statusData.toString());
        //   debugPrint("📲 ORDER STATUS WS = $statusData");
        //
        //   if (!mounted) return;
        //
        //   final latest = await DeliveryService.getOrderById(_orderId!);
        //
        //   setState(() {
        //     order = latest;
        //     status = latest.status;
        //   });
        //
        //   debugPrint("LIVE STATUS UPDATED = ${latest.status}");
        //   if (latest.status == "COMPLETED") {
        //     final prefs = await SharedPreferences.getInstance();
        //     await prefs.remove("activeLogisticsOrderId");
        //
        //     Future.delayed(const Duration(milliseconds: 500), () {
        //       if (!mounted) return;
        //
        //       Navigator.of(context).pop();
        //       // or pushNamedAndRemoveUntil("/home", (route) => false);
        //     });
        //   }
        // });
        WebSocketManager().subscribeLogisticOrderStatus(
          _orderId!,
              (statusData) async {

            debugPrint("========== SCREEN CALLBACK ==========");
            debugPrint(statusData.toString());

            final latest = await DeliveryService.getOrderById(_orderId!);

            debugPrint("API STATUS = ${latest.status}");

            if (!mounted) return;

            setState(() {
              order = latest;
              status = latest.status;
            });

            debugPrint("UI STATUS = $status");
          },
        );
      }
    });
  }

  void _listenPartnerLocation(int partnerId) {
    WebSocketManager().subscribePartnerLocation(partnerId, (data) {
      debugPrint("Partner Location : $data");

      final lat = double.parse(data["latitude"].toString());
      final lng = double.parse(data["longitude"].toString());

      setState(() {
        _driverMarker = Marker(
          markerId: const MarkerId("driver"),
          position: LatLng(lat, lng),
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueViolet,
          ),
        );
      });

      _mapController?.animateCamera(CameraUpdate.newLatLng(LatLng(lat, lng)));
      _updateCamera(lat, lng);
    });
  }

  void _updateCamera(double driverLat, double driverLng) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        driverLat < order!.pickupLatitude ? driverLat : order!.pickupLatitude,
        driverLng < order!.pickupLongitude ? driverLng : order!.pickupLongitude,
      ),
      northeast: LatLng(
        driverLat > order!.pickupLatitude ? driverLat : order!.pickupLatitude,
        driverLng > order!.pickupLongitude ? driverLng : order!.pickupLongitude,
      ),
    );

    _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // Future<void> _refreshOrderStatus() async {
  //   if (_orderId == null) {
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Order not available yet")));
  //     return;
  //   }
  //
  //   try {
  //     final latestOrder = await DeliveryService.getOrderById(_orderId!);
  //
  //     if (!mounted) return;
  //
  //     setState(() {
  //       order = latestOrder;
  //       status = latestOrder.status;
  //     });
  //
  //     debugPrint("Manual Refresh Status : ${latestOrder.status}");
  //   } catch (e) {
  //     debugPrint("Refresh Error : $e");
  //
  //     ScaffoldMessenger.of(
  //       context,
  //     ).showSnackBar(const SnackBar(content: Text("Unable to refresh status")));
  //   }
  // }

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
      case "PAYMENT_PENDING":
        return "Payment is in pending";
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

  Future<void> _payOnline() async {
    if (order == null) return;

    try {
      debugPrint("=========== START PAYMENT ===========");
      debugPrint("Ride Fare : ${order!.fare}");

      _showProcessingDialog("Preparing payment...\nPlease wait.");

      final razorpayOrderId = await food_Authservice.createOrder(order!.fare);

      if (!mounted) return;

      if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
        _hideProcessingDialog();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to create payment order.")),
        );
        return;
      }

      _hideProcessingDialog();

      debugPrint("Received Razorpay Order Id : $razorpayOrderId");

      final razorpay = RazorpayService();

      razorpay.onSuccess = (success) async {
        try {
          debugPrint("=========== PAYMENT SUCCESS ===========");
          debugPrint("PaymentId : ${success.paymentId}");
          debugPrint("OrderId : ${success.orderId}");
          debugPrint("Signature : ${success.signature}");

          _showProcessingDialog("Capturing payment...\nPlease wait.");

          final captured = await food_Authservice.capturePayment(
            paymentId: success.paymentId!,
            amount: order!.fare,
          );

          debugPrint("Capture Result : $captured");

          _hideProcessingDialog();

          _showProcessingDialog("Verifying payment...\nPlease wait.");

          final verify = await food_Authservice.verifyPayment(
            success.paymentId!,
          );

          _hideProcessingDialog();

          debugPrint("Verify Response : $verify");

          if (verify == null) {
            await DeliveryService.updateLogisticsPayment(
              orderId: order!.orderId,
              paymentMode: "UPI",
              paymentStatus: "PENDING",
              transactionId: success.paymentId,
              gatewayOrderId: success.orderId,
              gatewayPaymentId: success.paymentId,
              totalAmount: order!.fare,
            );

            _showPaymentFailed("Unable to verify payment.");
            return;
          }

          final status = verify.status?.toLowerCase() ?? "";

          debugPrint("Payment Status : $status");

          switch (status) {
            case "captured":
              await DeliveryService.updateLogisticsPayment(
                orderId: order!.orderId,
                paymentMode: "UPI",
                paymentStatus: "SUCCESS",
                transactionId: success.paymentId,
                gatewayOrderId: success.orderId,
                gatewayPaymentId: success.paymentId,
                totalAmount: order!.fare,
              );

              _showPaymentSuccess();
              break;

            case "authorized":
              await DeliveryService.updateLogisticsPayment(
                orderId: order!.orderId,
                paymentMode: "UPI",
                paymentStatus: "PENDING",
                transactionId: success.paymentId,
                gatewayOrderId: success.orderId,
                gatewayPaymentId: success.paymentId,
                totalAmount: order!.fare,
              );

              _showPaymentPending();
              break;

            case "refunded":
              _showPaymentRefunded();
              break;

            case "failed":
              _showPaymentFailed("Payment Failed");
              break;

            default:
              _showPaymentPending();
          }
        } catch (e, s) {
          _hideProcessingDialog();

          debugPrint(e.toString());
          debugPrint(s.toString());

          _showPaymentFailed("Something went wrong while processing payment.");
        }
      };

      razorpay.onError = (error) async {
        await DeliveryService.updateLogisticsPayment(
          orderId: order!.orderId,
          paymentMode: "UPI",
          paymentStatus: "PENDING",
          totalAmount: order!.fare,
        );
        _hideProcessingDialog();

        debugPrint("=========== PAYMENT FAILED ===========");
        debugPrint(error.toString());

        _showPaymentFailed(error.message ?? "Payment Failed");
      };

      razorpay.onExternalWallet = (wallet) {
        debugPrint("External Wallet : ${wallet.walletName}");
      };

      debugPrint("Opening Razorpay");

      await razorpay.startPayment(
        orderId: razorpayOrderId,
        amount: order!.fare,
        description: "Ride Payment",
      );
    } catch (e, s) {
      _hideProcessingDialog();

      debugPrint("PAYMENT EXCEPTION");
      debugPrint(e.toString());
      debugPrint(s.toString());

      _showPaymentFailed("Unexpected error occurred.");
    }
  }

  void _showPaymentSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Payment Successful"),
        content: const Text(
          "Your ride payment has been completed successfully.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPaymentPending() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Processing"),
        content: const Text(
          "Your payment has been authorized and is being processed.\n\nPlease wait a moment.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPaymentRefunded() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Refunded"),
        content: const Text("The payment has been refunded successfully."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              // Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showPaymentFailed(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Payment Failed"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  void _showProcessingDialog(String message) {
    if (_paymentDialogShowing) return;

    _paymentDialogShowing = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(
                  width: 45,
                  height: 45,
                  child: CircularProgressIndicator(),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _hideProcessingDialog() {
    if (!_paymentDialogShowing) return;

    _paymentDialogShowing = false;

    Navigator.of(context, rootNavigator: true).pop();
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

  Widget _buildBody() {
    debugPrint("BUILD STATUS = $status");
    if (status == "SEARCHING_PARTNER" || status == "PENDING") {
      return _SearchingView(
        key: const ValueKey('searching'),
        statusText: getStatusText(status),
        pulseController: _pulseController,
        onCancel: _cancelRide,
      );
    }

    if (status == "PAYMENT_PENDING") {
      return _PaymentSelectionView(
        order: order,
        onCash: () async {
          if (order == null) return;

          final success = await DeliveryService.updateLogisticsPayment(
            orderId: order!.orderId,
            paymentMode: "CASH",
            paymentStatus: "SUCCESS",
            totalAmount: order!.fare,
          );

          if (success && context.mounted) {
            Navigator.of(context).maybePop();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Unable to update payment.")),
            );
          }
        },
        onOnline: _payOnline,
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
      // onRefresh: _refreshOrderStatus,
      mapController: _mapController,
      driverMarker: _driverMarker,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}

class _Responsive {
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

class _DriverAssignedView extends StatelessWidget {
  final OrderDetails? order;
  final String status;
  final VoidCallback onCall;
  final VoidCallback onCancel;
  // final VoidCallback onRefresh;
  final GoogleMapController? mapController;
  final Marker? driverMarker;
  final Function(GoogleMapController) onMapCreated;

  const _DriverAssignedView({
    super.key,
    required this.order,
    required this.status,
    required this.onCall,
    required this.onCancel,
    // required this.onRefresh,
    required this.driverMarker,
    required this.mapController,
    required this.onMapCreated,
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
            // onMapCreated: (controller) {
            //   _mapController = controller;
            // },
            onMapCreated: onMapCreated,
            initialCameraPosition: CameraPosition(
              target: LatLng(order!.pickupLatitude, order!.pickupLongitude),
              zoom: 14,
            ),
            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            // markers: {
            //   Marker(
            //     markerId: const MarkerId("pickup"),
            //     position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
            //   ),
            //   if (order!.partnerLatitude != null &&
            //       order!.partnerLongitude != null)
            //     Marker(
            //       markerId: const MarkerId("driver"),
            //       position: LatLng(
            //         order!.partnerLatitude!,
            //         order!.partnerLongitude!,
            //       ),
            //       icon: BitmapDescriptor.defaultMarkerWithHue(
            //         BitmapDescriptor.hueViolet,
            //       ),
            //     ),
            // },
            markers: {
              Marker(
                markerId: const MarkerId("pickup"),
                position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
              ),

              if (driverMarker != null) driverMarker!,
            },
          ),
        ),

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
                  // onRefresh: onRefresh,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// class _DriverCard extends StatelessWidget {
//   final OrderDetails order;
//   final String status;
//   final VoidCallback onCall;
//   final VoidCallback onCancel;
//   // final VoidCallback onRefresh;
//
//   const _DriverCard({
//     super.key,
//     required this.order,
//     required this.status,
//     required this.onCall,
//     required this.onCancel,
//     // required this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: _AppColors.surface,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: const [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 16,
//             offset: Offset(0, 6),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Row(
//             children: [
//               CircleAvatar(
//                 radius: 32,
//                 backgroundColor: _AppColors.primary.withOpacity(0.12),
//                 child: const Icon(
//                   Icons.person_rounded,
//                   color: _AppColors.primary,
//                   size: 32,
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       order.partnerName ?? "Captain",
//                       overflow: TextOverflow.ellipsis,
//                       style: const TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w700,
//                         color: _AppColors.textPrimary,
//                       ),
//                     ),
//                     const SizedBox(height: 4),
//                     Row(
//                       children: [
//                         const Icon(
//                           Icons.star_rounded,
//                           size: 16,
//                           color: Color(0xFFF5A623),
//                         ),
//                         const SizedBox(width: 4),
//                         Text(
//                           order.partnerPhone ?? "",
//                           overflow: TextOverflow.ellipsis,
//                           style: const TextStyle(
//                             fontSize: 13,
//                             color: _AppColors.textSecondary,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               _CircleIconButton(
//                 icon: Icons.call_rounded,
//                 background: _AppColors.success,
//                 onTap: onCall,
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//
//           if (status == "PARTNER_ACCEPTED") ...[
//             const Text(
//               "Captain is on the way.",
//               style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
//             ),
//           ],
//
//           _OtpBanner(otp: "${order.pickupOtp}"),
//           const SizedBox(height: 15),
//
//           // SizedBox(
//           //   width: double.infinity,
//           //   child: OutlinedButton.icon(
//           //     onPressed: onRefresh,
//           //     icon: const Icon(Icons.refresh),
//           //     label: const Text("Refresh Status"),
//           //   ),
//           // ),
//           if (status == "PICKED_UP" || status == "ONGOING") ...[
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.green.shade50,
//                 borderRadius: BorderRadius.circular(12),
//               ),
//               child: const Row(
//                 children: [
//                   Icon(Icons.directions_car, color: Colors.green),
//                   SizedBox(width: 10),
//                   Expanded(
//                     child: Text(
//                       "Trip in progress",
//                       style: TextStyle(fontWeight: FontWeight.bold),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//           if (onCancel != null) ...[
//             const SizedBox(height: 20),
//             const Divider(color: _AppColors.divider, height: 1),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               child: TextButton(
//                 onPressed: onCancel,
//                 style: TextButton.styleFrom(
//                   foregroundColor: _AppColors.danger,
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                 ),
//                 child: const Text(
//                   "Cancel ride",
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//               ),
//             ),
//           ],
//         ],
//       ),
//     );
//   }
// }
//
// class _CircleIconButton extends StatelessWidget {
//   final IconData icon;
//   final Color background;
//   final VoidCallback onTap;
//
//   const _CircleIconButton({
//     required this.icon,
//     required this.background,
//     required this.onTap,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       color: background,
//       shape: const CircleBorder(),
//       child: InkWell(
//         customBorder: const CircleBorder(),
//         onTap: onTap,
//         child: Padding(
//           padding: const EdgeInsets.all(12),
//           child: Icon(icon, color: Colors.white, size: 22),
//         ),
//       ),
//     );
//   }
// }
//
// class _OtpBanner extends StatelessWidget {
//   final String otp;
//   const _OtpBanner({required this.otp});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
//       decoration: BoxDecoration(
//         color: _AppColors.success.withOpacity(0.08),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: _AppColors.success.withOpacity(0.25)),
//       ),
//       child: Column(
//         children: [
//           Row(
//             mainAxisSize: MainAxisSize.min,
//             children: const [
//               Icon(
//                 Icons.check_circle_rounded,
//                 color: _AppColors.success,
//                 size: 18,
//               ),
//               SizedBox(width: 6),
//               Text(
//                 "Captain has arrived",
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: FontWeight.w700,
//                   color: _AppColors.textPrimary,
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 12),
//           const Text(
//             "Share this OTP with your captain",
//             style: TextStyle(fontSize: 13, color: _AppColors.textSecondary),
//           ),
//           const SizedBox(height: 10),
//           Wrap(
//             spacing: 10,
//             alignment: WrapAlignment.center,
//             children: otp.split('').map((digit) {
//               return Container(
//                 width: 42,
//                 height: 52,
//                 alignment: Alignment.center,
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(10),
//                   border: Border.all(
//                     color: _AppColors.success.withOpacity(0.4),
//                   ),
//                 ),
//                 child: Text(
//                   digit,
//                   style: const TextStyle(
//                     fontSize: 24,
//                     fontWeight: FontWeight.w800,
//                     color: _AppColors.success,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

class _DriverCard extends StatelessWidget {
  final OrderDetails order;
  final String status;
  final VoidCallback onCall;
  final VoidCallback onCancel;
  // final VoidCallback onRefresh;

  const _DriverCard({
    required this.order,
    required this.status,
    required this.onCall,
    required this.onCancel,
    // required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    bool isOngoing = status == "PICKED_UP" || status == "ONGOING";

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: _AppColors.background,
              child: const Icon(
                Icons.person_rounded,
                color: _AppColors.textPrimary,
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    order.partnerName ?? "Captain Assigned",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        order.partnerPhone ?? "4.9",
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
            InkWell(
              onTap: onCall,
              borderRadius: BorderRadius.circular(50),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: _AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.call, color: Colors.white, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // OTP Banner (Show ONLY before pickup)
        if (!isOngoing) ...[
          _OtpBanner(otp: "${order.pickupOtp}"),
          const SizedBox(height: 14),
        ] else ...[
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: _AppColors.accent.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: const [
                Icon(Icons.directions_car_rounded, color: _AppColors.accent),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "Trip in progress to drop location",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
        ],

        Row(
          children: [
            // Expanded(
            //   child: OutlinedButton.icon(
            //     onPressed: onRefresh,
            //     icon: const Icon(Icons.refresh, size: 18),
            //     label: const Text("Refresh Status"),
            //     style: OutlinedButton.styleFrom(
            //       padding: const EdgeInsets.symmetric(vertical: 12),
            //       shape: RoundedRectangleBorder(
            //         borderRadius: BorderRadius.circular(10),
            //       ),
            //     ),
            //   ),
            // ),
            if (!isOngoing) ...[
              const SizedBox(width: 12),
              Expanded(
                child: TextButton(
                  onPressed: onCancel,
                  style: TextButton.styleFrom(
                    foregroundColor: _AppColors.danger,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    "Cancel Ride",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _OtpBanner extends StatelessWidget {
  final String otp;
  const _OtpBanner({required this.otp});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: _AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "START TRIP OTP",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _AppColors.textSecondary,
                ),
              ),
              Text(
                "Share with captain",
                style: TextStyle(fontSize: 12, color: _AppColors.textSecondary),
              ),
            ],
          ),
          Row(
            children: otp.split('').map((digit) {
              return Container(
                margin: const EdgeInsets.only(left: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
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

class _PaymentSelectionView extends StatelessWidget {
  final OrderDetails? order;
  final VoidCallback onCash;
  final VoidCallback onOnline;

  const _PaymentSelectionView({
    required this.order,
    required this.onCash,
    required this.onOnline,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),

          const SizedBox(height: 20),

          const Text(
            "Ride Completed",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 10),

          Text("Amount to Pay", style: TextStyle(color: Colors.grey.shade600)),

          const SizedBox(height: 8),

          Text(
            "₹ ${order?.fare.toStringAsFixed(2) ?? "0.00"}",
            style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 40),

          // SizedBox(
          //   width: double.infinity,
          //   child: ElevatedButton.icon(
          //     onPressed: onCash,
          //     icon: const Icon(Icons.money),
          //     label: const Text("Pay by Cash"),
          //   ),
          // ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: order?.cashPayment == true ? onCash : null,
              icon: const Icon(Icons.money),
              label: Text(
                order?.cashPayment == true
                    ? "Pay by Cash"
                    : "Cash Payment Not Available",
              ),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: Colors.grey.shade300,
                disabledForegroundColor: Colors.grey.shade600,
              ),
            ),
          ),

          const SizedBox(height: 15),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onOnline,
              icon: const Icon(Icons.payment),
              label: const Text("Pay Online"),
            ),
          ),
        ],
      ),
    );
  }
}

//
// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:http/http.dart' as http;
// import 'package:maamaas/Services/Auth_service/food_authservice.dart';
// import 'package:maamaas/Services/googleservices/googleapiservice.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:url_launcher/url_launcher.dart';
// import '../../Models/logistics/orderdetails.dart';
// import '../../Services/Auth_service/delivery_service.dart';
// import '../../Services/paymentservice/razorpayservice.dart';
// import '../../Services/websockets/web_socket_manager.dart';
//
// // IMPORTANT: Replace this with your Google Maps Directions API key
// // const String GOOGLE_MAPS_API_KEY = "YOUR_GOOGLE_MAPS_API_KEY";
//
// class _AppColors {
//   static const primary = Color(0xFF000000); // Uber/Ola classic dark style
//   static const accent = Color(0xFF276EF1);
//   static const success = Color(0xFF1FAA59);
//   static const danger = Color(0xFFE0403F);
//   static const surface = Colors.white;
//   static const background = Color(0xFFF4F5F7);
//   static const textPrimary = Color(0xFF1B1B23);
//   static const textSecondary = Color(0xFF6B6B76);
//   static const divider = Color(0xFFEDEBF2);
// }
//
// class FindingDriverScreen extends StatefulWidget {
//   const FindingDriverScreen({super.key});
//
//   @override
//   State<FindingDriverScreen> createState() => _FindingDriverScreenState();
// }
//
// class _FindingDriverScreenState extends State<FindingDriverScreen>
//     with SingleTickerProviderStateMixin {
//   String status = "SEARCHING_PARTNER";
//
//   OrderDetails? order;
//   int? userId;
//   int? _orderId;
//   GoogleMapController? _mapController;
//
//   Marker? _driverMarker;
//   Marker? _pickupMarker;
//   Marker? _dropMarker;
//
//   Set<Polyline> _polylines = {};
//   String _estimatedTime = "";
//
//   int? _partnerId;
//   late final AnimationController _pulseController;
//   bool _paymentDialogShowing = false;
//
//   @override
//   void initState() {
//     super.initState();
//     _pulseController = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1600),
//     )..repeat();
//     _listenForDriver();
//   }
//
//   @override
//   void dispose() {
//     if (_partnerId != null) {
//       WebSocketManager().unsubscribePartnerLocation(_partnerId!);
//     }
//     if (userId != null) {
//       WebSocketManager().unsubscribeLogisticOrder(userId!);
//     }
//     _pulseController.dispose();
//     super.dispose();
//   }
//
//   Future<void> _listenForDriver() async {
//     final prefs = await SharedPreferences.getInstance();
//     final int userId = prefs.getInt('userId') ?? 0;
//     debugPrint("Subscribing logistics for user : $userId");
//
//     WebSocketManager().subscribeLogisticOrder(userId, (data) async {
//       debugPrint("WS CALLBACK RECEIVED");
//       debugPrint("WS DATA : $data");
//       if (data["orderId"] == null) return;
//
//       _orderId = data["orderId"];
//       final latestOrder = await DeliveryService.getOrderById(_orderId!);
//
//       if (!mounted) return;
//
//       setState(() {
//         order = latestOrder;
//         status = latestOrder.status;
//         _setupStaticMarkers();
//         debugPrint("INSIDE SETSTATE -> $status");
//       });
//
//       if (latestOrder.partnerId != null &&
//           latestOrder.partnerId != _partnerId) {
//         _partnerId = latestOrder.partnerId;
//         _listenPartnerLocation(_partnerId!);
//       }
//     });
//   }
//
//   void _setupStaticMarkers() {
//     if (order == null) return;
//
//     _pickupMarker = Marker(
//       markerId: const MarkerId("pickup"),
//       position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       infoWindow: const InfoWindow(title: "Pickup Location"),
//     );
//
//     if (order!.dropLatitude != null && order!.dropLongitude != null) {
//       _dropMarker = Marker(
//         markerId: const MarkerId("drop"),
//         position: LatLng(order!.dropLatitude!, order!.dropLongitude!),
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
//         infoWindow: const InfoWindow(title: "Drop Location"),
//       );
//     }
//   }
//
//   void _listenPartnerLocation(int partnerId) {
//     WebSocketManager().subscribePartnerLocation(partnerId, (data) {
//       final lat = double.parse(data["latitude"].toString());
//       final lng = double.parse(data["longitude"].toString());
//       final driverLatLng = LatLng(lat, lng);
//
//       if (!mounted) return;
//
//       setState(() {
//         _driverMarker = Marker(
//           markerId: const MarkerId("driver"),
//           position: driverLatLng,
//           icon: BitmapDescriptor.defaultMarkerWithHue(
//             BitmapDescriptor.hueViolet,
//           ),
//           infoWindow: const InfoWindow(title: "Captain"),
//         );
//       });
//
//       _updateRouteAndCamera(driverLatLng);
//     });
//   }
//
//   // Fetch Route polyline from Google Directions API
//   Future<void> _updateRouteAndCamera(LatLng driverLatLng) async {
//     if (order == null) return;
//
//     LatLng origin;
//     LatLng destination;
//
//     // Check Status to decide route endpoints
//     if (status == "PICKED_UP" || status == "ONGOING") {
//       // Driver has picked up: Route from Driver/Pickup -> Drop Location
//       origin = driverLatLng;
//       destination = LatLng(order!.dropLatitude!, order!.dropLongitude!);
//     } else {
//       // Driver on the way to pickup: Route from Driver -> Pickup Location
//       origin = driverLatLng;
//       destination = LatLng(order!.pickupLatitude, order!.pickupLongitude);
//     }
//
//     // Fetch polylines dynamically
//     await _fetchRoutePolylines(origin, destination);
//     _fitCameraToBounds(origin, destination);
//   }
//
//   Future<void> _fetchRoutePolylines(LatLng origin, LatLng destination) async {
//     final _googleApiKey = ApiKeyService.getApiKey();
//     final url = Uri.parse(
//       'https://maps.googleapis.com/maps/api/directions/json'
//       '?origin=${origin.latitude},${origin.longitude}'
//       '&destination=${destination.latitude},${destination.longitude}'
//       '&mode=driving'
//       '&departure_time=now'
//       '&traffic_model=best_guess'
//       '&alternatives=false'
//       '&key=$_googleApiKey',
//     );
//
//     try {
//       final response = await http.get(url);
//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//
//         if (data['routes'] != null && (data['routes'] as List).isNotEmpty) {
//           final points = data['routes'][0]['overview_polyline']['points'];
//           final polylineCoordinates = _decodePolyline(points);
//
//           final durationText =
//               data['routes'][0]['legs'][0]['duration']['text'] ?? "";
//
//           setState(() {
//             _estimatedTime = durationText;
//             _polylines = {
//               Polyline(
//                 polylineId: const PolylineId("trip_route"),
//                 points: polylineCoordinates,
//                 color: _AppColors.accent,
//                 width: 5,
//                 jointType: JointType.round,
//                 startCap: Cap.roundCap,
//                 endCap: Cap.roundCap,
//               ),
//             };
//           });
//         }
//       }
//     } catch (e) {
//       debugPrint("Error fetching directions: $e");
//     }
//   }
//
//   // Decoding Google Encoded Polyline String
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> polyline = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;
//
//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       polyline.add(LatLng(lat / 1E5, lng / 1E5));
//     }
//     return polyline;
//   }
//
//   void _fitCameraToBounds(LatLng pos1, LatLng pos2) {
//     if (_mapController == null) return;
//
//     final bounds = LatLngBounds(
//       southwest: LatLng(
//         pos1.latitude < pos2.latitude ? pos1.latitude : pos2.latitude,
//         pos1.longitude < pos2.longitude ? pos1.longitude : pos2.longitude,
//       ),
//       northeast: LatLng(
//         pos1.latitude > pos2.latitude ? pos1.latitude : pos2.latitude,
//         pos1.longitude > pos2.longitude ? pos1.longitude : pos2.longitude,
//       ),
//     );
//
//     _mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 100));
//   }
//
//   Future<void> _refreshOrderStatus() async {
//     if (_orderId == null) return;
//     try {
//       final latestOrder = await DeliveryService.getOrderById(_orderId!);
//       if (!mounted) return;
//       setState(() {
//         order = latestOrder;
//         status = latestOrder.status;
//         debugPrint("INSIDE SETSTATE -> $status");
//       });
//     } catch (e) {
//       debugPrint("Refresh Error: $e");
//     }
//   }
//
//   String getStatusText(String status) {
//     switch (status) {
//       case "PENDING":
//         return "Preparing your booking";
//       case "SEARCHING_PARTNER":
//         return "Finding a captain nearby";
//       case "PARTNER_ASSIGNED":
//         return "Captain assigned";
//       case "PARTNER_ACCEPTED":
//         return "Captain is on the way";
//       case "ARRIVED":
//         return "Captain has arrived";
//       case "PICKED_UP":
//       case "ONGOING":
//         return "Heading to destination";
//       case "COMPLETED":
//         return "Trip completed";
//       case "CANCELLED":
//         return "Ride cancelled";
//       default:
//         return status;
//     }
//   }
//
//   Future<void> _callDriver() async {
//     final phone = order?.partnerPhone;
//     if (phone == null || phone.isEmpty) return;
//     final uri = Uri(scheme: 'tel', path: phone);
//     if (await canLaunchUrl(uri)) {
//       await launchUrl(uri);
//     }
//   }
//
//   Future<void> _payOnline() async {
//     if (order == null) return;
//     try {
//       _showProcessingDialog("Preparing payment...\nPlease wait.");
//       final razorpayOrderId = await food_Authservice.createOrder(order!.fare);
//       if (!mounted) return;
//
//       if (razorpayOrderId == null || razorpayOrderId.isEmpty) {
//         _hideProcessingDialog();
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Unable to create payment order.")),
//         );
//         return;
//       }
//       _hideProcessingDialog();
//
//       final razorpay = RazorpayService();
//       razorpay.onSuccess = (success) async {
//         try {
//           _showProcessingDialog("Capturing payment...");
//           await food_Authservice.capturePayment(
//             paymentId: success.paymentId!,
//             amount: order!.fare,
//           );
//           _hideProcessingDialog();
//
//           _showProcessingDialog("Verifying payment...");
//           final verify = await food_Authservice.verifyPayment(
//             success.paymentId!,
//           );
//           _hideProcessingDialog();
//
//           if (verify != null && verify.status?.toLowerCase() == "captured") {
//             _showPaymentSuccess();
//           } else {
//             _showPaymentFailed("Verification Pending or Failed");
//           }
//         } catch (e) {
//           _hideProcessingDialog();
//           _showPaymentFailed("Payment processing failed.");
//         }
//       };
//
//       razorpay.onError = (error) {
//         _hideProcessingDialog();
//         _showPaymentFailed(error.message ?? "Payment Failed");
//       };
//
//       await razorpay.startPayment(
//         orderId: razorpayOrderId,
//         amount: order!.fare,
//         description: "Ride Payment",
//       );
//     } catch (e) {
//       _hideProcessingDialog();
//       _showPaymentFailed("Unexpected error occurred.");
//     }
//   }
//
//   void _showPaymentSuccess() {
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => AlertDialog(
//         title: const Text("Payment Successful"),
//         content: const Text("Your ride payment has been completed."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.pop(context);
//               Navigator.pushNamedAndRemoveUntil(context, "/home", (_) => false);
//             },
//             child: const Text("OK"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showPaymentFailed(String message) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Payment Failed"),
//         content: Text(message),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context),
//             child: const Text("Retry"),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _showProcessingDialog(String message) {
//     if (_paymentDialogShowing) return;
//     _paymentDialogShowing = true;
//     showDialog(
//       context: context,
//       barrierDismissible: false,
//       builder: (_) => PopScope(
//         canPop: false,
//         child: AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(16),
//           ),
//           content: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 20),
//               Text(
//                 message,
//                 textAlign: TextAlign.center,
//                 style: const TextStyle(fontWeight: FontWeight.w600),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _hideProcessingDialog() {
//     if (!_paymentDialogShowing) return;
//     _paymentDialogShowing = false;
//     Navigator.of(context, rootNavigator: true).pop();
//   }
//
//   void _cancelRide() {
//     showModalBottomSheet(
//       context: context,
//       backgroundColor: Colors.transparent,
//       builder: (ctx) => _CancelRideSheet(
//         onConfirm: () {
//           Navigator.pop(ctx);
//           Navigator.pop(context);
//         },
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: _AppColors.background,
//       body: SafeArea(
//         child: AnimatedSwitcher(
//           duration: const Duration(milliseconds: 350),
//           child: _buildBody(),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildBody() {
//     if (status == "SEARCHING_PARTNER" || status == "PENDING") {
//       debugPrint("Showing Searching View");
//       return _SearchingView(
//         key: const ValueKey("searching"),
//         statusText: getStatusText(status),
//         pulseController: _pulseController,
//         onCancel: _cancelRide,
//       );
//     }
//
//     if (status == "PAYMENT_PENDING") {
//       return _PaymentSelectionView(
//         order: order,
//         onCash: () => Navigator.of(context).maybePop(),
//         onOnline: _payOnline,
//       );
//     }
//
//     if (status == "CANCELLED") {
//       return const _ResultView(
//         key: ValueKey('cancelled'),
//         icon: Icons.cancel_rounded,
//         iconColor: _AppColors.danger,
//         title: "Ride cancelled",
//         subtitle: "You can book another ride anytime.",
//       );
//     }
//     debugPrint("Showing Driver View");
//     return _DriverAssignedView(
//       key: const ValueKey("driver"),
//       order: order,
//       status: status,
//       etaText: _estimatedTime,
//       polylines: _polylines,
//       onCall: _callDriver,
//       onCancel: _cancelRide,
//       onRefresh: _refreshOrderStatus,
//       driverMarker: _driverMarker,
//       pickupMarker: _pickupMarker,
//       dropMarker: _dropMarker,
//       onMapCreated: (controller) => _mapController = controller,
//     );
//   }
// }
//
// class _DriverAssignedView extends StatelessWidget {
//   final OrderDetails? order;
//   final String status;
//   final String etaText;
//   final Set<Polyline> polylines;
//   final VoidCallback onCall;
//   final VoidCallback onCancel;
//   final VoidCallback onRefresh;
//   final Marker? driverMarker;
//   final Marker? pickupMarker;
//   final Marker? dropMarker;
//   final Function(GoogleMapController) onMapCreated;
//
//   const _DriverAssignedView({
//     super.key,
//     required this.order,
//     required this.status,
//     required this.etaText,
//     required this.polylines,
//     required this.onCall,
//     required this.onCancel,
//     required this.onRefresh,
//     required this.driverMarker,
//     required this.pickupMarker,
//     required this.dropMarker,
//     required this.onMapCreated,
//   });
//
//   Set<Marker> _buildMapMarkers() {
//     final Set<Marker> markers = {};
//     if (pickupMarker != null) markers.add(pickupMarker!);
//
//     // Show Drop marker as well when trip has started
//     if ((status == "PICKED_UP" || status == "ONGOING") && dropMarker != null) {
//       markers.add(dropMarker!);
//     }
//     if (driverMarker != null) markers.add(driverMarker!);
//     return markers;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (order == null) {
//       return const Center(child: CircularProgressIndicator());
//     }
//
//     return Stack(
//       children: [
//         // Map Section
//         Positioned.fill(
//           child: GoogleMap(
//             onMapCreated: onMapCreated,
//             initialCameraPosition: CameraPosition(
//               target: LatLng(order!.pickupLatitude, order!.pickupLongitude),
//               zoom: 15,
//             ),
//             zoomControlsEnabled: false,
//             myLocationButtonEnabled: false,
//             markers: _buildMapMarkers(),
//             polylines: polylines,
//           ),
//         ),
//
//         // Floating ETA Badge Header (Ola/Uber style)
//         if (etaText.isNotEmpty)
//           Positioned(
//             top: 16,
//             left: 16,
//             right: 16,
//             child: Center(
//               child: Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 10,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(24),
//                   boxShadow: const [
//                     BoxShadow(color: Colors.black26, blurRadius: 10),
//                   ],
//                 ),
//                 child: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     const Icon(
//                       Icons.access_time_filled,
//                       color: Colors.white,
//                       size: 18,
//                     ),
//                     const SizedBox(width: 8),
//                     Text(
//                       status == "PICKED_UP" || status == "ONGOING"
//                           ? "Reaching destination in $etaText"
//                           : "Captain arriving in $etaText",
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontWeight: FontWeight.bold,
//                         fontSize: 13,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//
//         // Bottom Sheet Driver Information Card
//         Positioned(
//           left: 0,
//           right: 0,
//           bottom: 0,
//           child: SafeArea(
//             top: false,
//             child: Container(
//               constraints: const BoxConstraints(maxHeight: 380),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black12,
//                     blurRadius: 15,
//                     offset: Offset(0, -3),
//                   ),
//                 ],
//               ),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: _DriverCard(
//                   order: order!,
//                   status: status,
//                   onCall: onCall,
//                   onCancel: onCancel,
//                   onRefresh: onRefresh,
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }
//
// class _DriverCard extends StatelessWidget {
//   final OrderDetails order;
//   final String status;
//   final VoidCallback onCall;
//   final VoidCallback onCancel;
//   final VoidCallback onRefresh;
//
//   const _DriverCard({
//     required this.order,
//     required this.status,
//     required this.onCall,
//     required this.onCancel,
//     required this.onRefresh,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     bool isOngoing = status == "PICKED_UP" || status == "ONGOING";
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.stretch,
//       mainAxisSize: MainAxisSize.min,
//       children: [
//         Row(
//           children: [
//             CircleAvatar(
//               radius: 28,
//               backgroundColor: _AppColors.background,
//               child: const Icon(
//                 Icons.person_rounded,
//                 color: _AppColors.textPrimary,
//                 size: 30,
//               ),
//             ),
//             const SizedBox(width: 14),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     order.partnerName ?? "Captain Assigned",
//                     overflow: TextOverflow.ellipsis,
//                     style: const TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: _AppColors.textPrimary,
//                     ),
//                   ),
//                   const SizedBox(height: 2),
//                   Row(
//                     children: [
//                       const Icon(
//                         Icons.star_rounded,
//                         size: 16,
//                         color: Colors.amber,
//                       ),
//                       const SizedBox(width: 4),
//                       Text(
//                         order.partnerPhone ?? "4.9",
//                         style: const TextStyle(
//                           fontSize: 13,
//                           color: _AppColors.textSecondary,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//             InkWell(
//               onTap: onCall,
//               borderRadius: BorderRadius.circular(50),
//               child: Container(
//                 padding: const EdgeInsets.all(12),
//                 decoration: const BoxDecoration(
//                   color: _AppColors.success,
//                   shape: BoxShape.circle,
//                 ),
//                 child: const Icon(Icons.call, color: Colors.white, size: 20),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//
//         // OTP Banner (Show ONLY before pickup)
//         if (!isOngoing) ...[
//           _OtpBanner(otp: "${order.pickupOtp}"),
//           const SizedBox(height: 14),
//         ] else ...[
//           Container(
//             padding: const EdgeInsets.all(14),
//             decoration: BoxDecoration(
//               color: _AppColors.accent.withOpacity(0.08),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: Row(
//               children: const [
//                 Icon(Icons.directions_car_rounded, color: _AppColors.accent),
//                 SizedBox(width: 12),
//                 Expanded(
//                   child: Text(
//                     "Trip in progress to drop location",
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       color: _AppColors.textPrimary,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(height: 14),
//         ],
//
//         Row(
//           children: [
//             Expanded(
//               child: OutlinedButton.icon(
//                 onPressed: onRefresh,
//                 icon: const Icon(Icons.refresh, size: 18),
//                 label: const Text("Refresh Status"),
//                 style: OutlinedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(vertical: 12),
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                 ),
//               ),
//             ),
//             if (!isOngoing) ...[
//               const SizedBox(width: 12),
//               Expanded(
//                 child: TextButton(
//                   onPressed: onCancel,
//                   style: TextButton.styleFrom(
//                     foregroundColor: _AppColors.danger,
//                     padding: const EdgeInsets.symmetric(vertical: 12),
//                   ),
//                   child: const Text(
//                     "Cancel Ride",
//                     style: TextStyle(fontWeight: FontWeight.bold),
//                   ),
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ],
//     );
//   }
// }
//
// class _OtpBanner extends StatelessWidget {
//   final String otp;
//   const _OtpBanner({required this.otp});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
//       decoration: BoxDecoration(
//         color: _AppColors.background,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(color: Colors.black12),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           const Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 "START TRIP OTP",
//                 style: TextStyle(
//                   fontSize: 11,
//                   fontWeight: FontWeight.bold,
//                   color: _AppColors.textSecondary,
//                 ),
//               ),
//               Text(
//                 "Share with captain",
//                 style: TextStyle(fontSize: 12, color: _AppColors.textSecondary),
//               ),
//             ],
//           ),
//           Row(
//             children: otp.split('').map((digit) {
//               return Container(
//                 margin: const EdgeInsets.only(left: 4),
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 10,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black,
//                   borderRadius: BorderRadius.circular(6),
//                 ),
//                 child: Text(
//                   digit,
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _SearchingView extends StatelessWidget {
//   final String statusText;
//   final AnimationController pulseController;
//   final VoidCallback onCancel;
//
//   const _SearchingView({
//     super.key,
//     required this.statusText,
//     required this.pulseController,
//     required this.onCancel,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Spacer(flex: 2),
//           SizedBox(
//             width: 140,
//             height: 140,
//             child: AnimatedBuilder(
//               animation: pulseController,
//               builder: (context, _) {
//                 return Stack(
//                   alignment: Alignment.center,
//                   children:
//                       List.generate(3, (i) {
//                         final t = (pulseController.value + i / 3) % 1.0;
//                         return Opacity(
//                           opacity: (1 - t) * 0.4,
//                           child: Container(
//                             width: 80 + t * 60,
//                             height: 80 + t * 60,
//                             decoration: const BoxDecoration(
//                               shape: BoxShape.circle,
//                               color: Colors.black,
//                             ),
//                           ),
//                         );
//                       })..add(
//                         Container(
//                           width: 70,
//                           height: 70,
//                           decoration: const BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.black,
//                           ),
//                           child: const Icon(
//                             Icons.local_taxi_rounded,
//                             color: Colors.white,
//                             size: 32,
//                           ),
//                         ),
//                       ),
//                 );
//               },
//             ),
//           ),
//           const SizedBox(height: 32),
//           Text(
//             statusText,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 22,
//               fontWeight: FontWeight.bold,
//               color: _AppColors.textPrimary,
//             ),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Connecting you with a captain nearby...",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: _AppColors.textSecondary),
//           ),
//           const Spacer(flex: 3),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: onCancel,
//               style: OutlinedButton.styleFrom(
//                 foregroundColor: _AppColors.danger,
//                 side: const BorderSide(color: _AppColors.danger, width: 1.2),
//                 padding: const EdgeInsets.symmetric(vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 "Cancel Ride",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//               ),
//             ),
//           ),
//           const SizedBox(height: 24),
//         ],
//       ),
//     );
//   }
// }
//
// class _ResultView extends StatelessWidget {
//   final IconData icon;
//   final Color iconColor;
//   final String title;
//   final String subtitle;
//
//   const _ResultView({
//     super.key,
//     required this.icon,
//     required this.iconColor,
//     required this.title,
//     required this.subtitle,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Icon(icon, size: 80, color: iconColor),
//           const SizedBox(height: 20),
//           Text(
//             title,
//             style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             subtitle,
//             textAlign: TextAlign.center,
//             style: const TextStyle(color: _AppColors.textSecondary),
//           ),
//           const SizedBox(height: 30),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton(
//               onPressed: () => Navigator.of(context).maybePop(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               child: const Text("Done", style: TextStyle(color: Colors.white)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _CancelRideSheet extends StatelessWidget {
//   final VoidCallback onConfirm;
//   const _CancelRideSheet({required this.onConfirm});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text(
//             "Cancel Ride?",
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           const Text(
//             "Are you sure you want to cancel this booking?",
//             textAlign: TextAlign.center,
//             style: TextStyle(color: _AppColors.textSecondary),
//           ),
//           const SizedBox(height: 20),
//           Row(
//             children: [
//               Expanded(
//                 child: OutlinedButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Keep Ride"),
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: ElevatedButton(
//                   onPressed: onConfirm,
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: _AppColors.danger,
//                   ),
//                   child: const Text(
//                     "Cancel",
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class _PaymentSelectionView extends StatelessWidget {
//   final OrderDetails? order;
//   final VoidCallback onCash;
//   final VoidCallback onOnline;
//
//   const _PaymentSelectionView({
//     required this.order,
//     required this.onCash,
//     required this.onOnline,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(24),
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           const Icon(Icons.check_circle, color: _AppColors.success, size: 72),
//           const SizedBox(height: 16),
//           const Text(
//             "Trip Completed",
//             style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 8),
//           Text(
//             "₹${order?.fare.toStringAsFixed(2) ?? "0.00"}",
//             style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 32),
//           SizedBox(
//             width: double.infinity,
//             child: ElevatedButton.icon(
//               onPressed: onCash,
//               icon: const Icon(Icons.money),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               label: const Text(
//                 "Pay Cash",
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//           const SizedBox(height: 12),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton.icon(
//               onPressed: onOnline,
//               icon: const Icon(Icons.payment),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(vertical: 14),
//               ),
//               label: const Text("Pay Online"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
