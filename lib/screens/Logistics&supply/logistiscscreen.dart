// import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:google_api_headers/google_api_headers.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
//
// import '../../Models/logistics/locationmodel.dart';
// import '../../Models/logistics/vechilemodel.dart';
// import '../../Services/Auth_service/Subscription_authservice.dart';
// import '../../Services/Auth_service/logisticsservice.dart';
// import '../../Services/googleservices/Location_servces.dart';
// import 'finding_driver_screen.dart';
// import 'location.dart';
//
// const _kPrimary = Color(0xFF6C3CE1); // deep violet
// const _kPrimaryDark = Color(0xFF5429C7);
// const _kPrimaryLight = Color(0xFFF0EAFB); // lavender tint
// const _kAccent = Color(0xFF00C896); // mint green
// const _kBg = Color(0xFFF7F8FC); // off-white background
// const _kSurface = Colors.white;
// const _kText = Color(0xFF1A1A2E); // near-black
// const _kTextSub = Color(0xFF8A8FAB); // muted label
// const _kBorder = Color(0xFFE8EAF2);
// const primary = Color(0xFFE23744);
// const surface = Colors.white;
// const text = Color(0xFF1C1C1C);
// const textMuted = Color(0xFF7C7C7C);
//
// // ─── Responsive helpers ───────────────────────────────────────────────────────
// /// Caps content width on large / tablet screens so the form doesn't stretch
// /// edge-to-edge and stay readable, while remaining full-width on phones.
// double _kMaxContentWidth = 560;
//
// class _ResponsiveContent extends StatelessWidget {
//   final Widget child;
//   const _ResponsiveContent({required this.child});
//
//   @override
//   Widget build(BuildContext context) {
//     final screenWidth = MediaQuery.of(context).size.width;
//     final isWide = screenWidth > _kMaxContentWidth.w;
//     if (!isWide) return child;
//     return Center(
//       child: ConstrainedBox(
//         constraints: BoxConstraints(maxWidth: _kMaxContentWidth.w),
//         child: child,
//       ),
//     );
//   }
// }
//
// class LogisticsScreen extends StatefulWidget {
//   const LogisticsScreen({super.key});
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _LogisticsScreenState createState() => _LogisticsScreenState();
// }
//
// class _LogisticsScreenState extends State<LogisticsScreen>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _animationController;
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
//           width: double.infinity,
//           decoration: BoxDecoration(
//             color: _kSurface,
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withOpacity(0.04),
//                 blurRadius: 24,
//                 offset: const Offset(0, -6),
//               ),
//             ],
//           ),
//           child: ClipRRect(
//             borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
//             child: _ResponsiveContent(
//               child: Padding(
//                 padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
//                 child: AnimatedSwitcher(
//                   duration: const Duration(milliseconds: 300),
//                   transitionBuilder: (child, anim) => FadeTransition(
//                     opacity: anim,
//                     child: SlideTransition(
//                       position: Tween<Offset>(
//                         begin: const Offset(0.04, 0),
//                         end: Offset.zero,
//                       ).animate(anim),
//                       child: child,
//                     ),
//                   ),
//                   child: const PassengerForm(),
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
// // ─── Shared Form Shell ────────────────────────────────────────────────────────
//
// // ─── Shared Section Header ────────────────────────────────────────────────────
// Widget _sectionLabel(String text) => Padding(
//   padding: EdgeInsets.only(bottom: 10.h),
//   child: Text(
//     text,
//     style: TextStyle(
//       fontSize: 14.sp,
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
//         onLocationSelected: (location) {
//           setState(() {
//             widget.controller.text = location.address;
//           });
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
//         padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
//         decoration: BoxDecoration(
//           color: _kBg,
//           borderRadius: BorderRadius.circular(16.r),
//           border: Border.all(color: _kBorder),
//         ),
//         child: Row(
//           children: [
//             Container(
//               width: 34.w,
//               height: 34.w,
//               decoration: BoxDecoration(
//                 color: _dotColor.withOpacity(0.12),
//                 shape: BoxShape.circle,
//               ),
//               child: Icon(widget.icon, size: 16.sp, color: _dotColor),
//             ),
//             SizedBox(width: 12.w),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.label,
//                     style: TextStyle(
//                       fontSize: 11.sp,
//                       color: _kTextSub,
//                       fontWeight: FontWeight.w500,
//                     ),
//                   ),
//                   SizedBox(height: 2.h),
//                   Text(
//                     widget.controller.text.isEmpty
//                         ? 'Tap to search location'
//                         : widget.controller.text,
//                     maxLines: 1,
//                     style: TextStyle(
//                       fontSize: 14.sp,
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
//                 child: Icon(Icons.close_rounded, size: 18.sp, color: _kTextSub),
//               )
//             else
//               Icon(Icons.search_rounded, size: 18.sp, color: _kTextSub),
//           ],
//         ),
//       ),
//     );
//   }
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
//   VehicleModel? selectedVehicle;
//   String? _name;
//   String? _mobile;
//
//   @override
//   void initstate() {
//     super.initState();
//     _loadUserProfile();
//   }
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
//         pickupLongitude: pickupLocation!.longitude,
//         dropLatitude: dropLocation!.latitude,
//         dropLongitude: dropLocation!.longitude,
//         passengers: noOfPeople,
//       );
//
//       if (!mounted) return;
//       setState(() {
//         availableVehicles = vehicles;
//       });
//     } catch (e) {
//       debugPrint('Vehicle fetch error: $e');
//     } finally {
//       if (mounted) {
//         setState(() {
//           loadingVehicles = false;
//         });
//       }
//     }
//   }
//
//   Future<void> _loadUserProfile() async {
//     final profile = await subscription_AuthService.getAccount();
//
//     if (profile != null) {
//       _name = profile.userName;
//       _mobile = profile.phoneNumber;
//       print("name : $_name");
//       print("name : $_name");
//     }
//   }
//
//   Future<void> _bookRide() async {
//     if (pickupLocation == null ||
//         dropLocation == null ||
//         selectedVehicle == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Please complete all details")),
//       );
//       return;
//     }
//
//     try {
//       await LogisticsService.bookRide(
//         userName: _name ?? '',
//         userPhone: _mobile ?? '',
//
//         pickupLatitude: pickupLocation!.latitude,
//         pickupLongitude: pickupLocation!.longitude,
//         pickupAddress: pickupLocation!.address,
//
//         dropLatitude: dropLocation!.latitude,
//         dropLongitude: dropLocation!.longitude,
//         dropAddress: dropLocation!.address,
//
//         bookingDateTime: DateTime.now(),
//
//         vehicle: selectedVehicle!,
//       );
//       print("name : $_name");
//       print("name : $_name");
//
//       Navigator.push(
//         context,
//         MaterialPageRoute(builder: (_) => const FindingDriverScreen()),
//       );
//     } catch (e) {
//       print(e);
//     }
//   }
//
//   @override
//   // Widget build(BuildContext context) {
//   //   return SingleChildScrollView(
//   //     child: Column(
//   //       children: [
//   //         _sectionLabel('Passengers'),
//   //         _modernTextField(
//   //           controller: noofpeopleController,
//   //           hint: 'Number of passengers',
//   //           icon: Icons.person_outline_rounded,
//   //           keyboardType: TextInputType.number,
//   //           onChanged: (v) {
//   //             setState(() {
//   //               noOfPeople = int.tryParse(v) ?? 0;
//   //             });
//   //             fetchAvailableVehicles();
//   //           },
//   //         ),
//   //         SizedBox(height: 16.h),
//   //         _sectionLabel('Pickup & Drop'),
//   //         LocationField(
//   //           label: 'Pickup Location',
//   //           controller: pickupController,
//   //           icon: Icons.trip_origin_rounded,
//   //           onLocationSelected: (location) {
//   //             setState(() {
//   //               pickupLocation = location;
//   //             });
//   //             fetchAvailableVehicles();
//   //           },
//   //         ),
//   //         SizedBox(height: 10.h),
//   //         LocationField(
//   //           label: 'Drop Location',
//   //           controller: dropController,
//   //           icon: Icons.location_on_rounded,
//   //           onLocationSelected: (location) {
//   //             setState(() {
//   //               dropLocation = location;
//   //             });
//   //             fetchAvailableVehicles();
//   //           },
//   //         ),
//   //         SizedBox(height: 16.h),
//   //         const DateTimePickerField(),
//   //         SizedBox(height: 16.h),
//   //         _vehicleSection(),
//   //         SizedBox(
//   //           width: double.infinity,
//   //           height: 52.h,
//   //           child: ElevatedButton(
//   //             onPressed: _bookRide,
//   //
//   //             style:
//   //                 ElevatedButton.styleFrom(
//   //                   backgroundColor: _kPrimary,
//   //                   foregroundColor: Colors.white,
//   //                   elevation: 0,
//   //                   shadowColor: _kPrimary.withOpacity(0.4),
//   //                   shape: RoundedRectangleBorder(
//   //                     borderRadius: BorderRadius.circular(16.r),
//   //                   ),
//   //                 ).copyWith(
//   //                   elevation: WidgetStateProperty.resolveWith(
//   //                     (states) => states.contains(WidgetState.pressed) ? 0 : 2,
//   //                   ),
//   //                 ),
//   //             child: Text(
//   //               'Book Now',
//   //               style: TextStyle(
//   //                 fontSize: 16.sp,
//   //                 fontWeight: FontWeight.w700,
//   //                 letterSpacing: 0.3,
//   //               ),
//   //             ),
//   //           ),
//   //         ),
//   //       ],
//   //     ),
//   //   );
//   // }
//   Widget build(BuildContext context) {
//     return SingleChildScrollView(
//       child: Column(
//         children: [
//           // Google Map
//           SizedBox(
//             height: 200.h,
//             width: double.infinity,
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16.r),
//               child: GoogleMap(
//                 initialCameraPosition: CameraPosition(
//                   target: LatLng(
//                     pickupLocation?.latitude ?? 17.3850,
//                     pickupLocation?.longitude ?? 78.4867,
//                   ),
//                   zoom: 14,
//                 ),
//                 myLocationEnabled: true,
//                 myLocationButtonEnabled: true,
//                 zoomControlsEnabled: false,
//                 mapToolbarEnabled: false,
//
//                 // Prevent conflicts with SingleChildScrollView
//                 scrollGesturesEnabled: false,
//                 zoomGesturesEnabled: false,
//                 rotateGesturesEnabled: false,
//                 tiltGesturesEnabled: false,
//
//                 markers: {
//                   if (pickupLocation != null)
//                     Marker(
//                       markerId: const MarkerId('pickup'),
//                       position: LatLng(
//                         pickupLocation!.latitude,
//                         pickupLocation!.longitude,
//                       ),
//                       infoWindow: const InfoWindow(title: 'Pickup'),
//                     ),
//                   if (dropLocation != null)
//                     Marker(
//                       markerId: const MarkerId('drop'),
//                       position: LatLng(
//                         dropLocation!.latitude,
//                         dropLocation!.longitude,
//                       ),
//                       infoWindow: const InfoWindow(title: 'Drop'),
//                     ),
//                 },
//               ),
//             ),
//           ),
//
//           // SizedBox(height: 20.h),
//           //
//           // _sectionLabel('Passengers'),
//           // _modernTextField(
//           //   controller: noofpeopleController,
//           //   hint: 'Number of passengers',
//           //   icon: Icons.person_outline_rounded,
//           //   keyboardType: TextInputType.number,
//           //   onChanged: (v) {
//           //     setState(() {
//           //       noOfPeople = int.tryParse(v) ?? 0;
//           //     });
//           //     fetchAvailableVehicles();
//           //   },
//           // ),
//           SizedBox(height: 16.h),
//
//           _sectionLabel('Pickup & Drop'),
//
//           LocationField(
//             label: 'Pickup Location',
//             controller: pickupController,
//             icon: Icons.trip_origin_rounded,
//             onLocationSelected: (location) {
//               setState(() {
//                 pickupLocation = location;
//               });
//               fetchAvailableVehicles();
//             },
//           ),
//
//           SizedBox(height: 10.h),
//
//           LocationField(
//             label: 'Drop Location',
//             controller: dropController,
//             icon: Icons.location_on_rounded,
//             onLocationSelected: (location) {
//               setState(() {
//                 dropLocation = location;
//               });
//               fetchAvailableVehicles();
//             },
//           ),
//
//           SizedBox(height: 16.h),
//
//           const DateTimePickerField(),
//
//           SizedBox(height: 16.h),
//
//           _vehicleSection(),
//
//           SizedBox(
//             width: double.infinity,
//             height: 52.h,
//             child: ElevatedButton(
//               onPressed: _bookRide,
//               child: const Text("Book Now"),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _vehicleSection() {
//     if (loadingVehicles) {
//       return Padding(
//         padding: EdgeInsets.symmetric(vertical: 24.h),
//         child: Column(
//           children: [
//             SizedBox(
//               width: 26.w,
//               height: 26.w,
//               child: const CircularProgressIndicator(
//                 color: _kPrimary,
//                 strokeWidth: 2.5,
//               ),
//             ),
//             SizedBox(height: 10.h),
//             Text(
//               'Finding available rides…',
//               style: TextStyle(fontSize: 12.5.sp, color: _kTextSub),
//             ),
//           ],
//         ),
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
//         SizedBox(height: 4.h),
//         ...availableVehicles.map((vehicle) {
//           final isSelected = selectedCategory == vehicle.vehicleStatus;
//           return _VehicleCard(
//             vehicle: vehicle,
//             isSelected: isSelected,
//             onTap: () {
//               setState(() {
//                 selectedCategory = vehicle.vehicleStatus;
//                 selectedVehicle = vehicle;
//               });
//             },
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
//       style: TextStyle(color: _kText, fontSize: 14.sp),
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: _kTextSub, fontSize: 14.sp),
//         prefixIcon: Icon(icon, color: _kTextSub, size: 20.sp),
//         filled: true,
//         fillColor: _kBg,
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16.r),
//           borderSide: const BorderSide(color: _kBorder),
//         ),
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16.r),
//           borderSide: const BorderSide(color: _kBorder),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16.r),
//           borderSide: const BorderSide(color: _kPrimary, width: 1.5),
//         ),
//         contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
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
// /// Extracted vehicle option card — cleaner layout, adapts to narrow phone
// /// widths by letting the meta row wrap instead of overflowing.
// class _VehicleCard extends StatelessWidget {
//   final VehicleModel vehicle;
//   final bool isSelected;
//   final VoidCallback onTap;
//
//   const _VehicleCard({
//     required this.vehicle,
//     required this.isSelected,
//     required this.onTap,
//   });
//
//   String get _emoji {
//     switch (vehicle.vehicleType) {
//       case "BIKE":
//         return "🏍️";
//       case "AUTO":
//         return "🛺";
//       default:
//         return "🚗";
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 220),
//         curve: Curves.easeOut,
//         margin: EdgeInsets.only(bottom: 12.h),
//         padding: EdgeInsets.all(14.w),
//         decoration: BoxDecoration(
//           color: isSelected ? _kPrimary.withOpacity(0.07) : Colors.white,
//           borderRadius: BorderRadius.circular(18.r),
//           border: Border.all(
//             color: isSelected ? _kPrimary : _kBorder,
//             width: isSelected ? 1.8 : 1,
//           ),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(isSelected ? 0.08 : 0.03),
//               blurRadius: isSelected ? 14 : 8,
//               offset: const Offset(0, 5),
//             ),
//           ],
//         ),
//
//         child: Row(
//           children: [
//             // Vehicle Icon
//             Container(
//               width: 40.w,
//               height: 40.w,
//               decoration: BoxDecoration(
//                 color: isSelected ? _kPrimary : _kPrimaryLight,
//                 shape: BoxShape.circle,
//               ),
//               child: Center(
//                 child: Text(_emoji, style: TextStyle(fontSize: 26.sp)),
//               ),
//             ),
//
//             SizedBox(width: 14.w),
//
//             // Vehicle Details
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     vehicle.vehicleStatus.replaceAll("_", " "),
//                     maxLines: 1,
//                     overflow: TextOverflow.ellipsis,
//                     style: TextStyle(
//                       fontSize: 15.sp,
//                       fontWeight: FontWeight.w700,
//                       color: isSelected ? _kPrimary : _kText,
//                     ),
//                   ),
//
//                   SizedBox(height: 5.h),
//
//                   Row(
//                     children: [
//                       Container(
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 8.w,
//                           vertical: 4.h,
//                         ),
//                         decoration: BoxDecoration(
//                           color: _kBg,
//                           borderRadius: BorderRadius.circular(8.r),
//                         ),
//                         child: Text(
//                           vehicle.vehicleType,
//                           style: TextStyle(
//                             fontSize: 11.sp,
//                             fontWeight: FontWeight.w600,
//                             color: _kTextSub,
//                           ),
//                         ),
//                       ),
//
//                       SizedBox(width: 8.w),
//
//                       Icon(
//                         Icons.people_alt_outlined,
//                         size: 14.sp,
//                         color: _kTextSub,
//                       ),
//
//                       SizedBox(width: 3.w),
//
//                       Text(
//                         "${vehicle.availablePartners} available",
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: _kTextSub,
//                           fontWeight: FontWeight.w500,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ),
//
//             // Fare Section
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 Text(
//                   "₹${vehicle.estimatedFare.toStringAsFixed(2)}",
//                   style: TextStyle(
//                     fontSize: 17.sp,
//                     fontWeight: FontWeight.w800,
//                     color: isSelected ? _kPrimary : _kText,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
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
//   bool _searching = false;
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
//     setState(() {
//       _showRecent = false;
//       _searching = true;
//     });
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
//     if (!mounted) return;
//
//     if (response.isOkay) {
//       setState(() {
//         _suggestions = response.predictions
//             .map((e) => e.description ?? '')
//             .toList();
//         _searching = false;
//       });
//     } else {
//       setState(() {
//         _suggestions = [];
//         _searching = false;
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
//     final size = MediaQuery.of(context).size;
//     // Taller sheet on small phones so the keyboard doesn't crowd content;
//     // slightly shorter, centered on large/tablet screens.
//     final sheetHeight = size.width > 600
//         ? size.height * 0.7
//         : size.height * (size.height < 700 ? 0.85 : 0.75);
//
//     return Padding(
//       padding: EdgeInsets.only(
//         bottom: MediaQuery.of(context).viewInsets.bottom,
//       ),
//       child: Container(
//         height: sheetHeight,
//         width: double.infinity,
//         decoration: const BoxDecoration(
//           color: _kSurface,
//           borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
//         ),
//         child: _ResponsiveContent(
//           child: Padding(
//             padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Center(
//                   child: Container(
//                     margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
//                     width: 40.w,
//                     height: 4.h,
//                     decoration: BoxDecoration(
//                       color: _kBorder,
//                       borderRadius: BorderRadius.circular(2.r),
//                     ),
//                   ),
//                 ),
//                 Row(
//                   children: [
//                     Container(
//                       width: 38.w,
//                       height: 38.w,
//                       decoration: BoxDecoration(
//                         color: accentColor.withOpacity(0.12),
//                         shape: BoxShape.circle,
//                       ),
//                       child: Icon(
//                         isPickup
//                             ? Icons.trip_origin_rounded
//                             : Icons.location_on_rounded,
//                         color: accentColor,
//                         size: 18.sp,
//                       ),
//                     ),
//                     SizedBox(width: 12.w),
//                     Expanded(
//                       child: Text(
//                         '${isPickup ? 'Pickup' : 'Drop'} Location',
//                         style: TextStyle(
//                           fontSize: 18.sp,
//                           fontWeight: FontWeight.w700,
//                           color: _kText,
//                         ),
//                       ),
//                     ),
//                     IconButton(
//                       icon: Icon(
//                         Icons.close_rounded,
//                         color: _kTextSub,
//                         size: 22.sp,
//                       ),
//                       onPressed: () => Navigator.pop(context),
//                     ),
//                   ],
//                 ),
//                 SizedBox(height: 14.h),
//
//                 // Search field
//                 Container(
//                   decoration: BoxDecoration(
//                     color: _kBg,
//                     borderRadius: BorderRadius.circular(16.r),
//                     border: Border.all(color: _kBorder),
//                   ),
//                   child: TextField(
//                     controller: _controller,
//                     autofocus: false,
//                     style: TextStyle(fontSize: 14.sp),
//                     decoration: InputDecoration(
//                       hintText: 'Search area, street or landmark',
//                       hintStyle: TextStyle(color: _kTextSub, fontSize: 14.sp),
//                       border: InputBorder.none,
//                       prefixIcon: Icon(
//                         Icons.search_rounded,
//                         color: _kTextSub,
//                         size: 20.sp,
//                       ),
//                       suffixIcon: _searching
//                           ? Padding(
//                               padding: EdgeInsets.all(12.w),
//                               child: SizedBox(
//                                 width: 16.w,
//                                 height: 16.w,
//                                 child: CircularProgressIndicator(
//                                   strokeWidth: 2,
//                                   color: accentColor,
//                                 ),
//                               ),
//                             )
//                           : IconButton(
//                               icon: Icon(
//                                 Icons.my_location_rounded,
//                                 color: accentColor,
//                                 size: 20.sp,
//                               ),
//                               onPressed: () async {
//                                 final result =
//                                     await LocationService.getCurrentLocationWithAddress();
//
//                                 if (result == null || !mounted) return;
//
//                                 widget.onLocationSelected(
//                                   SelectedLocation(
//                                     address: result.fullAddress,
//                                     latitude: result.latitude,
//                                     longitude: result.longitude,
//                                   ),
//                                 );
//
//                                 Navigator.pop(context);
//                               },
//                             ),
//                       contentPadding: EdgeInsets.symmetric(
//                         horizontal: 16.w,
//                         vertical: 14.h,
//                       ),
//                     ),
//                     onChanged: (v) {
//                       _generateSuggestions(v);
//                     },
//                   ),
//                 ),
//                 SizedBox(height: 14.h),
//
//                 // Map button
//                 GestureDetector(
//                   onTap: () async {
//                     final SelectedLocation? loc = await Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (_) => MapLocationSelector(
//                           onLocationSelected: (location) {},
//                         ),
//                       ),
//                     );
//
//                     if (loc != null && mounted) {
//                       widget.onLocationSelected(loc);
//                       Navigator.pop(context);
//                     }
//                   },
//                   child: Container(
//                     padding: EdgeInsets.symmetric(
//                       vertical: 13.h,
//                       horizontal: 16.w,
//                     ),
//                     decoration: BoxDecoration(
//                       color: _kPrimaryLight,
//                       borderRadius: BorderRadius.circular(16.r),
//                     ),
//                     child: Row(
//                       children: [
//                         Icon(Icons.map_outlined, color: _kPrimary, size: 20.sp),
//                         SizedBox(width: 10.w),
//                         Text(
//                           'Select from Map',
//                           style: TextStyle(
//                             color: _kPrimary,
//                             fontWeight: FontWeight.w600,
//                             fontSize: 14.sp,
//                           ),
//                         ),
//                         const Spacer(),
//                         Icon(
//                           Icons.chevron_right_rounded,
//                           color: _kPrimary,
//                           size: 20.sp,
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 20.h),
//
//                 Text(
//                   _showRecent ? 'Recent' : 'Results',
//                   style: TextStyle(
//                     fontSize: 13.sp,
//                     fontWeight: FontWeight.w700,
//                     color: _kTextSub,
//                     letterSpacing: 0.5,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//
//                 Expanded(
//                   child: _suggestions.isEmpty
//                       ? Center(
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Icon(
//                                 Icons.location_off_outlined,
//                                 size: 44.sp,
//                                 color: _kBorder,
//                               ),
//                               SizedBox(height: 12.h),
//                               Text(
//                                 'No locations found',
//                                 style: TextStyle(
//                                   color: _kTextSub,
//                                   fontSize: 13.sp,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         )
//                       : ListView.separated(
//                           itemCount: _suggestions.length,
//                           separatorBuilder: (_, __) =>
//                               const Divider(height: 1, color: _kBorder),
//                           itemBuilder: (context, i) {
//                             final loc = _suggestions[i];
//                             return ListTile(
//                               contentPadding: EdgeInsets.zero,
//                               dense: true,
//                               leading: Container(
//                                 width: 36.w,
//                                 height: 36.w,
//                                 decoration: BoxDecoration(
//                                   color: _kPrimaryLight,
//                                   shape: BoxShape.circle,
//                                 ),
//                                 child: Icon(
//                                   _showRecent
//                                       ? Icons.history_rounded
//                                       : Icons.location_on_rounded,
//                                   color: _kPrimary,
//                                   size: 16.sp,
//                                 ),
//                               ),
//                               title: Text(
//                                 loc,
//                                 maxLines: 2,
//                                 overflow: TextOverflow.ellipsis,
//                                 style: TextStyle(
//                                   fontWeight: FontWeight.w500,
//                                   color: _kText,
//                                   fontSize: 14.sp,
//                                 ),
//                               ),
//                               trailing: Icon(
//                                 Icons.north_west_rounded,
//                                 size: 14.sp,
//                                 color: _kTextSub,
//                               ),
//                               onTap: () async {
//                                 try {
//                                   final locations = await locationFromAddress(
//                                     loc,
//                                   );
//
//                                   if (locations.isEmpty || !mounted) return;
//
//                                   final position = locations.first;
//
//                                   final selectedLocation = SelectedLocation(
//                                     address: loc,
//                                     latitude: position.latitude,
//                                     longitude: position.longitude,
//                                   );
//
//                                   widget.onLocationSelected(selectedLocation);
//
//                                   Navigator.pop(context);
//                                 } catch (e) {
//                                   debugPrint("Location conversion error $e");
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                 ),
//                 SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
//               ],
//             ),
//           ),
//         ),
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
//   ThemeData _pickerTheme() => ThemeData.light().copyWith(
//     colorScheme: const ColorScheme.light(primary: _kPrimary),
//   );
//
//   Future<void> _pickCustomDateTime() async {
//     final date = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//       builder: (context, child) => Theme(data: _pickerTheme(), child: child!),
//     );
//     if (date == null || !mounted) return;
//     final time = await showTimePicker(
//       // ignore: use_build_context_synchronously
//       context: context,
//       initialTime: TimeOfDay.now(),
//       builder: (context, child) => Theme(data: _pickerTheme(), child: child!),
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
//       builder: (context, child) => Theme(data: _pickerTheme(), child: child!),
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
//     // On very narrow phones, stack the picker and quick-action buttons
//     // instead of forcing them into one row where text would get clipped.
//     final isNarrow = MediaQuery.of(context).size.width < 340;
//
//     final dateDisplay = GestureDetector(
//       onTap: _pickCustomDateTime,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
//         child: selectedDateTime == null
//             ? Row(
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Icon(
//                     Icons.calendar_today_rounded,
//                     size: 18.sp,
//                     color: _kTextSub,
//                   ),
//                   SizedBox(width: 8.w),
//                   Flexible(
//                     child: Text(
//                       'Pick date & time',
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(color: _kTextSub, fontSize: 13.sp),
//                     ),
//                   ),
//                 ],
//               )
//             : Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 mainAxisSize: MainAxisSize.min,
//                 children: [
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.calendar_today_rounded,
//                         size: 16.sp,
//                         color: _kPrimary,
//                       ),
//                       SizedBox(width: 6.w),
//                       Text(
//                         DateFormat('dd MMM yyyy').format(selectedDateTime!),
//                         style: TextStyle(
//                           color: _kText,
//                           fontWeight: FontWeight.w600,
//                           fontSize: 13.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                   SizedBox(height: 4.h),
//                   Row(
//                     mainAxisSize: MainAxisSize.min,
//                     children: [
//                       Icon(
//                         Icons.access_time_rounded,
//                         size: 16.sp,
//                         color: _kPrimary,
//                       ),
//                       SizedBox(width: 6.w),
//                       Text(
//                         DateFormat('hh:mm a').format(selectedDateTime!),
//                         style: TextStyle(
//                           color: _kPrimary,
//                           fontWeight: FontWeight.w500,
//                           fontSize: 13.sp,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//       ),
//     );
//
//     final quickButtons = Wrap(
//       spacing: 6.w,
//       runSpacing: 6.h,
//       children: [
//         _quickTimeButton('Today', () => _pickTimeForBaseDate(today)),
//         _quickTimeButton('Tomorrow', () => _pickTimeForBaseDate(tomorrow)),
//       ],
//     );
//
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         _sectionLabel('Schedule (Optional)'),
//         Container(
//           width: double.infinity,
//           padding: EdgeInsets.all(isNarrow ? 8.w : 4.w),
//           decoration: BoxDecoration(
//             color: _kBg,
//             borderRadius: BorderRadius.circular(16.r),
//             border: Border.all(color: _kBorder),
//           ),
//           child: isNarrow
//               ? Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     dateDisplay,
//                     SizedBox(height: 4.h),
//                     quickButtons,
//                   ],
//                 )
//               : Row(
//                   children: [
//                     Expanded(child: dateDisplay),
//                     quickButtons,
//                     SizedBox(width: 2.w),
//                   ],
//                 ),
//         ),
//       ],
//     );
//   }
//
//   Widget _quickTimeButton(String label, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
//         decoration: BoxDecoration(
//           color: _kPrimaryLight,
//           borderRadius: BorderRadius.circular(10.r),
//         ),
//         child: Text(
//           label,
//           style: TextStyle(
//             color: _kPrimary,
//             fontSize: 12.sp,
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

import '../../Models/logistics/locationmodel.dart';
import '../../Models/logistics/vechilemodel.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/Auth_service/logisticsservice.dart';
import '../../Services/googleservices/Location_servces.dart';
import 'finding_driver_screen.dart';
import 'location.dart';

const _kPrimary = Color(0xFF6C3CE1); // deep violet
const _kPrimaryDark = Color(0xFF5429C7);
const _kPrimaryLight = Color(0xFFF0EAFB); // lavender tint
const _kAccent = Color(0xFF00C896); // mint green
const _kBg = Color(0xFFF7F8FC); // off-white background
const _kSurface = Colors.white;
const _kText = Color(0xFF1A1A2E); // near-black
const _kTextSub = Color(0xFF8A8FAB); // muted label
const _kBorder = Color(0xFFE8EAF2);
const primary = Color(0xFFE23744);
const surface = Colors.white;
const text = Color(0xFF1C1C1C);
const textMuted = Color(0xFF7C7C7C);

// ─── Responsive helpers ───────────────────────────────────────────────────────
/// Caps content width on large / tablet screens so the form doesn't stretch
/// edge-to-edge and stay readable, while remaining full-width on phones.
double _kMaxContentWidth = 560;

class _ResponsiveContent extends StatelessWidget {
  final Widget child;
  const _ResponsiveContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isWide = screenWidth > _kMaxContentWidth.w;
    if (!isWide) return child;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: _kMaxContentWidth.w),
        child: child,
      ),
    );
  }
}

