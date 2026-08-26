import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/delivery/deliverpartnerreview.dart';
import '../../Models/delivery/fooddelivery.dart';
import '../../Models/food/verifypaymentl.dart';
import '../../Models/logistics/bookingresposne.dart';
import '../../Models/logistics/orderdetails.dart';
import '../../Models/logistics/vechilemodel.dart';
import 'Apiclient.dart';

class DeliveryService {
  static Future<DeliveryOrderModel?> getOrder(int orderId) async {
    final endpoint =
        'api/get/order?orderId=$orderId&appType=FOOD_AND_BEVERAGES';

    try {
      final response = await ApiClient.get(endpoint, service: "delivery");
      //
      // debugPrint("DELIVERY Services STATUS: ${response.statusCode}");
      // debugPrint("DELIVERY Services BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DeliveryOrderModel.fromJson(data);
      } else {
        //         debugPrint("Delivery Services failed");
        return null;
      }
    } catch (e) {
      //       debugPrint("Error fetching delivery order: $e");
      return null;
    }
  }

  static Future<bool> submitDeliveryPartnerReview({
    required int orderId,
    required int rating,
    required String review,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final int userId = prefs.getInt('userId') ?? 0;
      // debugPrint("Submitting review...");
      // debugPrint("OrderId: $orderId");
      // debugPrint("Rating: $rating");
      // debugPrint("Review: $review");
      final endpoint =
          "api/user/add/review"
          "?orderId=$orderId"
          "&userId=$userId"
          "&rating=$rating"
          "&review=${Uri.encodeComponent(review)}"
          "&appType=FOOD_AND_BEVERAGES";

      final response = await ApiClient.post(endpoint, {}, service: 'delivery');
      // debugPrint("Status Code: ${response.statusCode}");
      // debugPrint("Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      } else {
        // debugPrint("Review API Failed: ${response.statusCode}");
        // debugPrint("Response: ${response.body}");
        return false;
      }
    } catch (e) {
      // debugPrint("Review API Exception: $e");
      return false;
    }
  }

  static Future<DeliveryPartnerReview?> getDeliveryPartnerReview(
    int orderId,
  ) async {
    try {
      final endpoint = "api/user/get/review?orderId=$orderId";
      final response = await ApiClient.get(endpoint, service: "delivery");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data == null || data.isEmpty) {
          return null;
        }

        return DeliveryPartnerReview.fromJson(data);
      }
    } catch (e) {
      // debugPrint(e.toString());
    }

    return null;
  }

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

    debugPrint("request body :${body}");
    final response = await ApiClient.post(endpoint, body, service: "delivery");
    debugPrint("request body :${response.body}");
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
      debugPrint("response :${response.body}");
      return BookRideResponse.fromJson(data);
    }

    throw Exception("Booking failed");
  }

  static Future<OrderDetails> getOrderById(int orderId) async {
    final endpoint =
        "api/logistics/logistics/orders/by/orderId?orderId=$orderId";

    final response = await ApiClient.get(endpoint, service: "delivery");

    debugPrint("STATUS CODE = ${response.statusCode}");
    debugPrint("BODY = ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);

      debugPrint("JSON STATUS = ${data['status']}");

      final order = OrderDetails.fromJson(data);

      debugPrint("MODEL STATUS = ${order.status}");

      return order;
    }

    throw Exception("Failed to fetch order details");
  }

  static Future<String?> createOrder(double amount) async {
    try {
      String endpoint = "api/payments/create-order/user";

      final body = {
        "amount": amount,
        "currency": "INR",
        "receipt": "receipt#${DateTime.now().millisecondsSinceEpoch}",
        "notes": {"key1": "value3", "key2": "value2"},
      };
      debugPrint("=========== CREATE ORDER ===========");
      debugPrint("Amount : $amount");
      debugPrint("Endpoint : $endpoint");
      debugPrint("Request Body : ${jsonEncode(body)}");

      final res = await ApiClient.post(endpoint, body, service: "delivery");

      debugPrint("Status Code : ${res.statusCode}");
      debugPrint("Response : ${res.body}");

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);

        debugPrint("Decoded : $data");
        debugPrint("orderId : ${data["orderId"]}");
        debugPrint("id : ${data["id"]}");

        return data["orderId"] ?? data["id"];
      }

      return null;
    } catch (e, s) {
      debugPrint("CREATE ORDER ERROR");
      debugPrint(e.toString());
      debugPrint(s.toString());
      return null;
    }
  }

  // 2️⃣ CAPTURE PAYMENT
  static Future<bool> capturePayment({
    required String paymentId,
    required double amount,
  }) async {
    try {
      String endpoint = "api/payments/capture";

      final body = {
        "paymentId": paymentId,
        "amount": amount,
        "currency": "INR",
        "receipt":
            "order#${DateTime.now().millisecondsSinceEpoch} for wallet top-up",
      };

      debugPrint("=========== CAPTURE PAYMENT ===========");
      debugPrint(jsonEncode(body));

      final res = await ApiClient.post(endpoint, body, service: "delivery");

      debugPrint("Status : ${res.statusCode}");
      debugPrint("Response : ${res.body}");
      // print("captured :${res.body}");
      return res.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<PaymentVerifyModel?> verifyPayment(String paymentId) async {
    try {
      final endpoint = "api/payments/verify/$paymentId";

      debugPrint("=========== VERIFY PAYMENT ===========");

      final res = await ApiClient.get(endpoint, service: "delivery");

      debugPrint("Status : ${res.statusCode}");
      debugPrint("Response : ${res.body}");

      if (res.statusCode == 200) {
        return PaymentVerifyModel.fromJson(jsonDecode(res.body));
      }
    } catch (_) {}

    return null;
  }

  static Future<bool> updateLogisticsPayment({
    required int orderId,
    required String paymentMode,
    required String paymentStatus,
    String? transactionId,
    String? gatewayOrderId,
    String? gatewayPaymentId,
    required double totalAmount,
  }) async {
    try {
      final endpoint = "api/logistics/payment/$orderId";
      final body = {
        "paymentMode": paymentMode,
        "paymentStatus": paymentStatus,
        "transactionId": transactionId ?? "",
        "gatewayOrderId": gatewayOrderId ?? "",
        "gatewayPaymentId": gatewayPaymentId ?? "",
        "totalAmount": totalAmount,
      };
      final response = await ApiClient.put(endpoint, body, service: "delivery");
      debugPrint("Status Code : ${response.statusCode}");
      debugPrint("Response    : ${response.body}");
      return response.statusCode == 200;
    } catch (e) {
      debugPrint("Error      : $e");
      return false;
    }
  }
}
