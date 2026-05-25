import '../../../../Models/food/orders_model.dart';
import 'package:flutter/material.dart';

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

enum OrderType {
  DINE_IN,
  DELIVERY,
  TAKEAWAY,
  TABLE_DINE_IN;

  static OrderType fromString(dynamic type) {
    if (type == null) return OrderType.DINE_IN;

    final normalized = type
        .toString()
        .trim()
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    const map = {
      'DINE_IN': OrderType.DINE_IN,
      'DELIVERY': OrderType.DELIVERY,
      'TAKEAWAY': OrderType.TAKEAWAY,
      'TABLE_DINE_IN': OrderType.TABLE_DINE_IN,
    };

    return map[normalized] ?? OrderType.DINE_IN;
  }
}

extension OrderTypeExtension on OrderType {
  String get label {
    switch (this) {
      case OrderType.DINE_IN:
        return "Dine In";
      case OrderType.DELIVERY:
        return "Delivery";
      case OrderType.TAKEAWAY:
        return "Takeaway";
      case OrderType.TABLE_DINE_IN:
        return "Dine Out"; // custom fix
    }
  }
}