class LogisticsScreen extends StatefulWidget {
  const LogisticsScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _LogisticsScreenState createState() => _LogisticsScreenState();
}

class _LogisticsScreenState extends State<LogisticsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
          child: const PassengerForm(),
        ),
      ),
    );
  }
}

// ─── Shared Form Shell ────────────────────────────────────────────────────────

// ─── Shared Section Header ────────────────────────────────────────────────────
Widget _sectionLabel(String text) => Padding(
  padding: EdgeInsets.only(bottom: 10.h),
  child: Text(
    text,
    style: TextStyle(
      fontSize: 14.sp,
      fontWeight: FontWeight.w700,
      color: _kText,
      letterSpacing: 0.2,
    ),
  ),
);

class LocationField extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final Function(SelectedLocation location)? onLocationSelected;
  final List<String> Function()? recentLocationsProvider;

  const LocationField({
    super.key,
    required this.label,
    required this.controller,
    required this.icon,
    this.recentLocationsProvider,
    this.onLocationSelected,
  });

  @override
  State<LocationField> createState() => _LocationFieldState();
}

class _LocationFieldState extends State<LocationField> {
  bool get _isPickup => widget.label.toLowerCase().contains('pickup');

  Color get _dotColor => _isPickup ? _kAccent : _kPrimary;

