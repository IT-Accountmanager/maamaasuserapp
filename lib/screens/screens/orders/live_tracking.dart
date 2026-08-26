import 'package:flutter/services.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Models/delivery/deliverpartnerreview.dart';
import '../../../Services/googleservices/googleapiservice.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../Services/Auth_service/delivery_service.dart';
import '../../../Services/websockets/web_socket_manager.dart';
import '../../../Models/delivery/fooddelivery.dart';
import '../../../Models/food/orders_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';

enum EtaConfidence { high, medium, low }

class ModernDeliveryTracking extends StatefulWidget {
  final int orderId;
  final OrderStatus orderStatus;
  final DeliveryOrderModel? deliveryModel;
  final VoidCallback? onRefresh;

  // ignore: use_super_parameters
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
  late OrderStatus _currentOrderStatus;

  // ── Debounce: avoid hammering ETA API ────────────────────────────────────
  DateTime? _lastEtaFetch;
  static const _etaDebounce = Duration(seconds: 20);

  // ================= Production Tracking Constants =================

  static const double _gpsNoiseThreshold = 8.0; // meters
  static const double _minCameraMoveDistance = 20.0;

  double _currentBearing = 0;

  DateTime? _lastLocationTime;

  bool _followPartner = true;

  // ================= Route Engine =================

  bool _isFetchingRoute = false;

  DateTime? _lastRouteRefresh;

  static const Duration _routeRefreshCooldown = Duration(seconds: 20);

  static const double _routeDeviationDistance = 35;

  static const double _routeAdvanceDistance = 15.0;

  double _deliveryRating = 0;
  final TextEditingController _deliveryReviewController =
      TextEditingController();

  DeliveryPartnerReview? _postedReview;
  bool _loadingReview = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _currentOrderStatus = widget.orderStatus;
    _initializeAnimations();
    _loadDeliveryData();
    _loadDeliveryReview();
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

  bool _shouldIgnoreLocation(LatLng newPosition) {
    if (_lastPartnerPosition == null) return false;

    final distance = Geolocator.distanceBetween(
      _lastPartnerPosition!.latitude,
      _lastPartnerPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    return distance < _gpsNoiseThreshold;
  }

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
          await DeliveryService.getOrder(widget.orderId);

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
      //       debugPrint('Error loading delivery data: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _loadDeliveryReview() async {
    setState(() {
      _loadingReview = true;
    });

    final review = await DeliveryService.getDeliveryPartnerReview(
      widget.orderId,
    );

    if (!mounted) return;

    setState(() {
      _postedReview = review;
      _loadingReview = false;
    });
  }

