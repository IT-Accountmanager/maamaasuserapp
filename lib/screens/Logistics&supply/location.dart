// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
//
// class MapLocationSelector extends StatefulWidget {
//   final Function(String) onLocationSelected;
//
//   const MapLocationSelector({super.key, required this.onLocationSelected});
//
//   @override
//   _MapLocationSelectorState createState() => _MapLocationSelectorState();
// }
//
// class _MapLocationSelectorState extends State<MapLocationSelector> {
//   List<String> _searchResults = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Location selector")),
//       body: Column(
//         children: [
//           SingleChildScrollView(
//             child: Container(
//               height: MediaQuery.of(context).size.height * 0.85,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(20),
//                   topRight: Radius.circular(20),
//                 ),
//               ),
//               child: Column(
//                 children: [
//                   // Drag handle
//                   Container(
//                     margin: EdgeInsets.only(top: 12),
//                     width: 40,
//                     height: 5,
//                     decoration: BoxDecoration(
//                       color: Colors.grey[300],
//                       borderRadius: BorderRadius.circular(3),
//                     ),
//                   ),
//
//                   // Search header
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: Text(
//                       "Select Location from Map",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                   ),
//                   Expanded(
//                     child: Stack(
//                       children: [
//                         // Simulated map
//                         Container(
//                           margin: EdgeInsets.all(16),
//                           decoration: BoxDecoration(
//                             color: Colors.blue[50],
//                             borderRadius: BorderRadius.circular(12),
//                             border: Border.all(color: Colors.grey[300]!),
//                           ),
//                           child: GoogleMap(
//                             initialCameraPosition: CameraPosition(
//                               target: initialTarget,
//                               zoom: 14,
//                             ),
//                             markers: _markers,
//                             polylines: _polylines,
//                             zoomControlsEnabled: false,
//                             myLocationEnabled: false,
//                             compassEnabled: false,
//                             scrollGesturesEnabled: false,
//                             zoomGesturesEnabled: false,
//                             rotateGesturesEnabled: false,
//                             tiltGesturesEnabled: false,
//                             onMapCreated: (c) {
//                               _mapController = c;
//                               Future.delayed(
//                                 const Duration(milliseconds: 300),
//                                 _fitMapBounds,
//                               );
//                             },
//                             gestureRecognizers: {
//                               Factory<OneSequenceGestureRecognizer>(
//                                     () => EagerGestureRecognizer(),
//                               ),
//                             },
//                           ),
//                         ),
//
//                         // Map pin
//                         Positioned(
//                           top:
//                               MediaQuery.of(context).size.height * 0.85 / 2 -
//                               30,
//                           left: MediaQuery.of(context).size.width / 2 - 15,
//                           child: Icon(
//                             Icons.location_pin,
//                             size: 30,
//                             color: Colors.red,
//                           ),
//                         ),
//
//                         // Current location button
//                         Positioned(
//                           bottom: 20,
//                           right: 20,
//                           child: FloatingActionButton(
//                             mini: true,
//                             backgroundColor: Colors.white,
//                             onPressed: () {},
//                             child: Icon(
//                               Icons.my_location,
//                               color: Color(0xFF6A1B9A),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   // Search results
//                   if (_searchResults.isNotEmpty)
//                     Container(
//                       height: 150,
//                       margin: EdgeInsets.symmetric(horizontal: 16),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black12,
//                             blurRadius: 8,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//                       child: ListView.builder(
//                         itemCount: _searchResults.length,
//                         itemBuilder: (context, index) {
//                           return ListTile(
//                             leading: Icon(
//                               Icons.location_on,
//                               color: Colors.grey,
//                             ),
//                             title: Text(_searchResults[index]),
//                             onTap: () {
//                               widget.onLocationSelected(_searchResults[index]);
//                               Navigator.pop(context);
//                             },
//                           );
//                         },
//                       ),
//                     ),
//
//                   // Confirm selection button
//                   Padding(
//                     padding: EdgeInsets.all(16),
//                     child: ElevatedButton(
//                       onPressed: () {
//                         // widget.onLocationSelected("Selected Map Location");
//                         Navigator.pop(context);
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xFF6A1B9A),
//                         minimumSize: Size(double.infinity, 50),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                       ),
//                       child: Text(
//                         "Confirm Location",
//                         style: TextStyle(color: Colors.white),
//                       ),
//                     ),
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
// }

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ─── Design Tokens (matches logistics_homepage.dart) ─────────────────────────
const _kPrimary = Color(0xFF6C3CE1);
const _kPrimaryLight = Color(0xFFF0EAFB);
const _kAccent = Color(0xFF00C896);
const _kBg = Color(0xFFF7F8FC);
const _kSurface = Colors.white;
const _kText = Color(0xFF1A1A2E);
const _kTextSub = Color(0xFF8A8FAB);
const _kBorder = Color(0xFFE8EAF2);
const _kRadius = 16.0;
const _kRadiusLg = 24.0;

