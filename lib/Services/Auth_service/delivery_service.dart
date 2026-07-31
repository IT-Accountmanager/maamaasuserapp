import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Models/delivery/deliverpartnerreview.dart';
import '../../Models/delivery/fooddelivery.dart';
import 'Apiclient.dart';

class DeliveryOrderService {
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
}
