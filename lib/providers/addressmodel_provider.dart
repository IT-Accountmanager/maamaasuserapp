import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../Services/Auth_service/Apiclient.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String baseurl = "http://testing.maamaas.com:8080/subscription";
// const String baseurl = "http://backend.maamaas.com/subscription";

class AddressState {
  final String city;
  final String stateName;
  final String pincode;
  final double latitude;
  final double longitude;
  final String fullAddress;
  final String category; // ✅ ADD THIS

  const AddressState({
    this.city = '',
    this.stateName = '',
    this.pincode = '',
    this.latitude = 0,
    this.longitude = 0,
    this.fullAddress = '',
    this.category = '', // ✅ DEFAULT
  });

  AddressState copyWith({
    String? city,
    String? stateName,
    String? pincode,
    double? latitude,
    double? longitude,
    String? fullAddress,
    String? category, // ✅ ADD
  }) {
    return AddressState(
      city: city ?? this.city,
      stateName: stateName ?? this.stateName,
      pincode: pincode ?? this.pincode,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      fullAddress: fullAddress ?? this.fullAddress,
      category: category ?? this.category, // ✅ ADD
    );
  }

  Map<String, dynamic> toJson() => {
    "city": city,
    "state": stateName,
    "pincode": pincode,
    "latitude": latitude,
    "longitude": longitude,
    "address": fullAddress,
    "category": category, // ✅ ADD
  };
}

// -----------------------------
// Address Notifier
// -----------------------------
class AddressNotifier extends StateNotifier<AddressState> {
  AddressNotifier() : super(const AddressState());

  // -----------------------------
  // Update local state manually
  // -----------------------------
  Future<void> updateLocalAddress({
    required String city,
    required String stateName,
    required String pincode,
    required double latitude,
    required double longitude,
    String? fullAddress,
    String? category, // ✅ ADDED
  }) async {
    final address = fullAddress ?? "$city   ,$stateName - $pincode";

    state = AddressState(
      city: city,
      stateName: stateName,
      pincode: pincode,
      latitude: latitude,
      longitude: longitude,
      fullAddress: address,
      category: category ?? state.category, // ✅ KEEP OLD IF NULL
    );
  }

  // -----------------------------
  // Update state from GPS position
  // -----------------------------
  Future<bool> updateLocationFromPosition(
    Position pos, {
    String? category, // ✅ ADD PARAM
  }) async {
    try {
      String city = '';
      String stateName = '';
      String pincode = '';
      String fullAddress = "${pos.latitude}, ${pos.longitude}";

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          pos.latitude,
          pos.longitude,
        );

        if (placemarks.isNotEmpty) {
          final place = placemarks.first;

          final subLocality = place.subLocality ?? '';
          final locality = place.locality ?? '';
          final street = place.street ?? '';
          final name = place.name ?? '';
          final stateName = place.administrativeArea ?? '';
          final pincode = place.postalCode ?? '';

          fullAddress = [
            name,
            street,
            subLocality,
            locality,
            stateName,
            pincode,
          ].where((e) => e.isNotEmpty).join(', ');
        }
      } catch (_) {}

      // ✅ PRESERVE / SET CATEGORY
      state = state.copyWith(
        city: city,
        stateName: stateName,
        pincode: pincode,
        latitude: pos.latitude,
        longitude: pos.longitude,
        fullAddress: fullAddress,
        category:
            category ??
            (state.category.isEmpty ? "Current Location" : state.category),
      );

      return await sendCurrentLocationToBackend();
    } catch (e) {
      return false;
    }
  }

  // -----------------------------
  // Send to backend
  // -----------------------------
  Future<bool> sendCurrentLocationToBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt('userId') ?? 0;
      final customerId = prefs.getString('customerId') ?? '';

      final body = {
        "userId": userId,
        "customerId": customerId,
        "latitude": state.latitude,
        "longitude": state.longitude,
        "address": state.fullAddress,
        "city": state.city,
        "category": state.category.isEmpty
            ? "Current Location"
            : state.category, // ✅ FINAL FIX
      };

      debugPrint("📍 CATEGORY SENT: ${body['category']}");

      final uri = Uri.parse("$baseurl/api/user/curret/location/update");

      final resp = await http.post(
        uri,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      debugPrint("location response: ${resp.body}");

      return resp.statusCode >= 200 && resp.statusCode < 300;
    } catch (e) {
      return false;
    }
  }

  // -----------------------------
  // Send address to cart
  // -----------------------------
  // Update cart delivery address API
  static Future<bool> updateDeliveryAddress({
    required int cartId,
    required int addressId,
  }) async {
    try {
      final body = {"addressId": addressId, "cartId": cartId};
      final endpoint = "api/cart/delivery/$cartId/address/$addressId";

      debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
      debugPrint(
        "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
      );

      final response = await ApiClient.put(endpoint, body, service: "food");

      debugPrint(
        "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
      );
      debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e, st) {
      debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
      debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
      return false;
    }
  }

  static Future<bool> updatecateringDeliveryAddress({
    required int cartId,
    required int addressId,
  }) async {
    try {
      final body = {"addressId": addressId, "cartId": cartId};
      final endpoint = "api/user/delivery/$cartId/address/$addressId";

      debugPrint("🔹 [UpdateDeliveryAddress] Sending request to: $endpoint");
      debugPrint(
        "🔹 [UpdateDeliveryAddress] Request body: ${jsonEncode(body)}",
      );

      final response = await ApiClient.put(endpoint, body, service: "catering");
      debugPrint("response body : ${response.body}");

      debugPrint(
        "🔹 [UpdateDeliveryAddress] Status code: ${response.statusCode}",
      );
      debugPrint("🔹 [UpdateDeliveryAddress] Response body: ${response.body}");

      return response.statusCode == 200;
    } catch (e, st) {
      debugPrint("❌ [UpdateDeliveryAddress] Error: $e");
      debugPrint("❌ [UpdateDeliveryAddress] StackTrace: $st");
      return false;
    }
  }
}

// -----------------------------
// Global provider
// -----------------------------
final addressProvider = StateNotifierProvider<AddressNotifier, AddressState>((
  ref,
) {
  return AddressNotifier();
});
