
import 'package:flutter/cupertino.dart';
import 'package:intl/intl.dart';

enum OrderStatus {
  confirmed,
  beingPrepared,
  completed,
  cancelled,
  pending,
  processing,
  waitingForPickup,
  orderIsReady,
  hold,
  ontheway,
  unknown;

  static OrderStatus fromString(dynamic status) {
    if (status == null) return OrderStatus.unknown;

    final raw = status.toString().trim();

    final normalized = raw
        .toUpperCase()
        .replaceAll(' ', '_')
        .replaceAll('-', '_');

    debugPrint("📡 RAW STATUS: $raw → NORMALIZED: $normalized");

    const map = {
      'HOLD': OrderStatus.hold,
      'PENDING': OrderStatus.pending,
      'CONFIRMED': OrderStatus.confirmed,
      'PROCESSING': OrderStatus.processing,

      'BEING_PREPARED': OrderStatus.beingPrepared,
      'PREPARING': OrderStatus.beingPrepared,

      'ORDER_IS_READY': OrderStatus.orderIsReady,
      'READY': OrderStatus.orderIsReady,

      'WAITING_FOR_PICKUP': OrderStatus.waitingForPickup,

      'ON_THE_WAY': OrderStatus.ontheway,
      'ONTHEWAY': OrderStatus.ontheway,

      'DELIVERED': OrderStatus.completed,
      'COMPLETED': OrderStatus.completed,

      'CANCELLED': OrderStatus.cancelled,
    };

    final result = map[normalized];

    if (result == null) {
      debugPrint("❌ UNKNOWN STATUS FROM API: $raw");
      return OrderStatus.unknown;
    }

    return result;
  }
}

class OrderItem {
  final String dishName;
  final int quantity;
  final double price;
  final double totalPrice;
  final double gst;
  final double packingCharges;
  final String dishImage;

  OrderItem({
    required this.dishName,
    required this.quantity,
    required this.price,
    required this.totalPrice,
    required this.gst,
    required this.packingCharges,
    required this.dishImage,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      dishName: json['dishName'] ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      packingCharges: (json['packingCharges'] as num?)?.toDouble() ?? 0.0,
      dishImage: json['dishImage'] ?? '',
    );
  }
}

class Order {
  final String id;
  final int orderId;
  final int userId;
  final int vendorId;
  final String location;
  final String pincode;
  final String date;
  final String time;
  final String orderDateAndTime;
  final DateTime parsedDateTime;
  final double grandTotal;
  final String couponCode;
  final double discountAmount;
  final double sgst;
  final double cgst;
  final double subTotal;
  final double amount;
  final List<OrderItem> items;
  final String paymentMethod;
  final double totalAmount;
  final double serviceCharge;
  final double packingCharges;
  final double platformCharges;
  final double deliveryCharges;
  final int people;
  final OrderType orderType;
  final OrderStatus status;
  bool isRated;
  final bool sheduled;
  final String deliveryAddress;
  final String deliveryUserName;
  final String mobileNo;

