class PackageItem {
  final int itemId;
  final String itemName;
  final double price;

  PackageItem({
    required this.itemId,
    required this.itemName,
    required this.price,
  });

  factory PackageItem.fromJson(Map<String, dynamic> json) {
    return PackageItem(
      itemId: json['itemId'] ?? 0,
      itemName: json['itemName'] ?? 'Unnamed Item',
      price: (json['price'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': itemId,
    'itemName': itemName,
    'price': price,
  };
}

class CartPackage {
  final int id;
  final int packageId;
  final String packageName;
  final String packageType;
  final double packagePrice;
  int quantity;
  final List<PackageItem> packageItems;
  bool isExpanded;

  CartPackage({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.packageType,
    required this.packagePrice,
    required this.quantity,
    required this.packageItems,
    this.isExpanded = false,
  });

  factory CartPackage.fromJson(Map<String, dynamic> json) {
    return CartPackage(
      id: json['id'] ?? 0,
      packageId: json['packageId'] ?? 0,
      packageName: json['packageName'] ?? 'Unnamed Package',
      packageType: json['packageType'] ?? 'Veg',
      packagePrice: (json['packagePrice'] ?? 0).toDouble(),
      quantity: json['quantity'] ?? 1,
      packageItems: (json['packageItems'] as List?)
          ?.map((i) => PackageItem.fromJson(i))
          .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'packageId': packageId,
    'packageName': packageName,
    'packageType': packageType,
    'packagePrice': packagePrice,
    'quantity': quantity,
    'packageItems': packageItems.map((e) => e.toJson()).toList(),
  };
}

// ignore: camel_case_types
class catering_Cart {
  final int id;
  final int userId;
  final double subtotal;
  final double gstAmount;
  final double platformFeeAmount;
  final double total;
  final double partialPayment;
  final DateTime? cateringDate;
  final String? cateringTime;
  final List<CartPackage> items;
  final String deliveryAddress;
  final String mobileNo;
  final String name;
  final double deliveryFee;

  catering_Cart({
    required this.id,
    required this.userId,
    required this.subtotal,
    required this.gstAmount,
    required this.platformFeeAmount,
    required this.total,
    required this.partialPayment,
    this.cateringDate,
    this.cateringTime,
    required this.items,
    required this.deliveryAddress,
    required this.mobileNo,
    required this.name,
    required this.deliveryFee
  });

  factory catering_Cart.fromJson(Map<String, dynamic> json) {
    return catering_Cart(
      id: json['id'] ?? 0,
      userId: json['userId'] ?? 0,
      subtotal: (json['subtotal'] ?? 0).toDouble(),
      gstAmount: (json['gstAmount'] ?? 0).toDouble(),
      platformFeeAmount: (json['platformFeeAmount'] ?? 0).toDouble(),
      total: (json['total'] ?? 0).toDouble(),
      partialPayment: (json['partialPayment'] ?? 0).toDouble(),
      cateringDate: json['cateringDate'] != null && json['cateringDate'] != ""
          ? DateTime.tryParse(json['cateringDate'])
          : null,
      cateringTime: json['cateringTime'], // simple string, e.g. "03:20:00"
      items: (json['items'] as List?)
          ?.map((i) => CartPackage.fromJson(i))
          .toList() ??
          [],
      deliveryAddress: json['deliveryAddress'] ?? " ",
      mobileNo: json["mobileNo"] ?? "",
      name: json["name"] ?? "",
      deliveryFee: (json['deliveryFee'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'subtotal': subtotal,
    'gstAmount': gstAmount,
    'platformFeeAmount': platformFeeAmount,
    'total': total,
    'partialPayment': partialPayment,
    'cateringDate':
    cateringDate?.toIso8601String().split('T').first,
    'cateringTime': cateringTime,
    'items': items.map((e) => e.toJson()).toList(),
  };
}