// ─── MapLocationSelector ──────────────────────────────────────────────────────
class MapLocationSelector extends StatefulWidget {
  final Function(String) onLocationSelected;

  const MapLocationSelector({super.key, required this.onLocationSelected});

  @override
  _MapLocationSelectorState createState() => _MapLocationSelectorState();
}

class _MapLocationSelectorState extends State<MapLocationSelector> {
  GoogleMapController? _mapController;
  final LatLng _initialTarget = const LatLng(17.3850, 78.4867); // Hyderabad
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<String> _searchResults = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _selectedAddress = '';
  bool _isPinDragging = false;

  @override
  void dispose() {
    _searchCtrl.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (query.isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    // Mock suggestions — replace with Places API
    setState(() {
      _searchResults = [
        '$query, Banjara Hills',
        '$query, Jubilee Hills',
        '$query, Madhapur',
        '$query, Gachibowli',
      ];
    });
  }

  void _selectResult(String address) {
    setState(() {
      _selectedAddress = address;
      _searchResults = [];
      _searchCtrl.text = address;
    });
  }

  void _confirm() {
    final addr = _selectedAddress.isNotEmpty
        ? _selectedAddress
        : 'Selected Map Location';
    widget.onLocationSelected(addr);
    Navigator.pop(context);
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
                  // Map
                  GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _initialTarget,
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    zoomControlsEnabled: false,
                    myLocationEnabled: false,
                    compassEnabled: false,
                    onMapCreated: (c) => _mapController = c,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
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
          Expanded(
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: _kBg,
                borderRadius: BorderRadius.circular(_kRadius),
                border: Border.all(color: _kBorder),
              ),
              child: Stack(
                children: [
                  TextField(
                    controller: _searchCtrl,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(fontSize: 14, color: _kText),
                    decoration: InputDecoration(
                      hintText: 'Search area, street or landmark…',
                      hintStyle: const TextStyle(
                        color: _kTextSub,
                        fontSize: 14,
                      ),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: _kTextSub,
                        size: 18,
                      ),
                      suffixIcon: _searchCtrl.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: _kTextSub,
                              ),
                              onPressed: () {
                                _searchCtrl.clear();
                                setState(() => _searchResults = []);
                              },
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                  ),

                  // Dropdown results
                  if (_searchResults.isNotEmpty)
                    Positioned(
                      top: 48,
                      left: 0,
                      right: 0,
                      child: Material(
                        elevation: 8,
                        borderRadius: BorderRadius.circular(_kRadius),
                        color: _kSurface,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(_kRadius),
                          child: Column(
                            children: _searchResults
                                .map(
                                  (r) => ListTile(
                                    dense: true,
                                    leading: const Icon(
                                      Icons.location_on_rounded,
                                      color: _kPrimary,
                                      size: 18,
                                    ),
                                    title: Text(
                                      r,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: _kText,
                                      ),
                                    ),
                                    onTap: () => _selectResult(r),
                                  ),
                                )
                                .toList(),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
