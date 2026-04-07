import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationResult {
  final double latitude;
  final double longitude;

  final String city;
  final String? state;
  final String? pincode;

  // ✅ ADD THESE
  final String? area;              // subLocality
  final String? adminArea;         // subAdministrativeArea

  final String fullAddress;

  LocationResult({
    required this.latitude,
    required this.longitude,
    required this.city,
    this.state,
    this.pincode,
    this.area,
    this.adminArea,
    required this.fullAddress,
  });
}

class LocationService {
  /// 🔐 Check & Request Permission
  static Future<bool> checkPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// 📍 Get Current Location + Address
  static Future<LocationResult?> getCurrentLocationWithAddress() async {
    final hasPermission = await checkPermission();
    if (!hasPermission) return null;

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isEmpty) return null;

    final place = placemarks.first;

    // ✅ fallback for city
    final city =
        place.locality?.trim() ??
        place.subLocality?.trim() ??
        place.administrativeArea?.trim() ??
        "Unknown";

    final state = place.administrativeArea?.trim() ?? "";
    final pincode = place.postalCode?.trim() ?? "";

    // full address
    final fullAddress = [
      place.name,
      place.street,
      place.subLocality,
      place.locality,
      place.administrativeArea,
      place.postalCode,
    ].where((e) => e != null && e.trim().isNotEmpty).join(", ");

    return LocationResult(
      latitude: position.latitude,
      longitude: position.longitude,
      city: city,
      state: state,
      pincode: pincode,
      fullAddress: fullAddress,
    );
  }
}
