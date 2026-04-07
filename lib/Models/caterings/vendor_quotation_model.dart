class VendorQuotationResponse {
  final bool success;
  final String message;
  final List<VendorQuotation> data;

  VendorQuotationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VendorQuotationResponse.fromJson(Map<String, dynamic> json) {
    return VendorQuotationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>? ?? [])
          .map((e) => VendorQuotation.fromJson(e))
          .toList(),
    );
  }
}

class VendorQuotation {
  final int quotationId;
  final int vendorId;
  final int leadId;
  final int userId;
  final String vendorName;
  final double quotedAmount;
  final String quotationDetails;
  final String status;
  final DateTime createdAt;
  final String city;
  final double totalPlates;
  final double vegPerPlatePrice;
  final double nonVegPerPlatePrice;
  final double mixedPerPlatePrice;
  final double cgstAmount;
  final double sgstAmount;
  final double platformFee;
  final double deliveryFee;
  final double grandTotal;
  final List<AddOnPrice> addOnPrices;
  final double partialAmount;
  final double remainingAmount;

  VendorQuotation({
    required this.quotationId,
    required this.vendorId,
    required this.leadId,
    required this.userId,
    required this.vendorName,
    required this.quotedAmount,
    required this.quotationDetails,
    required this.status,
    required this.createdAt,
    required this.city,
    required this.totalPlates,
    required this.mixedPerPlatePrice,
    required this.nonVegPerPlatePrice,
    required this.vegPerPlatePrice,
    required this.cgstAmount,
    required this.deliveryFee,
    required this.platformFee,
    required this.sgstAmount,
    required this.addOnPrices,
    required this.grandTotal,
    required this.partialAmount,
    required this.remainingAmount,
  });

  VendorQuotation copyWith({String? status}) {
    return VendorQuotation(
      quotationId: quotationId,
      vendorId: vendorId,
      leadId: leadId,
      userId: userId,
      vendorName: vendorName,
      quotedAmount: quotedAmount,
      quotationDetails: quotationDetails,
      status: status ?? this.status,
      createdAt: createdAt,
      city: city,
      totalPlates: totalPlates,
      mixedPerPlatePrice: mixedPerPlatePrice,
      nonVegPerPlatePrice: nonVegPerPlatePrice,
      vegPerPlatePrice: vegPerPlatePrice,
      cgstAmount: cgstAmount,
      sgstAmount: sgstAmount,
      platformFee: platformFee,
      deliveryFee: deliveryFee,
      addOnPrices: addOnPrices,
      grandTotal: grandTotal,
      partialAmount: partialAmount,
      remainingAmount: remainingAmount,
    );
  }

  factory VendorQuotation.fromJson(Map<String, dynamic> json) {
    return VendorQuotation(
      quotationId: json['quotationId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      leadId: json['leadId'] ?? 0,
      userId: json['userId'] ?? 0,
      vendorName: json['vendorName'] ?? 'Vendor',
      quotedAmount: (json['quotedAmount'] as num?)?.toDouble() ?? 0.0,
      quotationDetails: json['quotationDetails'] ?? '',
      status: _mapStatus(json['status']),
      createdAt: DateTime.parse(json['createdAt']),
      city: json['city'] ?? '',
      totalPlates: (json['totalPlates'] as num?)?.toDouble() ?? 0.0,

      vegPerPlatePrice: (json['vegPerPlatePrice'] as num?)?.toDouble() ?? 0.0,

      nonVegPerPlatePrice:
          (json['nonVegPerPlatePrice'] as num?)?.toDouble() ?? 0.0,

      mixedPerPlatePrice:
          (json['mixedPerPlatePrice'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgstAmount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgstAmount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platformFee'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grandTotal']as num ?)?.toDouble() ?? 0.0,
      addOnPrices: (json['addOnPrices'] as List<dynamic>? ?? [])
          .map((e) => AddOnPrice.fromJson(e))
          .toList(),
      remainingAmount: (json['remainingAmount']as num ?)?.toDouble() ?? 0.0,
      partialAmount: (json['partialAmount']as num ?)?.toDouble() ?? 0.0,
    );
  }

  static String _mapStatus(String? apiStatus) {
    switch (apiStatus?.toUpperCase()) {
      case 'SUBMITTED':
        return 'submitted';
      case 'SELECTED':
        return 'selected';
      case 'REJECTED':
        return 'rejected';
      default:
        return 'pending';
    }
  }
}

class AddOnPrice {
  final int addOnId;
  final String addOnType;
  final int quantity;
  final double price;
  final double totalAmount;

  AddOnPrice({
    required this.addOnId,
    required this.addOnType,
    required this.quantity,
    required this.price,
    required this.totalAmount,
  });

  factory AddOnPrice.fromJson(Map<String, dynamic> json) {
    return AddOnPrice(
      addOnId: json['addOnId'] ?? 0,
      addOnType: json['addOnType'] ?? '',
      quantity: json['quantity'] ?? 0,
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
