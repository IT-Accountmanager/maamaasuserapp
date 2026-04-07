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
  final String orderStatus;

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
    required this.orderStatus,
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
    return CartModel(
      cartId: json['cartId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      orderType: json['orderType'] ?? '',
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
      tableCode: json['tableCode'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
      couponCode: json['couponCode'],
      discountAmount: (json['discountAmount'] ?? 0).toDouble(),
      savedAmount: (json['savedAmount'] ?? 0).toDouble(),
      userCompany: json['userCompany'] ?? '',
      deliveryAddress: json['deliveryAddress'] ?? '',
      mobileNo: json['mobileNo'] ?? '',
      name: json['name'] ?? '',
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
    // FIX: Properly handle dynamic bool from JSON
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

    print(
      'Item: ${json['dishName']}, raw shedule: ${json['shedule']}, parsed: $parsedShedule',
    );

    return CartItem(
      itemId: json['itemId'] ?? 0,
      price: (json['price'] ?? 0).toDouble(),
      dishName: json['dishName'] ?? '',
      dishId: json['dishId'] ?? 0,
      gst: (json['gst'] ?? 0).toDouble(),
      packingCharges: (json['packingCharges'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 0,
      chefType: json['chefType'] ?? '',
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      dishImage: json['dishImage'],
      actualPrice: (json['actualPrice'] ?? 0).toDouble(),
      balanceQuantity: json['balanceQuantity'] ?? 0,
      available: json['available'] == true,
      shedule: parsedShedule,
    );
  }
}