  void _openLocationPicker() {
    FocusScope.of(context).unfocus();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => LocationEntryScreen(
        type: _isPickup ? 'pickup' : 'drop',
        recentLocations: const ["Home", "Office", "Airport"],
        onLocationSelected: (location) {
          setState(() {
            widget.controller.text = location.address;
          });
          widget.onLocationSelected?.call(location);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _openLocationPicker,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: _dotColor.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(widget.icon, size: 16.sp, color: _dotColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: _kTextSub,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    widget.controller.text.isEmpty
                        ? 'Tap to search location'
                        : widget.controller.text,
                    maxLines: 1,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: widget.controller.text.isEmpty
                          ? _kTextSub
                          : _kText,
                      fontWeight: widget.controller.text.isEmpty
                          ? FontWeight.w400
                          : FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (widget.controller.text.isNotEmpty)
              GestureDetector(
                onTap: () => setState(() => widget.controller.clear()),
                child: Icon(Icons.close_rounded, size: 18.sp, color: _kTextSub),
              )
            else
              Icon(Icons.search_rounded, size: 18.sp, color: _kTextSub),
          ],
        ),
      ),
    );
  }
}

// ─── Passenger Form ───────────────────────────────────────────────────────────
class PassengerForm extends StatefulWidget {
  const PassengerForm({super.key});
  @override
  // ignore: library_private_types_in_public_api
  _PassengerFormState createState() => _PassengerFormState();
}

