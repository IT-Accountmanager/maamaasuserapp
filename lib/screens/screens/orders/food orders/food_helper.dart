import 'package:flutter/material.dart';
import '../../../../Models/food/orders_model.dart';
import 'food_orders.dart';

class FoodOrdersHelper {
  static Color getStatusColor(OrderStatus status) {
    switch (status) {
      case OrderStatus.cancelled:
        return Colors.red;
      case OrderStatus.completed:
        return Colors.green;
      case OrderStatus.pending:
        return Colors.orange;
      case OrderStatus.confirmed:
      case OrderStatus.beingPrepared:
      case OrderStatus.processing:
      case OrderStatus.waitingForPickup:
      case OrderStatus.orderIsReady:
        return Colors.blue;
      default:
        return Colors.blueGrey;
    }
  }
}

extension OrderStatusX on OrderStatus {
  String get label {
    switch (this) {
      case OrderStatus.hold:
        return "Pending";
      case OrderStatus.pending:
        return "Not accepted";
      case OrderStatus.confirmed:
        return "Confirmed";
      case OrderStatus.beingPrepared:
        return "Preparing";
      case OrderStatus.orderIsReady:
        return "Order is Ready";
      case OrderStatus.waitingForPickup:
        return "Waiting for Pickup";
      case OrderStatus.ontheway:
        return "On the Way";
      case OrderStatus.completed:
        return "Delivered";
      case OrderStatus.cancelled:
        return "Cancelled";
      default:
        return "Unknown";
    }
  }
}

String ratingCategoryToString(RatingCategory category) {
  return category.toString().split('.').last;
}

enum RatingCategory { FOOD_QUALITY, PACKAGING, DELIVERY, SERVICE, OTHERS }
