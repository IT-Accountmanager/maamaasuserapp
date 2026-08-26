import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Models/logistics/orderdetails.dart';
import '../../Services/Auth_service/delivery_service.dart';
import '../../Services/websockets/web_socket_manager.dart';
import 'dart:math' as math;

class _AppColors {
  static const primary = Color(0xFFB15DC6);
  static const success = Color(0xFF1FAA59);
  static const danger = Color(0xFFE0403F);
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
  String status = "SEARCHING_PARTNER";

  OrderDetails? order;
  int? userId;
  int? _orderId;
  GoogleMapController? _mapController;

  Marker? _pickupMarker;
  Marker? _dropMarker;

  bool _isAnimatingDriver = false;

  DateTime? _lastLocationUpdate;
  DateTime? _lastRouteUpdate;

  List<LatLng> _routePoints = [];

  int? _partnerId;
  late final AnimationController _pulseController;

  bool _statusSocketSubscribed = false;

  Marker? _driverMarker;

  Set<Polyline> _polylines = {};

  LatLng? _driverPosition;

  double _driverBearing = 0;

  bool _isFollowingDriver = true;

  bool _driverLocationSubscribed = false;

  DateTime? _lastDriverLocationTime;

  int? _trackingPartnerId;
  String? _trackingListenerId;

  LatLng? _pendingDriverPosition;
  double? _pendingDriverBearing;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _listenForDriver();

