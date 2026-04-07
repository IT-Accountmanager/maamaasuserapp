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
// // Callback the parent uses to push live updates directly into FullScreenMapPage
// typedef LiveMapUpdater =
//     void Function(
//       Set<Marker> markers,
//       Set<Polyline> polylines,
//       String etaText,
//       LatLng? partnerPosition,
//     );
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
//   late AnimationController _pulseController;
//   late AnimationController _slideController;
//   late Animation<double> _pulseAnimation;
//   late Animation<Offset> _slideAnimation;
//   AnimationController? _moveController;
//
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   Marker? _partnerMarker;
//
//   // _lastPartnerPosition is the confirmed "arrived-at" position.
//   // _currentAnimatedPosition is the live interpolated position.
//   LatLng? _lastPartnerPosition;
//   LatLng? _currentAnimatedPosition;
//
//   // pending target — if a new WS update arrives mid-animation,
//   // we store it here and process it once the current animation finishes.
//   LatLng? _pendingPartnerPosition;
//   bool _isAnimating = false;
//
//   BitmapDescriptor? _bikeIcon;
//   BitmapDescriptor? _vendorIcon;
//   BitmapDescriptor? _customerIcon;
//
//   // When FullScreenMapPage is open it registers here; null when closed.
//   LiveMapUpdater? _fullScreenUpdater;
//
//   // ── FIX: Store the full decoded route so we can trim it as partner moves ──
//   List<LatLng> _fullRoutePoints = [];
//
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
//   bool _wsSubscribed = false;
//   int? _subscribedPartnerId;
//
//   String? _googleApiKey;
//   bool _isLoading = true;
//   double _deliveryProgress = 0.0;
//   late OrderStatus _currentOrderStatus;
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
//     _moveController?.stop();
//     _moveController?.dispose();
//     _etaTimer?.cancel();
//     _etaRefreshTimer?.cancel();
//     _mapController?.dispose();
//     _fullScreenUpdater = null;
//     if (_subscribedPartnerId != null) {
//       WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
//     }
//     if (_wsSubscribed) {
//       WebSocketManager().unsubscribeOrderStatus(widget.orderId);
//     }
//     super.dispose();
//   }
//
//   // Push current state to full-screen map if it is open
//   void _notifyFullScreen() {
//     if (_fullScreenUpdater == null) return;
//
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (_fullScreenUpdater != null) {
//         debugPrint("📤 PUSHING UPDATE TO FULLSCREEN");
//
//         _fullScreenUpdater!(
//           Set.from(_markers),
//           Set.from(_polylines),
//           _formattedEta,
//           _currentAnimatedPosition,
//         );
//       }
//     });
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
//   Future<void> _loadDeliveryData() async {
//     if (mounted) setState(() => _isLoading = true);
//     try {
//       _googleApiKey = await ApiKeyService.getApiKey();
//       _delivery =
//           widget.deliveryModel ??
//           await DeliveryOrderService.getOrder(widget.orderId);
//
//       if (_delivery != null) {
//         _orderStartTime = DateTime.now();
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
//           final initialBearing = _calculateBearing(
//             partnerPos,
//             LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//           );
//           _addPartnerMarker(partnerPos, bearing: initialBearing);
//           // Trim polyline to start from partner's initial position
//           if (_fullRoutePoints.isNotEmpty) {
//             _applyTrimmedPolyline(partnerPos);
//             if (mounted) setState(() {});
//           }
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
//         if (!_wsSubscribed) _listenToWebSocket();
//       }
//     } catch (e) {
//       debugPrint('Error loading delivery data: $e');
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }
//
//   Future<void> _fetchRealEta(LatLng origin) async {
//     if (_googleApiKey == null || _delivery == null) return;
//     if (_etaLoading) return;
//     if (_currentOrderStatus == OrderStatus.completed) return;
//     if (mounted) setState(() => _etaLoading = true);
//
//     try {
//       final url = Uri.parse(
//         'https://maps.googleapis.com/maps/api/distancematrix/json'
//         '?origins=${origin.latitude},${origin.longitude}'
//         '&destinations=${_delivery!.userLatitude},${_delivery!.userLongitude}'
//         '&mode=driving&departure_time=now&key=$_googleApiKey',
//       );
//       final response = await http.get(url).timeout(const Duration(seconds: 8));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         final elements = data['rows']?[0]?['elements']?[0];
//         if (elements != null && elements['status'] == 'OK') {
//           final durationSeconds =
//               (elements['duration_in_traffic'] ??
//                       elements['duration'])?['value']
//                   as int?;
//           if (durationSeconds != null && mounted) {
//             setState(() {
//               _remainingEta = Duration(seconds: durationSeconds);
//               _estimatedArrival = DateTime.now().add(
//                 Duration(seconds: durationSeconds),
//               );
//               _etaLoading = false;
//             });
//             _notifyFullScreen();
//             return;
//           }
//         }
//       }
//     } catch (e) {
//       debugPrint('Distance Matrix error: $e');
//     } finally {
//       if (mounted && _etaLoading) setState(() => _etaLoading = false);
//     }
//     _straightLineFallback(origin);
//   }
//
//   void _straightLineFallback(LatLng origin) {
//     if (_delivery == null) return;
//     final distance = Geolocator.distanceBetween(
//       origin.latitude,
//       origin.longitude,
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//     final etaSeconds = (distance / 6.94).round();
//     if (mounted) {
//       setState(() {
//         _remainingEta = Duration(seconds: etaSeconds);
//         _estimatedArrival = DateTime.now().add(Duration(seconds: etaSeconds));
//       });
//       _notifyFullScreen();
//     }
//   }
//
//   void _updateEtaBasedOnPosition(LatLng newPosition) {
//     if (_currentOrderStatus == OrderStatus.completed) return;
//     if (_lastPartnerPosition != null) {
//       final distance = Geolocator.distanceBetween(
//         _lastPartnerPosition!.latitude,
//         _lastPartnerPosition!.longitude,
//         newPosition.latitude,
//         newPosition.longitude,
//       );
//       if (distance < 50) return;
//     }
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
//       final origin =
//           _currentAnimatedPosition ??
//           ((_delivery?.deliveryPartnerLatitude ?? 0) != 0
//               ? LatLng(
//                   _delivery!.deliveryPartnerLatitude,
//                   _delivery!.deliveryPartnerLongitude,
//                 )
//               : LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude));
//       await _fetchRealEta(origin);
//     });
//   }
//
//   void _startEtaCountdown() {
//     _etaTimer?.cancel();
//     OrderStatus? _prevStatus;
//     _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
//       if (!mounted) return;
//       if (_currentOrderStatus == OrderStatus.completed &&
//           _prevStatus != OrderStatus.completed) {
//         _onDelivered();
//         return;
//       }
//       _prevStatus = _currentOrderStatus;
//       if (_remainingEta == null || _remainingEta!.inSeconds <= 0) return;
//       setState(
//         () => _remainingEta = _remainingEta! - const Duration(seconds: 1),
//       );
//     });
//   }
//
//   void _onDelivered() {
//     _etaTimer?.cancel();
//     _etaRefreshTimer?.cancel();
//     _moveController?.stop();
//     _deliveredAt = DateTime.now();
//     _deliveredInMinutes = _orderStartTime != null
//         ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
//         : null;
//     if (_estimatedArrival != null) {
//       final diff = _deliveredAt!.difference(_estimatedArrival!).inMinutes;
//       _deliveryWasEarly = diff < -2;
//       _deliveryWasLate = diff > 5;
//     }
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
//     _deliveredAt = DateTime.now();
//     _deliveredInMinutes = _orderStartTime != null
//         ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
//         : null;
//     _remainingEta = null;
//     _currentOrderStatus = OrderStatus.completed;
//   }
//
//   Future<void> _loadCustomIcons() async {
//     _vendorIcon = await _createCustomMarker(Icons.store, Colors.orange, 80);
//     _customerIcon = await _createCustomMarker(Icons.home, Colors.blue, 80);
//     _bikeIcon = await _createDirectionalBikeIcon();
//   }
//
//   Future<BitmapDescriptor> _createDirectionalBikeIcon() async {
//     const double size = 120;
//     final recorder = PictureRecorder();
//     final canvas = Canvas(recorder);
//     final center = Offset(size / 2, size / 2);
//
//     canvas.drawCircle(
//       center,
//       size / 2 - 4,
//       Paint()
//         ..color = Colors.black.withOpacity(0.18)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
//     );
//     canvas.drawCircle(
//       center,
//       size / 2 - 8,
//       Paint()..color = Colors.green.shade600,
//     );
//     canvas.drawCircle(
//       center,
//       size / 2 - 8,
//       Paint()
//         ..color = Colors.white
//         ..style = PaintingStyle.stroke
//         ..strokeWidth = 4,
//     );
//
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
//     canvas.drawPath(
//       Path()
//         ..moveTo(center.dx, 6)
//         ..lineTo(center.dx - 9, 22)
//         ..lineTo(center.dx + 9, 22)
//         ..close(),
//       Paint()..color = Colors.white,
//     );
//
//     final picture = recorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
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
//     textPainter.text = TextSpan(
//       text: String.fromCharCode(icon.codePoint),
//       style: TextStyle(
//         fontSize: size,
//         fontFamily: icon.fontFamily,
//         package: icon.fontPackage,
//         color: color,
//       ),
//     );
//     textPainter.layout();
//     textPainter.paint(canvas, Offset.zero);
//     final picture = recorder.endRecording();
//     final image = await picture.toImage(size.toInt(), size.toInt());
//     final byteData = await image.toByteData(format: ImageByteFormat.png);
//     return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
//   }
//
//   void _setupDeliverySteps() {
//     if (_delivery == null) return;
//     final s = _currentOrderStatus;
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
//   }
//
//   void _setupStaticMarkers() {
//     if (_delivery == null) return;
//     _markers.removeWhere(
//       (m) => m.markerId.value == 'vendor' || m.markerId.value == 'customer',
//     );
//
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
//     _markers.removeWhere((m) => m.markerId.value == 'partner');
//     _markers.add(_partnerMarker!);
//     if (mounted) setState(() {});
//   }
//
//   // ── FIX: Returns the index of the route point closest to [partner] ──────────
//   int _nearestPointIndex(List<LatLng> points, LatLng partner) {
//     double minDist = double.infinity;
//     int idx = 0;
//     for (int i = 0; i < points.length; i++) {
//       final d = Geolocator.distanceBetween(
//         partner.latitude,
//         partner.longitude,
//         points[i].latitude,
//         points[i].longitude,
//       );
//       if (d < minDist) {
//         minDist = d;
//         idx = i;
//       }
//     }
//     return idx;
//   }
//
//   // ── FIX: Trims _fullRoutePoints from the partner's position onward and
//   //         replaces the active polylines. Optionally accepts an explicit
//   //         routePoints list (used on first draw before _fullRoutePoints is set).
//   void _applyTrimmedPolyline(LatLng partnerPos, [List<LatLng>? routePoints]) {
//     final points = routePoints ?? _fullRoutePoints;
//     if (points.isEmpty) return;
//
//     final nearestIdx = _nearestPointIndex(points, partnerPos);
//
//     // Build trimmed list: exact live partner position → rest of encoded route
//     final trimmed = <LatLng>[partnerPos, ...points.sublist(nearestIdx)];
//
//     _polylines
//       ..removeWhere(
//         (p) =>
//             p.polylineId.value == 'route' ||
//             p.polylineId.value == 'route_solid',
//       )
//       ..add(
//         Polyline(
//           polylineId: const PolylineId('route'),
//           color: Colors.blue.shade300,
//           width: 5,
//           points: trimmed,
//           patterns: [PatternItem.dash(20), PatternItem.gap(10)],
//         ),
//       )
//       ..add(
//         Polyline(
//           polylineId: const PolylineId('route_solid'),
//           color: Colors.blue.withOpacity(0.4),
//           width: 2,
//           points: trimmed,
//         ),
//       );
//   }
//
//   // Non-async, non-awaited animation with a pending-position queue.
//   // If a new position arrives while animating, it is stored in
//   // _pendingPartnerPosition and processed the moment the current anim ends.
//   void _schedulePartnerMovement(LatLng to) {
//     if (_lastPartnerPosition == to) return; // 🔥 prevent duplicate
//
//     if (_isAnimating) {
//       _pendingPartnerPosition = to;
//       return;
//     }
//     _startPartnerAnimation(_lastPartnerPosition!, to);
//   }
//
//   void _startPartnerAnimation(LatLng from, LatLng to) {
//     if (!mounted) return;
//     _isAnimating = true;
//
//     _moveController?.stop();
//     _moveController?.dispose();
//     _moveController = null;
//
//     final bearing = _delivery != null
//         ? _calculateBearing(
//             to,
//             LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//           )
//         : _calculateBearing(from, to);
//
//     final controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _moveController = controller;
//
//     final latTween = Tween<double>(begin: from.latitude, end: to.latitude);
//     final lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
//     final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
//
//     controller.addListener(() {
//       if (!mounted) return;
//       final currentPos = LatLng(
//         latTween.evaluate(curved),
//         lngTween.evaluate(curved),
//       );
//       _currentAnimatedPosition = currentPos;
//
//       // ── FIX: Trim the polyline on every animation tick so the "behind"
//       //         segment disappears cleanly as the partner moves forward. ──────
//       if (_fullRoutePoints.isNotEmpty) {
//         _applyTrimmedPolyline(currentPos);
//       }
//
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
//       _markers.removeWhere((m) => m.markerId.value == 'partner');
//       _markers.add(_partnerMarker!);
//       _updateDeliveryProgressInternal(currentPos);
//       _notifyFullScreen();
//       if (mounted) setState(() {});
//     });
//
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed ||
//           status == AnimationStatus.dismissed) {
//         _lastPartnerPosition = to;
//         _currentAnimatedPosition = to;
//         _isAnimating = false;
//         _panMapToPartner(to);
//         _notifyFullScreen();
//
//         final pending = _pendingPartnerPosition;
//         if (pending != null && mounted) {
//           _pendingPartnerPosition = null;
//           _startPartnerAnimation(to, pending);
//         }
//       }
//     });
//
//     controller.forward();
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
//   Future<void> _drawPolyline() async {
//     if (_googleApiKey == null || _delivery == null) return;
//     final bool isOnTheWay = _currentOrderStatus == OrderStatus.ontheway;
//
//     final PointLatLng origin;
//     if (isOnTheWay && _currentAnimatedPosition != null) {
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
//       final result = await PolylinePoints().getRouteBetweenCoordinates(
//         request: PolylineRequest(
//           origin: origin,
//           destination: destination,
//           mode: TravelMode.driving,
//         ),
//         googleApiKey: _googleApiKey!,
//       );
//       if (result.points.isNotEmpty) {
//         final points = result.points
//             .map((p) => LatLng(p.latitude, p.longitude))
//             .toList();
//
//         // ── FIX: Save the full decoded route for later trimming ──────────────
//         _fullRoutePoints = points;
//
//         // Determine the correct trim origin:
//         // If the partner is already known, trim from their live position.
//         // Otherwise start from the beginning of the fetched route (vendor).
//         final trimFrom = _currentAnimatedPosition ?? points.first;
//         _applyTrimmedPolyline(trimFrom, points);
//
//         if (mounted) setState(() {});
//         _notifyFullScreen();
//       }
//     } catch (e) {
//       debugPrint('Error drawing polyline: $e');
//     }
//   }
//
//   void _updateDeliveryProgressInternal(LatLng partnerPosition) {
//     if (_delivery == null) return;
//     final total = Geolocator.distanceBetween(
//       _delivery!.vendorLatitude,
//       _delivery!.vendorLongitude,
//       _delivery!.userLatitude,
//       _delivery!.userLongitude,
//     );
//     if (total == 0) return;
//     final covered = Geolocator.distanceBetween(
//       _delivery!.vendorLatitude,
//       _delivery!.vendorLongitude,
//       partnerPosition.latitude,
//       partnerPosition.longitude,
//     );
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
//   Future<void> _refreshDeliveryData() async {
//     if (!mounted) return;
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
//     if (updated.partnerId != _subscribedPartnerId) _listenToWebSocket();
//     if (wasDelivered) _onDelivered();
//     widget.onRefresh?.call();
//   }
//
//   String get _formattedEta {
//     if (_etaLoading && _remainingEta == null) return 'Calculating...';
//     if (_remainingEta == null) return '--';
//     if (_remainingEta!.inSeconds <= 0) return 'Arriving soon';
//     final hours = _remainingEta!.inHours;
//     final minutes = _remainingEta!.inMinutes.remainder(60);
//     if (hours > 0) return '${hours}h ${minutes}min';
//     if (_remainingEta!.inMinutes < 1) return 'Arriving soon';
//     return '${_remainingEta!.inMinutes} min';
//   }
//
//   void _listenToWebSocket() {
//     if (_delivery == null) return;
//
//     if (!_wsSubscribed) {
//       _wsSubscribed = true;
//       WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
//         if (!mounted) return;
//         final newStatus = OrderStatus.fromString(data['status']);
//         if (newStatus == _currentOrderStatus) return;
//
//         final wasOnTheWay =
//             _currentOrderStatus != OrderStatus.ontheway &&
//             newStatus == OrderStatus.ontheway;
//
//         setState(() {
//           _currentOrderStatus = newStatus;
//           _setupDeliverySteps();
//           _setupStaticMarkers();
//         });
//
//         if (wasOnTheWay) _drawPolyline();
//
//         if (newStatus == OrderStatus.completed ||
//             newStatus == OrderStatus.cancelled) {
//           _refreshDeliveryData();
//         }
//       });
//     }
//
//     final partnerId = _delivery!.partnerId;
//     if (_subscribedPartnerId == partnerId) return;
//
//     if (_subscribedPartnerId != null) {
//       WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
//     }
//     _subscribedPartnerId = partnerId;
//
//     WebSocketManager().subscribePartnerLocation(partnerId, (data) {
//       debugPrint("📍 LOCATION WS DATA: $data");
//       if (!mounted) return;
//
//       final lat = (data['latitude'] as num?)?.toDouble();
//       final lng = (data['longitude'] as num?)?.toDouble();
//       if (lat == null || lng == null) return;
//
//       final newPosition = LatLng(lat, lng);
//
//       if (_lastPartnerPosition != null) {
//         _schedulePartnerMovement(newPosition);
//       } else {
//         // First-ever position — place marker immediately, no animation needed.
//         _lastPartnerPosition = newPosition;
//         _currentAnimatedPosition = newPosition;
//         final initialBearing = _delivery != null
//             ? _calculateBearing(
//                 newPosition,
//                 LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
//               )
//             : 0.0;
//         _addPartnerMarker(newPosition, bearing: initialBearing);
//
//         // ── FIX: Trim polyline on first ever WS position too ─────────────────
//         if (_fullRoutePoints.isNotEmpty) {
//           _applyTrimmedPolyline(newPosition);
//           if (mounted) setState(() {});
//         }
//         _notifyFullScreen();
//       }
//
//       _updateEtaBasedOnPosition(newPosition);
//       _updateDeliveryProgress(newPosition);
//       _notifyFullScreen();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_currentOrderStatus == OrderStatus.cancelled) {
//       return const SizedBox.shrink();
//     }
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
//   Widget _buildStatusHeader() {
//     final isDelivered = _currentOrderStatus == OrderStatus.completed;
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
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => FullScreenMapPage(
//               initialMarkers: Set.from(_markers),
//               initialPolylines: Set.from(_polylines),
//               initialEtaText: _formattedEta,
//               initialPartnerPosition: _currentAnimatedPosition,
//
//               onRegisterUpdater: (updater) {
//                 debugPrint("🟢 FULLSCREEN REGISTERED");
//                 _fullScreenUpdater = null; // clear old
//                 _fullScreenUpdater = updater;
//               },
//
//               onUnregisterUpdater: () {
//                 debugPrint("🔴 FULLSCREEN UNREGISTERED");
//                 _fullScreenUpdater = null;
//               },
//
//               partnerId: _delivery?.partnerId,
//             ),
//           ),
//         );
//       },
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
//   void _fitMapBounds() {
//     if (_delivery == null || _mapController == null) return;
//     final bounds = LatLngBounds(
//       southwest: LatLng(
//         min(_delivery!.vendorLatitude, _delivery!.userLatitude),
//         min(_delivery!.vendorLongitude, _delivery!.userLongitude),
//       ),
//       northeast: LatLng(
//         max(_delivery!.vendorLatitude, _delivery!.userLatitude),
//         max(_delivery!.vendorLongitude, _delivery!.userLongitude),
//       ),
//     );
//     _mapController!.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
//   }
//
//   Widget _buildPartnerInfo() {
//     if (_delivery?.deliveryPartnerName.isEmpty ?? true)
//       return const SizedBox.shrink();
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
// // ─────────────────────────────────────────────────────────────────────────────
//
// class DeliveryStep {
//   final String status;
//   final bool isCompleted;
//   final IconData icon;
//   DeliveryStep({
//     required this.status,
//     required this.isCompleted,
//     required this.icon,
//   });
// }
//
// class FullScreenMapPage extends StatefulWidget {
//   final Set<Marker> initialMarkers;
//   final Set<Polyline> initialPolylines;
//   final String initialEtaText;
//   final LatLng? initialPartnerPosition;
//   final void Function(LiveMapUpdater updater) onRegisterUpdater;
//   final VoidCallback onUnregisterUpdater;
//   final int? partnerId;
//
//   const FullScreenMapPage({
//     super.key,
//     required this.initialMarkers,
//     required this.initialPolylines,
//     required this.initialEtaText,
//     this.initialPartnerPosition,
//     required this.onRegisterUpdater,
//     required this.onUnregisterUpdater,
//     this.partnerId,
//   });
//
//   @override
//   State<FullScreenMapPage> createState() => _FullScreenMapPageState();
// }
//
// class _FullScreenMapPageState extends State<FullScreenMapPage>
//     with TickerProviderStateMixin {
//   GoogleMapController? _controller;
//   late Set<Marker> _markers;
//   late Set<Polyline> _polylines;
//   late String _etaText;
//   LatLng? _partnerPosition;
//
//   LatLng? _lastPosition;
//   AnimationController? _moveController;
//   double _bearing = 0;
//
//   // Pending queue — same pattern as parent
//   bool _isAnimating = false;
//   LatLng? _pendingPosition;
//
//   LiveMapUpdater? _mapUpdater;
//
//   @override
//   void initState() {
//     super.initState();
//     _markers = Set.from(widget.initialMarkers);
//     // ── FIX: Use the already-trimmed polylines passed from parent ────────────
//     _polylines = Set.from(widget.initialPolylines);
//     _etaText = widget.initialEtaText;
//     _partnerPosition = widget.initialPartnerPosition;
//     // Register so parent can push updates here directly.
//     widget.onRegisterUpdater(_applyUpdate);
//   }
//
//   @override
//   void dispose() {
//     _moveController?.stop();
//     _moveController?.dispose();
//     widget.onUnregisterUpdater();
//     _controller?.dispose();
//     super.dispose();
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
//   // ── FIX: Parent passes already-trimmed polylines on every tick.
//   //         We just apply them directly — no re-trimming needed here.
//   void _applyUpdate(
//     Set<Marker> markers,
//     Set<Polyline> polylines,
//     String etaText,
//     LatLng? partnerPosition,
//   ) {
//     if (!mounted) return;
//
//     // Apply markers and the trimmed polylines from parent immediately.
//     setState(() {
//       // ── FIX: Replace polylines wholesale with the trimmed set from parent ──
//       _polylines = Set.from(polylines);
//       _etaText = etaText;
//       // Merge non-partner markers from the update; partner is handled by
//       // our local animation so we keep it separate.
//       _markers = {
//         ...markers.where((m) => m.markerId.value != 'partner'),
//         ..._markers.where((m) => m.markerId.value == 'partner'),
//       };
//     });
//
//     if (partnerPosition != null) {
//       _scheduleAnimation(partnerPosition);
//     }
//   }
//
//   void _scheduleAnimation(LatLng to) {
//     if (_lastPosition == null) {
//       // Very first position: place immediately, no animation needed.
//       _lastPosition = to;
//       _updateMarkerAt(to);
//       return;
//     }
//     if (_isAnimating) {
//       _pendingPosition = to; // keep only the freshest pending
//       return;
//     }
//     _startAnimation(_lastPosition!, to);
//   }
//
//   void _startAnimation(LatLng from, LatLng to) {
//     if (!mounted) return;
//     _isAnimating = true;
//
//     _moveController?.stop();
//     _moveController?.dispose();
//     _moveController = null;
//
//     _bearing = _calculateBearing(from, to);
//
//     final controller = AnimationController(
//       vsync: this,
//       duration: const Duration(milliseconds: 1000),
//     );
//     _moveController = controller;
//
//     final latTween = Tween<double>(begin: from.latitude, end: to.latitude);
//     final lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
//     final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);
//
//     controller.addListener(() {
//       if (!mounted) return;
//       final pos = LatLng(latTween.evaluate(curved), lngTween.evaluate(curved));
//       // ── FIX: Only update the partner marker position here.
//       //         The polyline is already trimmed by the parent and arrives via
//       //         _applyUpdate — no re-trimming needed in the full-screen view. ──
//       _updateMarkerAt(pos);
//     });
//
//     controller.addStatusListener((status) {
//       if (status == AnimationStatus.completed ||
//           status == AnimationStatus.dismissed) {
//         _lastPosition = to;
//         _isAnimating = false;
//
//         final pending = _pendingPosition;
//         if (pending != null && mounted) {
//           _pendingPosition = null;
//           _startAnimation(to, pending);
//         }
//       }
//     });
//
//     controller.forward();
//   }
//
//   void _updateMarkerAt(LatLng pos) {
//     // Preserve the bike icon that was passed in from the parent.
//     final existing = _markers.where((m) => m.markerId.value == 'partner');
//     final icon = existing.isNotEmpty
//         ? existing.first.icon
//         : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
//
//     final marker = Marker(
//       markerId: const MarkerId('partner'),
//       position: pos,
//       rotation: _bearing,
//       flat: true,
//       anchor: const Offset(0.5, 0.5),
//       zIndex: 2,
//       icon: icon,
//       infoWindow: const InfoWindow(title: 'Delivery Partner'),
//     );
//
//     if (!mounted) return;
//     setState(() {
//       _partnerPosition = pos;
//       _markers = {
//         ..._markers.where((m) => m.markerId.value != 'partner'),
//         marker,
//       };
//     });
//
//     _controller?.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(target: pos, zoom: 17, bearing: _bearing),
//       ),
//     );
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
//     double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
//     for (final m in _markers) {
//       minLat = min(minLat, m.position.latitude);
//       maxLat = max(maxLat, m.position.latitude);
//       minLng = min(minLng, m.position.longitude);
//       maxLng = max(maxLng, m.position.longitude);
//     }
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
//             markers: _markers,
//             // ── FIX: _polylines is now always the trimmed set from parent ────
//             polylines: _polylines,
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
//           // Live ETA chip
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
//                 'ETA: $_etaText',
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

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../../../Models/delivery/fooddelivery.dart';
import '../../../Models/food/orders_model.dart';
import '../../../Services/Auth_service/delivery_service.dart';
import '../../../Services/googleservices/googleapiservice.dart';
import '../../../Services/websockets/web_socket_manager.dart';

// ---------------------------------------------------------------------------
// ModernDeliveryTracking
// ---------------------------------------------------------------------------
// FULLY SELF-CONTAINED:
//   • Subscribes to order-status WS independently (does not share the
//     parent screen's subscription).
//   • Subscribes to partner-location WS independently.
//   • Both subscriptions survive navigation away from the parent screen
//     as long as this widget is in the tree.
//   • FullScreenMapPage runs its OWN independent WS subscriptions — it
//     does not depend on callbacks from this widget at all.
// ---------------------------------------------------------------------------

class ModernDeliveryTracking extends StatefulWidget {
  final int orderId;
  final OrderStatus orderStatus;
  final DeliveryOrderModel? deliveryModel;
  final VoidCallback? onRefresh;

  const ModernDeliveryTracking({
    Key? key,
    required this.orderId,
    required this.orderStatus,
    this.deliveryModel,
    this.onRefresh,
  }) : super(key: key);

  @override
  State<ModernDeliveryTracking> createState() => _ModernDeliveryTrackingState();
}

class _ModernDeliveryTrackingState extends State<ModernDeliveryTracking>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // ── Map ──────────────────────────────────────────────────────────────────
  GoogleMapController? _mapController;
  DeliveryOrderModel? _delivery;

  // ── Animations ───────────────────────────────────────────────────────────
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;
  AnimationController? _moveController;

  // ── Map data ─────────────────────────────────────────────────────────────
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  Marker? _partnerMarker;

  /// Confirmed resting position (end of last completed animation).
  LatLng? _lastPartnerPosition;

  /// Live interpolated position during animation.
  LatLng? _currentAnimatedPosition;

  /// Next target queued while an animation is running.
  LatLng? _pendingPartnerPosition;
  bool _isAnimating = false;

  // ── Marker icons ─────────────────────────────────────────────────────────
  BitmapDescriptor? _bikeIcon;
  BitmapDescriptor? _vendorIcon;
  BitmapDescriptor? _customerIcon;

  // ── Full route (for polyline trimming) ───────────────────────────────────
  List<LatLng> _fullRoutePoints = [];

  // ── ETA ──────────────────────────────────────────────────────────────────
  Timer? _etaCountdownTimer;
  Timer? _etaRefreshTimer;
  Duration? _remainingEta;
  bool _etaLoading = false;
  DateTime? _orderStartTime;
  DateTime? _estimatedArrival;
  DateTime? _deliveredAt;
  int? _deliveredInMinutes;
  bool _deliveryWasEarly = false;
  bool _deliveryWasLate = false;

  // ── WebSocket state ───────────────────────────────────────────────────────
  bool _wsOrderSubscribed = false;
  int? _subscribedPartnerId;

  // ── General ──────────────────────────────────────────────────────────────
  String? _googleApiKey;
  bool _isLoading = true;
  double _deliveryProgress = 0.0;
  late OrderStatus _currentOrderStatus;

  // ── Debounce: avoid hammering ETA API ────────────────────────────────────
  DateTime? _lastEtaFetch;
  static const _etaDebounce = Duration(seconds: 20);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentOrderStatus = widget.orderStatus;
    _initializeAnimations();
    _loadDeliveryData();
  }

  @override
  void didUpdateWidget(ModernDeliveryTracking old) {
    super.didUpdateWidget(old);
    // If parent passes a newer status (e.g. from the parent's own WS),
    // merge it without overriding our own WS.
    if (old.orderStatus != widget.orderStatus &&
        widget.orderStatus != _currentOrderStatus) {
      _handleStatusChange(widget.orderStatus);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Re-connect WS if app came back from background
      if (_delivery != null) _listenToWebSocket();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _slideController.dispose();
    _moveController?.stop();
    _moveController?.dispose();
    _etaCountdownTimer?.cancel();
    _etaRefreshTimer?.cancel();
    _mapController?.dispose();

    if (_wsOrderSubscribed) {
      WebSocketManager().unsubscribeOrderStatus(widget.orderId);
    }
    if (_subscribedPartnerId != null) {
      WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
    }
    super.dispose();
  }

  // ── Animations ────────────────────────────────────────────────────────────

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideController, curve: Curves.easeOut));

    _slideController.forward();
  }

  // ── Data Loading ──────────────────────────────────────────────────────────

  Future<void> _loadDeliveryData() async {
    if (mounted) setState(() => _isLoading = true);
    try {
      _googleApiKey = await ApiKeyService.getApiKey();
      _delivery =
          widget.deliveryModel ??
          await DeliveryOrderService.getOrder(widget.orderId);

      if (_delivery != null) {
        _orderStartTime = DateTime.now();
        await _loadCustomIcons();
        _setupStaticMarkers();
        await _drawPolyline();

        final partnerLat = _delivery!.deliveryPartnerLatitude;
        final partnerLng = _delivery!.deliveryPartnerLongitude;

        if (partnerLat != 0 && partnerLng != 0) {
          final partnerPos = LatLng(partnerLat, partnerLng);
          _lastPartnerPosition = partnerPos;
          _currentAnimatedPosition = partnerPos;
          final bearing = _calculateBearing(
            partnerPos,
            LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
          );
          _addPartnerMarker(partnerPos, bearing: bearing);
          if (_fullRoutePoints.isNotEmpty) {
            _applyTrimmedPolyline(partnerPos);
          }
          await _fetchRealEta(partnerPos);
        } else {
          await _fetchRealEta(
            LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude),
          );
        }

        _calculateInitialProgress();
        _startEtaCountdown();
        _startPeriodicEtaRefresh();
        _checkIfAlreadyDelivered();
        _listenToWebSocket();
      }
    } catch (e) {
      debugPrint('Error loading delivery data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── ETA ───────────────────────────────────────────────────────────────────

  Future<void> _fetchRealEta(LatLng origin) async {
    if (_googleApiKey == null || _delivery == null) return;
    if (_currentOrderStatus == OrderStatus.completed) return;

    // Debounce: don't hammer the Distance Matrix API
    final now = DateTime.now();
    if (_lastEtaFetch != null && now.difference(_lastEtaFetch!) < _etaDebounce)
      return;
    _lastEtaFetch = now;

    if (mounted) setState(() => _etaLoading = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=${origin.latitude},${origin.longitude}'
        '&destinations=${_delivery!.userLatitude},${_delivery!.userLongitude}'
        '&mode=driving&departure_time=now&key=$_googleApiKey',
      );
      final response = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final elements = data['rows']?[0]?['elements']?[0];
        if (elements != null && elements['status'] == 'OK') {
          final durationSeconds =
              (elements['duration_in_traffic'] ??
                      elements['duration'])?['value']
                  as int?;
          if (durationSeconds != null) {
            setState(() {
              _remainingEta = Duration(seconds: durationSeconds);
              _estimatedArrival = DateTime.now().add(
                Duration(seconds: durationSeconds),
              );
              _etaLoading = false;
            });
            return;
          }
        }
      }
    } catch (e) {
      debugPrint('Distance Matrix error: $e');
    } finally {
      if (mounted && _etaLoading) setState(() => _etaLoading = false);
    }
    _straightLineFallback(origin);
  }

  void _straightLineFallback(LatLng origin) {
    if (_delivery == null || !mounted) return;
    final distance = Geolocator.distanceBetween(
      origin.latitude,
      origin.longitude,
      _delivery!.userLatitude,
      _delivery!.userLongitude,
    );
    final etaSeconds = (distance / 6.94).round();
    setState(() {
      _remainingEta = Duration(seconds: etaSeconds);
      _estimatedArrival = DateTime.now().add(Duration(seconds: etaSeconds));
    });
  }

  void _updateEtaIfMoved(LatLng newPosition) {
    if (_currentOrderStatus == OrderStatus.completed) return;
    if (_lastPartnerPosition != null) {
      final distance = Geolocator.distanceBetween(
        _lastPartnerPosition!.latitude,
        _lastPartnerPosition!.longitude,
        newPosition.latitude,
        newPosition.longitude,
      );
      // Only refresh ETA if partner moved at least 50 m
      if (distance < 50) return;
    }
    _fetchRealEta(newPosition);
  }

  void _startPeriodicEtaRefresh() {
    _etaRefreshTimer?.cancel();
    _etaRefreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      if (!mounted) return;
      if (_currentOrderStatus == OrderStatus.completed) {
        _etaRefreshTimer?.cancel();
        return;
      }
      final origin =
          _currentAnimatedPosition ??
          ((_delivery?.deliveryPartnerLatitude ?? 0) != 0
              ? LatLng(
                  _delivery!.deliveryPartnerLatitude,
                  _delivery!.deliveryPartnerLongitude,
                )
              : LatLng(
                  _delivery?.vendorLatitude ?? 0,
                  _delivery?.vendorLongitude ?? 0,
                ));
      _fetchRealEta(origin);
    });
  }

  void _startEtaCountdown() {
    _etaCountdownTimer?.cancel();
    _etaCountdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_currentOrderStatus == OrderStatus.completed) {
        _etaCountdownTimer?.cancel();
        return;
      }
      if (_remainingEta == null || _remainingEta!.inSeconds <= 0) return;
      setState(
        () => _remainingEta = _remainingEta! - const Duration(seconds: 1),
      );
    });
  }

  void _onDelivered() {
    _etaCountdownTimer?.cancel();
    _etaRefreshTimer?.cancel();
    _moveController?.stop();
    _deliveredAt = DateTime.now();
    _deliveredInMinutes = _orderStartTime != null
        ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
        : null;
    if (_estimatedArrival != null) {
      final diff = _deliveredAt!.difference(_estimatedArrival!).inMinutes;
      _deliveryWasEarly = diff < -2;
      _deliveryWasLate = diff > 5;
    }
    if (mounted) {
      setState(() {
        _remainingEta = null;
        _currentOrderStatus = OrderStatus.completed;
      });
    }
  }

  void _checkIfAlreadyDelivered() {
    if (_currentOrderStatus != OrderStatus.completed) return;
    _deliveredAt = DateTime.now();
    _deliveredInMinutes = _orderStartTime != null
        ? _deliveredAt!.difference(_orderStartTime!).inMinutes.clamp(1, 999)
        : null;
    _remainingEta = null;
  }

  // ── Icons ─────────────────────────────────────────────────────────────────

  Future<void> _loadCustomIcons() async {
    _vendorIcon = await _createCustomMarker(Icons.store, Colors.orange, 80);
    _customerIcon = await _createCustomMarker(Icons.home, Colors.blue, 80);
    _bikeIcon = await _createDirectionalBikeIcon();
  }

  Future<BitmapDescriptor> _createDirectionalBikeIcon() async {
    const double size = 120;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    // Shadow
    canvas.drawCircle(
      center,
      size / 2 - 4,
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    // Circle background
    canvas.drawCircle(
      center,
      size / 2 - 8,
      Paint()..color = Colors.green.shade600,
    );
    // White ring
    canvas.drawCircle(
      center,
      size / 2 - 8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    // Bike icon
    final bikeText = TextPainter(textDirection: TextDirection.ltr);
    bikeText.text = TextSpan(
      text: String.fromCharCode(Icons.delivery_dining.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: Icons.delivery_dining.fontFamily,
        package: Icons.delivery_dining.fontPackage,
        color: Colors.white,
      ),
    );
    bikeText.layout();
    bikeText.paint(
      canvas,
      Offset(center.dx - bikeText.width / 2, center.dy - bikeText.height / 2),
    );

    // Direction arrow at the top (always north — we use marker.rotation)
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, 6)
        ..lineTo(center.dx - 9, 22)
        ..lineTo(center.dx + 9, 22)
        ..close(),
      Paint()..color = Colors.white,
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  Future<BitmapDescriptor> _createCustomMarker(
    IconData icon,
    Color color,
    double size,
  ) async {
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final textPainter = TextPainter(textDirection: ui.TextDirection.ltr);
    textPainter.text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: size,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: color,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset.zero);
    final picture = recorder.endRecording();
    final image = await picture.toImage(size.toInt(), size.toInt());
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  }

  // ── Markers ───────────────────────────────────────────────────────────────

  void _setupStaticMarkers() {
    if (_delivery == null) return;
    _markers.removeWhere(
      (m) => m.markerId.value == 'vendor' || m.markerId.value == 'customer',
    );

    // Show vendor marker only before pickup
    if (_currentOrderStatus != OrderStatus.ontheway &&
        _currentOrderStatus != OrderStatus.completed) {
      _markers.add(
        Marker(
          markerId: const MarkerId('vendor'),
          position: LatLng(
            _delivery!.vendorLatitude,
            _delivery!.vendorLongitude,
          ),
          icon:
              _vendorIcon ??
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          infoWindow: const InfoWindow(title: 'Restaurant'),
        ),
      );
    }

    _markers.add(
      Marker(
        markerId: const MarkerId('customer'),
        position: LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
        icon:
            _customerIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: const InfoWindow(title: 'Your location'),
      ),
    );

    if (mounted) setState(() {});
  }

  void _addPartnerMarker(LatLng position, {required double bearing}) {
    _partnerMarker = Marker(
      markerId: const MarkerId('partner'),
      position: position,
      icon:
          _bikeIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      rotation: bearing,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndex: 2,
      infoWindow: const InfoWindow(title: 'Delivery Partner'),
    );
    _markers.removeWhere((m) => m.markerId.value == 'partner');
    _markers.add(_partnerMarker!);
    if (mounted) setState(() {});
  }

  // ── Polyline ──────────────────────────────────────────────────────────────

  Future<void> _drawPolyline() async {
    if (_googleApiKey == null || _delivery == null) return;

    final bool isOnTheWay = _currentOrderStatus == OrderStatus.ontheway;

    final PointLatLng origin;
    if (isOnTheWay && _currentAnimatedPosition != null) {
      origin = PointLatLng(
        _currentAnimatedPosition!.latitude,
        _currentAnimatedPosition!.longitude,
      );
    } else if (isOnTheWay &&
        _delivery!.deliveryPartnerLatitude != 0 &&
        _delivery!.deliveryPartnerLongitude != 0) {
      origin = PointLatLng(
        _delivery!.deliveryPartnerLatitude,
        _delivery!.deliveryPartnerLongitude,
      );
    } else {
      origin = PointLatLng(
        _delivery!.vendorLatitude,
        _delivery!.vendorLongitude,
      );
    }

    final destination = PointLatLng(
      _delivery!.userLatitude,
      _delivery!.userLongitude,
    );

    try {
      final result = await PolylinePoints().getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: origin,
          destination: destination,
          mode: TravelMode.driving,
        ),
        googleApiKey: _googleApiKey!,
      );
      if (result.points.isNotEmpty) {
        final points = result.points
            .map((p) => LatLng(p.latitude, p.longitude))
            .toList();
        _fullRoutePoints = points;

        final trimFrom = _currentAnimatedPosition ?? points.first;
        _applyTrimmedPolyline(trimFrom, points);

        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error drawing polyline: $e');
    }
  }

  /// Finds the route point nearest to [partner].
  int _nearestPointIndex(List<LatLng> points, LatLng partner) {
    double minDist = double.infinity;
    int idx = 0;
    for (int i = 0; i < points.length; i++) {
      final d = Geolocator.distanceBetween(
        partner.latitude,
        partner.longitude,
        points[i].latitude,
        points[i].longitude,
      );
      if (d < minDist) {
        minDist = d;
        idx = i;
      }
    }
    return idx;
  }

  /// Trims the polyline to show only the remaining route ahead of the partner.
  void _applyTrimmedPolyline(LatLng partnerPos, [List<LatLng>? routePoints]) {
    final points = routePoints ?? _fullRoutePoints;
    if (points.isEmpty) return;

    final nearestIdx = _nearestPointIndex(points, partnerPos);
    final trimmed = <LatLng>[partnerPos, ...points.sublist(nearestIdx)];

    _polylines
      ..removeWhere(
        (p) =>
            p.polylineId.value == 'route' ||
            p.polylineId.value == 'route_solid' ||
            p.polylineId.value == 'route_glow',
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route_glow'),
          color: Colors.blue.withOpacity(0.15),
          width: 10,
          points: trimmed,
        ),
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue.shade600,
          width: 5,
          points: trimmed,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route_solid'),
          color: Colors.blue.withOpacity(0.35),
          width: 2,
          points: trimmed,
        ),
      );
  }

  // ── Partner Animation ─────────────────────────────────────────────────────

  void _schedulePartnerMovement(LatLng to) {
    if (_lastPartnerPosition == to) return;

    if (_isAnimating) {
      _pendingPartnerPosition = to; // keep only latest
      return;
    }
    _startPartnerAnimation(_lastPartnerPosition!, to);
  }

  void _startPartnerAnimation(LatLng from, LatLng to) {
    if (!mounted) return;
    _isAnimating = true;

    _moveController?.stop();
    _moveController?.dispose();
    _moveController = null;

    final bearing = _delivery != null
        ? _calculateBearing(
            to,
            LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
          )
        : _calculateBearing(from, to);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _moveController = controller;

    final latTween = Tween<double>(begin: from.latitude, end: to.latitude);
    final lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      if (!mounted) return;
      final currentPos = LatLng(
        latTween.evaluate(curved),
        lngTween.evaluate(curved),
      );
      _currentAnimatedPosition = currentPos;

      if (_fullRoutePoints.isNotEmpty) {
        _applyTrimmedPolyline(currentPos);
      }

      _partnerMarker = Marker(
        markerId: const MarkerId('partner'),
        position: currentPos,
        icon:
            _bikeIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        rotation: bearing,
        anchor: const Offset(0.5, 0.5),
        flat: true,
        zIndex: 2,
        infoWindow: const InfoWindow(title: 'Delivery Partner'),
      );
      _markers.removeWhere((m) => m.markerId.value == 'partner');
      _markers.add(_partnerMarker!);
      _updateDeliveryProgressInternal(currentPos);

      if (mounted) setState(() {});
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _lastPartnerPosition = to;
        _currentAnimatedPosition = to;
        _isAnimating = false;

        // Smooth pan: follow partner but don't disrupt user panning
        _mapController?.animateCamera(CameraUpdate.newLatLng(to));

        final pending = _pendingPartnerPosition;
        if (pending != null && mounted) {
          _pendingPartnerPosition = null;
          _startPartnerAnimation(to, pending);
        }
      }
    });

    controller.forward();
  }

  double _calculateBearing(LatLng start, LatLng end) {
    if (start.latitude == end.latitude && start.longitude == end.longitude) {
      return 0;
    }
    final lat1 = start.latitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final dLon = (end.longitude - start.longitude) * pi / 180;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  // ── Progress ──────────────────────────────────────────────────────────────

  void _updateDeliveryProgressInternal(LatLng partnerPosition) {
    if (_delivery == null) return;
    final total = Geolocator.distanceBetween(
      _delivery!.vendorLatitude,
      _delivery!.vendorLongitude,
      _delivery!.userLatitude,
      _delivery!.userLongitude,
    );
    if (total == 0) return;
    final covered = Geolocator.distanceBetween(
      _delivery!.vendorLatitude,
      _delivery!.vendorLongitude,
      partnerPosition.latitude,
      partnerPosition.longitude,
    );
    _deliveryProgress = (covered / total).clamp(0.0, 1.0);
  }

  void _calculateInitialProgress() {
    if (_lastPartnerPosition == null) return;
    _updateDeliveryProgressInternal(_lastPartnerPosition!);
    if (mounted) setState(() {});
  }

  // ── WebSocket ─────────────────────────────────────────────────────────────

  void _listenToWebSocket() {
    if (_delivery == null) return;

    // ── Order-status subscription ────────────────────────────────────────
    if (!_wsOrderSubscribed) {
      _wsOrderSubscribed = true;
      WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
        if (!mounted) return;
        final newStatus = OrderStatus.fromString(
          data['status'] as String? ?? '',
        );
        _handleStatusChange(newStatus);
      });
    }

    // ── Partner-location subscription ────────────────────────────────────
    final partnerId = _delivery!.partnerId;
    if (_subscribedPartnerId == partnerId) return; // already subscribed

    if (_subscribedPartnerId != null) {
      WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
    }
    _subscribedPartnerId = partnerId;

    WebSocketManager().subscribePartnerLocation(partnerId, (data) {
      debugPrint('📍 LOCATION WS: $data');
      if (!mounted) return;

      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);

      if (_lastPartnerPosition != null) {
        _schedulePartnerMovement(newPos);
      } else {
        // First-ever position — place immediately
        _lastPartnerPosition = newPos;
        _currentAnimatedPosition = newPos;
        final bearing = _delivery != null
            ? _calculateBearing(
                newPos,
                LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
              )
            : 0.0;
        _addPartnerMarker(newPos, bearing: bearing);
        if (_fullRoutePoints.isNotEmpty) {
          _applyTrimmedPolyline(newPos);
          if (mounted) setState(() {});
        }
      }

      _updateEtaIfMoved(newPos);
      _updateDeliveryProgressInternal(newPos);
      if (mounted) setState(() {});
    });
  }

  void _handleStatusChange(OrderStatus newStatus) {
    if (newStatus == _currentOrderStatus) return;

    final wasOnTheWay =
        _currentOrderStatus != OrderStatus.ontheway &&
        newStatus == OrderStatus.ontheway;

    setState(() {
      _currentOrderStatus = newStatus;
      _setupStaticMarkers();
    });

    if (wasOnTheWay) _drawPolyline();

    if (newStatus == OrderStatus.completed) {
      _onDelivered();
      _refreshDeliveryData();
    } else if (newStatus == OrderStatus.cancelled) {
      _refreshDeliveryData();
    }
  }

  Future<void> _refreshDeliveryData() async {
    if (!mounted) return;
    final updated = await DeliveryOrderService.getOrder(widget.orderId);
    if (updated == null || !mounted) return;

    setState(() => _delivery = updated);

    // If partner changed (reassignment), re-subscribe to new partner
    if (updated.partnerId != _subscribedPartnerId) _listenToWebSocket();

    widget.onRefresh?.call();
  }

  // ── ETA helpers ───────────────────────────────────────────────────────────

  String get _formattedEta {
    if (_etaLoading && _remainingEta == null) return 'Calculating...';
    if (_remainingEta == null) return '--';
    if (_remainingEta!.inSeconds <= 0) return 'Arriving soon';
    final hours = _remainingEta!.inHours;
    final minutes = _remainingEta!.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}min';
    if (_remainingEta!.inMinutes < 1) return 'Arriving soon';
    return '${_remainingEta!.inMinutes} min';
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    if (_currentOrderStatus == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: _isLoading ? _buildShimmer() : _buildDeliveryTracking(),
    );
  }

  Widget _buildShimmer() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildDeliveryTracking() {
    return SlideTransition(
      position: _slideAnimation,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            _buildStatusHeader(),
            if (_currentOrderStatus == OrderStatus.ontheway ||
                _currentOrderStatus == OrderStatus.waitingForPickup)
              _buildProgressMap(),
            _buildPartnerInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    final isDelivered = _currentOrderStatus == OrderStatus.completed;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _getStatusColor(),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(_getStatusIcon(), color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getStatusTitle(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStatusSubtitle(),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
                if (isDelivered) ...[
                  const SizedBox(height: 6),
                  _buildDeliveryBadge(),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          if (!isDelivered) ...[
            if (_etaLoading && _remainingEta == null)
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            else if (_remainingEta != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  children: [
                    const Text(
                      'ETA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      _formattedEta,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
          ],
          if (isDelivered && _deliveredInMinutes != null)
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withOpacity(0.4),
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_deliveredInMinutes',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      height: 1,
                    ),
                  ),
                  Text(
                    'min',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDeliveryBadge() {
    final String label;
    final Color color;
    if (_deliveryWasEarly) {
      label = '🚀 Early!';
      color = const Color(0xFF1565C0);
    } else if (_deliveryWasLate) {
      label = '⏰ Late';
      color = Colors.orange.shade700;
    } else {
      label = '✅ On Time';
      color = const Color(0xFF2E7D32);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getStatusColor() {
    switch (_currentOrderStatus) {
      case OrderStatus.completed:
        return Colors.green.shade700;
      case OrderStatus.ontheway:
        return Colors.blue;
      case OrderStatus.waitingForPickup:
        return Colors.orange;
      default:
        return Colors.purple;
    }
  }

  IconData _getStatusIcon() {
    switch (_currentOrderStatus) {
      case OrderStatus.completed:
        return Icons.verified;
      case OrderStatus.ontheway:
        return Icons.delivery_dining;
      case OrderStatus.waitingForPickup:
        return Icons.inventory;
      case OrderStatus.beingPrepared:
        return Icons.restaurant;
      default:
        return Icons.pending;
    }
  }

  String _getStatusTitle() {
    switch (_currentOrderStatus) {
      case OrderStatus.pending:
        return 'Order Pending';
      case OrderStatus.confirmed:
        return 'Order Confirmed';
      case OrderStatus.processing:
        return 'Processing Order';
      case OrderStatus.beingPrepared:
        return 'Preparing Your Food';
      case OrderStatus.orderIsReady:
        return 'Order Ready';
      case OrderStatus.waitingForPickup:
        return 'Waiting for Pickup';
      case OrderStatus.ontheway:
        return 'On The Way';
      case OrderStatus.completed:
        return 'Order Delivered! 🎉';
      case OrderStatus.cancelled:
        return 'Order Cancelled';
      case OrderStatus.hold:
        return 'On Hold';
      default:
        return 'Processing your order';
    }
  }

  String _getStatusSubtitle() {
    switch (_currentOrderStatus) {
      case OrderStatus.pending:
        return 'Waiting for confirmation';
      case OrderStatus.confirmed:
        return 'Restaurant confirmed your order';
      case OrderStatus.processing:
        return 'Order is being processed';
      case OrderStatus.beingPrepared:
        return 'Restaurant is preparing your food';
      case OrderStatus.orderIsReady:
        return 'Order is ready for pickup';
      case OrderStatus.waitingForPickup:
        return 'Delivery partner is on the way to restaurant';
      case OrderStatus.ontheway:
        return 'Your food is on the way';
      case OrderStatus.completed:
        return _deliveredInMinutes != null
            ? 'Delivered in $_deliveredInMinutes min'
            : 'Delivered successfully';
      case OrderStatus.cancelled:
        return 'Order was cancelled';
      case OrderStatus.hold:
        return 'Order is on hold';
      default:
        return 'Processing your order';
    }
  }

  // ── Mini Map ──────────────────────────────────────────────────────────────

  Widget _buildProgressMap() {
    final initialTarget =
        _currentAnimatedPosition ??
        _lastPartnerPosition ??
        LatLng(
          _delivery?.vendorLatitude ?? 17.385044,
          _delivery?.vendorLongitude ?? 78.486671,
        );

    return GestureDetector(
      onTap: () {
        // Open full-screen map — it runs its own independent WS
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullScreenMapPage(
              orderId: widget.orderId,
              initialMarkers: Set.from(_markers),
              initialPolylines: Set.from(_polylines),
              initialEtaText: _formattedEta,
              initialPartnerPosition: _currentAnimatedPosition,
              partnerId: _delivery?.partnerId,
              userLatLng: _delivery != null
                  ? LatLng(_delivery!.userLatitude, _delivery!.userLongitude)
                  : null,
              vendorLatLng: _delivery != null
                  ? LatLng(
                      _delivery!.vendorLatitude,
                      _delivery!.vendorLongitude,
                    )
                  : null,
              googleApiKey: _googleApiKey,
            ),
          ),
        );
      },
      child: Container(
        height: 160,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: initialTarget,
                  zoom: 14,
                ),
                markers: _markers,
                polylines: _polylines,
                zoomControlsEnabled: false,
                myLocationEnabled: false,
                compassEnabled: false,
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
                onMapCreated: (c) {
                  _mapController = c;
                  Future.delayed(
                    const Duration(milliseconds: 300),
                    _fitMapBounds,
                  );
                },
                gestureRecognizers: {
                  Factory<OneSequenceGestureRecognizer>(
                    () => EagerGestureRecognizer(),
                  ),
                },
              ),
              // Gradient + stats overlay
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.65),
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.delivery_dining,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Tap to view full map',
                          style: TextStyle(color: Colors.white, fontSize: 12),
                        ),
                      ),
                      // Progress pill
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${(_deliveryProgress * 100).toInt()}%',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (_remainingEta != null) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _formattedEta,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _fitMapBounds() {
    if (_delivery == null || _mapController == null) return;
    final points = <LatLng>[
      LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude),
      LatLng(_delivery!.userLatitude, _delivery!.userLongitude),
      if (_currentAnimatedPosition != null) _currentAnimatedPosition!,
    ];
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final p in points) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }
    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        50,
      ),
    );
  }

  Widget _buildPartnerInfo() {
    if (_delivery?.deliveryPartnerName.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.green.shade100,
            child: const Icon(Icons.person, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _delivery!.deliveryPartnerName,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Vehicle: ${_delivery!.vehicleStatus.name.replaceAll('_', ' ')}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 2),
                Text(
                  'OTP: ${_delivery?.userOtp.toString() ?? '0'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// FullScreenMapPage — COMPLETELY INDEPENDENT
// ---------------------------------------------------------------------------
// Runs its OWN WebSocket subscriptions for partner location AND order status.
// Does NOT depend on any callback from ModernDeliveryTracking.
// When closed, it cleans up its own WS subscriptions.
// ---------------------------------------------------------------------------

class FullScreenMapPage extends StatefulWidget {
  final int orderId;
  final Set<Marker> initialMarkers;
  final Set<Polyline> initialPolylines;
  final String initialEtaText;
  final LatLng? initialPartnerPosition;
  final int? partnerId;
  final LatLng? userLatLng;
  final LatLng? vendorLatLng;
  final String? googleApiKey;

  const FullScreenMapPage({
    super.key,
    required this.orderId,
    required this.initialMarkers,
    required this.initialPolylines,
    required this.initialEtaText,
    this.initialPartnerPosition,
    this.partnerId,
    this.userLatLng,
    this.vendorLatLng,
    this.googleApiKey,
  });

  @override
  State<FullScreenMapPage> createState() => _FullScreenMapPageState();
}

class _FullScreenMapPageState extends State<FullScreenMapPage>
    with TickerProviderStateMixin {
  GoogleMapController? _controller;
  late Set<Marker> _markers;
  late Set<Polyline> _polylines;
  String _etaText = '';
  LatLng? _partnerPosition;

  // ── Partner animation ─────────────────────────────────────────────────────
  LatLng? _lastPosition;
  AnimationController? _moveController;
  double _bearing = 0;
  bool _isAnimating = false;
  LatLng? _pendingPosition;

  // ── Route ──────────────────────────────────────────────────────────────
  List<LatLng> _fullRoutePoints = [];

  // ── WS ────────────────────────────────────────────────────────────────────
  int? _subscribedPartnerId;
  bool _wsOrderSubscribed = false;
  OrderStatus _currentOrderStatus = OrderStatus.ontheway;

  // ── ETA ──────────────────────────────────────────────────────────────────
  Duration? _remainingEta;
  Timer? _etaTimer;
  DateTime? _lastEtaFetch;
  static const _etaDebounce = Duration(seconds: 20);

  // ── Icon ─────────────────────────────────────────────────────────────────
  BitmapDescriptor? _bikeIcon;

  @override
  void initState() {
    super.initState();
    _markers = Set.from(widget.initialMarkers);
    _polylines = Set.from(widget.initialPolylines);
    _etaText = widget.initialEtaText;
    _partnerPosition = widget.initialPartnerPosition;

    // Seed last position so first WS update triggers animation
    if (widget.initialPartnerPosition != null) {
      _lastPosition = widget.initialPartnerPosition;
    }

    // Extract full route from passed-in polylines (use the longest one)
    final routePoly = widget.initialPolylines
        .where((p) => p.polylineId.value == 'route')
        .firstOrNull;
    if (routePoly != null) _fullRoutePoints = List.from(routePoly.points);

    _loadBikeIcon().then((_) {
      _startWs();
      _startEtaCountdown();
    });
  }

  @override
  void dispose() {
    _moveController?.stop();
    _moveController?.dispose();
    _etaTimer?.cancel();
    _controller?.dispose();
    if (_wsOrderSubscribed) {
      WebSocketManager().unsubscribeOrderStatus(widget.orderId);
    }
    if (_subscribedPartnerId != null) {
      WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
    }
    super.dispose();
  }

  // ── Own WS ────────────────────────────────────────────────────────────────

  void _startWs() {
    // Order-status
    if (!_wsOrderSubscribed) {
      _wsOrderSubscribed = true;
      WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
        if (!mounted) return;
        final newStatus = OrderStatus.fromString(
          data['status'] as String? ?? '',
        );
        if (newStatus != _currentOrderStatus) {
          setState(() => _currentOrderStatus = newStatus);
        }
        if (newStatus == OrderStatus.completed) {
          setState(() => _etaText = 'Delivered!');
          _etaTimer?.cancel();
        }
      });
    }

    // Partner location
    final partnerId = widget.partnerId;
    if (partnerId == null) return;
    if (_subscribedPartnerId == partnerId) return;

    if (_subscribedPartnerId != null) {
      WebSocketManager().unsubscribePartnerLocation(_subscribedPartnerId!);
    }
    _subscribedPartnerId = partnerId;

    WebSocketManager().subscribePartnerLocation(partnerId, (data) {
      debugPrint('🗺️ FULLSCREEN LOC: $data');
      if (!mounted) return;

      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);
      _scheduleAnimation(newPos);
      _refreshEtaIfMoved(newPos);
    });
  }

  // ── ETA (own refresh) ─────────────────────────────────────────────────────

  void _startEtaCountdown() {
    // Parse initial ETA from text (best-effort)
    _etaTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      if (_remainingEta == null || _remainingEta!.inSeconds <= 0) return;
      setState(() {
        _remainingEta = _remainingEta! - const Duration(seconds: 1);
        _etaText = _fmtEta(_remainingEta!);
      });
    });
  }

  Future<void> _refreshEtaIfMoved(LatLng newPos) async {
    if (widget.googleApiKey == null || widget.userLatLng == null) return;
    if (_currentOrderStatus == OrderStatus.completed) return;

    // Debounce
    final now = DateTime.now();
    if (_lastEtaFetch != null && now.difference(_lastEtaFetch!) < _etaDebounce)
      return;
    if (_lastPosition != null) {
      final moved = Geolocator.distanceBetween(
        _lastPosition!.latitude,
        _lastPosition!.longitude,
        newPos.latitude,
        newPos.longitude,
      );
      if (moved < 50) return;
    }
    _lastEtaFetch = now;

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/distancematrix/json'
        '?origins=${newPos.latitude},${newPos.longitude}'
        '&destinations=${widget.userLatLng!.latitude},${widget.userLatLng!.longitude}'
        '&mode=driving&departure_time=now&key=${widget.googleApiKey}',
      );
      final resp = await http.get(url).timeout(const Duration(seconds: 10));
      if (!mounted) return;
      if (resp.statusCode == 200) {
        final d = jsonDecode(resp.body);
        final el = d['rows']?[0]?['elements']?[0];
        if (el != null && el['status'] == 'OK') {
          final secs =
              (el['duration_in_traffic'] ?? el['duration'])?['value'] as int?;
          if (secs != null) {
            setState(() {
              _remainingEta = Duration(seconds: secs);
              _etaText = _fmtEta(_remainingEta!);
            });
          }
        }
      }
    } catch (_) {}
  }

  String _fmtEta(Duration d) {
    if (d.inSeconds <= 0) return 'Arriving soon';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}min';
    if (d.inMinutes < 1) return 'Arriving soon';
    return '${d.inMinutes} min';
  }

  // ── Icon ──────────────────────────────────────────────────────────────────

  Future<void> _loadBikeIcon() async {
    const double size = 120;
    final recorder = PictureRecorder();
    final canvas = Canvas(recorder);
    final center = Offset(size / 2, size / 2);

    canvas.drawCircle(
      center,
      size / 2 - 4,
      Paint()
        ..color = Colors.black.withOpacity(0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    canvas.drawCircle(
      center,
      size / 2 - 8,
      Paint()..color = Colors.green.shade600,
    );
    canvas.drawCircle(
      center,
      size / 2 - 8,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );
    final tp = TextPainter(textDirection: TextDirection.ltr);
    tp.text = TextSpan(
      text: String.fromCharCode(Icons.delivery_dining.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: Icons.delivery_dining.fontFamily,
        package: Icons.delivery_dining.fontPackage,
        color: Colors.white,
      ),
    );
    tp.layout();
    tp.paint(
      canvas,
      Offset(center.dx - tp.width / 2, center.dy - tp.height / 2),
    );
    canvas.drawPath(
      Path()
        ..moveTo(center.dx, 6)
        ..lineTo(center.dx - 9, 22)
        ..lineTo(center.dx + 9, 22)
        ..close(),
      Paint()..color = Colors.white,
    );
    final picture = recorder.endRecording();
    final img = await picture.toImage(size.toInt(), size.toInt());
    final bytes = await img.toByteData(format: ImageByteFormat.png);
    if (mounted) {
      setState(
        () =>
            _bikeIcon = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List()),
      );
    }
  }

  // ── Bearing ───────────────────────────────────────────────────────────────

  double _calculateBearing(LatLng start, LatLng end) {
    if (start.latitude == end.latitude && start.longitude == end.longitude)
      return 0;
    final lat1 = start.latitude * pi / 180;
    final lat2 = end.latitude * pi / 180;
    final dLon = (end.longitude - start.longitude) * pi / 180;
    final y = sin(dLon) * cos(lat2);
    final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
    return (atan2(y, x) * 180 / pi + 360) % 360;
  }

  // ── Polyline trimming ─────────────────────────────────────────────────────

  int _nearestPointIndex(List<LatLng> points, LatLng partner) {
    double minDist = double.infinity;
    int idx = 0;
    for (int i = 0; i < points.length; i++) {
      final d = Geolocator.distanceBetween(
        partner.latitude,
        partner.longitude,
        points[i].latitude,
        points[i].longitude,
      );
      if (d < minDist) {
        minDist = d;
        idx = i;
      }
    }
    return idx;
  }

  void _applyTrimmedPolyline(LatLng partnerPos) {
    if (_fullRoutePoints.isEmpty) return;
    final nearest = _nearestPointIndex(_fullRoutePoints, partnerPos);
    final trimmed = <LatLng>[partnerPos, ..._fullRoutePoints.sublist(nearest)];

    _polylines
      ..removeWhere(
        (p) =>
            p.polylineId.value == 'route' ||
            p.polylineId.value == 'route_solid' ||
            p.polylineId.value == 'route_glow',
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route_glow'),
          color: Colors.blue.withOpacity(0.15),
          width: 10,
          points: trimmed,
        ),
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue.shade600,
          width: 5,
          points: trimmed,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route_solid'),
          color: Colors.blue.withOpacity(0.35),
          width: 2,
          points: trimmed,
        ),
      );
  }

  // ── Animation ─────────────────────────────────────────────────────────────

  void _scheduleAnimation(LatLng to) {
    if (_lastPosition == null) {
      _lastPosition = to;
      _updateMarkerAt(to);
      return;
    }
    if (_isAnimating) {
      _pendingPosition = to;
      return;
    }
    _startAnimation(_lastPosition!, to);
  }

  void _startAnimation(LatLng from, LatLng to) {
    if (!mounted) return;
    _isAnimating = true;

    _moveController?.stop();
    _moveController?.dispose();
    _moveController = null;

    _bearing = _calculateBearing(from, to);

    final controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _moveController = controller;

    final latTween = Tween<double>(begin: from.latitude, end: to.latitude);
    final lngTween = Tween<double>(begin: from.longitude, end: to.longitude);
    final curved = CurvedAnimation(parent: controller, curve: Curves.easeInOut);

    controller.addListener(() {
      if (!mounted) return;
      final pos = LatLng(latTween.evaluate(curved), lngTween.evaluate(curved));
      _applyTrimmedPolyline(pos);
      _updateMarkerAt(pos);
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed ||
          status == AnimationStatus.dismissed) {
        _lastPosition = to;
        _isAnimating = false;

        final pending = _pendingPosition;
        if (pending != null && mounted) {
          _pendingPosition = null;
          _startAnimation(to, pending);
        }
      }
    });

    controller.forward();
  }

  void _updateMarkerAt(LatLng pos) {
    // Reuse icon from existing partner marker if available
    final existing = _markers.where((m) => m.markerId.value == 'partner');
    final icon =
        _bikeIcon ??
        (existing.isNotEmpty
            ? existing.first.icon
            : BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen));

    final marker = Marker(
      markerId: const MarkerId('partner'),
      position: pos,
      rotation: _bearing,
      flat: true,
      anchor: const Offset(0.5, 0.5),
      zIndex: 2,
      icon: icon,
      infoWindow: const InfoWindow(title: 'Delivery Partner'),
    );

    if (!mounted) return;
    setState(() {
      _partnerPosition = pos;
      _markers = {
        ..._markers.where((m) => m.markerId.value != 'partner'),
        marker,
      };
    });

    // Follow partner with smooth camera pan
    _controller?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: pos, zoom: 17, bearing: _bearing),
      ),
    );
  }

  // ── Initial camera target ─────────────────────────────────────────────────

  LatLng get _initialTarget {
    if (widget.initialPartnerPosition != null)
      return widget.initialPartnerPosition!;
    final partner = widget.initialMarkers.where(
      (m) => m.markerId.value == 'partner',
    );
    if (partner.isNotEmpty) return partner.first.position;
    if (widget.initialMarkers.isNotEmpty)
      return widget.initialMarkers.first.position;
    return const LatLng(17.385044, 78.486671);
  }

  void _fitBounds() {
    if (_controller == null || _markers.length < 2) return;
    double minLat = 90, maxLat = -90, minLng = 180, maxLng = -180;
    for (final m in _markers) {
      minLat = min(minLat, m.position.latitude);
      maxLat = max(maxLat, m.position.latitude);
      minLng = min(minLng, m.position.longitude);
      maxLng = max(maxLng, m.position.longitude);
    }
    _controller!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        80,
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialTarget,
              zoom: 15,
            ),
            markers: _markers,
            polylines: _polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            trafficEnabled: false,
            buildingsEnabled: true,
            zoomControlsEnabled: false,
            onMapCreated: (c) {
              _controller = c;
              Future.delayed(const Duration(milliseconds: 300), _fitBounds);
            },
          ),

          // ── Close button ────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 16,
            child: Material(
              shape: const CircleBorder(),
              elevation: 4,
              color: Colors.white,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.close, size: 22),
                ),
              ),
            ),
          ),

          // ── ETA chip ────────────────────────────────────────────────────
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            right: 16,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_etaText),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: _currentOrderStatus == OrderStatus.completed
                      ? Colors.green.shade700
                      : Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  _currentOrderStatus == OrderStatus.completed
                      ? '✓ Delivered'
                      : 'ETA: $_etaText',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ),

          // ── Re-center button ────────────────────────────────────────────
          if (_partnerPosition != null)
            Positioned(
              bottom: 80,
              right: 16,
              child: Material(
                shape: const CircleBorder(),
                elevation: 4,
                color: Colors.white,
                child: InkWell(
                  customBorder: const CircleBorder(),
                  onTap: () {
                    _controller?.animateCamera(
                      CameraUpdate.newCameraPosition(
                        CameraPosition(
                          target: _partnerPosition!,
                          zoom: 17,
                          bearing: _bearing,
                        ),
                      ),
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(10),
                    child: Icon(
                      Icons.my_location,
                      size: 22,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ),
            ),

          // ── Fit-all button ───────────────────────────────────────────────
          Positioned(
            bottom: 140,
            right: 16,
            child: Material(
              shape: const CircleBorder(),
              elevation: 4,
              color: Colors.white,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _fitBounds,
                child: const Padding(
                  padding: EdgeInsets.all(10),
                  child: Icon(Icons.fit_screen, size: 22, color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// DeliveryStep (unchanged, kept for any local use)
// ---------------------------------------------------------------------------
class DeliveryStep {
  final String status;
  final bool isCompleted;
  final IconData icon;
  DeliveryStep({
    required this.status,
    required this.isCompleted,
    required this.icon,
  });
}
