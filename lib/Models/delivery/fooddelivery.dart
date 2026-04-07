class DeliveryOrderModel {
  final String id;
  final int orderId;
  final int partnerId;
  final deliveryStatus status;

  final double userLatitude;
  final double userLongitude;
  final String deliveryAddress;
  final String userName;
  final String userPhone;

  final double vendorLatitude;
  final double vendorLongitude;
  final String vendorFullAddress;
  final String vendorRestaurantName;

  final String items;
  final double earning;
  final String deliveryDistanceKm;
  final int estimatedDeliveryTimeMinutes;

  final int vendorOtp;
  final int userOtp;

  final double deliveryPartnerLatitude;
  final double deliveryPartnerLongitude;
  final String deliveryPartnerName;

  final VehicleStatus vehicleStatus;

  final DateTime createdAt;
  final DateTime updatedAt;

  DeliveryOrderModel({
    required this.id,
    required this.orderId,
    required this.partnerId,
    required this.status,
    required this.userLatitude,
    required this.userLongitude,
    required this.deliveryAddress,
    required this.userName,
    required this.userPhone,
    required this.vendorLatitude,
    required this.vendorLongitude,
    required this.vendorFullAddress,
    required this.vendorRestaurantName,
    required this.items,
    required this.earning,
    required this.deliveryDistanceKm,
    required this.estimatedDeliveryTimeMinutes,
    required this.vendorOtp,
    required this.userOtp,
    required this.deliveryPartnerLatitude,
    required this.deliveryPartnerLongitude,
    required this.deliveryPartnerName,
    required this.vehicleStatus,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DeliveryOrderModel.fromJson(Map<String, dynamic> json) {
    return DeliveryOrderModel(
      id: json['id']?.toString() ?? '',

      orderId: json['orderId'] is int ? json['orderId'] : 0,
      partnerId: json['partnerId'] is int ? json['partnerId'] : 0,

      status: OrderStatusExtension.fromString(json['status']?.toString()),

      userLatitude: (json['userLatitude'] ?? 0).toDouble(),
      userLongitude: (json['userLongitude'] ?? 0).toDouble(),

      deliveryAddress: json['deliveryAddress']?.toString() ?? '',
      userName: json['userName']?.toString() ?? '',
      userPhone: json['userPhone']?.toString() ?? '',

      vendorLatitude: (json['vendorLatitude'] ?? 0).toDouble(),
      vendorLongitude: (json['vendorLongitude'] ?? 0).toDouble(),

      vendorFullAddress: json['vendorFullAddress']?.toString() ?? '',
      vendorRestaurantName: json['vendorRestaurentname']?.toString() ?? '',

      items: json['items']?.toString() ?? '',

      earning: (json['earning'] ?? 0).toDouble(),

      deliveryDistanceKm: json['deliveryDistanceKm']?.toString() ?? '',

      estimatedDeliveryTimeMinutes: json['estimatedDeliveryTimeMinutes'] ?? 0,

      vendorOtp: json['vendorOtp'] ?? 0,
      userOtp: json['userOtp'] ?? 0,

      // 🔥 BACKEND TYPO HANDLED
      deliveryPartnerLatitude:
          (json['deliveryPartnerLatitude'] ??
                  json['deliveryPartnerLatiude'] ??
                  0)
              .toDouble(),

      deliveryPartnerLongitude: (json['deliveryPartnerLongitude'] ?? 0)
          .toDouble(),

      deliveryPartnerName: json['deliveryPartnerName']?.toString() ?? '',

      vehicleStatus: VehicleStatusExtension.fromString(
        json['vehicleStatus']?.toString(),
      ),

      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),

      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt']) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'orderId': orderId,
      'partnerId': partnerId,
      'status': status.name,
      'userLatitude': userLatitude,
      'userLongitude': userLongitude,
      'deliveryAddress': deliveryAddress,
      'userName': userName,
      'userPhone': userPhone,
      'vendorLatitude': vendorLatitude,
      'vendorLongitude': vendorLongitude,
      'vendorFullAddress': vendorFullAddress,
      'vendorRestaurentname': vendorRestaurantName,
      'items': items,
      'earning': earning,
      'deliveryDistanceKm': deliveryDistanceKm,
      'estimatedDeliveryTimeMinutes': estimatedDeliveryTimeMinutes,
      'vendorOtp': vendorOtp,
      'userOtp': userOtp,
      'deliveryPartnerLatiude': deliveryPartnerLatitude,
      'deliveryPartnerLongitude': deliveryPartnerLongitude,
      'deliveryPartnerName': deliveryPartnerName,
      'vehicleStatus': vehicleStatus.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

// ignore: camel_case_types
enum deliveryStatus {
  // ignore: constant_identifier_names
  ACCEPTED,
  // ignore: constant_identifier_names
  PICKED_UP,
  // ignore: constant_identifier_names
  DELIVERED,
  // ignore: constant_identifier_names
  CANCELLED,
  // ignore: constant_identifier_names
  ONGOING,
  // ignore: constant_identifier_names
  ARRIVED,
  // ignore: constant_identifier_names
  REJECTED,
}

extension OrderStatusExtension on deliveryStatus {
  static deliveryStatus fromString(String? value) {
    return deliveryStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => deliveryStatus.ACCEPTED,
    );
  }
}

// ignore: constant_identifier_names
enum VehicleStatus { TWO_WHEELER, FOUR_WHEELER }

extension VehicleStatusExtension on VehicleStatus {
  static VehicleStatus fromString(String? value) {
    return VehicleStatus.values.firstWhere(
      (e) => e.name == value,
      orElse: () => VehicleStatus.TWO_WHEELER,
    );
  }
}
