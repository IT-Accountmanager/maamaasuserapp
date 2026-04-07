import 'dart:convert';
import 'package:flutter/cupertino.dart';
import '../../Models/delivery/fooddelivery.dart';
import 'Apiclient.dart';

class DeliveryOrderService {
  static Future<DeliveryOrderModel?> getOrder(int orderId) async {
    final endpoint = 'api/get/order?orderId=$orderId&appType=FOOD_AND_BEVERAGES';

    try {
      final response = await ApiClient.get(endpoint, service: "delivery");

      debugPrint("DELIVERY Services STATUS: ${response.statusCode}");
      debugPrint("DELIVERY Services BODY: ${response.body}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return DeliveryOrderModel.fromJson(data);
      } else {
        debugPrint("Delivery Services failed");
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching delivery order: $e");
      return null;
    }
  }
}
