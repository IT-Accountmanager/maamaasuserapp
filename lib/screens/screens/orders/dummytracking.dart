// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import '../../../Models/delivery/fooddelivery.dart';
// import '../../../Models/food/orders_model.dart';
// import '../../../Services/Auth_service/delivery_service.dart';
// import '../../../Services/googleservices/googleapiservice.dart';
// import '../../../Services/websockets/web_socket_manager.dart';
//
// class ModernDeliveryTracking extends StatefulWidget {
//   final int orderId;
//   final OrderStatus orderStatus;
//   final DeliveryOrderModel? deliveryModel;
//   final VoidCallback? onRefresh;
//
//   const ModernDeliveryTracking({
//     Key? key,
//     required this.orderId,
//     required this.orderStatus,
//     this.deliveryModel,
//     this.onRefresh,
//   }) : super(key: key);
//
//   @override
//   State<ModernDeliveryTracking> createState() => _ModernDeliveryTrackingState();
// }
//
// class _ModernDeliveryTrackingState extends State<ModernDeliveryTracking>
//     with TickerProviderStateMixin {
//   GoogleMapController? _mapController;
//   DeliveryOrderModel? _delivery;
//
//   // ── Animations ────────────────────────────────────────────────────────────
//   late AnimationController _pulseController;
//   late AnimationController _slideController;
//   late Animation<double> _pulseAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   // ── Partner movement animation (separate controller per move) ─────────────
//   AnimationController? _moveController;
//
//   // ── Map ───────────────────────────────────────────────────────────────────
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   Marker? _partnerMarker;
//   LatLng? _lastPartnerPosition;
//   LatLng? _currentAnimatedPosition; // tracks live interpolated position
//   BitmapDescriptor? _bikeIcon;
//   BitmapDescriptor? _vendorIcon;
//   BitmapDescriptor? _customerIcon;
//
//   // ── ETA ───────────────────────────────────────────────────────────────────
//   Timer? _etaTimer;
//   Timer? _etaRefreshTimer;
//   Duration? _remainingEta;
//   bool _etaLoading = false;
//   DateTime? _orderStartTime;
//   DateTime? _estimatedArrival;
//   DateTime? _deliveredAt;
//   int? _deliveredInMinutes;
//   bool _deliveryWasEarly = false;
//   bool _deliveryWasLate = false;
//
//   // ── WebSocket subscription guard ──────────────────────────────────────────
//   bool _wsSubscribed = false;
//   int? _subscribedPartnerId;
//
//   // ── Misc ──────────────────────────────────────────────────────────────────
//   String? _googleApiKey;
//   bool _isLoading = true;
//   double _deliveryProgress = 0.0;
//   List<DeliveryStep> _deliverySteps = [];
//   // deliveryStatus? _previousStatus;
//
//   // ── Food order status (updated via food-order WebSocket) ──────────────────
//   late OrderStatus _currentOrderStatus;
//
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _currentOrderStatus = widget.orderStatus;
//     _initializeAnimations();
//     _loadDeliveryData(); // WebSocket is subscribed INSIDE here, after data loads
//     // _listenToWebSocket();
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _slideController.dispose();
//     _moveController?.dispose();
//     _etaTimer?.cancel();
//     _etaRefreshTimer?.cancel();
//     _mapController?.dispose();
//
//     if (_subscribedPartnerId != null) {
//       WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
//     }
//
//     if (_wsSubscribed) {
//       WebSocketManager().unsubscribeOrderStatus(widget.orderId);
//     }
//
//     super.dispose();
//   }
//
//   // ── Animations ────────────────────────────────────────────────────────────
//
//   bool _isStatusAhead(OrderStatus newStatus, OrderStatus currentStatus) {
//     const orderFlow = [
//       OrderStatus.pending,
//       OrderStatus.confirmed,
//       OrderStatus.processing,
//       OrderStatus.beingPrepared,
//       OrderStatus.orderIsReady,
//       OrderStatus.waitingForPickup,
//       OrderStatus.ontheway,
//       OrderStatus.completed,
//     ];
//
//     return orderFlow.indexOf(newStatus) > orderFlow.indexOf(currentStatus);
//   }
//
//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.15),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
//
//     _slideController.forward();
//   }
//
//   // ── Load data ─────────────────────────────────────────────────────────────
//
//   Future<void> _loadDeliveryData() async {
//     if (mounted) setState(() => _isLoading = true);
//
//     try {
//       _googleApiKey = await ApiKeyService.getApiKey();
//
//       _delivery =
//           widget.deliveryModel ??
//           await DeliveryOrderService.getOrder(widget.orderId);
//
//       if (_delivery != null) {
//         _orderStartTime = DateTime.now();
//
//         await _loadCustomIcons();
//         _setupDeliverySteps();
//         _setupStaticMarkers();
//         await _drawPolyline();
//
//         final partnerLat = _delivery!.deliveryPartnerLatitude;
//         final partnerLng = _delivery!.deliveryPartnerLongitude;
//
//         if (partnerLat != 0 && partnerLng != 0) {
//           final partnerPos = LatLng(partnerLat, partnerLng);
//           _lastPartnerPosition = partnerPos;
//           _currentAnimatedPosition = partnerPos;
//           _addPartnerMarker(partnerPos);
//           await _fetchRealEta(partnerPos);
//         } else {
//           await _fetchRealEta(
//             LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude),
//           );
//         }
//
//         _calculateInitialProgress();
//         _startEtaCountdown();
//         _startPeriodicEtaRefresh();
//         _checkIfAlreadyDelivered();
//
//         // Subscribe ONCE after data is ready
//         if (!_wsSubscribed) {
//           _listenToWebSocket();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading delivery data: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // ── ETA: Distance Matrix API ──────────────────────────────────────────────
//
//   Future<void> _fetchRealEta(LatLng origin) async {
//     if (_googleApiKey == null || _delivery == null) return;
//     if (_etaLoading) return;
//     if (_currentOrderStatus == OrderStatus.completed) return;
//
//     if (mounted) setState(() => _etaLoading = true);
//
//     try {
//       final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/distancematrix/json'
//         '?origins=${origin.latitude},${origin.longitude}'
//         '&destinations=${_delivery!.userLatitude},${_delivery!.userLongitude}'
//         '&mode=driving'
//         '&departure_time=now'
//         '&key=$_googleApiKey',
//       );
//
//       final response = await http.get(url).timeout(const Duration(seconds: 8));
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final elements = data['rows']?[0]?['elements']?[0];
//
//         if (elements != null && elements['status'] == 'OK') {
//           final durationSeconds =
//               (elements['duration_in_traffic'] ??
//                       elements['duration'])?['value']
//                   as int?;
//
//           if (durationSeconds != null && mounted) {
//             setState(() {
//               _remainingEta = Duration(seconds: durationSeconds);
//               _estimatedArrival = DateTime.now().add(
//                 Duration(seconds: durationSeconds),
//               );
//               _etaLoading = false;
//             });
//             return;
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Distance Matrix error: $e');
//     } finally {
//       if (mounted && _etaLoading) setState(() => _etaLoading = false);
//     }
//
//     // Fallback: straight-line ÷ 25 km/h
//     _straightLineFallback(origin);
//   }
//
//   // ── ETA: straight-line fallback ───────────────────────────────────────────
//
//   void _straightLineFallback(LatLng origin) {
//     if (_delivery == null) return;
//
//     final distance = Geolocator.distanceBetween(
//       origin.latitude,
//       origin.longitude,
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//
//     const speedMps = 6.94; // ~25 km/h
//     final etaSeconds = (distance / speedMps).round();
//
//     if (mounted) {
//       setState(() {
//         _remainingEta = Duration(seconds: etaSeconds);
//         _estimatedArrival = DateTime.now().add(Duration(seconds: etaSeconds));
//       });
//     }
//   }
//
//   // ── ETA: throttled refresh on position update ─────────────────────────────
//
//   void _updateEtaBasedOnPosition(LatLng newPosition) {
//     if (_currentOrderStatus == OrderStatus.completed) return;
//
//     // Throttle: only refresh if partner moved > 50 m
//     if (_lastPartnerPosition != null) {
//       final distance = Geolocator.distanceBetween(
//         _lastPartnerPosition!.latitude,
//         _lastPartnerPosition!.longitude,
//         newPosition.latitude,
//         newPosition.longitude,
//       );
//       if (distance < 50) return;
//     }
//
//     _fetchRealEta(newPosition);
//   }
//
//   // ── ETA: periodic refresh every 30 s ─────────────────────────────────────
//
//   void _startPeriodicEtaRefresh() {
//     _etaRefreshTimer?.cancel();
//     _etaRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
//       if (!mounted) return;
//       if (_currentOrderStatus == OrderStatus.completed) {
//         _etaRefreshTimer?.cancel();
//         return;
//       }
//
//       final partnerLat = _delivery?.deliveryPartnerLatitude ?? 0;
//       final partnerLng = _delivery?.deliveryPartnerLongitude ?? 0;
//
//       // Use live animated position if available, else stored model coords
//       final origin = (_currentAnimatedPosition != null)
//           ? _currentAnimatedPosition!
//           : (partnerLat != 0 && partnerLng != 0)
//           ? LatLng(partnerLat, partnerLng)
//           : LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude);
//
//       await _fetchRealEta(origin);
//     });
//   }
//
//   // ── ETA: 1-second countdown ───────────────────────────────────────────────
//
//   void _startEtaCountdown() {
//     _etaTimer?.cancel();
//     OrderStatus? _prevStatus;
//
//     _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//
//       // Detect transition to delivered
//       if (_currentOrderStatus == OrderStatus.completed &&
//           _prevStatus != OrderStatus.completed) {
//         _onDelivered();
//         return;
//       }
//       _prevStatus = _currentOrderStatus;
//
//       if (_remainingEta == null || _remainingEta!.inSeconds <= 0) return;
//       setState(() {
//         _remainingEta = _remainingEta! - const Duration(seconds: 1);
//       });
//     });
//   }
//
//   // ── ETA: on delivery completed ────────────────────────────────────────────
//
//   void _onDelivered() {
//     _etaTimer?.cancel();
//     _etaRefreshTimer?.cancel();
//     _moveController?.stop();
//
//     _deliveredAt = DateTime.now();
//
//     _deliveredInMinutes = _orderStartTime != null
//         ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
//         : null;
//
//     if (_estimatedArrival != null) {
//       final diff = _deliveredAt!.difference(_estimatedArrival!).inMinutes;
//       _deliveryWasEarly = diff < -2;
//       _deliveryWasLate = diff > 5;
//     }
//
//     if (mounted) {
//       setState(() {
//         _remainingEta = null;
//         _currentOrderStatus = OrderStatus.completed;
//       });
//     }
//   }
//
//   // ── ETA: already delivered when screen opens ──────────────────────────────
//
//   void _checkIfAlreadyDelivered() {
//     if (_currentOrderStatus != OrderStatus.completed) return;
//
//     _deliveredAt = DateTime.now();
//     _deliveredInMinutes = _orderStartTime != null
//         ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
//         : null;
//     _remainingEta = null;
//     _currentOrderStatus = OrderStatus.completed;
//   }
//
//   // ── Icons ─────────────────────────────────────────────────────────────────
//
//   Future<void> _loadCustomIcons() async {
//     _vendorIcon = await _createCustomMarker(Icons.store, Colors.orange, 80);
//     _customerIcon = await _createCustomMarker(Icons.home, Colors.blue, 80);
//     _bikeIcon = await _createCustomMarker(
//       Icons.delivery_dining,
//       Colors.green,
//       100,
//     );
//   }
//
//   Future<BitmapDescriptor> _createCustomMarker(
//     IconData icon,
//     Color color,
//     double size,
//   ) async {
//     final recorder = PictureRecorder();
//     final canvas = Canvas(recorder);
//     final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
//
//     textPainter.text = TextSpan(
//       text: String.fromCharCode(icon.codePoint),
//       style: TextStyle(
//         fontSize: size,
//         fontFamily: icon.fontFamily,
//         package: icon.fontPackage,
//         color: color,
//       ),
//     );
//
//     textPainter.layout();
//     textPainter.paint(canvas, Offset.zero);
//
//     final picture = recorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//
//     return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
//   }
//
//   // ── Delivery steps ────────────────────────────────────────────────────────
//
//   void _setupDeliverySteps() {
//     if (_delivery == null) return;
//     final s = _currentOrderStatus;
//
//     bool atOrPast(OrderStatus milestone) {
//       const order = [
//         OrderStatus.confirmed,
//         OrderStatus.beingPrepared,
//         OrderStatus.orderIsReady,
//         OrderStatus.waitingForPickup,
//         OrderStatus.ontheway,
//         OrderStatus.completed,
//       ];
//       return order.indexOf(s) >= order.indexOf(milestone);
//     }
//
//     _deliverySteps = [
//       DeliveryStep(
//         status: 'Order Confirmed',
//         isCompleted: true,
//         icon: Icons.check_circle,
//       ),
//       DeliveryStep(
//         status: 'Preparing',
//         isCompleted: atOrPast(OrderStatus.beingPrepared),
//         icon: Icons.restaurant,
//       ),
//       DeliveryStep(
//         status: 'Waiting for Pickup',
//         isCompleted: atOrPast(OrderStatus.waitingForPickup),
//         icon: Icons.inventory,
//       ),
//       DeliveryStep(
//         status: 'On The Way',
//         isCompleted: atOrPast(OrderStatus.ontheway),
//         icon: Icons.delivery_dining,
//       ),
//       DeliveryStep(
//         status: 'Delivered',
//         isCompleted: atOrPast(OrderStatus.completed),
//         icon: Icons.verified,
//       ),
//     ];
//   }
//
//   void _setupStaticMarkers() {
//     if (_delivery == null) return;
//
//     _markers.removeWhere(
//       (m) => m.markerId.value == 'vendor' || m.markerId.value == 'customer',
//     );
//
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('vendor'),
//         position: LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude),
//         icon:
//             _vendorIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//         infoWindow: const InfoWindow(title: 'Restaurant'),
//       ),
//     );
//
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('customer'),
//         position: LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//         icon:
//             _customerIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: const InfoWindow(title: 'Delivery Location'),
//       ),
//     );
//   }
//
//   void _addPartnerMarker(LatLng position, {double bearing = 0}) {
//     _partnerMarker = Marker(
//       markerId: const MarkerId('partner'),
//       position: position,
//       icon:
//           _bikeIcon ??
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       rotation: bearing,
//       anchor: const Offset(0.5, 0.5),
//       flat: true,
//       zIndex: 2,
//       infoWindow: const InfoWindow(title: 'Delivery Partner'),
//     );
//
//     _markers.removeWhere((m) => m.markerId.value == 'partner');
//     _markers.add(_partnerMarker!);
//
//     if (mounted) setState(() {});
//   }
//
//   // ── Partner smooth movement ───────────────────────────────────────────────
//
//   Future<void> _animatePartnerMovement(LatLng from, LatLng to) async {
//     if (!mounted) return;
//
//     // Cancel any in-progress movement animation
//     _moveController?.stop();
//     _moveController?.dispose();
//
//     final bearing = _calculateBearing(from, to);
//     const duration = Duration(milliseconds: 1800);
//
//     _moveController = AnimationController(vsync: this, duration: duration);
//
//     final latTween = Tween<double>(begin: from.latitude, end: to.latitude);
//     final lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
//
//     // Use easeInOut for natural deceleration
//     final curved = CurvedAnimation(
//       parent: _moveController!,
//       curve: Curves.easeInOut,
//     );
//
//     _moveController!.addListener(() {
//       if (!mounted) return;
//
//       final currentPos = LatLng(
//         latTween.evaluate(curved),
//         lngTween.evaluate(curved),
//       );
//
//       _currentAnimatedPosition = currentPos;
//
//       // Rebuild marker at interpolated position
//       _partnerMarker = Marker(
//         markerId: const MarkerId('partner'),
//         position: currentPos,
//         icon:
//             _bikeIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         rotation: bearing,
//         anchor: const Offset(0.5, 0.5),
//         flat: true,
//         zIndex: 2,
//         infoWindow: const InfoWindow(title: 'Delivery Partner'),
//       );
//
//       _markers.removeWhere((m) => m.markerId.value == 'partner');
//       _markers.add(_partnerMarker!);
//
//       // Update progress continuously during movement
//       _updateDeliveryProgressInternal(currentPos);
//
//       if (mounted) setState(() {});
//     });
//
//     _moveController!.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _lastPartnerPosition = to;
//         _currentAnimatedPosition = to;
//
//         // Auto-pan map to keep partner in view
//         _panMapToPartner(to);
//       }
//     });
//
//     await _moveController!.forward();
//   }
//
//   // ── Auto-pan map ──────────────────────────────────────────────────────────
//
//   void _panMapToPartner(LatLng position) {
//     _mapController?.animateCamera(CameraUpdate.newLatLng(position));
//   }
//
//   // ── Bearing calculation ───────────────────────────────────────────────────
//
//   double _calculateBearing(LatLng start, LatLng end) {
//     // Avoid calculating bearing for identical points
//     if (start.latitude == end.latitude && start.longitude == end.longitude) {
//       return 0;
//     }
//     final lat1 = start.latitude * pi / 180;
//     final lat2 = end.latitude * pi / 180;
//     final dLon = (end.longitude - start.longitude) * pi / 180;
//     final y = sin(dLon) * cos(lat2);
//     final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
//     return (atan2(y, x) * 180 / pi + 360) % 360;
//   }
//
//   // ── Polyline ──────────────────────────────────────────────────────────────
//
//   Future<void> _drawPolyline() async {
//     if (_googleApiKey == null || _delivery == null) return;
//
//     try {
//       final polylinePoints = PolylinePoints();
//       final result = await polylinePoints.getRouteBetweenCoordinates(
//         request: PolylineRequest(
//           origin: PointLatLng(
//             _delivery!.vendorLatitude,
//             _delivery!.vendorLongitude,
//           ),
//           destination: PointLatLng(
//             _delivery!.userLatitude,
//             _delivery!.userLongitude,
//           ),
//           mode: TravelMode.driving,
//         ),
//         googleApiKey: _googleApiKey!,
//       );
//
//       if (result.points.isNotEmpty) {
//         final points = result.points
//             .map((p) => LatLng(p.latitude, p.longitude))
//             .toList();
//
//         _polylines
//           ..removeWhere(
//             (p) =>
//                 p.polylineId.value == 'route' ||
//                 p.polylineId.value == 'route_solid',
//           )
//           ..add(
//             Polyline(
//               polylineId: const PolylineId('route'),
//               color: Colors.blue.shade300,
//               width: 5,
//               points: points,
//               patterns: [PatternItem.dash(20), PatternItem.gap(10)],
//             ),
//           )
//           ..add(
//             Polyline(
//               polylineId: const PolylineId('route_solid'),
//               color: Colors.blue.withOpacity(0.4),
//               width: 2,
//               points: points,
//             ),
//           );
//
//         if (mounted) setState(() {});
//       }
//     } catch (e) {
//       debugPrint('Error drawing polyline: $e');
//     }
//   }
//
//   // ── Progress ──────────────────────────────────────────────────────────────
//
//   void _updateDeliveryProgressInternal(LatLng partnerPosition) {
//     if (_delivery == null) return;
//
//     final total = Geolocator.distanceBetween(
//       _delivery!.vendorLatitude,
//       _delivery!.vendorLongitude,
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//
//     if (total == 0) return;
//
//     final covered = Geolocator.distanceBetween(
//       _delivery!.vendorLatitude,
//       _delivery!.vendorLongitude,
//       partnerPosition.latitude,
//       partnerPosition.longitude,
//     );
//
//     _deliveryProgress = (covered / total).clamp(0.0, 1.0);
//   }
//
//   void _updateDeliveryProgress(LatLng partnerPosition) {
//     _updateDeliveryProgressInternal(partnerPosition);
//     if (mounted) setState(() {});
//   }
//
//   void _calculateInitialProgress() {
//     if (_lastPartnerPosition == null) return;
//     _updateDeliveryProgress(_lastPartnerPosition!);
//   }
//
//   // ── Refresh ───────────────────────────────────────────────────────────────
//
//   Future<void> _refreshDeliveryData() async {
//     if (!mounted) return;
//
//     final updated = await DeliveryOrderService.getOrder(widget.orderId);
//     if (updated == null) return;
//
//     final wasDelivered =
//         _currentOrderStatus != OrderStatus.completed &&
//         updated.status == OrderStatus.completed;
//
//     setState(() {
//       _delivery = updated;
//
//       // ❗ DO NOT override websocket status blindly
//       if (_currentOrderStatus != OrderStatus.completed &&
//           _currentOrderStatus != OrderStatus.cancelled) {
//         // {
//         //   _currentOrderStatus = updated.status;
//         // }
//         _setupDeliverySteps();
//       }
//     });
//
//     // ✅ resubscribe ONLY if partner changed
//     if (updated.partnerId != _subscribedPartnerId) {
//       _listenToWebSocket();
//     }
//
//     if (wasDelivered) _onDelivered();
//
//     widget.onRefresh?.call();
//   }
//
//   // ── ETA display string ────────────────────────────────────────────────────
//
//   String get _formattedEta {
//     if (_etaLoading && _remainingEta == null) return 'Calculating...';
//     if (_remainingEta == null) return '--';
//     if (_remainingEta!.inSeconds <= 0) return 'Arriving soon';
//
//     final hours = _remainingEta!.inHours;
//     final minutes = _remainingEta!.inMinutes.remainder(60);
//
//     if (hours > 0) return '${hours}h ${minutes}min';
//     if (_remainingEta!.inMinutes < 1) return 'Arriving soon';
//     return '${_remainingEta!.inMinutes} min';
//   }
//
//   void _listenToWebSocket() {
//     debugPrint("📡 WS INIT CALLED");
//
//     if (_delivery == null) {
//       debugPrint("❌ Delivery is NULL, skipping WS setup");
//       return;
//     }
//
//     // ==========================
//     // ORDER STATUS SUBSCRIPTION
//     // ==========================
//     if (!_wsSubscribed) {
//       _wsSubscribed = true;
//
//       WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
//         if (!mounted) return;
//
//         final newStatus = OrderStatus.fromString(data['status']);
//
//         debugPrint("🔥 WS STATUS: ${data['status']} → $newStatus");
//
//         if (newStatus == _currentOrderStatus) return;
//
//         setState(() {
//           _currentOrderStatus = newStatus;
//           _setupDeliverySteps();
//         });
//
//         // refresh only for final states
//         if (newStatus == OrderStatus.completed ||
//             newStatus == OrderStatus.cancelled) {
//           _refreshDeliveryData();
//         }
//       });
//     } else {
//       debugPrint("⏭️ ORDER WS already subscribed");
//     }
//
//     // ==========================
//     // PARTNER LOCATION SUBSCRIPTION
//     // ==========================
//     final partnerId = _delivery!.partnerId;
//
//     debugPrint("👤 Current Partner ID: $partnerId");
//
//     if (partnerId == null) {
//       debugPrint("❌ Partner ID is NULL, skipping location WS");
//       return;
//     }
//
//     if (_subscribedPartnerId == partnerId) {
//       debugPrint("⏭️ Already subscribed to this partner ($partnerId)");
//       return;
//     }
//
//     // unsubscribe old partner
//     if (_subscribedPartnerId != null) {
//       debugPrint("🔴 Unsubscribing old partner: $_subscribedPartnerId");
//       WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
//     }
//
//     _subscribedPartnerId = partnerId;
//
//     debugPrint("🟢 Subscribing to PARTNER LOCATION: $partnerId");
//
//     WebSocketManager().subscribePartnerLocation(partnerId, (data) {
//       debugPrint("📍 LOCATION WS DATA: $data");
//
//       if (!mounted) {
//         debugPrint("❌ Widget not mounted, ignoring LOCATION update");
//         return;
//       }
//
//       final lat = (data['latitude'] as num?)?.toDouble();
//       final lng = (data['longitude'] as num?)?.toDouble();
//
//       debugPrint("📌 Parsed LatLng: lat=$lat, lng=$lng");
//
//       if (lat == null || lng == null) {
//         debugPrint("❌ Invalid coordinates, skipping");
//         return;
//       }
//
//       final newPosition = LatLng(lat, lng);
//
//       if (_lastPartnerPosition != null) {
//         debugPrint(
//           "🚗 Animating movement from $_lastPartnerPosition → $newPosition",
//         );
//         _animatePartnerMovement(_lastPartnerPosition!, newPosition);
//       } else {
//         debugPrint("📍 First location received, placing marker");
//
//         _lastPartnerPosition = newPosition;
//         _currentAnimatedPosition = newPosition;
//
//         _addPartnerMarker(newPosition);
//       }
//
//       debugPrint("⏱️ Updating ETA & progress");
//       _updateEtaBasedOnPosition(newPosition);
//       _updateDeliveryProgress(newPosition);
//     });
//   }
//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     if (_currentOrderStatus == OrderStatus.cancelled) {
//       return const SizedBox.shrink();
//     }
//
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 300),
//       child: _isLoading ? _buildShimmerLoading() : _buildDeliveryTracking(),
//     );
//   }
//
//   Widget _buildShimmerLoading() {
//     return Container(
//       height: 200,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//     );
//   }
//
//   Widget _buildDeliveryTracking() {
//     return SlideTransition(
//       position: _slideAnimation,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             _buildStatusHeader(),
//
//             // Live map — only while in transit
//             if (_currentOrderStatus == OrderStatus.ontheway)
//               _buildProgressMap(),
//
//             // Timeline — hidden after delivered
//             // if (_currentOrderStatus != OrderStatus.completed) _buildTimeline(),
//             _buildPartnerInfo(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Status header (includes ETA badge + delivered state) ──────────────────
//
//   Widget _buildStatusHeader() {
//     final isDelivered = _currentOrderStatus == OrderStatus.completed;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _getStatusColor(),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           ScaleTransition(
//             scale: _pulseAnimation,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(_getStatusIcon(), color: Colors.white, size: 28),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _getStatusTitle(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _getStatusSubtitle(),
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 13,
//                   ),
//                 ),
//                 // Delivered early/ontime/late badge inline
//                 if (isDelivered) ...[
//                   const SizedBox(height: 6),
//                   _buildDeliveryBadge(),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//
//           // ETA badge — shown while not yet delivered
//           if (!isDelivered) ...[
//             if (_etaLoading && _remainingEta == null)
//               const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             else if (_remainingEta != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'ETA',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       _formattedEta,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//
//           // Delivered: show minutes circle
//           if (isDelivered && _deliveredInMinutes != null)
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.4),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     '${_deliveredInMinutes}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       height: 1,
//                     ),
//                   ),
//                   Text(
//                     'min',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.85),
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeliveryBadge() {
//     final String label;
//     final Color color;
//
//     if (_deliveryWasEarly) {
//       label = '🚀 Early!';
//       color = const Color(0xFF1565C0);
//     } else if (_deliveryWasLate) {
//       label = '⏰ Late';
//       color = Colors.orange.shade700;
//     } else {
//       label = '✅ On Time';
//       color = const Color(0xFF2E7D32);
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.completed:
//         return Colors.green.shade700;
//       case OrderStatus.ontheway:
//         return Colors.blue;
//       case OrderStatus.waitingForPickup:
//         return Colors.orange;
//       default:
//         return Colors.purple;
//     }
//   }
//
//   IconData _getStatusIcon() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.completed:
//         return Icons.verified;
//       case OrderStatus.ontheway:
//         return Icons.delivery_dining;
//       case OrderStatus.waitingForPickup:
//         return Icons.inventory;
//       case OrderStatus.beingPrepared:
//         return Icons.restaurant;
//       default:
//         return Icons.pending;
//     }
//   }
//
//   String _getStatusTitle() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.pending:
//         return 'Order Pending';
//
//       case OrderStatus.confirmed:
//         return 'Order Confirmed';
//
//       case OrderStatus.processing:
//         return 'Processing Order';
//
//       case OrderStatus.beingPrepared:
//         return 'Preparing';
//
//       case OrderStatus.orderIsReady:
//         return 'Order Ready';
//
//       case OrderStatus.waitingForPickup:
//         return 'Waiting for Pickup';
//
//       case OrderStatus.ontheway:
//         return 'On The Way';
//
//       case OrderStatus.completed:
//         return 'Order Delivered! 🎉';
//
//       case OrderStatus.cancelled:
//         return 'Order Cancelled';
//
//       case OrderStatus.hold:
//         return 'On Hold';
//
//       case OrderStatus.unknown:
//         return 'Updating status...';
//
//       default:
//         return 'Processing your order';
//     }
//   }
//
//   String _getStatusSubtitle() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.pending:
//         return 'Waiting for confirmation';
//
//       case OrderStatus.confirmed:
//         return 'Restaurant confirmed your order';
//
//       case OrderStatus.processing:
//         return 'Order is being processed';
//
//       case OrderStatus.beingPrepared:
//         return 'Restaurant is preparing your food';
//
//       case OrderStatus.orderIsReady:
//         return 'Order is ready for pickup';
//
//       case OrderStatus.waitingForPickup:
//         return 'Delivery partner is assigned';
//
//       case OrderStatus.ontheway:
//         return 'Your food is on the way';
//
//       case OrderStatus.completed:
//         return _deliveredInMinutes != null
//             ? 'Delivered in $_deliveredInMinutes min'
//             : 'Delivered successfully';
//
//       case OrderStatus.cancelled:
//         return 'Order was cancelled';
//
//       case OrderStatus.hold:
//         return 'Order is on hold';
//
//       case OrderStatus.unknown:
//         return 'Fetching latest status...';
//
//       default:
//         return 'Processing your order';
//     }
//   }
//
//   // ── Progress map ──────────────────────────────────────────────────────────
//
//   Widget _buildProgressMap() {
//     final initialTarget =
//         _currentAnimatedPosition ??
//         _lastPartnerPosition ??
//         LatLng(
//           _delivery?.vendorLatitude ?? 17.385044,
//           _delivery?.vendorLongitude ?? 78.486671,
//         );
//
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => FullScreenMapPage(
//             markers: Set.from(_markers),
//             polylines: Set.from(_polylines),
//             etaText: _formattedEta,
//           ),
//         ),
//       ),
//       child: Container(
//         height: 160,
//         margin: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: initialTarget,
//                   zoom: 14,
//                 ),
//                 markers: _markers,
//                 polylines: _polylines,
//                 zoomControlsEnabled: false,
//                 myLocationEnabled: false,
//                 compassEnabled: false,
//                 scrollGesturesEnabled: false,
//                 zoomGesturesEnabled: false,
//                 rotateGesturesEnabled: false,
//                 tiltGesturesEnabled: false,
//                 onMapCreated: (c) {
//                   _mapController = c;
//                   // Fit bounds to show vendor → customer
//                   _fitMapBounds();
//                 },
//                 gestureRecognizers: {
//                   Factory<OneSequenceGestureRecognizer>(
//                     () => EagerGestureRecognizer(),
//                   ),
//                 },
//               ),
//
//               // Gradient overlay at bottom
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Colors.black.withOpacity(0.65),
//                       ],
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.directions_bike,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       const Expanded(
//                         child: Text(
//                           'Tap to view full map',
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
//                       ),
//                       Container(
//                         padding: const EdgeInsets.symmetric(
//                           horizontal: 8,
//                           vertical: 4,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.white,
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         child: Text(
//                           '${(_deliveryProgress * 100).toInt()}%',
//                           style: const TextStyle(
//                             fontSize: 11,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
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
//
//   // ── Fit map to show vendor + customer bounds ───────────────────────────────
//
//   void _fitMapBounds() {
//     if (_delivery == null || _mapController == null) return;
//
//     final vendorLat = _delivery!.vendorLatitude;
//     final vendorLng = _delivery!.vendorLongitude;
//     final userLat = _delivery!.userLatitude;
//     final userLng = _delivery!.userLongitude;
//
//     final bounds = LatLngBounds(
//       southwest: LatLng(min(vendorLat, userLat), min(vendorLng, userLng)),
//       northeast: LatLng(max(vendorLat, userLat), max(vendorLng, userLng)),
//     );
//
//     _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   }
//
//   // ── Timeline ──────────────────────────────────────────────────────────────
//
//   Widget _buildTimeline() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Delivery Timeline',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           ..._deliverySteps.map((s) => _buildTimelineStep(s)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimelineStep(DeliveryStep step) {
//     final isLast = _deliverySteps.last == step;
//
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 40,
//             child: Column(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: step.isCompleted
//                         ? Colors.green
//                         : Colors.grey.shade300,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     step.isCompleted ? Icons.check : step.icon,
//                     color: Colors.white,
//                     size: 14,
//                   ),
//                 ),
//                 // NOTE: Expanded cannot be used inside a Column that is itself
//                 // inside IntrinsicHeight — it creates competing ParentData.
//                 // Instead, use a plain Container that fills the remaining space
//                 // via the Column's default stretch behaviour under IntrinsicHeight.
//                 if (!isLast)
//                   Flexible(
//                     child: Container(
//                       width: 2,
//                       color: step.isCompleted
//                           ? Colors.green
//                           : Colors.grey.shade300,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 16),
//               child: Text(
//                 step.status,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: step.isCompleted
//                       ? FontWeight.w600
//                       : FontWeight.normal,
//                   color: step.isCompleted ? Colors.black87 : Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Partner info ──────────────────────────────────────────────────────────
//
//   Widget _buildPartnerInfo() {
//     if (_delivery?.deliveryPartnerName.isEmpty ?? true) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.green.shade100,
//             child: const Icon(Icons.person, color: Colors.green, size: 28),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _delivery!.deliveryPartnerName,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Vehicle: ${_delivery!.vehicleStatus.name.replaceAll('_', ' ')}',
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'OTP: ${_delivery?.userOtp.toString() ?? '0'}',
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Helper classes ────────────────────────────────────────────────────────────
//
// class DeliveryStep {
//   final String status;
//   final bool isCompleted;
//   final IconData icon;
//
//   DeliveryStep({
//     required this.status,
//     required this.isCompleted,
//     required this.icon,
//   });
// }
//
// // ── Full screen map ───────────────────────────────────────────────────────────
//
// class FullScreenMapPage extends StatefulWidget {
//   final Set<Marker> markers;
//   final Set<Polyline> polylines;
//   final String etaText;
//
//   const FullScreenMapPage({
//     Key? key,
//     required this.markers,
//     required this.polylines,
//     required this.etaText,
//   }) : super(key: key);
//
//   @override
//   State<FullScreenMapPage> createState() => _FullScreenMapPageState();
// }
//
// class _FullScreenMapPageState extends State<FullScreenMapPage> {
//   GoogleMapController? _controller;
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   LatLng get _initialTarget {
//     final partner = widget.markers
//         .where((m) => m.markerId.value == 'partner')
//         .toList();
//     if (partner.isNotEmpty) return partner.first.position;
//     if (widget.markers.isNotEmpty) return widget.markers.first.position;
//     return const LatLng(17.385044, 78.486671);
//   }
//
//   void _fitBounds() {
//     if (_controller == null || widget.markers.length < 2) return;
//
//     double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
//     for (final m in widget.markers) {
//       minLat = min(minLat, m.position.latitude);
//       maxLat = max(maxLat, m.position.latitude);
//       minLng = min(minLng, m.position.longitude);
//       maxLng = max(maxLng, m.position.longitude);
//     }
//
//     _controller!.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(minLat, minLng),
//           northeast: LatLng(maxLat, maxLng),
//         ),
//         80,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _initialTarget,
//               zoom: 15,
//             ),
//             markers: widget.markers,
//             polylines: widget.polylines,
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             compassEnabled: true,
//             trafficEnabled: false,
//             buildingsEnabled: true,
//             onMapCreated: (c) {
//               _controller = c;
//               // Fit all markers into view
//               Future.delayed(const Duration(milliseconds: 300), _fitBounds);
//             },
//           ),
//
//           // Close button
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             left: 16,
//             child: Material(
//               shape: const CircleBorder(),
//               elevation: 4,
//               child: InkWell(
//                 customBorder: const CircleBorder(),
//                 onTap: () => Navigator.pop(context),
//                 child: const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Icon(Icons.close, size: 22),
//                 ),
//               ),
//             ),
//           ),
//
//           // ETA chip
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withOpacity(0.35),
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'ETA: ${widget.etaText}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:ui' as ui;
// import 'dart:ui';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import '../../../Models/delivery/fooddelivery.dart';
// import '../../../Models/food/orders_model.dart';
// import '../../../Services/Auth_service/delivery_service.dart';
// import '../../../Services/googleservices/googleapiservice.dart';
// import '../../../Services/websockets/web_socket_manager.dart';
//
// class ModernDeliveryTracking extends StatefulWidget {
//   final int orderId;
//   final OrderStatus orderStatus;
//   final DeliveryOrderModel? deliveryModel;
//   final VoidCallback? onRefresh;
//
//   const ModernDeliveryTracking({
//     Key? key,
//     required this.orderId,
//     required this.orderStatus,
//     this.deliveryModel,
//     this.onRefresh,
//   }) : super(key: key);
//
//   @override
//   State<ModernDeliveryTracking> createState() => _ModernDeliveryTrackingState();
// }
//
// class _ModernDeliveryTrackingState extends State<ModernDeliveryTracking>
//     with TickerProviderStateMixin {
//   GoogleMapController? _mapController;
//   DeliveryOrderModel? _delivery;
//
//   // ── Animations ────────────────────────────────────────────────────────────
//   late AnimationController _pulseController;
//   late AnimationController _slideController;
//   late Animation<double> _pulseAnimation;
//   late Animation<Offset> _slideAnimation;
//
//   // ── Partner movement animation ─────────────────────────────────────────────
//   AnimationController? _moveController;
//
//   // ── Map ───────────────────────────────────────────────────────────────────
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   Marker? _partnerMarker;
//   LatLng? _lastPartnerPosition;
//   LatLng? _currentAnimatedPosition;
//   double _currentBearing = 0.0; // FIX 1: track current bearing
//   BitmapDescriptor? _bikeIcon;
//   BitmapDescriptor? _vendorIcon;
//   BitmapDescriptor? _customerIcon;
//
//   // ── FIX 3: StreamController to push live state to FullScreenMapPage ────────
//   final StreamController<_LiveMapState> _liveMapStream =
//       StreamController<_LiveMapState>.broadcast();
//
//   // ── ETA ───────────────────────────────────────────────────────────────────
//   Timer? _etaTimer;
//   Timer? _etaRefreshTimer;
//   Duration? _remainingEta;
//   bool _etaLoading = false;
//   DateTime? _orderStartTime;
//   DateTime? _estimatedArrival;
//   DateTime? _deliveredAt;
//   int? _deliveredInMinutes;
//   bool _deliveryWasEarly = false;
//   bool _deliveryWasLate = false;
//
//   // ── WebSocket subscription guard ──────────────────────────────────────────
//   bool _wsSubscribed = false;
//   int? _subscribedPartnerId;
//
//   // ── Misc ──────────────────────────────────────────────────────────────────
//   String? _googleApiKey;
//   bool _isLoading = true;
//   double _deliveryProgress = 0.0;
//   List<DeliveryStep> _deliverySteps = [];
//
//   // ── Food order status ──────────────────────────────────────────────────────
//   late OrderStatus _currentOrderStatus;
//
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   void initState() {
//     super.initState();
//     _currentOrderStatus = widget.orderStatus;
//     _initializeAnimations();
//     _loadDeliveryData();
//   }
//
//   @override
//   void dispose() {
//     _pulseController.dispose();
//     _slideController.dispose();
//     _moveController?.dispose();
//     _etaTimer?.cancel();
//     _etaRefreshTimer?.cancel();
//     _mapController?.dispose();
//     _liveMapStream.close(); // FIX 3: close stream
//
//     if (_subscribedPartnerId != null) {
//       WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
//     }
//
//     if (_wsSubscribed) {
//       WebSocketManager().unsubscribeOrderStatus(widget.orderId);
//     }
//
//     super.dispose();
//   }
//
//   // ── Helpers ────────────────────────────────────────────────────────────────
//
//   bool _isStatusAhead(OrderStatus newStatus, OrderStatus currentStatus) {
//     const orderFlow = [
//       OrderStatus.pending,
//       OrderStatus.confirmed,
//       OrderStatus.processing,
//       OrderStatus.beingPrepared,
//       OrderStatus.orderIsReady,
//       OrderStatus.waitingForPickup,
//       OrderStatus.ontheway,
//       OrderStatus.completed,
//     ];
//     return orderFlow.indexOf(newStatus) > orderFlow.indexOf(currentStatus);
//   }
//
//   // ── Push live state to full-screen map ────────────────────────────────────
//
//   void _pushLiveState() {
//     if (!_liveMapStream.isClosed) {
//       _liveMapStream.add(
//         _LiveMapState(
//           markers: Set.from(_markers),
//           polylines: Set.from(_polylines),
//           etaText: _formattedEta,
//           partnerPosition: _currentAnimatedPosition,
//           bearing: _currentBearing,
//         ),
//       );
//     }
//   }
//
//   // ── Animations ────────────────────────────────────────────────────────────
//
//   void _initializeAnimations() {
//     _pulseController = AnimationController(
//       duration: const Duration(milliseconds: 1500),
//       vsync: this,
//     )..repeat(reverse: true);
//
//     _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
//       CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
//     );
//
//     _slideController = AnimationController(
//       duration: const Duration(milliseconds: 400),
//       vsync: this,
//     );
//
//     _slideAnimation = Tween<Offset>(
//       begin: const Offset(0, 0.15),
//       end: Offset.zero,
//     ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));
//
//     _slideController.forward();
//   }
//
//   // ── Load data ─────────────────────────────────────────────────────────────
//
//   Future<void> _loadDeliveryData() async {
//     if (mounted) setState(() => _isLoading = true);
//
//     try {
//       _googleApiKey = await ApiKeyService.getApiKey();
//
//       _delivery =
//           widget.deliveryModel ??
//           await DeliveryOrderService.getOrder(widget.orderId);
//
//       if (_delivery != null) {
//         _orderStartTime = DateTime.now();
//
//         await _loadCustomIcons();
//         _setupDeliverySteps();
//         _setupStaticMarkers();
//         await _drawPolyline(); // FIX 2: will draw correct route
//
//         final partnerLat = _delivery!.deliveryPartnerLatitude;
//         final partnerLng = _delivery!.deliveryPartnerLongitude;
//
//         if (partnerLat != 0 && partnerLng != 0) {
//           final partnerPos = LatLng(partnerLat, partnerLng);
//           _lastPartnerPosition = partnerPos;
//           _currentAnimatedPosition = partnerPos;
//           _addPartnerMarker(partnerPos, bearing: 0);
//           await _fetchRealEta(partnerPos);
//         } else {
//           await _fetchRealEta(
//             LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude),
//           );
//         }
//
//         _calculateInitialProgress();
//         _startEtaCountdown();
//         _startPeriodicEtaRefresh();
//         _checkIfAlreadyDelivered();
//
//         if (!_wsSubscribed) {
//           _listenToWebSocket();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error loading delivery data: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   // ── ETA: Distance Matrix API ──────────────────────────────────────────────
//
//   Future<void> _fetchRealEta(LatLng origin) async {
//     if (_googleApiKey == null || _delivery == null) return;
//     if (_etaLoading) return;
//     if (_currentOrderStatus == OrderStatus.completed) return;
//
//     if (mounted) setState(() => _etaLoading = true);
//
//     try {
//       final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/distancematrix/json'
//         '?origins=${origin.latitude},${origin.longitude}'
//         '&destinations=${_delivery!.userLatitude},${_delivery!.userLongitude}'
//         '&mode=driving'
//         '&departure_time=now'
//         '&key=$_googleApiKey',
//       );
//
//       final response = await http.get(url).timeout(const Duration(seconds: 8));
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final elements = data['rows']?[0]?['elements']?[0];
//
//         if (elements != null && elements['status'] == 'OK') {
//           final durationSeconds =
//               (elements['duration_in_traffic'] ??
//                       elements['duration'])?['value']
//                   as int?;
//
//           if (durationSeconds != null && mounted) {
//             setState(() {
//               _remainingEta = Duration(seconds: durationSeconds);
//               _estimatedArrival = DateTime.now().add(
//                 Duration(seconds: durationSeconds),
//               );
//               _etaLoading = false;
//             });
//             _pushLiveState(); // FIX 3: push updated ETA
//             return;
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Distance Matrix error: $e');
//     } finally {
//       if (mounted && _etaLoading) setState(() => _etaLoading = false);
//     }
//
//     _straightLineFallback(origin);
//   }
//
//   void _straightLineFallback(LatLng origin) {
//     if (_delivery == null) return;
//
//     final distance = Geolocator.distanceBetween(
//       origin.latitude,
//       origin.longitude,
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//
//     const speedMps = 6.94;
//     final etaSeconds = (distance / speedMps).round();
//
//     if (mounted) {
//       setState(() {
//         _remainingEta = Duration(seconds: etaSeconds);
//         _estimatedArrival = DateTime.now().add(Duration(seconds: etaSeconds));
//       });
//       _pushLiveState();
//     }
//   }
//
//   void _updateEtaBasedOnPosition(LatLng newPosition) {
//     if (_currentOrderStatus == OrderStatus.completed) return;
//
//     if (_lastPartnerPosition != null) {
//       final distance = Geolocator.distanceBetween(
//         _lastPartnerPosition!.latitude,
//         _lastPartnerPosition!.longitude,
//         newPosition.latitude,
//         newPosition.longitude,
//       );
//       if (distance < 50) return;
//     }
//
//     _fetchRealEta(newPosition);
//   }
//
//   void _startPeriodicEtaRefresh() {
//     _etaRefreshTimer?.cancel();
//     _etaRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
//       if (!mounted) return;
//       if (_currentOrderStatus == OrderStatus.completed) {
//         _etaRefreshTimer?.cancel();
//         return;
//       }
//
//       final partnerLat = _delivery?.deliveryPartnerLatitude ?? 0;
//       final partnerLng = _delivery?.deliveryPartnerLongitude ?? 0;
//
//       final origin = (_currentAnimatedPosition != null)
//           ? _currentAnimatedPosition!
//           : (partnerLat != 0 && partnerLng != 0)
//           ? LatLng(partnerLat, partnerLng)
//           : LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude);
//
//       await _fetchRealEta(origin);
//     });
//   }
//
//   void _startEtaCountdown() {
//     _etaTimer?.cancel();
//     OrderStatus? _prevStatus;
//
//     _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//
//       if (_currentOrderStatus == OrderStatus.completed &&
//           _prevStatus != OrderStatus.completed) {
//         _onDelivered();
//         return;
//       }
//       _prevStatus = _currentOrderStatus;
//
//       if (_remainingEta == null || _remainingEta!.inSeconds <= 0) return;
//       setState(() {
//         _remainingEta = _remainingEta! - const Duration(seconds: 1);
//       });
//     });
//   }
//
//   void _onDelivered() {
//     _etaTimer?.cancel();
//     _etaRefreshTimer?.cancel();
//     _moveController?.stop();
//
//     _deliveredAt = DateTime.now();
//
//     _deliveredInMinutes = _orderStartTime != null
//         ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
//         : null;
//
//     if (_estimatedArrival != null) {
//       final diff = _deliveredAt!.difference(_estimatedArrival!).inMinutes;
//       _deliveryWasEarly = diff < -2;
//       _deliveryWasLate = diff > 5;
//     }
//
//     if (mounted) {
//       setState(() {
//         _remainingEta = null;
//         _currentOrderStatus = OrderStatus.completed;
//       });
//     }
//   }
//
//   void _checkIfAlreadyDelivered() {
//     if (_currentOrderStatus != OrderStatus.completed) return;
//
//     _deliveredAt = DateTime.now();
//     _deliveredInMinutes = _orderStartTime != null
//         ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
//         : null;
//     _remainingEta = null;
//     _currentOrderStatus = OrderStatus.completed;
//   }
//
//   // ── Icons ─────────────────────────────────────────────────────────────────
//
//   Future<void> _loadCustomIcons() async {
//     _vendorIcon = await _createCustomMarker(Icons.store, Colors.orange, 80);
//     _customerIcon = await _createCustomMarker(Icons.home, Colors.blue, 80);
//     // FIX 1: Use directional arrow icon so rotation is visible
//     _bikeIcon = await _createDirectionalBikeIcon();
//   }
//
//   /// FIX 1: Creates a bike marker with a built-in direction arrow.
//   /// The arrow points "up" (north) by default; rotation: bearing rotates it.
//   Future<BitmapDescriptor> _createDirectionalBikeIcon() async {
//     const double size = 120;
//     final recorder = PictureRecorder();
//     final canvas = Canvas(recorder);
//     final center = Offset(size / 2, size / 2);
//
//     // Outer circle (shadow)
//     canvas.drawCircle(
//       center,
//       size / 2 - 4,
//       Paint()
//         ..color = Colors.black.withOpacity(0.18)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
//     );
//
//     // Green filled circle
//     canvas.drawCircle(
//       center,
//       size / 2 - 8,
//       Paint()..color = Colors.green.shade600,
//     );
//
//     // White border
//     canvas.drawCircle(
//       center,
//       size / 2 - 8,
//       Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 4,
//     );
//
//     // Bike icon (centered)
//     final bikeText = TextPainter(textDirection: TextDirection.ltr);
//     bikeText.text = TextSpan(
//       text: String.fromCharCode(Icons.delivery_dining.codePoint),
//       style: TextStyle(
//         fontSize: 48,
//         fontFamily: Icons.delivery_dining.fontFamily,
//         package: Icons.delivery_dining.fontPackage,
//         color: Colors.white,
//       ),
//     );
//     bikeText.layout();
//     bikeText.paint(
//       canvas,
//       Offset(center.dx - bikeText.width / 2, center.dy - bikeText.height / 2),
//     );
//
//     // Direction arrow at top — points forward (up = bearing direction)
//     final arrowPaint = Paint()
//       ..color = Colors.white
//       ..style = PaintingStyle.fill;
//
//     final arrowPath = Path()
//       ..moveTo(center.dx, 6) // tip
//       ..lineTo(center.dx - 9, 22)
//       ..lineTo(center.dx + 9, 22)
//       ..close();
//     canvas.drawPath(arrowPath, arrowPaint);
//
//     final picture = recorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//
//     return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
//   }
//
//   Future<BitmapDescriptor> _createCustomMarker(
//     IconData icon,
//     Color color,
//     double size,
//   ) async {
//     final recorder = PictureRecorder();
//     final canvas = Canvas(recorder);
//     final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
//
//     textPainter.text = TextSpan(
//       text: String.fromCharCode(icon.codePoint),
//       style: TextStyle(
//         fontSize: size,
//         fontFamily: icon.fontFamily,
//         package: icon.fontPackage,
//         color: color,
//       ),
//     );
//
//     textPainter.layout();
//     textPainter.paint(canvas, Offset.zero);
//
//     final picture = recorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//
//     return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
//   }
//
//   // ── Delivery steps ────────────────────────────────────────────────────────
//
//   void _setupDeliverySteps() {
//     if (_delivery == null) return;
//     final s = _currentOrderStatus;
//
//     bool atOrPast(OrderStatus milestone) {
//       const order = [
//         OrderStatus.confirmed,
//         OrderStatus.beingPrepared,
//         OrderStatus.orderIsReady,
//         OrderStatus.waitingForPickup,
//         OrderStatus.ontheway,
//         OrderStatus.completed,
//       ];
//       return order.indexOf(s) >= order.indexOf(milestone);
//     }
//
//     _deliverySteps = [
//       DeliveryStep(
//         status: 'Order Confirmed',
//         isCompleted: true,
//         icon: Icons.check_circle,
//       ),
//       DeliveryStep(
//         status: 'Preparing',
//         isCompleted: atOrPast(OrderStatus.beingPrepared),
//         icon: Icons.restaurant,
//       ),
//       DeliveryStep(
//         status: 'Waiting for Pickup',
//         isCompleted: atOrPast(OrderStatus.waitingForPickup),
//         icon: Icons.inventory,
//       ),
//       DeliveryStep(
//         status: 'On The Way',
//         isCompleted: atOrPast(OrderStatus.ontheway),
//         icon: Icons.delivery_dining,
//       ),
//       DeliveryStep(
//         status: 'Delivered',
//         isCompleted: atOrPast(OrderStatus.completed),
//         icon: Icons.verified,
//       ),
//     ];
//   }
//
//   void _setupStaticMarkers() {
//     if (_delivery == null) return;
//
//     _markers.removeWhere(
//       (m) => m.markerId.value == 'vendor' || m.markerId.value == 'customer',
//     );
//
//     // FIX 2: Only show vendor marker when NOT ontheway
//     // When ontheway, we show partner→customer route, so vendor marker is hidden
//     if (_currentOrderStatus != OrderStatus.ontheway) {
//       _markers.add(
//         Marker(
//           markerId: const MarkerId('vendor'),
//           position: LatLng(
//             _delivery!.vendorLatitude,
//             _delivery!.vendorLongitude,
//           ),
//           icon:
//               _vendorIcon ??
//               BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//           infoWindow: const InfoWindow(title: 'Restaurant'),
//         ),
//       );
//     }
//
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('customer'),
//         position: LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//         icon:
//             _customerIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
//         infoWindow: const InfoWindow(title: 'Delivery Location'),
//       ),
//     );
//   }
//
//   void _addPartnerMarker(LatLng position, {required double bearing}) {
//     // FIX 1: Pass bearing (rotation) so arrow points toward destination
//     _partnerMarker = Marker(
//       markerId: const MarkerId('partner'),
//       position: position,
//       icon:
//           _bikeIcon ??
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       rotation: bearing, // ← actual bearing toward customer
//       anchor: const Offset(0.5, 0.5),
//       flat: true,
//       zIndex: 2,
//       infoWindow: const InfoWindow(title: 'Delivery Partner'),
//     );
//
//     _markers.removeWhere((m) => m.markerId.value == 'partner');
//     _markers.add(_partnerMarker!);
//
//     if (mounted) setState(() {});
//   }
//
//   // ── Partner smooth movement ───────────────────────────────────────────────
//
//   Future<void> _animatePartnerMovement(LatLng from, LatLng to) async {
//     if (!mounted) return;
//
//     _moveController?.stop();
//     _moveController?.dispose();
//
//     // FIX 1: Calculate bearing toward CUSTOMER (destination), not just next point
//     // This ensures arrow always points toward where the driver is heading
//     final bearing = _delivery != null
//         ? _calculateBearing(
//             to, // from current position
//             LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//           )
//         : _calculateBearing(from, to);
//
//     _currentBearing = bearing;
//
//     const duration = Duration(milliseconds: 1800);
//     _moveController = AnimationController(vsync: this, duration: duration);
//
//     final latTween = Tween<double>(begin: from.latitude, end: to.latitude);
//     final lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
//
//     final curved = CurvedAnimation(
//       parent: _moveController!,
//       curve: Curves.easeInOut,
//     );
//
//     _moveController!.addListener(() {
//       if (!mounted) return;
//
//       final currentPos = LatLng(
//         latTween.evaluate(curved),
//         lngTween.evaluate(curved),
//       );
//
//       _currentAnimatedPosition = currentPos;
//
//       // FIX 1: Always pass current bearing so marker rotates
//       _partnerMarker = Marker(
//         markerId: const MarkerId('partner'),
//         position: currentPos,
//         icon:
//             _bikeIcon ??
//             BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//         rotation: bearing,
//         anchor: const Offset(0.5, 0.5),
//         flat: true,
//         zIndex: 2,
//         infoWindow: const InfoWindow(title: 'Delivery Partner'),
//       );
//
//       _markers.removeWhere((m) => m.markerId.value == 'partner');
//       _markers.add(_partnerMarker!);
//
//       _updateDeliveryProgressInternal(currentPos);
//
//       // FIX 3: Push every animation frame to full-screen map stream
//       _pushLiveState();
//
//       if (mounted) setState(() {});
//     });
//
//     _moveController!.addStatusListener((status) {
//       if (status == AnimationStatus.completed) {
//         _lastPartnerPosition = to;
//         _currentAnimatedPosition = to;
//         _panMapToPartner(to);
//         _pushLiveState(); // FIX 3: push on completion too
//       }
//     });
//
//     await _moveController!.forward();
//   }
//
//   void _panMapToPartner(LatLng position) {
//     _mapController?.animateCamera(CameraUpdate.newLatLng(position));
//   }
//
//   double _calculateBearing(LatLng start, LatLng end) {
//     if (start.latitude == end.latitude && start.longitude == end.longitude) {
//       return 0;
//     }
//     final lat1 = start.latitude * pi / 180;
//     final lat2 = end.latitude * pi / 180;
//     final dLon = (end.longitude - start.longitude) * pi / 180;
//     final y = sin(dLon) * cos(lat2);
//     final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
//     return (atan2(y, x) * 180 / pi + 360) % 360;
//   }
//
//   // ── FIX 2: Route drawing ──────────────────────────────────────────────────
//   // When status is ontheway → draw partner→customer route
//   // Otherwise              → draw vendor→customer route
//
//   Future<void> _drawPolyline() async {
//     if (_googleApiKey == null || _delivery == null) return;
//
//     // Determine origin based on status
//     final bool isOnTheWay = _currentOrderStatus == OrderStatus.ontheway;
//
//     final PointLatLng origin;
//     if (isOnTheWay && _currentAnimatedPosition != null) {
//       // Partner is on the way — route from partner's current position
//       origin = PointLatLng(
//         _currentAnimatedPosition!.latitude,
//         _currentAnimatedPosition!.longitude,
//       );
//     } else if (isOnTheWay &&
//         _delivery!.deliveryPartnerLatitude != 0 &&
//         _delivery!.deliveryPartnerLongitude != 0) {
//       origin = PointLatLng(
//         _delivery!.deliveryPartnerLatitude,
//         _delivery!.deliveryPartnerLongitude,
//       );
//     } else {
//       // Not yet on the way — show vendor→customer
//       origin = PointLatLng(
//         _delivery!.vendorLatitude,
//         _delivery!.vendorLongitude,
//       );
//     }
//
//     final destination = PointLatLng(
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//
//     try {
//       final polylinePoints = PolylinePoints();
//       final result = await polylinePoints.getRouteBetweenCoordinates(
//         request: PolylineRequest(
//           origin: origin,
//           destination: destination,
//           mode: TravelMode.driving,
//         ),
//         googleApiKey: _googleApiKey!,
//       );
//
//       if (result.points.isNotEmpty) {
//         final points = result.points
//             .map((p) => LatLng(p.latitude, p.longitude))
//             .toList();
//
//         _polylines
//           ..removeWhere(
//             (p) =>
//                 p.polylineId.value == 'route' ||
//                 p.polylineId.value == 'route_solid',
//           )
//           ..add(
//             Polyline(
//               polylineId: const PolylineId('route'),
//               color: Colors.blue.shade300,
//               width: 5,
//               points: points,
//               patterns: [PatternItem.dash(20), PatternItem.gap(10)],
//             ),
//           )
//           ..add(
//             Polyline(
//               polylineId: const PolylineId('route_solid'),
//               color: Colors.blue.withOpacity(0.4),
//               width: 2,
//               points: points,
//             ),
//           );
//
//         if (mounted) setState(() {});
//         _pushLiveState(); // FIX 3: push updated polylines
//       }
//     } catch (e) {
//       debugPrint('Error drawing polyline: $e');
//     }
//   }
//
//   // ── Progress ──────────────────────────────────────────────────────────────
//
//   void _updateDeliveryProgressInternal(LatLng partnerPosition) {
//     if (_delivery == null) return;
//
//     final total = Geolocator.distanceBetween(
//       _delivery!.vendorLatitude,
//       _delivery!.vendorLongitude,
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//
//     if (total == 0) return;
//
//     final covered = Geolocator.distanceBetween(
//       _delivery!.vendorLatitude,
//       _delivery!.vendorLongitude,
//       partnerPosition.latitude,
//       partnerPosition.longitude,
//     );
//
//     _deliveryProgress = (covered / total).clamp(0.0, 1.0);
//   }
//
//   void _updateDeliveryProgress(LatLng partnerPosition) {
//     _updateDeliveryProgressInternal(partnerPosition);
//     if (mounted) setState(() {});
//   }
//
//   void _calculateInitialProgress() {
//     if (_lastPartnerPosition == null) return;
//     _updateDeliveryProgress(_lastPartnerPosition!);
//   }
//
//   // ── Refresh ───────────────────────────────────────────────────────────────
//
//   Future<void> _refreshDeliveryData() async {
//     if (!mounted) return;
//
//     final updated = await DeliveryOrderService.getOrder(widget.orderId);
//     if (updated == null) return;
//
//     final wasDelivered =
//         _currentOrderStatus != OrderStatus.completed &&
//         updated.status == OrderStatus.completed;
//
//     setState(() {
//       _delivery = updated;
//       if (_currentOrderStatus != OrderStatus.completed &&
//           _currentOrderStatus != OrderStatus.cancelled) {
//         _setupDeliverySteps();
//       }
//     });
//
//     if (updated.partnerId != _subscribedPartnerId) {
//       _listenToWebSocket();
//     }
//
//     if (wasDelivered) _onDelivered();
//
//     widget.onRefresh?.call();
//   }
//
//   // ── ETA display string ────────────────────────────────────────────────────
//
//   String get _formattedEta {
//     if (_etaLoading && _remainingEta == null) return 'Calculating...';
//     if (_remainingEta == null) return '--';
//     if (_remainingEta!.inSeconds <= 0) return 'Arriving soon';
//
//     final hours = _remainingEta!.inHours;
//     final minutes = _remainingEta!.inMinutes.remainder(60);
//
//     if (hours > 0) return '${hours}h ${minutes}min';
//     if (_remainingEta!.inMinutes < 1) return 'Arriving soon';
//     return '${_remainingEta!.inMinutes} min';
//   }
//
//   void _listenToWebSocket() {
//     debugPrint("📡 WS INIT CALLED");
//
//     if (_delivery == null) {
//       debugPrint("❌ Delivery is NULL, skipping WS setup");
//       return;
//     }
//
//     if (!_wsSubscribed) {
//       _wsSubscribed = true;
//
//       WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
//         if (!mounted) return;
//
//         final newStatus = OrderStatus.fromString(data['status']);
//         debugPrint("🔥 WS STATUS: ${data['status']} → $newStatus");
//
//         if (newStatus == _currentOrderStatus) return;
//
//         final wasOnTheWay =
//             _currentOrderStatus != OrderStatus.ontheway &&
//             newStatus == OrderStatus.ontheway;
//
//         setState(() {
//           _currentOrderStatus = newStatus;
//           _setupDeliverySteps();
//           // FIX 2: Rebuild markers when status changes (show/hide vendor)
//           _setupStaticMarkers();
//         });
//
//         // FIX 2: Redraw route when status becomes ontheway
//         if (wasOnTheWay) {
//           _drawPolyline();
//         }
//
//         if (newStatus == OrderStatus.completed ||
//             newStatus == OrderStatus.cancelled) {
//           _refreshDeliveryData();
//         }
//       });
//     }
//
//     final partnerId = _delivery!.partnerId;
//     debugPrint("👤 Current Partner ID: $partnerId");
//
//     if (partnerId == null) {
//       debugPrint("❌ Partner ID is NULL, skipping location WS");
//       return;
//     }
//
//     if (_subscribedPartnerId == partnerId) {
//       debugPrint("⏭️ Already subscribed to this partner ($partnerId)");
//       return;
//     }
//
//     if (_subscribedPartnerId != null) {
//       debugPrint("🔴 Unsubscribing old partner: $_subscribedPartnerId");
//       WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
//     }
//
//     _subscribedPartnerId = partnerId;
//     debugPrint("🟢 Subscribing to PARTNER LOCATION: $partnerId");
//
//     WebSocketManager().subscribePartnerLocation(partnerId, (data) {
//       debugPrint("📍 LOCATION WS DATA: $data");
//
//       if (!mounted) return;
//
//       final lat = (data['latitude'] as num?)?.toDouble();
//       final lng = (data['longitude'] as num?)?.toDouble();
//
//       if (lat == null || lng == null) return;
//
//       final newPosition = LatLng(lat, lng);
//
//       if (_lastPartnerPosition != null) {
//         _animatePartnerMovement(_lastPartnerPosition!, newPosition);
//       } else {
//         _lastPartnerPosition = newPosition;
//         _currentAnimatedPosition = newPosition;
//
//         // FIX 1: Calculate initial bearing toward customer
//         final initialBearing = _delivery != null
//             ? _calculateBearing(
//                 newPosition,
//                 LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//               )
//             : 0.0;
//         _currentBearing = initialBearing;
//
//         _addPartnerMarker(newPosition, bearing: initialBearing);
//         _pushLiveState(); // FIX 3
//       }
//
//       _updateEtaBasedOnPosition(newPosition);
//       _updateDeliveryProgress(newPosition);
//     });
//   }
//
//   // ─────────────────────────────────────────────────────────────────────────
//   // BUILD
//   // ─────────────────────────────────────────────────────────────────────────
//
//   @override
//   Widget build(BuildContext context) {
//     if (_currentOrderStatus == OrderStatus.cancelled) {
//       return const SizedBox.shrink();
//     }
//
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 300),
//       child: _isLoading ? _buildShimmerLoading() : _buildDeliveryTracking(),
//     );
//   }
//
//   Widget _buildShimmerLoading() {
//     return Container(
//       height: 200,
//       decoration: BoxDecoration(
//         color: Colors.grey.shade200,
//         borderRadius: BorderRadius.circular(16),
//       ),
//       child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
//     );
//   }
//
//   Widget _buildDeliveryTracking() {
//     return SlideTransition(
//       position: _slideAnimation,
//       child: Container(
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.05),
//               blurRadius: 10,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Column(
//           children: [
//             _buildStatusHeader(),
//             if (_currentOrderStatus == OrderStatus.ontheway)
//               _buildProgressMap(),
//             _buildPartnerInfo(),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // ── Status header ──────────────────────────────────────────────────────────
//
//   Widget _buildStatusHeader() {
//     final isDelivered = _currentOrderStatus == OrderStatus.completed;
//
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: _getStatusColor(),
//         borderRadius: const BorderRadius.only(
//           topLeft: Radius.circular(20),
//           topRight: Radius.circular(20),
//         ),
//       ),
//       child: Row(
//         children: [
//           ScaleTransition(
//             scale: _pulseAnimation,
//             child: Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(_getStatusIcon(), color: Colors.white, size: 28),
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _getStatusTitle(),
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 16,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   _getStatusSubtitle(),
//                   style: TextStyle(
//                     color: Colors.white.withOpacity(0.9),
//                     fontSize: 13,
//                   ),
//                 ),
//                 if (isDelivered) ...[
//                   const SizedBox(height: 6),
//                   _buildDeliveryBadge(),
//                 ],
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           if (!isDelivered) ...[
//             if (_etaLoading && _remainingEta == null)
//               const SizedBox(
//                 width: 20,
//                 height: 20,
//                 child: CircularProgressIndicator(
//                   color: Colors.white,
//                   strokeWidth: 2,
//                 ),
//               )
//             else if (_remainingEta != null)
//               Container(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 12,
//                   vertical: 6,
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.white.withOpacity(0.2),
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: Column(
//                   children: [
//                     const Text(
//                       'ETA',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 11,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     Text(
//                       _formattedEta,
//                       style: const TextStyle(
//                         color: Colors.white,
//                         fontSize: 14,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//           ],
//           if (isDelivered && _deliveredInMinutes != null)
//             Container(
//               width: 56,
//               height: 56,
//               decoration: BoxDecoration(
//                 color: Colors.white.withOpacity(0.2),
//                 shape: BoxShape.circle,
//                 border: Border.all(
//                   color: Colors.white.withOpacity(0.4),
//                   width: 1.5,
//                 ),
//               ),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     '${_deliveredInMinutes}',
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 20,
//                       fontWeight: FontWeight.bold,
//                       height: 1,
//                     ),
//                   ),
//                   Text(
//                     'min',
//                     style: TextStyle(
//                       color: Colors.white.withOpacity(0.85),
//                       fontSize: 10,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildDeliveryBadge() {
//     final String label;
//     final Color color;
//
//     if (_deliveryWasEarly) {
//       label = '🚀 Early!';
//       color = const Color(0xFF1565C0);
//     } else if (_deliveryWasLate) {
//       label = '⏰ Late';
//       color = Colors.orange.shade700;
//     } else {
//       label = '✅ On Time';
//       color = const Color(0xFF2E7D32);
//     }
//
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
//       decoration: BoxDecoration(
//         color: color,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
//       ),
//       child: Text(
//         label,
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 11,
//           fontWeight: FontWeight.w600,
//         ),
//       ),
//     );
//   }
//
//   Color _getStatusColor() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.completed:
//         return Colors.green.shade700;
//       case OrderStatus.ontheway:
//         return Colors.blue;
//       case OrderStatus.waitingForPickup:
//         return Colors.orange;
//       default:
//         return Colors.purple;
//     }
//   }
//
//   IconData _getStatusIcon() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.completed:
//         return Icons.verified;
//       case OrderStatus.ontheway:
//         return Icons.delivery_dining;
//       case OrderStatus.waitingForPickup:
//         return Icons.inventory;
//       case OrderStatus.beingPrepared:
//         return Icons.restaurant;
//       default:
//         return Icons.pending;
//     }
//   }
//
//   String _getStatusTitle() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.pending:
//         return 'Order Pending';
//       case OrderStatus.confirmed:
//         return 'Order Confirmed';
//       case OrderStatus.processing:
//         return 'Processing Order';
//       case OrderStatus.beingPrepared:
//         return 'Preparing';
//       case OrderStatus.orderIsReady:
//         return 'Order Ready';
//       case OrderStatus.waitingForPickup:
//         return 'Waiting for Pickup';
//       case OrderStatus.ontheway:
//         return 'On The Way';
//       case OrderStatus.completed:
//         return 'Order Delivered! 🎉';
//       case OrderStatus.cancelled:
//         return 'Order Cancelled';
//       case OrderStatus.hold:
//         return 'On Hold';
//       case OrderStatus.unknown:
//         return 'Updating status...';
//       default:
//         return 'Processing your order';
//     }
//   }
//
//   String _getStatusSubtitle() {
//     switch (_currentOrderStatus) {
//       case OrderStatus.pending:
//         return 'Waiting for confirmation';
//       case OrderStatus.confirmed:
//         return 'Restaurant confirmed your order';
//       case OrderStatus.processing:
//         return 'Order is being processed';
//       case OrderStatus.beingPrepared:
//         return 'Restaurant is preparing your food';
//       case OrderStatus.orderIsReady:
//         return 'Order is ready for pickup';
//       case OrderStatus.waitingForPickup:
//         return 'Delivery partner is assigned';
//       case OrderStatus.ontheway:
//         return 'Your food is on the way';
//       case OrderStatus.completed:
//         return _deliveredInMinutes != null
//             ? 'Delivered in $_deliveredInMinutes min'
//             : 'Delivered successfully';
//       case OrderStatus.cancelled:
//         return 'Order was cancelled';
//       case OrderStatus.hold:
//         return 'Order is on hold';
//       case OrderStatus.unknown:
//         return 'Fetching latest status...';
//       default:
//         return 'Processing your order';
//     }
//   }
//
//   // ── Progress map (thumbnail) ───────────────────────────────────────────────
//
//   Widget _buildProgressMap() {
//     final initialTarget =
//         _currentAnimatedPosition ??
//         _lastPartnerPosition ??
//         LatLng(
//           _delivery?.vendorLatitude ?? 17.385044,
//           _delivery?.vendorLongitude ?? 78.486671,
//         );
//
//     return GestureDetector(
//       onTap: () => Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (_) => FullScreenMapPage(
//             // FIX 3: Pass the live stream instead of a snapshot
//             liveStream: _liveMapStream.stream,
//             initialMarkers: Set.from(_markers),
//             initialPolylines: Set.from(_polylines),
//             initialEtaText: _formattedEta,
//             initialPartnerPosition: _currentAnimatedPosition,
//           ),
//         ),
//       ),
//       child: Container(
//         height: 160,
//         margin: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(color: Colors.grey.shade200),
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(16),
//           child: Stack(
//             children: [
//               GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: initialTarget,
//                   zoom: 14,
//                 ),
//                 markers: _markers,
//                 polylines: _polylines,
//                 zoomControlsEnabled: false,
//                 myLocationEnabled: false,
//                 compassEnabled: false,
//                 scrollGesturesEnabled: false,
//                 zoomGesturesEnabled: false,
//                 rotateGesturesEnabled: false,
//                 tiltGesturesEnabled: false,
//                 onMapCreated: (c) {
//                   _mapController = c;
//                   _fitMapBounds();
//                 },
//                 gestureRecognizers: {
//                   Factory<OneSequenceGestureRecognizer>(
//                     () => EagerGestureRecognizer(),
//                   ),
//                 },
//               ),
//               Positioned(
//                 bottom: 0,
//                 left: 0,
//                 right: 0,
//                 child: Container(
//                   padding: const EdgeInsets.symmetric(
//                     horizontal: 12,
//                     vertical: 8,
//                   ),
//                   decoration: BoxDecoration(
//                     gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomCenter,
//                       colors: [
//                         Colors.transparent,
//                         Colors.black.withOpacity(0.65),
//                       ],
//                     ),
//                   ),
//                   child: Row(
//                     children: [
//                       const Icon(
//                         Icons.directions_bike,
//                         color: Colors.white,
//                         size: 16,
//                       ),
//                       const SizedBox(width: 8),
//                       const Expanded(
//                         child: Text(
//                           'Tap to view full map',
//                           style: TextStyle(color: Colors.white, fontSize: 12),
//                         ),
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
//
//   void _fitMapBounds() {
//     if (_delivery == null || _mapController == null) return;
//
//     final vendorLat = _delivery!.vendorLatitude;
//     final vendorLng = _delivery!.vendorLongitude;
//     final userLat = _delivery!.userLatitude;
//     final userLng = _delivery!.userLongitude;
//
//     final bounds = LatLngBounds(
//       southwest: LatLng(min(vendorLat, userLat), min(vendorLng, userLng)),
//       northeast: LatLng(max(vendorLat, userLat), max(vendorLng, userLng)),
//     );
//
//     _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   }
//
//   // ── Timeline ──────────────────────────────────────────────────────────────
//
//   Widget _buildTimeline() {
//     return Padding(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Text(
//             'Delivery Timeline',
//             style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 16),
//           ..._deliverySteps.map((s) => _buildTimelineStep(s)),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildTimelineStep(DeliveryStep step) {
//     final isLast = _deliverySteps.last == step;
//
//     return IntrinsicHeight(
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           SizedBox(
//             width: 40,
//             child: Column(
//               children: [
//                 Container(
//                   width: 24,
//                   height: 24,
//                   decoration: BoxDecoration(
//                     color: step.isCompleted
//                         ? Colors.green
//                         : Colors.grey.shade300,
//                     shape: BoxShape.circle,
//                   ),
//                   child: Icon(
//                     step.isCompleted ? Icons.check : step.icon,
//                     color: Colors.white,
//                     size: 14,
//                   ),
//                 ),
//                 if (!isLast)
//                   Flexible(
//                     child: Container(
//                       width: 2,
//                       color: step.isCompleted
//                           ? Colors.green
//                           : Colors.grey.shade300,
//                     ),
//                   ),
//               ],
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: EdgeInsets.only(left: 8, bottom: isLast ? 0 : 16),
//               child: Text(
//                 step.status,
//                 style: TextStyle(
//                   fontSize: 15,
//                   fontWeight: step.isCompleted
//                       ? FontWeight.w600
//                       : FontWeight.normal,
//                   color: step.isCompleted ? Colors.black87 : Colors.grey,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ── Partner info ──────────────────────────────────────────────────────────
//
//   Widget _buildPartnerInfo() {
//     if (_delivery?.deliveryPartnerName.isEmpty ?? true) {
//       return const SizedBox.shrink();
//     }
//
//     return Container(
//       margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade200),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 24,
//             backgroundColor: Colors.green.shade100,
//             child: const Icon(Icons.person, color: Colors.green, size: 28),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _delivery!.deliveryPartnerName,
//                   style: const TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   'Vehicle: ${_delivery!.vehicleStatus.name.replaceAll('_', ' ')}',
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                 ),
//                 const SizedBox(height: 2),
//                 Text(
//                   'OTP: ${_delivery?.userOtp.toString() ?? '0'}',
//                   style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ── Helper classes ────────────────────────────────────────────────────────────
//
// class DeliveryStep {
//   final String status;
//   final bool isCompleted;
//   final IconData icon;
//
//   DeliveryStep({
//     required this.status,
//     required this.isCompleted,
//     required this.icon,
//   });
// }
//
// // ── FIX 3: Data class for live map state stream ───────────────────────────────
//
// class _LiveMapState {
//   final Set<Marker> markers;
//   final Set<Polyline> polylines;
//   final String etaText;
//   final LatLng? partnerPosition;
//   final double bearing;
//
//   _LiveMapState({
//     required this.markers,
//     required this.polylines,
//     required this.etaText,
//     this.partnerPosition,
//     required this.bearing,
//   });
// }
//
// // ── Full screen map (FIX 3: stream-driven, always live) ───────────────────────
//
// class FullScreenMapPage extends StatefulWidget {
//   /// FIX 3: Receive a broadcast stream of live state updates
//   final Stream<_LiveMapState> liveStream;
//   final Set<Marker> initialMarkers;
//   final Set<Polyline> initialPolylines;
//   final String initialEtaText;
//   final LatLng? initialPartnerPosition;
//
//   const FullScreenMapPage({
//     Key? key,
//     required this.liveStream,
//     required this.initialMarkers,
//     required this.initialPolylines,
//     required this.initialEtaText,
//     this.initialPartnerPosition,
//   }) : super(key: key);
//
//   @override
//   State<FullScreenMapPage> createState() => _FullScreenMapPageState();
// }
//
// class _FullScreenMapPageState extends State<FullScreenMapPage> {
//   GoogleMapController? _controller;
//   late Set<Marker> _markers;
//   late Set<Polyline> _polylines;
//   late String _etaText;
//   LatLng? _partnerPosition;
//   StreamSubscription<_LiveMapState>? _sub;
//
//   @override
//   void initState() {
//     super.initState();
//     _markers = Set.from(widget.initialMarkers);
//     _polylines = Set.from(widget.initialPolylines);
//     _etaText = widget.initialEtaText;
//     _partnerPosition = widget.initialPartnerPosition;
//
//     // FIX 3: Subscribe to live updates — rebuilds map on every partner move
//     _sub = widget.liveStream.listen((state) {
//       if (!mounted) return;
//       setState(() {
//         _markers = state.markers;
//         _polylines = state.polylines;
//         _etaText = state.etaText;
//
//         // Auto-follow partner on full-screen map
//         if (state.partnerPosition != null &&
//             state.partnerPosition != _partnerPosition) {
//           _partnerPosition = state.partnerPosition;
//           _controller?.animateCamera(
//             CameraUpdate.newLatLng(state.partnerPosition!),
//           );
//         }
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   LatLng get _initialTarget {
//     if (widget.initialPartnerPosition != null) {
//       return widget.initialPartnerPosition!;
//     }
//     final partner = widget.initialMarkers.where(
//       (m) => m.markerId.value == 'partner',
//     );
//     if (partner.isNotEmpty) return partner.first.position;
//     if (widget.initialMarkers.isNotEmpty) {
//       return widget.initialMarkers.first.position;
//     }
//     return const LatLng(17.385044, 78.486671);
//   }
//
//   void _fitBounds() {
//     if (_controller == null || _markers.length < 2) return;
//
//     double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
//     for (final m in _markers) {
//       minLat = min(minLat, m.position.latitude);
//       maxLat = max(maxLat, m.position.latitude);
//       minLng = min(minLng, m.position.longitude);
//       maxLng = max(maxLng, m.position.longitude);
//     }
//
//     _controller!.animateCamera(
//       CameraUpdate.newLatLngBounds(
//         LatLngBounds(
//           southwest: LatLng(minLat, minLng),
//           northeast: LatLng(maxLat, maxLng),
//         ),
//         80,
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             initialCameraPosition: CameraPosition(
//               target: _initialTarget,
//               zoom: 15,
//             ),
//             markers: _markers, // FIX 3: live-updated markers
//             polylines: _polylines, // FIX 3: live-updated polylines
//             myLocationEnabled: true,
//             myLocationButtonEnabled: true,
//             compassEnabled: true,
//             trafficEnabled: false,
//             buildingsEnabled: true,
//             onMapCreated: (c) {
//               _controller = c;
//               Future.delayed(const Duration(milliseconds: 300), _fitBounds);
//             },
//           ),
//
//           // Close button
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             left: 16,
//             child: Material(
//               shape: const CircleBorder(),
//               elevation: 4,
//               child: InkWell(
//                 customBorder: const CircleBorder(),
//                 onTap: () => Navigator.pop(context),
//                 child: const Padding(
//                   padding: EdgeInsets.all(10),
//                   child: Icon(Icons.close, size: 22),
//                 ),
//               ),
//             ),
//           ),
//
//           // ETA chip — live updated
//           Positioned(
//             top: MediaQuery.of(context).padding.top + 8,
//             right: 16,
//             child: Container(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               decoration: BoxDecoration(
//                 color: Colors.blue,
//                 borderRadius: BorderRadius.circular(30),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.blue.withOpacity(0.35),
//                     blurRadius: 10,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Text(
//                 'ETA: $_etaText', // FIX 3: live ETA text
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                   fontSize: 14,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }