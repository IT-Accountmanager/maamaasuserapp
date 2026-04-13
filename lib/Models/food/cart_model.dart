String? safeString(dynamic value) {
  if (value == null) return null;
  if (value is String) return value;
  if (value is num || value is bool) return value.toString();
  // If it's a Map (like couponCode object), return null or extract known key
  return null;
}

/// Same but with a fallback default
String safeStringOrDefault(dynamic value, [String fallback = '']) {
  return safeString(value) ?? fallback;
}

class CartModel {
  final int cartId;
  final int userId;
  final int vendorId;
  final String orderType;

  List<CartItem> cartItems;

  num subtotal;
  num gstTotal;
  num platformCharges;
  num grandTotal;
  num packingTotal;
  num serviceCharges;
  num deliveryCharges;
  num cgst;
  num sgst;

  final int seatingId;
  final String tableCode;
  final String? orderStatus;

  String? couponCode;
  final int couponId;
  num discountAmount;

  final String userCompany;
  num savedAmount;

  String deliveryAddress;
  String mobileNo;
  String name;

  final List<String>? vendorOrderType;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.vendorId,
    required this.orderType,
    required this.cartItems,
    required this.subtotal,
    required this.gstTotal,
    required this.platformCharges,
    required this.grandTotal,
    required this.packingTotal,
    required this.serviceCharges,
    required this.deliveryCharges,
    required this.cgst,
    required this.sgst,
    required this.seatingId,
    required this.tableCode,
    this.orderStatus,
    this.couponCode,
    required this.couponId,
    required this.discountAmount,
    required this.userCompany,
    required this.savedAmount,
    required this.deliveryAddress,
    required this.mobileNo,
    required this.name,
    required this.vendorOrderType,
  });

  factory CartModel.fromJson(Map<String, dynamic> json) {
    // Robust couponCode extraction
    final rawCoupon = json['couponCode'];
    String? parsedCouponCode;
    if (rawCoupon is String) {
      parsedCouponCode = rawCoupon;
    } else if (rawCoupon is Map) {
      parsedCouponCode = rawCoupon['code']?.toString();
    }

    return CartModel(
      cartId: json['cartId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      orderType: safeStringOrDefault(json['orderType']), // ← safe
      cartItems:
          (json['cartItems'] as List<dynamic>?)
              ?.map((item) => CartItem.fromJson(item))
              .toList() ??
          [],
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      gstTotal: (json['gstTotal'] ?? 0).toDouble(),
      platformCharges: (json['platformCharges'] ?? 0).toDouble(),
      grandTotal: (json['grandTotal'] ?? 0).toDouble(),
      packingTotal: (json['packingTotal'] ?? 0).toDouble(),
      serviceCharges: (json['serviceCharges'] ?? 0).toDouble(),
      deliveryCharges: (json['deliveryCharges'] ?? 0).toDouble(),
      cgst: (json['cgst'] ?? 0).toDouble(),
      sgst: (json['sgst'] ?? 0).toDouble(),
      seatingId: json['seatingId'] ?? 0,
      couponId: json['couponId'] ?? 0,
      tableCode: safeStringOrDefault(json['tableCode']), // ← safe
      orderStatus: safeString(json['orderStatus']), // ← safe (nullable)
      couponCode: parsedCouponCode,
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      savedAmount: (json['savedAmount'] ?? 0).toDouble(),
      userCompany: safeStringOrDefault(json['userCompany']), // ← safe
      deliveryAddress: safeStringOrDefault(json['deliveryAddress']),
      mobileNo: safeStringOrDefault(json['mobileNo']),
      name: safeStringOrDefault(json['name']),
      vendorOrderType: (json['vendorOrderType'] as List?)
          ?.map((e) => e.toString())
          .toList(),
    );
  }

  // ===============================
  // ✅ SCHEDULE LOGIC
  // ===============================

  /// 👉 At least one item scheduled
  bool get hasAnyScheduledItem {
    return cartItems.any((item) => item.shedule);
  }

  /// 👉 All items are normal
  bool get allItemsNormal {
    return cartItems.every((item) => !item.shedule);
  }

  /// 👉 All items scheduled
  bool get allItemsScheduled {
    return cartItems.isNotEmpty && cartItems.every((item) => item.shedule);
  }

  /// 👉 Only scheduled items
  List<CartItem> get scheduledItems {
    return cartItems.where((item) => item.shedule).toList();
  }

  /// 👉 Only normal items
  List<CartItem> get normalItems {
    return cartItems.where((item) => !item.shedule).toList();
  }
}

// Add at top of cart_model.dart (outside any class)
String? _safeStr(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  if (v is num || v is bool) return v.toString();
  if (v is Map)
    return v['url']?.toString() ?? v['path']?.toString() ?? v.toString();
  return null;
}

String _safeStrOr(dynamic v, [String fallback = '']) => _safeStr(v) ?? fallback;

class CartItem {
  final int itemId;
  num price;
  final String dishName;
  final int dishId;
  final num gst;
  num packingCharges;
  int quantity;
  final String chefType;
  num totalPrice;
  final String? dishImage;
  final num actualPrice;
  final int balanceQuantity;
  final bool available;
  bool shedule;

  CartItem({
    required this.itemId,
    required this.price,
    required this.dishName,
    required this.dishId,
    required this.gst,
    required this.packingCharges,
    required this.quantity,
    required this.chefType,
    required this.totalPrice,
    this.dishImage,
    required this.actualPrice,
    required this.balanceQuantity,
    required this.available,
    required this.shedule,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      if (value is int) return value == 1;
      if (value is String) return value.toLowerCase() == 'true';
      return false;
    }

    final parsedShedule = parseBool(
      json['shedule'] ??
          json['schedule'] ??
          json['isScheduled'] ??
          json['scheduled'],
    );

    return CartItem(
      itemId: json['itemId'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      dishName: _safeStrOr(json['dishName']), // ✅ safe
      dishId: json['dishId'] ?? 0,
      gst: (json['gst'] ?? 0).toDouble(),
      packingCharges: (json['packingCharges'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      chefType: _safeStrOr(json['chefType']), // ✅ safe
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      dishImage: _safeStr(json['dishImage']), // ✅ safe (nullable — Map → url)
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      balanceQuantity: json['balanceQuantity'] ?? 0,
      available: json['available'] == true,
      shedule: parsedShedule,
    );
  }
}
