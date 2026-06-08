class CouponModel {
  final int id;
  final String code;
  final double discountPercentage;
  final DateTime startDate;
  final DateTime endDate;

  final String? startTime; // HH:mm:ss
  final String? endTime; // HH:mm:ss

  final int? vendorId;
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
    this.startTime,
    this.endTime,
    required this.vendorId,
    required this.active,
    required this.usageCount,
    required this.couponType,
    required this.minimumOrderValue,
    required this.discountType,
  });

  factory CouponModel.fromJson(Map<String, dynamic> json) {
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

      startTime: json['startTime'],
      endTime: json['endTime'],

      vendorId: json['vendorId'],
      active: json['active'] ?? false,
      usageCount: json['usageCount'] ?? 0,
      couponType: json['couponType'] ?? 'UNKNOWN',
      minimumOrderValue: (json['minimumOrderValue'] as num?)?.toDouble() ?? 0.0,
      discountType: json['discountType'] ?? 'PERCENTAGE',
    );
  }

  bool get isExpired {
    final now = DateTime.now();

    // If endTime exists, combine date + time
    if (endTime != null && endTime!.isNotEmpty) {
      final parts = endTime!.split(':');
      final expiry = DateTime(
        endDate.year,
        endDate.month,
        endDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        parts.length > 2 ? int.parse(parts[2]) : 0,
      );
      return now.isAfter(expiry);
    }

    // Fallback to end of day
    final expiry = DateTime(
      endDate.year,
      endDate.month,
      endDate.day,
      23,
      59,
      59,
    );

    return now.isAfter(expiry);
  }

  bool get isStarted {
    final now = DateTime.now();

    if (startTime != null && startTime!.isNotEmpty) {
      final parts = startTime!.split(':');
      final start = DateTime(
        startDate.year,
        startDate.month,
        startDate.day,
        int.parse(parts[0]),
        int.parse(parts[1]),
        parts.length > 2 ? int.parse(parts[2]) : 0,
      );
      return now.isAfter(start) || now.isAtSameMomentAs(start);
    }

    return now.isAfter(startDate);
  }

  bool get isCurrentlyActive => active && isStarted && !isExpired;

  bool isApplicableForVendor(int? vendorId) {
    if (this.vendorId == null) return true;
    return this.vendorId == vendorId;
  }

  bool get isCurrentlyAvailable {
    final now = DateTime.now();

    // Check date range first
    if (now.isBefore(startDate) || now.isAfter(endDate)) {
      return false;
    }

    // No time restriction
    if (startTime == null || endTime == null) {
      return true;
    }

    final startParts = startTime!.split(':');
    final endParts = endTime!.split(':');

    final start = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(startParts[0]),
      int.parse(startParts[1]),
    );

    final end = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(endParts[0]),
      int.parse(endParts[1]),
    );

    return now.isAfter(start) && now.isBefore(end);
  }


}

class CouponResult {
  final bool success;
  final String? error;

  CouponResult({required this.success, this.error});
}
