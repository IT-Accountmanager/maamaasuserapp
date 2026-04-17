class CouponModel {
  final int id;
  final String code;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;
  final int? vendorId; // null = global coupon
  final bool active;
  final int usageCount;
  final String couponType;
  final double minimumOrderValue;
  final String discountType;

  CouponModel({
    required this.id,
    required this.code,
    required this.discountPercentage,
    required this.startDate,
    required this.endDate,
    required this.vendorId,
    required this.active,
    required this.usageCount,
    required this.couponType,
    required this.minimumOrderValue,
    required this.discountType,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
    // debugPrint("🧩 Parsing Coupon JSON: $json");

    return CouponModel(
      id: json['id'] ?? 0,
      code: json['code'] ?? '',
      discountPercentage:
      (json['discountPercentage'] as num?)?.toDouble() ?? 0.0,

      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),

      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now(),

      vendorId: json['vendorId'], // nullable is fine

      active: json['active'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      couponType: json['couponType'] ?? 'UNKNOWN',

      minimumOrderValue:
      (json['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,

      discountType: json['discountType'] ?? 'PERCENTAGE',
    );
  }


  bool get isExpired {
    final expiry = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );
    return DateTime.now().isAfter(expiry);
  }
  bool isApplicableForVendor(int? vendorId) {
    if (this.vendorId == null) return true; // global coupon
    return this.vendorId == vendorId;
  }
}

class CouponResult {
  final bool success;
  final String? error;

  CouponResult({required this.success, this.error});
}