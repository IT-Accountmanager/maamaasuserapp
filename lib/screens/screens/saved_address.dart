import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_google_places_hoc081098/flutter_google_places_hoc081098.dart';
import 'package:flutter_google_places_hoc081098/google_maps_webservice_places.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_api_headers/google_api_headers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maamaas/Services/scaffoldmessenger/messenger.dart';
import 'package:maamaas/screens/screens/selectaddress.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/subscrptions/address_model.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../providers/addressmodel_provider.dart';
import '../../Services/googleservices/Location_servces.dart';

// ── Design tokens (shared with Ticket & Wallet screens) ───────────────────────
class _A {
  static const bg = Color(0xFFF5F6FA);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE8ECF4);

  static const violet = Color(0xFF6C63FF);

  static const textPrimary = Color(0xFF1A1D2E);
  static const textSecondary = Color(0xFF64748B);
  static const textMuted = Color(0xFFB0B8CC);

  static const green = Color(0xFF10B981);
  static const blue = Color(0xFF3B82F6);
  static const purple = Color(0xFF8B5CF6);
  static const red = Color(0xFFEF4444);
}

// ═══════════════════════════════════════════════════════════════════════════════
// SavedAddress
// ═══════════════════════════════════════════════════════════════════════════════
class SavedAddress extends ConsumerStatefulWidget {
  final bool hideExtraWidgets;
  final void Function(SelectedAddress address)? onAddressSelected;

  const SavedAddress({
    super.key,
    this.onAddressSelected,
    this.hideExtraWidgets = false,
  });

  @override
  ConsumerState<SavedAddress> createState() => _SavedAddressState();
}

