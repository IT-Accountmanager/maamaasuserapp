import 'dart:convert';
import 'package:maamaas/Services/Auth_service/Apiclient.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Models/logistics/bookingresposne.dart';
import '../../Models/logistics/orderdetails.dart';
import '../../Models/logistics/vechilemodel.dart';

class LogisticsService {
  static Future<List<VehicleModel>> getVehicles({
    required double pickupLatitude,
    required double pickupLongitude,
    required double dropLatitude,
    required double dropLongitude,
    required int passengers,
  }) async {
    final endpoint = "api/logistics/vehicles";
    final body = {
      "pickupLatitude": pickupLatitude,
      "pickupLongitude": pickupLongitude,
      "dropLatitude": dropLatitude,
      "dropLongitude": dropLongitude,
      "totalPasengers": passengers,
    };
    final response = await ApiClient.post(endpoint, body, service: "delivery");

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      return data.map((e) => VehicleModel.fromJson(e)).toList();
    }

    throw Exception("Vehicle API failed");
  }

  static Future<BookRideResponse> bookRide({
    required String userName,
    required String userPhone,

    required double pickupLatitude,
    required double pickupLongitude,
    required String pickupAddress,

    required double dropLatitude,
    required double dropLongitude,
    required String dropAddress,

    required VehicleModel vehicle,
    required DateTime bookingDateTime,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final int userId = prefs.getInt('userId') ?? 0;
    const endpoint = "api/logistics/book";
    final body = {
      "userId": userId,
      "userName": userName,
      "userPhone": userPhone,

      "pickupLatitude": pickupLatitude,
      "pickupLongitude": pickupLongitude,
      "pickupAddress": pickupAddress,

      "dropLatitude": dropLatitude,
      "dropLongitude": dropLongitude,
      "dropAddress": dropAddress,

      "boolingDateTime": bookingDateTime.toUtc().toIso8601String(),

      "vehicleStatus": vehicle.vehicleStatus,
      "vehicleType": vehicle.vehicleType,

      "rideDistanceKm": vehicle.distanceKm,
      "estimatedFare": vehicle.estimatedFare,
    };

    final response = await ApiClient.post(endpoint, body, service: "delivery");

    if (response.statusCode == 200 || response.statusCode == 201) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return BookRideResponse.fromJson(data);
    }

    throw Exception("Booking failed");
  }

  static Future<OrderDetails> getOrderById(int orderId) async {
    final endoint =
        "api/logistics/logistics/orders/by/orderId?orderId=$orderId";
    final response = await ApiClient.get(endoint, service: "delivery");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return OrderDetails.fromJson(data);
    }

    throw Exception("Failed to fetch order details");
  }
}