class _PassengerFormState extends State<PassengerForm> {
  final pickupController = TextEditingController();
  final dropController = TextEditingController();
  String? selectedCategory;
  int noOfPeople = 0;
  final noofpeopleController = TextEditingController();
  SelectedLocation? pickupLocation;
  SelectedLocation? dropLocation;
  List<VehicleModel> availableVehicles = [];

  bool loadingVehicles = false;
  VehicleModel? selectedVehicle;
  String? _name;
  String? _mobile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    pickupController.dispose();
    dropController.dispose();
    noofpeopleController.dispose();
    super.dispose();
  }

  Future<void> fetchAvailableVehicles() async {
    if (pickupLocation == null || dropLocation == null || noOfPeople == 0) {
      return;
    }

    setState(() {
      loadingVehicles = true;
    });

    try {
      final vehicles = await LogisticsService.getVehicles(
        pickupLatitude: pickupLocation!.latitude,
        pickupLongitude: pickupLocation!.longitude,
        dropLatitude: dropLocation!.latitude,
        dropLongitude: dropLocation!.longitude,
        passengers: noOfPeople,
      );

      if (!mounted) return;
      setState(() {
        availableVehicles = vehicles;
      });
    } catch (e) {
      // debugPrint('Vehicle fetch error: $e');
    } finally {
      if (mounted) {
        setState(() {
          loadingVehicles = false;
        });
      }
    }
  }

  Future<void> _loadUserProfile() async {
    // print("Loading profile...");

    final profile = await subscription_AuthService.getAccount();

    // print("Profile: $profile");

    if (profile != null) {
      // print("Name = ${profile.userName}");
      // print("Phone = ${profile.phoneNumber}");

      setState(() {
        _name = profile.userName;
        _mobile = profile.phoneNumber;
      });
    }
  }

  Future<void> _bookRide() async {
    if (pickupLocation == null ||
        dropLocation == null ||
        selectedVehicle == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please complete all details")),
      );
      return;
    }

    try {
      final booking = await LogisticsService.bookRide(
        userName: _name ?? '',
        userPhone: _mobile ?? '',

        pickupLatitude: pickupLocation!.latitude,
        pickupLongitude: pickupLocation!.longitude,
        pickupAddress: pickupLocation!.address,

        dropLatitude: dropLocation!.latitude,
        dropLongitude: dropLocation!.longitude,
        dropAddress: dropLocation!.address,

        bookingDateTime: DateTime.now(),

        vehicle: selectedVehicle!,
      );
      // print("name : $_name");
      // print("name : $_name");

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => FindingDriverScreen()),
      );
    } catch (e) {
      // print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Google Map
          SizedBox(
            height: 250.h,
            width: double.infinity,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: GoogleMap(
                initialCameraPosition: CameraPosition(
                  target: LatLng(
                    pickupLocation?.latitude ?? 17.3850,
                    pickupLocation?.longitude ?? 78.4867,
                  ),
                  zoom: 14,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,

                // Prevent conflicts with SingleChildScrollView
                scrollGesturesEnabled: false,
                zoomGesturesEnabled: false,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,

                markers: {
                  if (pickupLocation != null)
                    Marker(
                      markerId: const MarkerId('pickup'),
                      position: LatLng(
                        pickupLocation!.latitude,
                        pickupLocation!.longitude,
                      ),
                      infoWindow: const InfoWindow(title: 'Pickup'),
                    ),
                  if (dropLocation != null)
                    Marker(
                      markerId: const MarkerId('drop'),
                      position: LatLng(
                        dropLocation!.latitude,
                        dropLocation!.longitude,
                      ),
                      infoWindow: const InfoWindow(title: 'Drop'),
                    ),
                },
              ),
            ),
          ),

          SizedBox(height: 20.h),

          // _sectionLabel('Passengers'),
          _modernTextField(
            controller: noofpeopleController,
            hint: 'Number of passengers',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.number,
            onChanged: (v) {
              setState(() {
                noOfPeople = int.tryParse(v) ?? 0;
              });
              fetchAvailableVehicles();
            },
          ),
          SizedBox(height: 16.h),

          // _sectionLabel('Pickup & Drop'),
          LocationField(
            label: 'Pickup Location',
            controller: pickupController,
            icon: Icons.trip_origin_rounded,
            onLocationSelected: (location) {
              setState(() {
                pickupLocation = location;
              });
              fetchAvailableVehicles();
            },
          ),

          SizedBox(height: 10.h),

          LocationField(
            label: 'Drop Location',
            controller: dropController,
            icon: Icons.location_on_rounded,
            onLocationSelected: (location) {
              setState(() {
                dropLocation = location;
              });
              fetchAvailableVehicles();
            },
          ),

          // SizedBox(height: 16.h),
          //
          // const DateTimePickerField(),
          SizedBox(height: 16.h),

          _vehicleSection(),

          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: _bookRide,
              child: const Text("Book Now"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _vehicleSection() {
    if (loadingVehicles) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 24.h),
        child: Column(
          children: [
            SizedBox(
              width: 26.w,
              height: 26.w,
              child: const CircularProgressIndicator(
                color: _kPrimary,
                strokeWidth: 2.5,
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              'Finding available rides…',
              style: TextStyle(fontSize: 12.5.sp, color: _kTextSub),
            ),
          ],
        ),
      );
    }
    if (availableVehicles.isEmpty) {
      return Container(
        width: double.infinity,
        margin: EdgeInsets.only(top: 16.h),
        padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 16.w),
        decoration: BoxDecoration(
          color: _kBg,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _kBorder),
        ),
        child: Column(
          children: [
            Icon(Icons.directions_car_outlined, size: 48.sp, color: _kTextSub),
            SizedBox(height: 12.h),
            Text(
              "No partners available",
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: _kText,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              "Sorry! No vehicles are currently available for the selected route. Please try again later or change your pickup/drop location.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: _kTextSub, height: 1.4),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Choose Vehicle'),
        SizedBox(height: 4.h),
        ...availableVehicles.map((vehicle) {
          final isSelected = selectedCategory == vehicle.vehicleStatus;
          return _VehicleCard(
            vehicle: vehicle,
            isSelected: isSelected,
            onTap: () {
              setState(() {
                selectedCategory = vehicle.vehicleStatus;
                selectedVehicle = vehicle;
              });
            },
          );
        }),
      ],
    );
  }

  Widget _modernTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: _kText, fontSize: 14.sp),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: _kTextSub, fontSize: 14.sp),
        prefixIcon: Icon(icon, color: _kTextSub, size: 20.sp),
        filled: true,
        fillColor: _kBg,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: _kBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16.r),
          borderSide: const BorderSide(color: _kPrimary, width: 1.5),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      ),
    );
  }

  Widget locationField(
    String label,
    TextEditingController controller,
    IconData icon,
  ) {
    return LocationField(label: label, controller: controller, icon: icon);
  }
}

