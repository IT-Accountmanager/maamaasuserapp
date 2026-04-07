enum OrderStatus { confirmed, preparing, ready, delivered, cancelled }

class CateringOrder {
  final int id;
  final int quotationId;
  final int leadId;
  final int userId;
  final String customerId;
  final String location;
  final int vendorId;
  final DateTime orderDateTime;
  final String paymentMethod;
  final String paymentType;
  final String? razorpayPaymentId;
  final String paymentStatus;
  final OrderStatus orderStatus;
  final double sgst;
  final double cgst;
  final String cateringDate;
  final String cateringTime;
  final double subtotal;
  final String fromDate;
  final String toDate;
  final double total;
  final double platformFeeAmount;
  final String transactionId;
  final String transactionId2;
  final double amountPaid;
  final double amountRemaining;
  final double deliveryFee;

  final List<CateringOrderItem> items;
  final String cancelReason;
  final String feedback;
  final num rating;
  final String eventType;
  final double deliveryDistanceKm;

  final String mobileNo;
  final String deliveryUserName;
  final String vendorRegisteredName;
  final String vendorFssai;
  final String vendorFullAddress;
  final String vendorCity;
  final String vendorState;
  final String vendorGstIn;
  final String deliveryAddress;
  final List<CateringAddOn> addOns;

  CateringOrder({
    required this.id,
    required this.quotationId,
    required this.leadId,
    required this.userId,
    required this.customerId,
    required this.location,
    required this.vendorId,
    required this.orderDateTime,
    required this.paymentMethod,
    required this.paymentType,
    this.razorpayPaymentId,
    required this.paymentStatus,
    required this.orderStatus,
    required this.sgst,
    required this.cgst,
    required this.cateringDate,
    required this.cateringTime,
    required this.subtotal,
    required this.fromDate,
    required this.toDate,
    required this.total,
    required this.platformFeeAmount,
    required this.transactionId,
    required this.transactionId2,
    required this.amountPaid,
    required this.amountRemaining,
    required this.deliveryFee,
    required this.items,
    required this.cancelReason,
    required this.feedback,
    required this.rating,
    required this.eventType,
    required this.deliveryDistanceKm,
    required this.mobileNo,
    required this.deliveryUserName,
    required this.vendorRegisteredName,
    required this.vendorFssai,
    required this.vendorFullAddress,
    required this.vendorCity,
    required this.vendorState,
    required this.vendorGstIn,
    required this.deliveryAddress,
    required this.addOns,
  });

  factory CateringOrder.fromJson(Map<String, dynamic> json) {


    List<CateringAddOn> safeAddOnList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .where((e) => e != null)
            .map((e) => CateringAddOn.fromJson(e))
            .toList();
      }
      return [];
    }


    return CateringOrder(
      id: json['orderId'] ?? 0,
      quotationId: json['quotationId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'] ?? 0,
      customerId: json['customerId']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      vendorId: json['vendorId'] ?? 0,
      orderDateTime: json['orderDateTime'] != null
          ? DateTime.tryParse(json['orderDateTime']) ?? DateTime.now()
          : DateTime.now(),
      paymentMethod: json['paymentMethod']?.toString() ?? '',
      paymentType: json['paymentType']?.toString() ?? '',
      razorpayPaymentId: json['razorpayPaymentId']?.toString(),
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      orderStatus: _parseOrderStatus(json['orderStatus']),
      sgst: (json['sgst'] as num?)?.toDouble() ?? 0.0,
      cgst: (json['cgst'] as num?)?.toDouble() ?? 0.0,
      cateringDate: json['cateringDate']?.toString() ?? '',
      cateringTime: json['cateringTime']?.toString() ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      fromDate: json['fromDate']?.toString() ?? '',
      toDate: json['toDate']?.toString() ?? '',
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
      platformFeeAmount: (json['platformFeeAmount'] as num?)?.toDouble() ?? 0.0,
      transactionId: json['transactionId']?.toString() ?? '',
      transactionId2: json['transactionId2']?.toString() ?? '',
      amountPaid: (json['amountPaid'] as num?)?.toDouble() ?? 0.0,
      amountRemaining: (json['amountRemaining'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      items:
          (json['orderItems'] as List<dynamic>?)
              ?.map((item) => CateringOrderItem.fromJson(item))
              .toList() ??
          [],
      cancelReason: json['cancelReason']?.toString() ?? '',
      feedback: json['feedback']?.toString() ?? '',
      rating: json['rating'] ?? 0,
      eventType: json['eventType']?.toString() ?? '',
      deliveryDistanceKm:
          (json['deliveryDistanceKm'] as num?)?.toDouble() ?? 0.0,
      mobileNo: json['mobileNo']?.toString() ?? '',
      deliveryUserName: json['deliveryUserName']?.toString() ?? '',
      vendorRegisteredName: json['vendorRegisteredName']?.toString() ?? '',
      vendorFssai: json['vendorFssai']?.toString() ?? '',
      vendorFullAddress: json['vendorFullAddress']?.toString() ?? '',
      vendorCity: json['vendorCity']?.toString() ?? '',
      vendorState: json['vendorState']?.toString() ?? '',
      vendorGstIn: json['vendorGstIn']?.toString() ?? '',
      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      addOns: safeAddOnList(json['addOns']),
    );
  }

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toUpperCase()) {
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PREPARING':
        return OrderStatus.preparing;
      case 'READY':
        return OrderStatus.ready;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.confirmed;
    }
  }
}

class CateringOrderItem {
  final int id;
  final int packageId;
  final String packageName;
  final String packageType;
  final double packagePrice;
  final int quantity;
  final String itemsName;
  final List<PackageItem> packageItems;

  CateringOrderItem({
    required this.id,
    required this.packageId,
    required this.packageName,
    required this.packageType,
    required this.packagePrice,
    required this.quantity,
    required this.itemsName,
    required this.packageItems,
  });

  factory CateringOrderItem.fromJson(Map<String, dynamic> json) {
    return CateringOrderItem(
      id: json['id'] ?? 0,
      packageId: json['packageId'] ?? 0,
      packageName: json['packageName'] ?? '',
      packageType: json['packageType'] ?? '',
      packagePrice: (json['packagePrice'] as num?)?.toDouble() ?? 0.0,
      quantity: json['quantity'] ?? 0,
      itemsName: json['itemsName'] ?? '',
      packageItems:
          (json['packageItems'] as List<dynamic>?)
              ?.map((item) => PackageItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}

class CateringAddOn {
  final int id;
  final int addOnId;
  final String addOnType;
  final int quantity;
  final double price;
  final double totalAmount;

  CateringAddOn({
    required this.id,
    required this.addOnId,
    required this.addOnType,
    required this.quantity,
    required this.price,
    required this.totalAmount,
  });

  factory CateringAddOn.fromJson(Map<String, dynamic> json) {
    return CateringAddOn(
      id: json['id'] ?? 0,
      addOnId: json['addOnId'] ?? 0,
      addOnType: json['addOnType'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}



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
      itemName: json['itemName'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
