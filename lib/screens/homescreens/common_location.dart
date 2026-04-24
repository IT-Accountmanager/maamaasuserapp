import 'package:flutter/material.dart';
import '../../Services/Auth_service/Subscription_authservice.dart';
import '../../Services/googleservices/Location_servces.dart';

/// Centralized location state shared across all screens via InheritedWidget.
/// Wrap your root widget (e.g. inside MainBottomNav or MaterialApp) with this.
class LocationProvider extends StatefulWidget {
  final Widget child;
  const LocationProvider({super.key, required this.child});

  @override
  State<LocationProvider> createState() => _LocationProviderState();

  /// Access from any descendant: LocationProvider.of(context)
  static _LocationProviderState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<_LocationScope>();
    assert(scope != null, 'No LocationProvider found in widget tree');
    return scope!.state;
  }
}

class _LocationProviderState extends State<LocationProvider> {
  String currentLocation = 'Fetching location...';
  String? locationCategory;
  bool isLoggedIn = false;
  bool isGuestLocationLoading = false;
  bool _hasShownLocationDialog = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _checkLogin();
    if (isLoggedIn) {
      await loadLocationFromAPI();
    } else {
      await loadGuestLocation();
    }
  }

  Future<void> _checkLogin() async {
    final v = await subscription_AuthService.isLoggedIn();
    if (mounted) setState(() => isLoggedIn = v);
  }

  Future<void> loadGuestLocation() async {
    if (mounted) setState(() => isGuestLocationLoading = true);
    try {
      final r = await LocationService.getCurrentLocationWithAddress();
      if (!mounted) return;
      if (r != null) {
        final parts = [
          r.area,
          r.adminArea,
          r.city,
          r.state,
        ].where((e) => e != null && e.isNotEmpty).toList();
        final addr = parts.join(', ');
        setState(() {
          currentLocation = (r.pincode != null && r.pincode!.isNotEmpty)
              ? '$addr - ${r.pincode}'
              : addr;
        });
      } else {
        setState(() => currentLocation = 'Enable location');
      }
    } catch (e) {
      debugPrint('Guest location error: $e');
      if (mounted) setState(() => currentLocation = 'Location unavailable');
    } finally {
      if (mounted) setState(() => isGuestLocationLoading = false);
    }
  }

  Future<void> loadLocationFromAPI() async {
    try {
      final loc = await subscription_AuthService.fetchCurrentLocation();
      if (!mounted) return;

      final isValid =
          loc != null &&
          loc.address.trim().isNotEmpty;

      if (isValid) {
        setState(() {
          currentLocation = loc.address;
          locationCategory = loc.category;
          _hasShownLocationDialog = false;
        });
      } else {
        _handleInvalidLocation();
      }
    } catch (e) {
      debugPrint('❌ Location API Error: $e');
      if (mounted) _handleInvalidLocation();
    }
  }

  void _handleInvalidLocation() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      if (currentLocation == 'Fetching location...' &&
          !_hasShownLocationDialog) {
        _hasShownLocationDialog = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _showUpdateLocationDialog(context);
        });
      }
    });
  }

  void _showUpdateLocationDialog(BuildContext ctx) {
    showDialog(
      context: ctx,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.location_off, color: Colors.red),
            SizedBox(width: 8),
            Text('Location Required'),
          ],
        ),
        content: const Text(
          "We couldn't detect your location. Please update your location to continue.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Later'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // Trigger navigation to SavedAddress from the screen itself
              onChangeLocationRequested?.call();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFB15DC6),
            ),
            child: const Text('Update Location'),
          ),
        ],
      ),
    );
  }

  /// Screens set this callback so the dialog can trigger their navigation.
  VoidCallback? onChangeLocationRequested;

  /// Called by screens after user picks a new address.
  void updateLocationFromAddress(String fullAddress, String? category) {
    if (mounted) {
      setState(() {
        currentLocation = fullAddress;
        locationCategory = category;
        _hasShownLocationDialog = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _LocationScope(state: this, child: widget.child);
  }
}

class _LocationScope extends InheritedWidget {
  final _LocationProviderState state;
  const _LocationScope({required this.state, required super.child});

  @override
  bool updateShouldNotify(_LocationScope old) => true;
}