  Future<void> _submitDeliveryPartnerReview() async {
    if (_deliveryRating == 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select a rating.")));
      return;
    }

    final success = await DeliveryService.submitDeliveryPartnerReview(
      orderId: widget.orderId,
      rating: _deliveryRating.toInt(),
      review: _deliveryReviewController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Thank you for your feedback!")),
      );

      setState(() async {
        _deliveryRating = 0;
        _deliveryReviewController.clear();
        await _loadDeliveryReview();
      });
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Failed to submit review.")));
    }
  }

  // ── ETA ───────────────────────────────────────────────────────────────────

  Future<void> _fetchRealEta(LatLng origin) async {
    if (_googleApiKey == null || _delivery == null) return;
    if (_currentOrderStatus == OrderStatus.completed) return;

    // Debounce: don't hammer the Distance Matrix API
    final now = DateTime.now();
    if (_lastEtaFetch != null &&
        now.difference(_lastEtaFetch!) < _etaDebounce) {
      return;
    }
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
      //       debugPrint('Distance Matrix error: $e');
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
    // _bikeIcon = await _createDirectionalBikeIcon();
    _bikeIcon = await _loadBikeAssetIcon(context);
  }

  Future<BitmapDescriptor> _loadBikeAssetIcon(BuildContext context) async {
    final Uint8List markerBytes = await _getBytesFromAsset(
      'assets/bike_rider_topdown.png',
      120, // target width in logical pixels
    );
    // ignore: deprecated_member_use
    return BitmapDescriptor.fromBytes(markerBytes);
  }

  Future<Uint8List> _getBytesFromAsset(String path, int width) async {
    final ByteData data = await rootBundle.load(path);
    final ui.Codec codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      targetWidth: width,
    );
    final ui.FrameInfo fi = await codec.getNextFrame();
    final ByteData? byteData = await fi.image.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  // Future<BitmapDescriptor> _createPartnerPinIcon() async {
  //   const double width = 110;
  //   const double height = 140;
  //   final recorder = PictureRecorder();
  //   final canvas = Canvas(recorder);
  //
  //   const pinColor = Color(0xFFB3282D); // deep red, matches the reference
  //   final r = width * 0.34;
  //   final cx = width / 2;
  //   final cy = r + 10;
  //
  //   final path = Path()
  //     ..moveTo(cx - r, cy)
  //     ..arcToPoint(
  //       Offset(cx + r, cy),
  //       radius: Radius.circular(r),
  //       clockwise: true,
  //       largeArc: true,
  //     )
  //     ..quadraticBezierTo(cx + r * 0.95, cy + r * 1.35, cx, height - 6)
  //     ..quadraticBezierTo(cx - r * 0.95, cy + r * 1.35, cx - r, cy)
  //     ..close();
  //
  //   // Shadow
  //   canvas.drawPath(
  //     path.shift(const Offset(0, 3)),
  //     Paint()
  //       ..color = Colors.black.withOpacity(0.25)
  //       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
  //   );
  //
  //   // Pin body
  //   canvas.drawPath(path, Paint()..color = pinColor);
  //
  //   // White outline for contrast
  //   canvas.drawPath(
  //     path,
  //     Paint()
  //       ..color = Colors.white
  //       ..style = PaintingStyle.stroke
  //       ..strokeWidth = 3,
  //   );
  //
  //   // Scooter icon, centered in the round part
  //   final iconPainter = TextPainter(textDirection: TextDirection.ltr);
  //   iconPainter.text = TextSpan(
  //     text: String.fromCharCode(Icons.two_wheeler.codePoint),
  //     style: TextStyle(
  //       fontSize: r * 1.15,
  //       fontFamily: Icons.two_wheeler.fontFamily,
  //       package: Icons.two_wheeler.fontPackage,
  //       color: Colors.white,
  //     ),
  //   );
  //   iconPainter.layout();
  //   iconPainter.paint(
  //     canvas,
  //     Offset(cx - iconPainter.width / 2, cy - iconPainter.height / 2),
  //   );
  //
  //   final picture = recorder.endRecording();
  //   final image = await picture.toImage(width.toInt(), height.toInt());
  //   final byteData = await image.toByteData(format: ImageByteFormat.png);
  //   // ignore: deprecated_member_use
  //   return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  // }

  // Future<BitmapDescriptor> _createDirectionalBikeIcon() async {
  //   const double size = 120;
  //   final recorder = PictureRecorder();
  //   final canvas = Canvas(recorder);
  //   final center = Offset(size / 2, size / 2);
  //
  //   // Shadow
  //   canvas.drawCircle(
  //     center,
  //     size / 2 - 4,
  //     Paint()
  //       // ignore: deprecated_member_use
  //       ..color = Colors.black.withOpacity(0.18)
  //       ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
  //   );
  //   // Circle background
  //   canvas.drawCircle(
  //     center,
  //     size / 2 - 8,
  //     Paint()..color = Colors.green.shade600,
  //   );
  //   // White ring
  //   canvas.drawCircle(
  //     center,
  //     size / 2 - 8,
  //     Paint()
  //       ..color = Colors.white
  //       ..style = PaintingStyle.stroke
  //       ..strokeWidth = 4,
  //   );
  //
  //   // Bike icon
  //   final bikeText = TextPainter(textDirection: TextDirection.ltr);
  //   bikeText.text = TextSpan(
  //     text: String.fromCharCode(Icons.delivery_dining.codePoint),
  //     style: TextStyle(
  //       fontSize: 48,
  //       fontFamily: Icons.delivery_dining.fontFamily,
  //       package: Icons.delivery_dining.fontPackage,
  //       color: Colors.white,
  //     ),
  //   );
  //   bikeText.layout();
  //   bikeText.paint(
  //     canvas,
  //     Offset(center.dx - bikeText.width / 2, center.dy - bikeText.height / 2),
  //   );
  //
  //   // Direction arrow at the top (always north — we use marker.rotation)
  //   canvas.drawPath(
  //     Path()
  //       ..moveTo(center.dx, 6)
  //       ..lineTo(center.dx - 9, 22)
  //       ..lineTo(center.dx + 9, 22)
  //       ..close(),
  //     Paint()..color = Colors.white,
  //   );
  //
  //   final picture = recorder.endRecording();
  //   final image = await picture.toImage(size.toInt(), size.toInt());
  //   final byteData = await image.toByteData(format: ImageByteFormat.png);
  //   // ignore: deprecated_member_use
  //   return BitmapDescriptor.fromBytes(byteData!.buffer.asUint8List());
  // }

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
    // ignore: deprecated_member_use
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
      // _markers.add(
      //   Marker(
      //     markerId: const MarkerId('vendor'),
      //     position: LatLng(
      //       _delivery!.vendorLatitude,
      //       _delivery!.vendorLongitude,
      //     ),
      //     icon:
      //         _vendorIcon ??
      //         BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      //     infoWindow: const InfoWindow(title: 'Restaurant'),
      //   ),
      Marker(
        markerId: const MarkerId('partner'),
        position: LatLng(_delivery!.vendorLatitude, _delivery!.vendorLongitude),
        // icon: _bikeIcon ?? BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        icon:
            _bikeIcon ??
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        anchor: const Offset(
          0.5,
          1.0,
        ), // was (0.5, 0.5) — pin tip now touches the exact location
        flat:
            false, // was true — pin stays upright/billboard-style, doesn't tilt/rotate with map
        zIndex: 2,
        infoWindow: const InfoWindow(title: 'Delivery Partner'),
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
      // ignore: deprecated_member_use
      zIndex: 2,
      infoWindow: const InfoWindow(title: 'Delivery Partner'),
    );
    _markers.removeWhere((m) => m.markerId.value == 'partner');
    _markers.add(_partnerMarker!);
    if (mounted) setState(() {});
  }

  // ── Polyline ──────────────────────────────────────────────────────────────

  Future<void> _drawPolyline() async {
    _googleApiKey = await ApiKeyService.getApiKey();
    if (_googleApiKey == null || _delivery == null) {
      debugPrint('❌ Google API key or delivery data is null');
      return;
    }

    PointLatLng origin;
    PointLatLng destination;

    switch (_currentOrderStatus) {
      case OrderStatus.waitingForPickup:
        origin = PointLatLng(
          _currentAnimatedPosition?.latitude ??
              _delivery!.deliveryPartnerLatitude,
          _currentAnimatedPosition?.longitude ??
              _delivery!.deliveryPartnerLongitude,
        );

        destination = PointLatLng(
          _delivery!.vendorLatitude,
          _delivery!.vendorLongitude,
        );
        break;

      case OrderStatus.ontheway:
        origin = PointLatLng(
          _currentAnimatedPosition?.latitude ??
              _delivery!.deliveryPartnerLatitude,
          _currentAnimatedPosition?.longitude ??
              _delivery!.deliveryPartnerLongitude,
        );

        destination = PointLatLng(
          _delivery!.userLatitude,
          _delivery!.userLongitude,
        );
        break;

      default:
        origin = PointLatLng(
          _delivery!.vendorLatitude,
          _delivery!.vendorLongitude,
        );

        destination = PointLatLng(
          _delivery!.userLatitude,
          _delivery!.userLongitude,
        );
    }

    debugPrint('🗺️ DRAWING ROUTE');
    debugPrint('Origin: ${origin.latitude}, ${origin.longitude}');
    debugPrint(
      'Destination: ${destination.latitude}, ${destination.longitude}',
    );
    debugPrint(
      'API KEY: ${_googleApiKey == null ? "NULL" : "LOADED (${_googleApiKey!.length} chars)"}',
    );

    try {
      final result = await PolylinePoints().getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey!,
        request: PolylineRequest(
          origin: origin,
          destination: destination,
          mode: TravelMode.driving,
        ),
      );

      debugPrint('🗺️ ROUTE STATUS: ${result.status}');
      debugPrint('🗺️ ROUTE POINTS: ${result.points.length}');

      if (result.points.isNotEmpty) {
        _fullRoutePoints = result.points
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList();

        _applyTrimmedPolyline(
          _currentAnimatedPosition ?? LatLng(origin.latitude, origin.longitude),
        );

        if (mounted) {
          setState(() {});
        }
      }
    } catch (e, stackTrace) {
      debugPrint('❌ POLYLINE ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);
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

  bool _isRouteDeviation(LatLng current) {
    if (_fullRoutePoints.isEmpty) return false;

    final nearest = _nearestPointIndex(_fullRoutePoints, current);

    final nearestPoint = _fullRoutePoints[nearest];

    final distance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,

      nearestPoint.latitude,
      nearestPoint.longitude,
    );

    return distance > _routeDeviationDistance;
  }

  Future<void> _refreshRoute(LatLng current) async {
    List<LatLng>? _cachedRoute;

    DateTime? _cachedRouteTime;

    if (_delivery == null) return;

    if (_isFetchingRoute) return;

    final now = DateTime.now();

    if (_lastRouteRefresh != null &&
        now.difference(_lastRouteRefresh!) < _routeRefreshCooldown) {
      return;
    }

    _lastRouteRefresh = now;

    _isFetchingRoute = true;

    try {
      if (_cachedRoute != null &&
          _cachedRouteTime != null &&
          DateTime.now().difference(_cachedRouteTime).inMinutes < 2) {
        _fullRoutePoints = _cachedRoute;

        _applyTrimmedPolyline(current);

        return;
      }

      final result = await PolylinePoints().getRouteBetweenCoordinates(
        googleApiKey: _googleApiKey!,

        request: PolylineRequest(
          origin: PointLatLng(current.latitude, current.longitude),

          destination: PointLatLng(
            _delivery!.userLatitude,
            _delivery!.userLongitude,
          ),

          mode: TravelMode.driving,
        ),
      );

      if (result.points.isNotEmpty) {
        _fullRoutePoints = result.points
            .map((e) => LatLng(e.latitude, e.longitude))
            .toList();

        _applyTrimmedPolyline(current);
      }
    } finally {
      _isFetchingRoute = false;
    }
  }

  /// Trims the polyline to show only the remaining route ahead of the partner.
  void _applyTrimmedPolyline(LatLng partnerPos, [List<LatLng>? routePoints]) {
    final points = routePoints ?? _fullRoutePoints;
    if (points.isEmpty) return;

    final nearestIdx = _nearestPointIndex(points, partnerPos);
    int start = nearestIdx;

    while (start < points.length) {
      final d = Geolocator.distanceBetween(
        partnerPos.latitude,
        partnerPos.longitude,

        points[start].latitude,
        points[start].longitude,
      );

      if (d > _routeAdvanceDistance) {
        break;
      }

      start++;
    }

    final trimmed = [partnerPos, ...points.sublist(start)];

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
          patterns: [PatternItem.dash(30), PatternItem.gap(12)],
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
    final jump = Geolocator.distanceBetween(
      _lastPartnerPosition!.latitude,
      _lastPartnerPosition!.longitude,

      to.latitude,
      to.longitude,
    );

    if (jump > 1000) {
      _lastPartnerPosition = to;

      _addPartnerMarker(to, bearing: _currentBearing);

      return;
    }

    if (_isAnimating) {
      _pendingPartnerPosition = to;

      return;
    }

    _startPartnerAnimation(_lastPartnerPosition!, to);
    if (_pendingPartnerPosition != null) {
      final next = _pendingPartnerPosition!;

      _pendingPartnerPosition = null;

      _startPartnerAnimation(to, next);
    }
    if (_isRouteDeviation(to)) {
      _refreshRoute(to);
    } else {
      _applyTrimmedPolyline(to);
    }
  }

  void _startPartnerAnimation(LatLng from, LatLng to) {
    if (!mounted) return;
    _isAnimating = true;

    _moveController?.stop();
    _moveController?.dispose();
    _moveController = null;

    final bearing = _calculateBearing(from, to);

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
        // ignore: deprecated_member_use
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

        if (_followPartner) {
          if (_currentAnimatedPosition != null) {
            final moved = Geolocator.distanceBetween(
              _currentAnimatedPosition!.latitude,
              _currentAnimatedPosition!.longitude,

              to.latitude,
              to.longitude,
            );

            if (moved > _minCameraMoveDistance) {
              _mapController?.animateCamera(
                CameraUpdate.newCameraPosition(
                  CameraPosition(
                    target: to,

                    zoom: 16.5,

                    tilt: 45,

                    bearing: bearing,
                  ),
                ),
              );
            }
          }
        }

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
      // WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
      //   if (!mounted) return;
      //   final newStatus = OrderStatus.fromString(
      //     data['status'] as String? ?? '',
      //   );
      //   _handleStatusChange(newStatus);
      // });
      WebSocketManager().subscribeOrderStatus(widget.orderId, (data) {
        if (!mounted) return;

        final newStatus = OrderStatus.fromString(
          data['status'] as String? ?? '',
        );

        // Status changed
        if (newStatus != _currentOrderStatus) {
          _handleStatusChange(newStatus);
        }

        // Partner assignment may happen without a status change.
        if (data['partnerId'] != null) {
          _refreshDeliveryData();
        }
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
      //       debugPrint('📍 LOCATION WS: $data');
      if (!mounted) return;

      final lat = (data['latitude'] as num?)?.toDouble();
      final lng = (data['longitude'] as num?)?.toDouble();
      if (lat == null || lng == null) return;

      final newPos = LatLng(lat, lng);

      if (_lastPartnerPosition != null) {
        if (!_shouldIgnoreLocation(newPos)) {
          _schedulePartnerMovement(newPos);
        }
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

      final timestamp = DateTime.tryParse(data["timestamp"] ?? "");

      if (timestamp != null) {
        if (_lastLocationTime != null &&
            timestamp.isBefore(_lastLocationTime!)) {
          return;
        }

        _lastLocationTime = timestamp;
      }
    });
  }

  // void _handleStatusChange(OrderStatus newStatus) {
  //   if (newStatus == _currentOrderStatus) return;
  //
  //   final wasOnTheWay =
  //       _currentOrderStatus != OrderStatus.ontheway &&
  //       newStatus == OrderStatus.ontheway;
  //
  //   setState(() {
  //     _currentOrderStatus = newStatus;
  //     _setupStaticMarkers();
  //   });
  //
  //   _drawPolyline();
  //
  //   if (newStatus == OrderStatus.completed) {
  //     _onDelivered();
  //     _refreshDeliveryData();
  //   } else if (newStatus == OrderStatus.cancelled) {
  //     _refreshDeliveryData();
  //   }
  // }

  void _handleStatusChange(OrderStatus newStatus) {
    if (newStatus == _currentOrderStatus) return;

    setState(() {
      _currentOrderStatus = newStatus;
      _setupStaticMarkers();
    });

    _drawPolyline();

    // Always refresh order data because partner assignment
    // can happen before ON THE WAY.
    _refreshDeliveryData();

    if (newStatus == OrderStatus.completed) {
      _onDelivered();
    }
  }

  Future<void> _refreshDeliveryData() async {
    if (!mounted) return;
    final updated = await DeliveryService.getOrder(widget.orderId);
    if (updated == null || !mounted) return;

    setState(() => _delivery = updated);

    // If partner changed (reassignment), re-subscribe to new partner
    if (updated.partnerId != _subscribedPartnerId) _listenToWebSocket();

    widget.onRefresh?.call();
  }

  // ── ETA helpers ───────────────────────────────────────────────────────────

  String get _formattedEta {
    if (_etaLoading && _remainingEta == null) return 'Calculating...';
    if (_remainingEta == null) {
      return 'Calculating...';
    }
    if (_remainingEta!.inSeconds <= 0) return 'Arriving soon';
    final hours = _remainingEta!.inHours;
    final minutes = _remainingEta!.inMinutes.remainder(60);
    if (hours > 0) return '${hours}h ${minutes}min';
    if (_remainingEta!.inMinutes < 1) return 'Arriving soon';
    return '${_remainingEta!.inMinutes} min';
  }

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
                _currentOrderStatus == OrderStatus.waitingForPickup) ...[
              _buildProgressMap(),
            ],
            SizedBox(height: 10.h),
            _buildPartnerInfo(),

            if (_currentOrderStatus == OrderStatus.completed && _loadingReview)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),

            if (_currentOrderStatus == OrderStatus.completed &&
                !_loadingReview &&
                _postedReview == null)
              _buildRateDeliveryPartner(),
          ],
        ),
      ),
    );
  }

  Widget _buildRateDeliveryPartner() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Rate Your Delivery Partner",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 6),

          Text(
            "How was your delivery experience?",
            style: TextStyle(color: Colors.grey.shade600),
          ),

          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                onPressed: () {
                  setState(() {
                    _deliveryRating = index + 1.0;
                  });
                },
                icon: Icon(
                  index < _deliveryRating
                      ? Icons.star_rounded
                      : Icons.star_border_rounded,
                  color: Colors.amber,
                  size: 36,
                ),
              );
            }),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: _deliveryReviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Write a review (optional)",
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _deliveryRating == 0
                  ? null
                  : () {
                      _submitDeliveryPartnerReview();
                    },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Submit Rating",
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
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
              ],
            ),
          ),
        ],
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
        height: 300,
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
                top: 12,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(
                      0.65,
                    ), // Dark semi-transparent background
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Tap to view full map',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to make phone call')),
      );
    }
  }

  String maskPhoneNumber(String phone) {
    if (phone.length < 4) return phone;
    return '${phone.substring(0, 2)}******${phone.substring(phone.length - 2)}';
  }

  // Widget _buildPartnerInfo() {
  //   final delivery = _delivery;
  //
  //   // Show partner details as soon as a partner is assigned.
  //   // Do not wait for order status to become ON THE WAY.
  //   final isPartnerAssigned =
  //       delivery != null &&
  //       delivery.partnerId != null &&
  //       delivery.partnerId! > 0 &&
  //       delivery.deliveryPartnerName.isNotEmpty;
  //
  //   if (!isPartnerAssigned) {
  //     return const SizedBox.shrink();
  //   }
  //
  //   return Container(
  //     margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  //     padding: const EdgeInsets.all(16),
  //     decoration: BoxDecoration(
  //       color: Colors.grey.shade50,
  //       borderRadius: BorderRadius.circular(16),
  //       border: Border.all(color: Colors.grey.shade200),
  //     ),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.start,
  //       children: [
  //         /// Partner Details
  //         Row(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             CircleAvatar(
  //               radius: 24,
  //               backgroundColor: Colors.green.shade100,
  //               child: const Icon(Icons.person, color: Colors.green, size: 28),
  //             ),
  //
  //             const SizedBox(width: 12),
  //
  //             Expanded(
  //               child: Column(
  //                 crossAxisAlignment: CrossAxisAlignment.start,
  //                 children: [
  //                   Row(
  //                     children: [
  //                       Expanded(
  //                         child: Text(
  //                           _delivery!.deliveryPartnerName,
  //                           style: const TextStyle(
  //                             fontSize: 16,
  //                             fontWeight: FontWeight.bold,
  //                           ),
  //                         ),
  //                       ),
  //
  //                       if (_currentOrderStatus != OrderStatus.completed)
  //                         InkWell(
  //                           onTap: () => _makePhoneCall(
  //                             _delivery!.deliveryPartnerPhoneNumber,
  //                           ),
  //                           borderRadius: BorderRadius.circular(20),
  //                           child: Container(
  //                             padding: const EdgeInsets.all(8),
  //                             decoration: BoxDecoration(
  //                               color: Colors.green.shade50,
  //                               shape: BoxShape.circle,
  //                             ),
  //                             child: const Icon(
  //                               Icons.call,
  //                               color: Colors.green,
  //                               size: 20,
  //                             ),
  //                           ),
  //                         ),
  //                     ],
  //                   ),
  //
  //                   const SizedBox(height: 4),
  //
  //                   Text(
  //                     "+91 ${maskPhoneNumber(_delivery!.deliveryPartnerPhoneNumber)}",
  //                     style: TextStyle(
  //                       color: Colors.grey.shade700,
  //                       fontSize: 14,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //
  //         if (_currentOrderStatus != OrderStatus.completed) ...[
  //           const SizedBox(height: 16),
  //           const Divider(height: 1),
  //           const SizedBox(height: 12),
  //
  //           Row(
  //             children: [
  //               Icon(Icons.two_wheeler, size: 18, color: Colors.grey.shade600),
  //               const SizedBox(width: 8),
  //
  //               Expanded(
  //                 child: Text(
  //                   _delivery!.vehicleStatus.name.replaceAll("_", " "),
  //                   style: TextStyle(color: Colors.grey.shade700),
  //                 ),
  //               ),
  //
  //               const Icon(Icons.lock_outline, size: 18),
  //
  //               const SizedBox(width: 6),
  //
  //               Text(
  //                 "OTP ${_delivery?.userOtp ?? ""}",
  //                 style: const TextStyle(fontWeight: FontWeight.w600),
  //               ),
  //             ],
  //           ),
  //         ],
  //
  //         if (_currentOrderStatus == OrderStatus.completed &&
  //             _postedReview != null) ...[
  //           const SizedBox(height: 16),
  //           Divider(color: Colors.grey.shade300),
  //           const SizedBox(height: 14),
  //
  //           Row(
  //             children: [
  //               const Icon(Icons.rate_review, color: Colors.orange, size: 20),
  //               const SizedBox(width: 8),
  //               const Text(
  //                 "Your Rating",
  //                 style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
  //               ),
  //             ],
  //           ),
  //
  //           const SizedBox(height: 10),
  //
  //           Row(
  //             children: [
  //               ...List.generate(
  //                 5,
  //                 (index) => Icon(
  //                   index < _postedReview!.rating
  //                       ? Icons.star_rounded
  //                       : Icons.star_border_rounded,
  //                   color: Colors.amber,
  //                   size: 22,
  //                 ),
  //               ),
  //
  //               const SizedBox(width: 8),
  //
  //               Text(
  //                 "${_postedReview!.rating}/5",
  //                 style: const TextStyle(fontWeight: FontWeight.bold),
  //               ),
  //             ],
  //           ),
  //
  //           if (_postedReview!.review.isNotEmpty) ...[
  //             const SizedBox(height: 3),
  //
  //             Text(
  //               _postedReview!.review,
  //               style: TextStyle(color: Colors.grey.shade800, height: 1.4),
  //             ),
  //           ],
  //         ],
  //       ],
  //     ),
  //   );
  // }

  Widget _buildPartnerInfo() {
    final delivery = _delivery;

    // Partner is assigned when partnerId and partner name are available.
    final isPartnerAssigned =
        delivery != null &&
        delivery.partnerId != null &&
        delivery.partnerId! > 0 &&
        delivery.deliveryPartnerName.isNotEmpty;

    if (!isPartnerAssigned) {
      return const SizedBox.shrink();
    }

    // Partner has been assigned but has not yet started delivery to customer.
    final isWaitingForPickup =
        _currentOrderStatus != OrderStatus.ontheway &&
        _currentOrderStatus != OrderStatus.completed;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Partner Details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            delivery.deliveryPartnerName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        if (_currentOrderStatus != OrderStatus.completed)
                          InkWell(
                            onTap: () => _makePhoneCall(
                              delivery.deliveryPartnerPhoneNumber,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.green.shade50,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call,
                                color: Colors.green,
                                size: 20,
                              ),
                            ),
                          ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Text(
                      "+91 ${maskPhoneNumber(delivery.deliveryPartnerPhoneNumber)}",
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Partner is assigned and going to restaurant
          if (isWaitingForPickup) ...[
            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.shade100),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.two_wheeler,
                    color: Colors.orange.shade700,
                    size: 22,
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Delivery Partner Assigned",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "${delivery.deliveryPartnerName} is on the way "
                          "to the restaurant to pick up your order.",
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 13,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],

          /// Vehicle + OTP
          if (_currentOrderStatus != OrderStatus.completed) ...[
            const SizedBox(height: 16),
            const Divider(height: 1),
            const SizedBox(height: 12),

            Row(
              children: [
                Icon(Icons.two_wheeler, size: 18, color: Colors.grey.shade600),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    delivery.vehicleStatus.name.replaceAll("_", " "),
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),

                const Icon(Icons.lock_outline, size: 18),

                const SizedBox(width: 6),

                Text(
                  "OTP ${delivery.userOtp ?? ""}",
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ],

          /// Completed + Review
          if (_currentOrderStatus == OrderStatus.completed &&
              _postedReview != null) ...[
            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300),
            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(Icons.rate_review, color: Colors.orange, size: 20),

                const SizedBox(width: 8),

                const Text(
                  "Your Rating",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                ...List.generate(
                  5,
                  (index) => Icon(
                    index < _postedReview!.rating
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                    color: Colors.amber,
                    size: 22,
                  ),
                ),

                const SizedBox(width: 8),

                Text(
                  "${_postedReview!.rating}/5",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),

            if (_postedReview!.review.isNotEmpty) ...[
              const SizedBox(height: 3),

              Text(
                _postedReview!.review,
                style: TextStyle(color: Colors.grey.shade800, height: 1.4),
              ),
            ],
          ],
        ],
      ),
    );
  }
}

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
  static const double _routeAdvanceDistance = 15.0;
  int _lastNearestIndex = 0;

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
      //       debugPrint('🗺️ FULLSCREEN LOC: $data');
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
    Duration _smoothEta(Duration current, Duration next) {
      final currentSec = current.inSeconds;

      final nextSec = next.inSeconds;

      final result = (currentSec * 0.7) + (nextSec * 0.3);

      return Duration(seconds: result.round());
    }
  }

  Future<void> _refreshEtaIfMoved(LatLng newPos) async {
    if (widget.googleApiKey == null || widget.userLatLng == null) return;
    if (_currentOrderStatus == OrderStatus.completed) return;

    // Debounce
    final now = DateTime.now();
    if (_lastEtaFetch != null &&
        now.difference(_lastEtaFetch!) < _etaDebounce) {
      return;
    }
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
            // ignore: deprecated_member_use
            _bikeIcon = BitmapDescriptor.fromBytes(bytes!.buffer.asUint8List()),
      );
    }
  }

  // ── Bearing ───────────────────────────────────────────────────────────────

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

  // ── Polyline trimming ─────────────────────────────────────────────────────

  // int _nearestPointIndex(List<LatLng> points, LatLng partner) {
  //   double minDist = double.infinity;
  //   int idx = 0;
  //   for (int i = 0; i < points.length; i++) {
  //     final d = Geolocator.distanceBetween(
  //       partner.latitude,
  //       partner.longitude,
  //       points[i].latitude,
  //       points[i].longitude,
  //     );
  //     if (d < minDist) {
  //       minDist = d;
  //       idx = i;
  //     }
  //   }
  //   return idx;
  // }
  int _nearestPointIndex(List<LatLng> points, LatLng current) {
    double minDistance = double.infinity;

    int nearest = _lastNearestIndex;

    for (int i = _lastNearestIndex; i < points.length; i++) {
      final distance = Geolocator.distanceBetween(
        current.latitude,
        current.longitude,

        points[i].latitude,
        points[i].longitude,
      );

      if (distance < minDistance) {
        minDistance = distance;

        nearest = i;
      }

      if (distance > minDistance + 50) {
        break;
      }
    }

    _lastNearestIndex = nearest;

    return nearest;
  }

  void _applyTrimmedPolyline(LatLng partnerPos) {
    if (_fullRoutePoints.isEmpty) return;

    final points = _fullRoutePoints;

    final nearest = _nearestPointIndex(points, partnerPos);

    int start = nearest;

    while (start < points.length) {
      final d = Geolocator.distanceBetween(
        partnerPos.latitude,
        partnerPos.longitude,
        points[start].latitude,
        points[start].longitude,
      );

      if (d > _routeAdvanceDistance) {
        break;
      }

      start++;
    }

    final trimmed = [partnerPos, ...points.sublist(start)];

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
          color: Colors.blue.withOpacity(.15),
          width: 10,
          points: trimmed,
        ),
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route'),
          color: Colors.blue,
          width: 5,
          points: trimmed,
          patterns: [PatternItem.dash(20), PatternItem.gap(10)],
        ),
      )
      ..add(
        Polyline(
          polylineId: const PolylineId('route_solid'),
          color: Colors.blue,
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
    double _calculateMovementBearing(LatLng previous, LatLng current) {
      return _calculateBearing(previous, current);
    }

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
    if (widget.initialPartnerPosition != null) {
      return widget.initialPartnerPosition!;
    }
    final partner = widget.initialMarkers.where(
      (m) => m.markerId.value == 'partner',
    );
    if (partner.isNotEmpty) return partner.first.position;
    if (widget.initialMarkers.isNotEmpty) {
      return widget.initialMarkers.first.position;
    }
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