class _SavedAddressState extends ConsumerState<SavedAddress> {
  bool isLoading = false;
  List<Address> addressList = [];
  Future<List<Address>>? _futureAddresses;
  bool _isLoading = false;
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _loadAddresses();
    _futureAddresses = subscription_AuthService.fetchAddresses();
    _loadLocationFromAPI();
    _getCurrentLocation();
    // _loadKey();
  }

  String formatAddress(Address a) {
    return [
      a.doorNumber,
      a.addressLine,
      a.landMark,
      a.city,
      a.state,
      a.pincode,
    ].where((e) => e.toString().trim().isNotEmpty).join(', ');
  }

  // Future<void> _loadKey() async {
  //   _googleApiKey = await ApiKeyService.getApiKey();
  // }

  void _refreshTable() {
    debugPrint("📦 Refreshing address list...");
    setState(() {
      _futureAddresses = subscription_AuthService.fetchAddresses();
    });
  }

  void _loadLocationFromAPI() async {
    await subscription_AuthService.fetchCurrentLocation();
  }

  Future<void> _loadAddresses() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getInt('userId') == null) {
      setState(() => isLoading = false);
      return;
    }
    try {
      final addresses = await subscription_AuthService.fetchAddresses();
      setState(() {
        addressList = addresses;
        _futureAddresses = Future.value(addresses);
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _deleteAddress(int addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _A.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          'Delete Address',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: _A.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this address?',
          style: TextStyle(fontSize: 13.sp, color: _A.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(color: _A.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Delete',
              style: TextStyle(color: _A.red, fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final ok = await subscription_AuthService.deleteAddress(addressId);
      if (ok) {
        // ignore: use_build_context_synchronously
        AppAlert.success(context, 'Address deleted');
        _refreshTable();
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, '$e');
    }
  }

  Future<void> _updateLocation(LatLng latLng) async {
    setState(() => isLoading = true);

    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final p = placemarks.first;

        await ref
            .read(addressProvider.notifier)
            .updateLocalAddress(
              city: p.locality ?? '',
              stateName: p.administrativeArea ?? '',
              pincode: p.postalCode ?? '',
              latitude: latLng.latitude,
              longitude: latLng.longitude,
              fullAddress:
                  '${p.street}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}',

              category: "Current Location", // ✅ CRITICAL FIX
            );

        await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();

        widget.onAddressSelected?.call(
          SelectedAddress(
            city: p.locality ?? '',
            state: p.administrativeArea ?? '',
            pincode: p.postalCode ?? '',
            landmark: p.street ?? '',
            subLocality: p.subLocality ?? '',
            fullAddress:
                '${p.name}, ${p.subLocality}, ${p.locality}, ${p.administrativeArea}, ${p.postalCode}',
            latitude: latLng.latitude,
            longitude: latLng.longitude,
            category: "Current Location",
          ),
        );
      }
    } catch (_) {}

    setState(() => isLoading = false);
  }

  Future<void> _handleSearch() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
      mode: Mode.overlay,
      language: 'en',
      components: [Component(Component.country, 'in')],
      logo: const SizedBox.shrink(),
    );
    if (p != null) {
      final places = GoogleMapsPlaces(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      final detail = await places.getDetailsByPlaceId(p.placeId!);
      final loc = detail.result.geometry!.location;
      _updateLocation(LatLng(loc.lat, loc.lng));
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final result = await LocationService.getCurrentLocationWithAddress();
    if (!mounted) return;
    if (result == null) {
      setState(() => _isLoading = false);
      return;
    }
    setState(() {
      _currentPosition = Position(
        latitude: result.latitude,
        longitude: result.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      );
      _currentAddress = result.fullAddress;
      _isLoading = false;
    });
  }

  IconData _categoryIcon(String cat) {
    switch (cat) {
      case 'Home':
        return Icons.home_rounded;
      case 'Office':
        return Icons.business_rounded;
      default:
        return Icons.location_on_rounded;
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'Home':
        return _A.green;
      case 'Office':
        return _A.blue;
      default:
        return _A.purple;
    }
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _A.bg,
      appBar: _buildAppBar(),
      body: SafeArea(
        child: RefreshIndicator(
          color: _A.violet,
          backgroundColor: _A.surface,
          onRefresh: () async => _refreshTable(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            children: [
              if (!widget.hideExtraWidgets) ...[
                _buildSearchBar(),
                _buildCurrentLocation(),
              ],
              _buildAddAddressButton(),
              _buildSavedSection(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: _A.surface,
      elevation: 0,
      centerTitle: true,
      title: Text(
        'Select a Location',
        style: TextStyle(
          fontSize: 17.sp,
          fontWeight: FontWeight.w700,
          color: _A.textPrimary,
        ),
      ),
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new_rounded,
        ), // iOS-style back arrow
        color: Color(0xFF1A1D2E),
        onPressed: () => Navigator.of(context).pop(),
      ),
      iconTheme: const IconThemeData(color: _A.textPrimary),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: _A.border),
      ),
    );
  }

  // ── Search bar ───────────────────────────────────────────────────────────
  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _handleSearch,
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
        height: 50.h,
        decoration: BoxDecoration(
          color: _A.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: _A.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            SizedBox(width: 14.w),
            Icon(Icons.search_rounded, color: _A.violet, size: 20.sp),
            SizedBox(width: 10.w),
            Text(
              'Search location...',
              style: TextStyle(fontSize: 14.sp, color: _A.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  // ── Current location tile ────────────────────────────────────────────────
  Widget _buildCurrentLocation() {
    if (_isLoading) {
      return Padding(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 12.h),
        child: Row(
          children: [
            /// 🔄 Icon / Loader
            Container(
              width: 36.w,
              height: 36.w,
              decoration: BoxDecoration(
                color: _A.violet.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: SizedBox(
                  width: 18.r,
                  height: 18.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: _A.violet,
                  ),
                ),
              ),
            ),

            SizedBox(width: 12.w),

            /// 📍 Text info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Detecting current location...',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    'Please wait while we fetch your location',
                    style: TextStyle(fontSize: 11.sp, color: _A.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    if (_currentPosition == null || _currentAddress == null) {
      return const SizedBox.shrink();
    }
    return _listTile(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      iconBg: _A.violet.withOpacity(0.10),
      icon: Icons.my_location_rounded,
      iconColor: _A.violet,
      title: 'Use Current Location',
      subtitle: _currentAddress!,
      onTap: () {
        _updateLocation(
          LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
        );
        Navigator.pop(context);
      },
    );
  }

  // ── Add address button ───────────────────────────────────────────────────
  Widget _buildAddAddressButton() {
    return _listTile(
      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      iconBg: _A.green.withOpacity(0.10),
      icon: Icons.add_location_alt_rounded,
      iconColor: _A.green,
      title: 'Add New Address',
      subtitle: 'Save a home, office or custom address',
      onTap: () async {
        final ok = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => AddressFormScreen()),
        );

        if (ok == true) {
          debugPrint("🔄 Refreshing after adding address");
          _refreshTable();
        }
      },
    );
  }

  Widget _listTile({
    required EdgeInsets margin,
    required Color iconBg,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: margin,
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: _A.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _A.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42.r,
              height: 42.r,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, size: 20.sp, color: iconColor),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: _A.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11.sp, color: _A.textSecondary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, size: 20.sp, color: _A.textMuted),
          ],
        ),
      ),
    );
  }

  // ── Saved addresses section ──────────────────────────────────────────────
  Widget _buildSavedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FutureBuilder<List<Address>>(
          future: _futureAddresses,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(24.h),
                  child: CircularProgressIndicator(
                    color: _A.violet,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Padding(
                padding: EdgeInsets.all(24.w),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_off_outlined,
                        size: 40.sp,
                        color: _A.textMuted,
                      ),
                      SizedBox(height: 10.h),
                      Text(
                        'No saved addresses',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: _A.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              itemCount: snapshot.data!.length,
              itemBuilder: (_, i) => _buildAddressCard(snapshot.data![i]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAddressCard(Address address) {
    final color = _categoryColor(address.category);

    return GestureDetector(
      onTap: () async {
        await ref
            .read(addressProvider.notifier)
            .updateLocalAddress(
              city: address.city,
              stateName: address.state,
              pincode: address.pincode.toString(),
              latitude: address.latitude,
              longitude: address.longitude,
              fullAddress: [
                address.doorNumber,
                address.addressLine,
                address.landMark,
                address.city,
                address.state,
                address.pincode.toString(),
              ].where((e) => e.toString().trim().isNotEmpty).join(', '),
              category: address.category,
            );
        await ref.read(addressProvider.notifier).sendCurrentLocationToBackend();
        widget.onAddressSelected?.call(
          SelectedAddress(
            city: address.city,
            state: address.state,
            pincode: address.pincode.toString(),
            latitude: address.latitude,
            longitude: address.longitude,
            addressId: address.id,
            category: address.category,
            fullAddress: [
              address.doorNumber,
              address.addressLine,
              address.landMark,
              address.city,
              address.state,
              address.pincode.toString(),
            ].where((e) => e.toString().isNotEmpty).join(', '),
          ),
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context);
      },
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 10.h),
        decoration: BoxDecoration(
          color: _A.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: _A.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // ── Coloured top accent bar ──────────────────────────
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(14.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon
                  Column(
                    children: [
                      Container(
                        width: 42.r,
                        height: 42.r,
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.10),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(
                            _categoryIcon(address.category),
                            size: 20.sp,
                            color: color,
                          ),
                        ),
                      ),

                      SizedBox(height: 4.h), // spacing

                      Text(
                        address.category,
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(width: 12.w),

                  // Address details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                address.name,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: _A.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),

                            // Category pill
                          ],
                        ),
                        SizedBox(height: 4.h),
                        // Text(
                        //   '${address.doorNumber}, ${address.addressLine}',
                        //   style: TextStyle(
                        //     fontSize: 12.sp,
                        //     color: _A.textSecondary,
                        //   ),
                        //   maxLines: 1,
                        //   overflow: TextOverflow.ellipsis,
                        // ),
                        // Text(
                        //   '${address.city}, ${address.pincode}',
                        //   style: TextStyle(
                        //     fontSize: 12.sp,
                        //     color: _A.textSecondary,
                        //   ),
                        // ),
                        Text(
                          address.address,
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _A.textSecondary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Row(
                          children: [
                            Icon(
                              Icons.phone_rounded,
                              size: 11.sp,
                              color: _A.textMuted,
                            ),
                            SizedBox(width: 3.w),
                            Text(
                              '+91 ${address.phoneNumber}',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: _A.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 8.w),

                  // Action buttons
                  Column(
                    children: [
                      _actionBtn(
                        icon: Icons.edit_rounded,
                        color: _A.violet,
                        onTap: () async {
                          final ok = await Navigator.push<bool>(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddressFormScreen(
                                addressId: address.id,
                                existingAddress: address,
                              ),
                            ),
                          );
                          if (ok == true) _refreshTable();
                        },
                      ),
                      SizedBox(height: 6.h),
                      _actionBtn(
                        icon: Icons.delete_rounded,
                        color: _A.red,
                        onTap: () => _deleteAddress(address.id),
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

  Widget _actionBtn({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34.r,
        height: 34.r,
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          shape: BoxShape.circle,
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Icon(icon, size: 16.sp, color: color),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// AddressFormScreen
// ═══════════════════════════════════════════════════════════════════════════════
class AddressFormScreen extends StatefulWidget {
  final Address? existingAddress;
  final int? addressId;
  const AddressFormScreen({super.key, this.addressId, this.existingAddress});

  @override
  State<AddressFormScreen> createState() => _AddressFormScreenState();
}

class _AddressFormScreenState extends State<AddressFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController categoryController;
  late TextEditingController doorNumberController;
  late TextEditingController addressLineController;
  late TextEditingController landMarkController;
  late TextEditingController cityController;
  late TextEditingController pincodeController;
  late TextEditingController stateController;
  late TextEditingController nameController;
  late TextEditingController phoneNumberController;
  late TextEditingController otherCategoryController;

  String _fullAddress = '';

  double? _latitude;
  double? _longitude;
  bool _isEditable = false;

  @override
  void initState() {
    super.initState();

    _loadUserProfile();
    final a = widget.existingAddress;
    categoryController = TextEditingController(text: a?.category ?? '');
    otherCategoryController = TextEditingController();
    doorNumberController = TextEditingController(text: a?.doorNumber ?? '');
    addressLineController = TextEditingController(text: a?.addressLine ?? '');
    landMarkController = TextEditingController(text: a?.landMark ?? '');
    cityController = TextEditingController(text: a?.city ?? '');
    pincodeController = TextEditingController(
      text: a?.pincode.toString() ?? '',
    );
    stateController = TextEditingController(text: a?.state ?? '');
    nameController = TextEditingController(text: a?.name ?? '');
    phoneNumberController = TextEditingController(text: a?.phoneNumber ?? '');

    for (final c in [
      doorNumberController,
      addressLineController,
      landMarkController,
      cityController,
      stateController,
      pincodeController,
    ]) {
      c.addListener(_updateFullAddress);
    }
  }

  @override
  void dispose() {
    for (final c in [
      categoryController,
      doorNumberController,
      addressLineController,
      landMarkController,
      cityController,
      pincodeController,
      stateController,
      nameController,
      phoneNumberController,
      otherCategoryController,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('userId');
    if (userId == null) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, 'User not logged in');
      return;
    }
    final addressParts = [
      doorNumberController.text.trim(),
      addressLineController.text.trim(),
      landMarkController.text.trim(),
      // cityController.text.trim(),
      // stateController.text.trim(),
      // pincodeController.text.trim(),
    ];

    final address = addressParts
        .where((e) => e.isNotEmpty && e != 'null')
        .join(', ');
    final categoryValue = categoryController.text == 'Other'
        ? otherCategoryController.text
        : categoryController.text;

    final body = {
      'userId': userId,
      'addressId': widget.addressId ?? 0,
      'doorNumber': doorNumberController.text,
      'addressLine': addressLineController.text,
      'landMark': landMarkController.text,
      'city': cityController.text,
      'state': stateController.text,
      'name': nameController.text,
      'phoneNumber': phoneNumberController.text,
      'pincode': int.tryParse(pincodeController.text) ?? 0,
      'category': categoryValue,
      'address': address,
      'latitude': _latitude,
      'longitude': _longitude,
      'updatedAt': DateTime.now().toIso8601String(),
    };

    try {
      final ok = widget.addressId == null
          ? await subscription_AuthService.addAddress(body)
          : await subscription_AuthService.updateAddress(
              widget.addressId!,
              body,
            );
      if (ok) {
        AppAlert.success(
          // ignore: use_build_context_synchronously
          context,
          widget.addressId == null ? 'Address added!' : 'Address updated!',
        );
        // ignore: use_build_context_synchronously
        Navigator.pop(context, true);
      } else {
        // ignore: use_build_context_synchronously
        AppAlert.error(context, 'Failed to save address');
      }
    } catch (e) {
      // ignore: use_build_context_synchronously
      AppAlert.error(context, 'Error: $e');
    }
  }

  void _updateFullAddress() {
    setState(() {
      _fullAddress = [
        doorNumberController.text,
        addressLineController.text,
        landMarkController.text,
        cityController.text,
        stateController.text,
        pincodeController.text,
      ].where((e) => e.isNotEmpty).join(', ');
    });
  }

  Future<void> _loadUserProfile() async {
    final profile = await subscription_AuthService.getAccount();

    if (profile != null) {
      nameController.text = profile.userName ?? '';
      phoneNumberController.text = profile.phoneNumber ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.addressId != null;
    return Scaffold(
      backgroundColor: _A.bg,
      appBar: AppBar(
        backgroundColor: _A.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: _A.textPrimary),
        title: Text(
          isEdit ? 'Edit Address' : 'Add New Address',
          style: TextStyle(
            fontSize: 17.sp,
            fontWeight: FontWeight.w700,
            color: _A.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: _A.border),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Map ──────────────────────────────────────
                      _buildMapSection(),
                      SizedBox(height: 20.h),
                      if (_fullAddress.isNotEmpty)
                        Container(
                          width: double.infinity,
                          margin: EdgeInsets.only(bottom: 16.h),
                          padding: EdgeInsets.all(14.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12.r),
                            border: Border.all(color: _A.border),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: _A.violet,
                                size: 18.sp,
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  _fullAddress,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: _A.textPrimary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                      // ── Form card ────────────────────────────────
                      _sectionCard(
                        title: 'Address Details',
                        child: Column(
                          children: [
                            _field(
                              doorNumberController,
                              'House / Flat Number/Tower Name',
                              'e.g. 4B, Plot 12, ...Homes',
                              Icons.home_rounded,
                              validator: _required,
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              addressLineController,
                              'Address',
                              'Enter street / area',
                              Icons.place_rounded,
                              validator: _required,
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              landMarkController,
                              'Landmark (optional)',
                              'Nearby landmark',
                              Icons.flag_rounded,
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              cityController,
                              'City',
                              'City name',
                              Icons.location_city_rounded,
                              validator: _required,
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              pincodeController,
                              'Pincode',
                              '6-digit pincode',
                              Icons.markunread_mailbox_rounded,
                              keyboard: TextInputType.number,
                              validator: (v) {
                                if (v == null || v.isEmpty) return 'Required';
                                if (int.tryParse(v) == null) {
                                  return 'Invalid pincode';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 14.h),
                            _field(
                              stateController,
                              'State',
                              'State',
                              Icons.map_rounded,
                              readOnly: true,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 14.h),
                      _sectionCard(
                        title: 'Address Type',
                        child: _buildAddressTypeSelector(),
                      ),
                      SizedBox(height: 14.h),

                      _sectionCard(
                        title: 'Contact Info',
                        trailing: TextButton(
                          // 👈 HERE
                          onPressed: () {
                            setState(() {
                              _isEditable = !_isEditable;

                              if (!_isEditable) {
                                _loadUserProfile(); // reset data
                              }
                            });
                          },
                          child: Text(
                            _isEditable ? 'Use My Info' : 'For Others',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: _A.violet,
                            ),
                          ),
                        ),
                        child: Column(
                          children: [
                            _field(
                              nameController,
                              'Full Name',
                              'Enter your full name',
                              Icons.person_rounded,
                              validator: _required,
                              enabled: _isEditable, // 👈 ADD THIS
                            ),
                            SizedBox(height: 14.h),
                            _phoneField(),
                          ],
                        ),
                      ),
                      SizedBox(height: 8.h),
                    ],
                  ),
                ),
              ),

              // ── Save bar ─────────────────────────────────────────
              _saveBar(isEdit),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: GoogleMapsPage(
          onAddressSelected: (fullAddress, city, pincode, state, lat, lng) {
            setState(() {
              addressLineController.text = fullAddress;
              cityController.text = city;
              pincodeController.text = pincode;
              stateController.text = state;
              _latitude = lat;
              _longitude = lng;

              _fullAddress = [
                // doorNumberController.text,
                addressLineController.text,
                landMarkController.text,
                // city,
                // state,
                // pincode,
              ].where((e) => e.isNotEmpty).join(', ');
            });
          },
        ),
      ),
    );
  }

  Widget _sectionCard({
    required String title,
    required Widget child,
    Widget? trailing, // 👈 ADD THIS
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _A.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _A.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 16.w, 0),
            child: Row(
              // 👈 CHANGE HERE
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: _A.textPrimary,
                  ),
                ),
                if (trailing != null) trailing, // 👈 ADD THIS
              ],
            ),
          ),
          Padding(padding: EdgeInsets.all(16.w), child: child),
        ],
      ),
    );
  }

  Widget _buildAddressTypeSelector() {
    final types = [
      {'type': 'Home', 'icon': Icons.home_rounded, 'color': _A.green},
      {'type': 'Office', 'icon': Icons.work_rounded, 'color': _A.blue},
      {'type': 'Other', 'icon': Icons.location_on_rounded, 'color': _A.purple},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: types.map((t) {
            final type = t['type'] as String;
            final icon = t['icon'] as IconData;
            final color = t['color'] as Color;
            final sel = categoryController.text == type;

            return GestureDetector(
              onTap: () {
                setState(() {
                  categoryController.text = type;

                  if (type != 'Other') {
                    otherCategoryController.clear();
                  }
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: sel ? color.withOpacity(0.12) : _A.bg,
                  borderRadius: BorderRadius.circular(30.r), // pill shape
                  border: Border.all(color: sel ? color : _A.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16.sp, color: sel ? color : _A.textMuted),
                    SizedBox(width: 6.w),
                    Text(
                      type,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: sel ? color : _A.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),

        /// 🔥 Show input for "Other"
        if (categoryController.text == 'Other') ...[
          SizedBox(height: 12.h),
          _field(
            otherCategoryController,
            'Custom Category',
            'e.g. Friend house, Shop, etc.',
            Icons.edit_location_alt_rounded,
            validator: (v) {
              if (categoryController.text == 'Other' &&
                  (v == null || v.isEmpty)) {
                return 'Please enter category';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label,
    String hint,
    IconData icon, {
    bool enabled = true, // 👈 ADD THIS
    bool readOnly = false,
    TextInputType keyboard = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _A.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: _A.bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _A.border),
          ),
          child: TextFormField(
            controller: ctrl,
            readOnly: readOnly,
            keyboardType: keyboard,
            style: TextStyle(fontSize: 14.sp, color: _A.textPrimary),
            cursorColor: _A.violet,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(icon, size: 18.sp, color: _A.violet),
              hintText: hint,
              hintStyle: TextStyle(color: _A.textMuted, fontSize: 13.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
            ),
            validator: validator,
          ),
        ),
      ],
    );
  }

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phone Number',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: _A.textSecondary,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: _A.bg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: _A.border),
          ),
          child: TextFormField(
            controller: phoneNumberController,
            keyboardType: TextInputType.phone,
            maxLength: 10,
            style: TextStyle(fontSize: 14.sp, color: _A.textPrimary),
            enabled: _isEditable,
            cursorColor: _A.violet,
            decoration: InputDecoration(
              border: InputBorder.none,
              prefixIcon: Icon(
                Icons.phone_android_rounded,
                size: 18.sp,
                color: _A.violet,
              ),
              prefixText: '+91  ',
              prefixStyle: TextStyle(
                fontSize: 14.sp,
                color: _A.textSecondary,
                fontWeight: FontWeight.w600,
              ),
              hintText: '10-digit number',
              hintStyle: TextStyle(color: _A.textMuted, fontSize: 13.sp),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 14.h,
              ),
              counterText: '',
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Required';
              if (!RegExp(r'^[0-9]{10}$').hasMatch(v)) {
                return 'Enter valid 10-digit number';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _saveBar(bool isEdit) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: _A.surface,
        border: Border(top: BorderSide(color: _A.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52.h,
        child: ElevatedButton(
          onPressed: _saveAddress,
          style: ElevatedButton.styleFrom(
            backgroundColor: _A.violet,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            shadowColor: _A.violet.withOpacity(0.3),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isEdit ? Icons.save_rounded : Icons.add_location_alt_rounded,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                isEdit ? 'Update Address' : 'Save Address',
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _required(String? v) => (v == null || v.isEmpty) ? 'Required' : null;
}

// ═══════════════════════════════════════════════════════════════════════════════
// GoogleMapsPage  (unchanged logic, polished UI)
// ═══════════════════════════════════════════════════════════════════════════════
class GoogleMapsPage extends StatefulWidget {
  final Function(
    String fullAddress,
    String city,
    String pincode,
    String state,
    double latitude,
    double longitude,
  )?
  onAddressSelected;
  const GoogleMapsPage({super.key, this.onAddressSelected});

  @override
  State<GoogleMapsPage> createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  GoogleMapController? mapController;
  static const LatLng _init = LatLng(17.385044, 78.486671);
  static const CameraPosition _initCam = CameraPosition(
    target: _init,
    zoom: 14,
  );

  LatLng _current = _init;
  bool _isLoading = false;
  bool _hasPermission = true;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadKey();
  }

  Future<void> _loadKey() async {}

  Future<void> _getCurrentLocation() async {
    final result = await LocationService.getCurrentLocationWithAddress();
    if (result == null) {
      setState(() => _hasPermission = false);
      return;
    }
    setState(() => _hasPermission = true);
    final latLng = LatLng(result.latitude, result.longitude);
    _updateLocation(latLng);
    mapController?.animateCamera(CameraUpdate.newLatLngZoom(latLng, 16));
  }

  Future<void> _updateLocation(LatLng latLng) async {
    setState(() {
      _current = latLng;
      _isLoading = true;
    });
    try {
      final placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final fullAddress = [
          (p.street != null && p.street!.isNotEmpty)
              ? p.street
              : p.name, // street
          p.subLocality, // area / colony
          p.locality, // city
          p.subAdministrativeArea,
          p.administrativeArea, // state
          p.postalCode, // pincode
          p.country, // country
        ].where((e) => e != null && e!.isNotEmpty).join(', ');
        widget.onAddressSelected?.call(
          fullAddress,
          p.locality ?? '',
          p.postalCode ?? '',
          p.administrativeArea ?? '',
          latLng.latitude,
          latLng.longitude,
        );
      }
    } catch (_) {}
    setState(() => _isLoading = false);
  }

  Future<void> _handleSearch() async {
    Prediction? p = await PlacesAutocomplete.show(
      context: context,
      apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
      mode: Mode.overlay,
      language: 'en',
      components: [Component(Component.country, 'in')],
      logo: const SizedBox.shrink(),
    );
    if (p != null) {
      final places = GoogleMapsPlaces(
        apiKey: dotenv.env['GOOGLE_MAPS_API_KEY'],
        apiHeaders: await const GoogleApiHeaders().getHeaders(),
      );
      final detail = await places.getDetailsByPlaceId(p.placeId!);
      final loc = detail.result.geometry!.location;
      _updateLocation(LatLng(loc.lat, loc.lng));
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(loc.lat, loc.lng), 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: _A.border),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: GoogleMap(
              initialCameraPosition: _initCam,
              onMapCreated: (c) => mapController = c,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              onCameraMove: (pos) => _current = pos.target,
              onCameraIdle: () => _updateLocation(_current),
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
          ),

          // Pin
          const Icon(Icons.location_pin, size: 46, color: Color(0xFFEF4444)),

          // Search bar overlay
          Positioned(
            top: 12.h,
            left: 12.w,
            right: 12.w,
            child: GestureDetector(
              onTap: _handleSearch,
              child: Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(Icons.search_rounded, color: _A.violet, size: 18.sp),
                    SizedBox(width: 10.w),
                    Text(
                      'Search location...',
                      style: TextStyle(color: _A.textMuted, fontSize: 13.sp),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Current location FAB
          Positioned(
            bottom: 60.h,
            right: 12.w,
            child: GestureDetector(
              onTap: _getCurrentLocation,
              child: Container(
                width: 38.r,
                height: 38.r,
                decoration: BoxDecoration(
                  color: _A.violet,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _A.violet.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.my_location_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
            ),
          ),

          // Loading chip
          if (_isLoading)
            Positioned(
              bottom: 14.h,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12.r,
                      height: 12.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _A.violet,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Getting address...',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: _A.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Permission denied overlay
          if (!_hasPermission)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.location_off_rounded,
                        size: 48.sp,
                        color: _A.textMuted,
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        'Location Access Required',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: _A.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        'Enable location to pin your address accurately.',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: _A.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _A.border),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                'Skip',
                                style: TextStyle(
                                  color: _A.textSecondary,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async =>
                                  Geolocator.openAppSettings(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _A.violet,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              child: Text(
                                'Enable',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
