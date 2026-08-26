import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../Models/logistics/locationmodel.dart';
import '../../Services/googleservices/Location_servces.dart';

// ─── Design Tokens (matches logistics_homepage.dart) ─────────────────────────
const _kPrimary = Color(0xFF6C3CE1);
const _kPrimaryLight = Color(0xFFF0EAFB);
const _kBg = Color(0xFFF7F8FC);
const _kSurface = Colors.white;
const _kText = Color(0xFF1A1A2E);
const _kTextSub = Color(0xFF8A8FAB);
const _kBorder = Color(0xFFE8EAF2);
const _kRadius = 16.0;
const _kRadiusLg = 24.0;

// ─── MapLocationSelector ──────────────────────────────────────────────────────
class MapLocationSelector extends StatefulWidget {
  final Function(SelectedLocation) onLocationSelected;

  const MapLocationSelector({super.key, required this.onLocationSelected});

  @override
  // ignore: library_private_types_in_public_api
  _MapLocationSelectorState createState() => _MapLocationSelectorState();
}

class _MapLocationSelectorState extends State<MapLocationSelector> {
  GoogleMapController? _mapController;
  LatLng _initialTarget = const LatLng(17.3850, 78.4867);

  LatLng _selectedLatLng = const LatLng(17.3850, 78.4867);
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedAddress = '';

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final loc = await LocationService.getCurrentLocationWithAddress();

    if (loc == null) return;

    final position = LatLng(loc.latitude!, loc.longitude!);

    _initialTarget = position;
    _selectedLatLng = position;

    setState(() {});

    _mapController?.animateCamera(CameraUpdate.newLatLng(position));
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final address = await LocationService.getAddressFromLatLng(
      _selectedLatLng.latitude,
      _selectedLatLng.longitude,
    );

    widget.onLocationSelected(
      SelectedLocation(
        address: address,
        latitude: _selectedLatLng.latitude,
        longitude: _selectedLatLng.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top Bar ──
            _buildTopBar(context),

            // ── Map Area ──
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialTarget,
                      zoom: 16,
                    ),

                    onMapCreated: (controller) {
                      _mapController = controller;
                    },

                    onCameraMove: (CameraPosition position) {
                      _selectedLatLng = position.target;
                    },

                    onCameraIdle: () async {
                      final address =
                          await LocationService.getAddressFromLatLng(
                            _selectedLatLng.latitude,
                            _selectedLatLng.longitude,
                          );

                      if (!mounted) return;

                      setState(() {
                        _selectedAddress = address;
                      });
                    },
                  ),

                  // Center pin
                  const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.location_pin, size: 42, color: _kPrimary),
                        SizedBox(height: 42), // visual offset so tip is center
                      ],
                    ),
                  ),

                  // My-location FAB
                  Positioned(
                    right: 16,
                    bottom: 16,
                    child: _mapFab(
                      icon: Icons.my_location_rounded,
                      onTap: () {},
                    ),
                  ),

                  // Zoom controls
                  Positioned(
                    right: 16,
                    bottom: 76,
                    child: Column(
                      children: [
                        _mapFab(
                          icon: Icons.add_rounded,
                          onTap: () => _mapController?.animateCamera(
                            CameraUpdate.zoomIn(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        _mapFab(
                          icon: Icons.remove_rounded,
                          onTap: () => _mapController?.animateCamera(
                            CameraUpdate.zoomOut(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // ── Bottom Sheet ──
            _buildBottomPanel(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Container(
      color: _kSurface,
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          // Back button
          IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 18,
              color: _kText,
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Search field
        ],
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: const BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(_kRadiusLg)),
        boxShadow: [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        16,
        20,
        MediaQuery.of(context).padding.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Selected location display
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _kPrimaryLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: _kPrimary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Selected Location',
                      style: TextStyle(
                        fontSize: 11,
                        color: _kTextSub,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _selectedAddress.isNotEmpty
                          ? _selectedAddress
                          : 'Move map to pin your location',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: _selectedAddress.isNotEmpty
                            ? FontWeight.w600
                            : FontWeight.w400,
                        color: _selectedAddress.isNotEmpty ? _kText : _kTextSub,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Confirm button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _confirm,
              icon: const Icon(Icons.check_circle_outline_rounded, size: 18),
              label: const Text(
                'Confirm Location',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _kPrimary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(_kRadius),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapFab({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _kSurface,
          shape: BoxShape.circle,
          boxShadow: const [
            BoxShadow(
              color: Color(0x18000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, size: 20, color: _kPrimary),
      ),
    );
  }
}