  Order({
    required this.id,
    required this.orderId,
    required this.userId,
    required this.vendorId,
    required this.location,
    required this.pincode,
    required this.date,
    required this.time,
    required this.orderDateAndTime,
    required this.parsedDateTime,
    required this.grandTotal,
    required this.couponCode,
    required this.discountAmount,
    required this.sgst,
    required this.cgst,
    required this.subTotal,
    required this.amount,
    required this.items,
    required this.paymentMethod,
    required this.totalAmount,
    required this.serviceCharge,
    required this.packingCharges,
    required this.platformCharges,
    required this.deliveryCharges,
    required this.people,
    required this.orderType,
    required this.status,
    this.isRated = false,
    required this.sheduled,
    required this.deliveryAddress,
    required this.deliveryUserName,
    required this.mobileNo,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    var list = json['order'] as List;
    List<OrderItem> itemList = list.map((i) => OrderItem.fromJson(i)).toList();
    return Order(
      id: json['orderId']?.toString() ?? '',
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      location: json['location'] ?? '',
      pincode: json['pincode'] ?? '',
      date: json['date'] ?? '',
      time: json['time'] ?? '',
      orderDateAndTime: json['orderDateAndTime'] ?? '',
      parsedDateTime: _parseOrderDate(json['orderDateAndTime']),
      grandTotal: (json['grandTotal'] as num?)?.toDouble() ?? 0.0,
      couponCode: json['couponCode'] ?? '',
      discountAmount: (json['discountAmount'] as num?)?.toDouble() ?? 0.0,
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      subTotal: (json['subTotal'] as num?)?.toDouble() ?? 0.0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      items: itemList,
      paymentMethod: json['paymentMethod'] ?? '',
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      serviceCharge: (json['serviceCharge'] as num?)?.toDouble() ?? 0.0,
      packingCharges: (json['packingCharges'] as num?)?.toDouble() ?? 0.0,
      platformCharges: (json['platformCharges'] as num?)?.toDouble() ?? 0.0,
      deliveryCharges: (json['deliveryCharges'] as num?)?.toDouble() ?? 0.0,
      people: json['people'] ?? 0,
      orderType: OrderTypeExtension.fromString(json['orderType']),
      status: OrderStatus.fromString(json['status']),
      sheduled: json['sheduled'],
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      deliveryUserName: json['deliveryUserName'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
    );
  }

  static DateTime _parseOrderDate(dynamic rawDate) {
    try {
      if (rawDate is String) return DateTime.parse(rawDate);
      if (rawDate is Map) {
        final combined = "${rawDate['date']} ${rawDate['time']}";
        return DateFormat("yyyy-MM-dd HH:mm:ss").parse(combined);
      }
    } catch (e) {
      debugPrint("Date parsing error: $e");
    }
    return DateTime.now();
  }

  // static OrderStatus _parseOrderStatus(dynamic status) {
  //   final s = status?.toString().toUpperCase() ?? '';
  //   switch (s) {
  //     case 'HOLD':
  //       return OrderStatus.hold;
  //     case 'PENDING':
  //       return OrderStatus.pending;
  //     case 'CONFIRMED':
  //       return OrderStatus.confirmed;
  //     case 'BEING_PREPARED':
  //       return OrderStatus.beingPrepared;
  //     case 'ORDER_IS_READY':
  //       return OrderStatus.orderIsReady;
  //     case 'WAITING_FOR_PICKUP':
  //       return OrderStatus.waitingForPickup;
  //     case 'ON_THE_WAY':
  //       return OrderStatus.ontheway;
  //     case 'DELIVERED':
  //       return OrderStatus.completed;
  //     case 'CANCELLED':
  //       return OrderStatus.cancelled;
  //
  //     default:
  //       return OrderStatus.unknown;
  //   }
  // }

  bool get isActive =>
      status == OrderStatus.hold ||
      status == OrderStatus.pending ||
      status == OrderStatus.confirmed ||
      status == OrderStatus.beingPrepared ||
      status == OrderStatus.orderIsReady ||
      status == OrderStatus.waitingForPickup ||
      status == OrderStatus.ontheway;
  Order copyWith({
    OrderStatus? status,
    bool? isRated,
  }) {
    return Order(
      id: id,
      orderId: orderId,
      userId: userId,
      vendorId: vendorId,
      location: location,
      pincode: pincode,
      date: date,
      time: time,
      orderDateAndTime: orderDateAndTime,
      parsedDateTime: parsedDateTime,
      grandTotal: grandTotal,
      couponCode: couponCode,
      discountAmount: discountAmount,
      sgst: sgst,
      cgst: cgst,
      subTotal: subTotal,
      amount: amount,
      items: items,
      paymentMethod: paymentMethod,
      totalAmount: totalAmount,
      serviceCharge: serviceCharge,
      packingCharges: packingCharges,
      platformCharges: platformCharges,
      deliveryCharges: deliveryCharges,
      people: people,
      orderType: orderType,
      status: status ?? this.status,
      isRated: isRated ?? this.isRated,
      sheduled: sheduled,
      deliveryAddress: deliveryAddress,
      deliveryUserName: deliveryUserName,
      mobileNo: mobileNo,
    );
  }
}

// ignore: constant_identifier_names
enum OrderType { DINE_IN, DELIVERY, TAKEAWAY }

extension OrderTypeExtension on OrderType {
  static OrderType fromString(String? value) {
    if (value == null) return OrderType.DINE_IN; // default
    return OrderType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => OrderType.DINE_IN, // default if no match
    );
  }
}