/// Extracted vehicle option card — cleaner layout, adapts to narrow phone
/// widths by letting the meta row wrap instead of overflowing.
class _VehicleCard extends StatelessWidget {
  final VehicleModel vehicle;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleCard({
    required this.vehicle,
    required this.isSelected,
    required this.onTap,
  });

  String get _emoji {
    switch (vehicle.vehicleType) {
      case "BIKE":
        return "🏍️";
      case "AUTO":
        return "🛺";
      default:
        return "🚗";
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: isSelected ? _kPrimary.withOpacity(0.07) : Colors.white,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: isSelected ? _kPrimary : _kBorder,
            width: isSelected ? 1.8 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isSelected ? 0.08 : 0.03),
              blurRadius: isSelected ? 14 : 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),

        child: Row(
          children: [
            // Vehicle Icon
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: isSelected ? _kPrimary : _kPrimaryLight,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(_emoji, style: TextStyle(fontSize: 26.sp)),
              ),
            ),

            SizedBox(width: 14.w),

            // Vehicle Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleStatus.replaceAll("_", " "),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? _kPrimary : _kText,
                    ),
                  ),

                  SizedBox(height: 5.h),

                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: _kBg,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          vehicle.vehicleType,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: _kTextSub,
                          ),
                        ),
                      ),

                      SizedBox(width: 8.w),

                      Icon(
                        Icons.people_alt_outlined,
                        size: 14.sp,
                        color: _kTextSub,
                      ),

                      SizedBox(width: 3.w),

                      Text(
                        "${vehicle.availablePartners} available",
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _kTextSub,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Fare Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "₹${vehicle.estimatedFare.toStringAsFixed(2)}",
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: isSelected ? _kPrimary : _kText,
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

class LocationEntryScreen extends StatefulWidget {
  final String type;
  final List<String> recentLocations;
  final Function(SelectedLocation) onLocationSelected;

  const LocationEntryScreen({
    super.key,
    required this.type,
    required this.recentLocations,
    required this.onLocationSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _LocationEntryScreenState createState() => _LocationEntryScreenState();
}

class _LocationEntryScreenState extends State<LocationEntryScreen> {
  final TextEditingController _controller = TextEditingController();
  List<String> _suggestions = [];
  bool _showRecent = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _suggestions = widget.recentLocations;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _generateSuggestions(String query) async {
    if (query.isEmpty) {
      setState(() {
        _showRecent = true;
        _suggestions = widget.recentLocations;
      });
      return;
    }

    setState(() {
      _showRecent = false;
      _searching = true;
    });

    final places = GoogleMapsPlaces(
      apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'] ?? '',
      apiHeaders: await const GoogleApiHeaders().getHeaders(),
    );

    final response = await places.autocomplete(
      query,
      components: [Component(Component.country, "in")],
    );

    if (!mounted) return;

    if (response.isOkay) {
      setState(() {
        _suggestions = response.predictions
            .map((e) => e.description ?? '')
            .toList();
        _searching = false;
      });
    } else {
      setState(() {
        _suggestions = [];
        _searching = false;
      });
    }

    places.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.type == 'pickup';
    final accentColor = isPickup ? _kAccent : _kPrimary;
    final size = MediaQuery.of(context).size;
    // Taller sheet on small phones so the keyboard doesn't crowd content;
    // slightly shorter, centered on large/tablet screens.
    final sheetHeight = size.width > 600
        ? size.height * 0.7
        : size.height * (size.height < 700 ? 0.85 : 0.75);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        height: sheetHeight,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: _kSurface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _ResponsiveContent(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    margin: EdgeInsets.only(top: 12.h, bottom: 16.h),
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: _kBorder,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                Row(
                  children: [
                    Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isPickup
                            ? Icons.trip_origin_rounded
                            : Icons.location_on_rounded,
                        color: accentColor,
                        size: 18.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Text(
                        '${isPickup ? 'Pickup' : 'Drop'} Location',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: _kText,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close_rounded,
                        color: _kTextSub,
                        size: 22.sp,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                SizedBox(height: 14.h),

                // Search field
                Container(
                  decoration: BoxDecoration(
                    color: _kBg,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: _kBorder),
                  ),
                  child: TextField(
                    controller: _controller,
                    autofocus: false,
                    style: TextStyle(fontSize: 14.sp),
                    decoration: InputDecoration(
                      hintText: 'Search area, street or landmark',
                      hintStyle: TextStyle(color: _kTextSub, fontSize: 14.sp),
                      border: InputBorder.none,
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: _kTextSub,
                        size: 20.sp,
                      ),
                      suffixIcon: _searching
                          ? Padding(
                              padding: EdgeInsets.all(12.w),
                              child: SizedBox(
                                width: 16.w,
                                height: 16.w,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: accentColor,
                                ),
                              ),
                            )
                          : IconButton(
                              icon: Icon(
                                Icons.my_location_rounded,
                                color: accentColor,
                                size: 20.sp,
                              ),
                              onPressed: () async {
                                final result =
                                    await LocationService.getCurrentLocationWithAddress();

                                if (result == null || !mounted) return;

                                widget.onLocationSelected(
                                  SelectedLocation(
                                    address: result.fullAddress,
                                    latitude: result.latitude,
                                    longitude: result.longitude,
                                  ),
                                );

                                Navigator.pop(context);
                              },
                            ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                    onChanged: (v) {
                      _generateSuggestions(v);
                    },
                  ),
                ),
                SizedBox(height: 14.h),

                // Map button
                GestureDetector(
                  onTap: () async {
                    final SelectedLocation? loc = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MapLocationSelector(
                          onLocationSelected: (location) {},
                        ),
                      ),
                    );

                    if (loc != null && mounted) {
                      widget.onLocationSelected(loc);
                      Navigator.pop(context);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      vertical: 13.h,
                      horizontal: 16.w,
                    ),
                    decoration: BoxDecoration(
                      color: _kPrimaryLight,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.map_outlined, color: _kPrimary, size: 20.sp),
                        SizedBox(width: 10.w),
                        Text(
                          'Select from Map',
                          style: TextStyle(
                            color: _kPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14.sp,
                          ),
                        ),
                        const Spacer(),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: _kPrimary,
                          size: 20.sp,
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                Text(
                  _showRecent ? 'Recent' : 'Results',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _kTextSub,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 8.h),

                Expanded(
                  child: _suggestions.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.location_off_outlined,
                                size: 44.sp,
                                color: _kBorder,
                              ),
                              SizedBox(height: 12.h),
                              Text(
                                'No locations found',
                                style: TextStyle(
                                  color: _kTextSub,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          itemCount: _suggestions.length,
                          separatorBuilder: (_, __) =>
                              const Divider(height: 1, color: _kBorder),
                          itemBuilder: (context, i) {
                            final loc = _suggestions[i];
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              dense: true,
                              leading: Container(
                                width: 36.w,
                                height: 36.w,
                                decoration: BoxDecoration(
                                  color: _kPrimaryLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  _showRecent
                                      ? Icons.history_rounded
                                      : Icons.location_on_rounded,
                                  color: _kPrimary,
                                  size: 16.sp,
                                ),
                              ),
                              title: Text(
                                loc,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: _kText,
                                  fontSize: 14.sp,
                                ),
                              ),
                              trailing: Icon(
                                Icons.north_west_rounded,
                                size: 14.sp,
                                color: _kTextSub,
                              ),
                              onTap: () async {
                                try {
                                  final locations = await locationFromAddress(
                                    loc,
                                  );

                                  if (locations.isEmpty || !mounted) return;

                                  final position = locations.first;

                                  final selectedLocation = SelectedLocation(
                                    address: loc,
                                    latitude: position.latitude,
                                    longitude: position.longitude,
                                  );

                                  widget.onLocationSelected(selectedLocation);

                                  Navigator.pop(context);
                                } catch (e) {
                                  // debugPrint("Location conversion error $e");
                                }
                              },
                            );
                          },
                        ),
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 8.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DateTimePickerField extends StatefulWidget {
  const DateTimePickerField({super.key});
  @override
  State<DateTimePickerField> createState() => _DateTimePickerFieldState();
}

class _DateTimePickerFieldState extends State<DateTimePickerField> {
  DateTime? selectedDateTime;

  ThemeData _pickerTheme() => ThemeData.light().copyWith(
    colorScheme: const ColorScheme.light(primary: _kPrimary),
  );

  Future<void> _pickCustomDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) => Theme(data: _pickerTheme(), child: child!),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      // ignore: use_build_context_synchronously
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: _pickerTheme(), child: child!),
    );
    if (time == null) return;
    setState(() {
      selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _pickTimeForBaseDate(DateTime baseDate) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) => Theme(data: _pickerTheme(), child: child!),
    );
    if (time == null) return;
    setState(() {
      selectedDateTime = DateTime(
        baseDate.year,
        baseDate.month,
        baseDate.day,
        time.hour,
        time.minute,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final tomorrow = today.add(const Duration(days: 1));
    // On very narrow phones, stack the picker and quick-action buttons
    // instead of forcing them into one row where text would get clipped.
    final isNarrow = MediaQuery.of(context).size.width < 340;

    final dateDisplay = GestureDetector(
      onTap: _pickCustomDateTime,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: selectedDateTime == null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 18.sp,
                    color: _kTextSub,
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      'Pick date & time',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: _kTextSub, fontSize: 13.sp),
                    ),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 16.sp,
                        color: _kPrimary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        DateFormat('dd MMM yyyy').format(selectedDateTime!),
                        style: TextStyle(
                          color: _kText,
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 16.sp,
                        color: _kPrimary,
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        DateFormat('hh:mm a').format(selectedDateTime!),
                        style: TextStyle(
                          color: _kPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );

    final quickButtons = Wrap(
      spacing: 6.w,
      runSpacing: 6.h,
      children: [
        _quickTimeButton('Today', () => _pickTimeForBaseDate(today)),
        _quickTimeButton('Tomorrow', () => _pickTimeForBaseDate(tomorrow)),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionLabel('Schedule (Optional)'),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(isNarrow ? 8.w : 4.w),
          decoration: BoxDecoration(
            color: _kBg,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: _kBorder),
          ),
          child: isNarrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    dateDisplay,
                    SizedBox(height: 4.h),
                    quickButtons,
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: dateDisplay),
                    quickButtons,
                    SizedBox(width: 2.w),
                  ],
                ),
        ),
      ],
    );
  }

  Widget _quickTimeButton(String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: _kPrimaryLight,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: _kPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