    _loadExistingOrder();
  }

  @override
  void dispose() {
    _stopDriverTracking();

    if (userId != null) {
      WebSocketManager().unsubscribeLogisticOrder(userId!);
    }

    if (_orderId != null) {
      WebSocketManager().unsubscribeLogisticOrderStatus(_orderId!);
    }

    _pulseController.dispose();

    super.dispose();
  }

  Future<void> _loadExistingOrder() async {
    final prefs = await SharedPreferences.getInstance();

    final activeOrderId = prefs.getInt("activeLogisticsOrderId");

    if (activeOrderId == null) {
      return;
    }

    try {
      final latestOrder = await DeliveryService.getOrderById(activeOrderId);

      if (!mounted) return;

      _orderId = latestOrder.orderId;

      setState(() {
        order = latestOrder;
        status = latestOrder.status;
      });

      debugPrint(
        "📦 Existing order loaded: "
        "${latestOrder.orderId}",
      );

      if (latestOrder.status == "PICKED_UP" ||
          latestOrder.status == "ONGOING") {
        _startDriverTracking(latestOrder);
      }

      _subscribeToOrderStatus(latestOrder.orderId);
    } catch (e) {
      debugPrint("❌ Failed to load existing order: $e");
    }
  }

  void _subscribeToOrderStatus(int orderId) {
    if (_statusSocketSubscribed && _orderId == orderId) {
      return;
    }

    _statusSocketSubscribed = true;
    _orderId = orderId;

    debugPrint("📡 Subscribing order status: $orderId");

    WebSocketManager().subscribeLogisticOrderStatus(orderId, (
      statusData,
    ) async {
      debugPrint("========== ORDER STATUS ==========");

      debugPrint(statusData.toString());

      try {
        final latest = await DeliveryService.getOrderById(orderId);

        if (!mounted) return;

        debugPrint("API STATUS = ${latest.status}");

        if (latest.status == "COMPLETED") {
          setState(() {
            order = latest;
            status = latest.status;
          });

          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              Navigator.of(context).pop();
            }
          });

          return;
        }

        setState(() {
          order = latest;
          status = latest.status;
        });

        if (latest.status == "PICKED_UP" || latest.status == "ONGOING") {
          _startDriverTracking(latest);
        }

        if (latest.status == "CANCELLED") {
          _stopDriverTracking();
        }
      } catch (e) {
        debugPrint("❌ Failed to refresh order: $e");
      }
    });
  }

  void _stopDriverTracking() {
    if (_trackingPartnerId != null) {
      WebSocketManager().unsubscribePartnerLocation(_trackingPartnerId!);
    }

    _trackingPartnerId = null;
    _driverLocationSubscribed = false;

    _pendingDriverPosition = null;
    _pendingDriverBearing = null;

    debugPrint("🛑 Driver tracking stopped");
  }

  void _startDriverTracking(OrderDetails latestOrder) {
    final partnerId = latestOrder.partnerId;

    if (partnerId == null) {
      debugPrint("⚠️ Cannot start driver tracking: partnerId is null");
      return;
    }

    // Initialize driver position from API.
    _initializeDriverPosition(latestOrder);

    // Already subscribed to this driver.
    if (_driverLocationSubscribed && _trackingPartnerId == partnerId) {
      return;
    }

    // If partner changed, clean old subscription.
    if (_trackingPartnerId != null && _trackingPartnerId != partnerId) {
      WebSocketManager().unsubscribePartnerLocation(_trackingPartnerId!);
    }

    _trackingPartnerId = partnerId;
    _driverLocationSubscribed = true;

    _trackingListenerId = "order_${latestOrder.orderId}";

    WebSocketManager().subscribePartnerLocation(
      partnerId,
      _onDriverLocation,
      listenerId: _trackingListenerId!,
    );

    debugPrint(
      "🚗 Driver tracking started | "
      "partner=$partnerId | "
      "order=${latestOrder.orderId}",
    );

    // Fit camera after map is available.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      if (_driverPosition != null) {
        _fitDriverAndDestination();
      }
    });
  }

  void _initializeDriverPosition(OrderDetails latestOrder) {
    final latitude = latestOrder.partnerLatitude;
    final longitude = latestOrder.partnerLongitude;

    if (latitude == null || longitude == null) {
      debugPrint("ℹ️ No initial driver location available");
      return;
    }

    if (latitude == 0 || longitude == 0) {
      debugPrint("⚠️ Invalid initial driver location");
      return;
    }

    final position = LatLng(latitude, longitude);

    _driverPosition = position;

    if (!mounted) return;

    setState(() {
      _driverMarker = _buildDriverMarker(position, _driverBearing);
    });
  }

  void _onDriverLocation(Map<String, dynamic> data) {
    debugPrint("🚗 DRIVER LOCATION = $data");

    final lat = double.tryParse(data["latitude"]?.toString() ?? "");

    final lng = double.tryParse(data["longitude"]?.toString() ?? "");

    if (lat == null || lng == null) {
      debugPrint("⚠️ Invalid driver coordinates");
      return;
    }

    if (lat == 0 || lng == 0) {
      return;
    }

    final newPosition = LatLng(lat, lng);

    final serverBearing = double.tryParse(data["bearing"]?.toString() ?? "");

    final bearing =
        serverBearing ?? _calculateBearing(_driverPosition, newPosition);

    _lastDriverLocationTime = DateTime.now();

    _animateDriver(newPosition, bearing);
  }

  Future<void> _animateDriver(LatLng target, double bearing) async {
    if (!mounted) return;

    // First location.
    if (_driverPosition == null) {
      _driverPosition = target;
      _driverBearing = bearing;

      setState(() {
        _driverMarker = _buildDriverMarker(target, bearing);
      });

      _fitDriverAndDestination();

      return;
    }

    // If an animation is already running,
    // keep only the newest location.
    if (_isAnimatingDriver) {
      _pendingDriverPosition = target;
      _pendingDriverBearing = bearing;
      return;
    }

    _isAnimatingDriver = true;

    try {
      LatLng start = _driverPosition!;
      LatLng destination = target;
      double currentBearing = bearing;

      while (mounted) {
        const duration = Duration(milliseconds: 1000);

        final stopwatch = Stopwatch()..start();

        while (stopwatch.elapsed < duration) {
          if (!mounted) return;

          final progress =
              stopwatch.elapsedMilliseconds / duration.inMilliseconds;

          final t = progress.clamp(0.0, 1.0);

          final lat =
              start.latitude + (destination.latitude - start.latitude) * t;

          final lng =
              start.longitude + (destination.longitude - start.longitude) * t;

          final position = LatLng(lat, lng);

          _driverPosition = position;
          _driverBearing = currentBearing;

          setState(() {
            _driverMarker = _buildDriverMarker(position, currentBearing);
          });

          // Don't animate camera every 50ms.
          // Update camera at a controlled interval.
          if (_isFollowingDriver && stopwatch.elapsedMilliseconds % 200 < 60) {
            _moveCameraToDriver(position);
          }

          await Future.delayed(const Duration(milliseconds: 50));
        }

        stopwatch.stop();

        if (!mounted) return;

        _driverPosition = destination;

        setState(() {
          _driverMarker = _buildDriverMarker(destination, currentBearing);
        });

        // A newer WebSocket location arrived
        // while we were animating.
        if (_pendingDriverPosition != null) {
          start = destination;

          destination = _pendingDriverPosition!;

          currentBearing =
              _pendingDriverBearing ?? _calculateBearing(start, destination);

          _pendingDriverPosition = null;
          _pendingDriverBearing = null;

          continue;
        }

        break;
      }
    } finally {
      _isAnimatingDriver = false;
    }
  }

  double _calculateBearing(LatLng? start, LatLng end) {
    if (start == null) {
      return _driverBearing;
    }

    final lat1 = start.latitude * math.pi / 180;
    final lat2 = end.latitude * math.pi / 180;

    final dLon = (end.longitude - start.longitude) * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2);

    final x =
        math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;

    return (bearing + 360) % 360;
  }

  Marker _buildDriverMarker(LatLng position, double bearing) {
    return Marker(
      markerId: const MarkerId('driver'),
      position: position,
      rotation: bearing,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      infoWindow: InfoWindow(title: order?.partnerName ?? 'Captain'),
    );
  }

  void _moveCameraToDriver(LatLng position) {
    if (_mapController == null || !_isFollowingDriver) {
      return;
    }

    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: 16, bearing: 0, tilt: 0),
      ),
    );
  }

  Future<void> _listenForDriver() async {
    final prefs = await SharedPreferences.getInstance();

    userId = prefs.getInt('userId') ?? 0;

    if (userId == 0) {
      debugPrint("⚠️ userId not found");
      return;
    }

    WebSocketManager().subscribeLogisticOrder(userId!, (data) async {
      debugPrint("📦 USER WS DATA = $data");

      final rawOrderId = data["orderId"];

      if (rawOrderId == null) {
        return;
      }

      final orderId = int.tryParse(rawOrderId.toString());

      if (orderId == null) {
        return;
      }

      try {
        final latestOrder = await DeliveryService.getOrderById(orderId);

        await prefs.setInt("activeLogisticsOrderId", latestOrder.orderId);

        if (!mounted) return;

        _orderId = latestOrder.orderId;

        setState(() {
          order = latestOrder;
          status = latestOrder.status;
        });

        debugPrint("API STATUS = ${latestOrder.status}");

        if (latestOrder.status == "PICKED_UP" ||
            latestOrder.status == "ONGOING") {
          _startDriverTracking(latestOrder);
        }

        _subscribeToOrderStatus(latestOrder.orderId);
      } catch (e) {
        debugPrint("❌ Failed to process order: $e");
      }
    });
  }

  void _fitDriverAndDestination() {
    if (_mapController == null || order == null || _driverPosition == null) {
      return;
    }

    final driver = _driverPosition!;

    final destination = LatLng(order!.dropLatitude, order!.dropLongitude);

    final southwest = LatLng(
      math.min(driver.latitude, destination.latitude),
      math.min(driver.longitude, destination.longitude),
    );

    final northeast = LatLng(
      math.max(driver.latitude, destination.latitude),
      math.max(driver.longitude, destination.longitude),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        80,
      ),
    );
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

  Marker _buildPickupMarker() {
    return Marker(
      markerId: const MarkerId('pickup'),
      position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
      infoWindow: InfoWindow(title: 'Pickup', snippet: order!.pickupAddress),
    );
  }

  Marker _buildDropMarker() {
    return Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(order!.dropLatitude, order!.dropLongitude),
      infoWindow: InfoWindow(title: 'Destination', snippet: order!.dropAddress),
    );
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
    // return _DriverAssignedView(
    //   key: const ValueKey("driver"),
    //   order: order,
    //   status: status,
    //   onCall: _callDriver,
    //   onCancel: _cancelRide,
    //   // onRefresh: _refreshOrderStatus,
    //   mapController: _mapController,
    //   driverMarker: _driverMarker,
    //   onMapCreated: (controller) {
    //     _mapController = controller;
    //   },
    // );

    return _DriverAssignedView(
      key: const ValueKey("driver"),

      order: order,
      status: status,

      onCall: _callDriver,
      onCancel: _cancelRide,

      mapController: _mapController,

      driverMarker: _driverMarker,

      pickupMarker: order != null ? _buildPickupMarker() : null,

      destinationMarker: order != null ? _buildDropMarker() : null,

      polylines: _polylines,
      onCameraMoveStarted: () {
        _isFollowingDriver = false;
      },

      showPickup:
          status != "PICKED_UP" && status != "ONGOING" && status != "COMPLETED",

      onRecenter: () {
        _isFollowingDriver = true;

        if (_driverPosition != null) {
          if (status == "PICKED_UP" || status == "ONGOING") {
            _fitDriverAndDestination();
          } else {
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(_driverPosition!),
            );
          }
        } else if (order != null) {
          _mapController?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(order!.pickupLatitude, order!.pickupLongitude),
            ),
          );
        }
      },

      onMapCreated: (controller) {
        _mapController = controller;

        if (_driverPosition != null &&
            (status == "PICKED_UP" || status == "ONGOING")) {
          _fitDriverAndDestination();
        }
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

  final GoogleMapController? mapController;

  final Marker? driverMarker;

  final Marker? pickupMarker;
  final Marker? destinationMarker;

  final Set<Polyline> polylines;

  final bool showPickup;

  final VoidCallback onRecenter;

  final Function(GoogleMapController) onMapCreated;
  final VoidCallback onCameraMoveStarted;

  const _DriverAssignedView({
    super.key,
    required this.order,
    required this.status,
    required this.onCall,
    required this.onCancel,
    required this.mapController,
    required this.driverMarker,
    required this.pickupMarker,
    required this.destinationMarker,
    required this.polylines,
    required this.showPickup,
    required this.onRecenter,
    required this.onMapCreated,
    required this.onCameraMoveStarted,
  });

  @override
  Widget build(BuildContext context) {
    if (order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Stack(
      children: [
        // Full Screen Map
        // Positioned.fill(
        //   child: GoogleMap(
        //     onMapCreated: onMapCreated,
        //     initialCameraPosition: CameraPosition(
        //       target: LatLng(order!.pickupLatitude, order!.pickupLongitude),
        //       zoom: 14,
        //     ),
        //     zoomControlsEnabled: false,
        //     myLocationButtonEnabled: false,
        //
        //     markers: {
        //       Marker(
        //         markerId: const MarkerId("pickup"),
        //         position: LatLng(order!.pickupLatitude, order!.pickupLongitude),
        //       ),
        //
        //
        //       if (driverMarker != null) driverMarker!,
        //     },
        //   ),
        // ),
        Positioned.fill(
          child: GoogleMap(
            onMapCreated: onMapCreated,

            initialCameraPosition: CameraPosition(
              target: LatLng(order!.pickupLatitude, order!.pickupLongitude),
              zoom: 14,
            ),

            markers: {
              if (showPickup && pickupMarker != null) pickupMarker!,

              if (destinationMarker != null) destinationMarker!,

              if (driverMarker != null) driverMarker!,
            },

            polylines: polylines,
            onCameraMoveStarted: onCameraMoveStarted,

            zoomControlsEnabled: false,
            myLocationButtonEnabled: false,
            compassEnabled: false,
            mapToolbarEnabled: false,
          ),
        ),

        // Re-center
        Positioned(
          right: 16,
          bottom: 340,
          child: FloatingActionButton.small(
            onPressed: onRecenter,
            child: const Icon(Icons.my_location),
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
