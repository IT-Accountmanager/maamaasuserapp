class OrderDetails {
  final int orderId;
  final int userId;
  final String userName;
  final String userPhone;

  final double pickupLatitude;
  final double pickupLongitude;
  final String pickupAddress;

  final double dropLatitude;
  final double dropLongitude;
  final String dropAddress;

  final String vehicleStatus;
  final String vehicleType;

  final double fare;
  final double distanceKm;

  final int? partnerId;
  final String? partnerName;
  final String? partnerPhone;
  final double? partnerLatitude;
  final double? partnerLongitude;
  final String? partnerAddress;

  final int? pickupOtp;

  final String appType;
  final String status;

  final DateTime createdAt;
  final DateTime updatedAt;

  OrderDetails({
    required this.orderId,
    required this.userId,
    required this.userName,
    required this.userPhone,
    required this.pickupLatitude,
    required this.pickupLongitude,
    required this.pickupAddress,
    required this.dropLatitude,
    required this.dropLongitude,
    required this.dropAddress,
    required this.vehicleStatus,
    required this.vehicleType,
    required this.fare,
    required this.distanceKm,
    this.partnerId,
    this.partnerName,
    this.partnerPhone,
    this.partnerLatitude,
    this.partnerLongitude,
    this.partnerAddress,
    this.pickupOtp,
    required this.appType,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderDetails.fromJson(Map<String, dynamic> json) {
    return OrderDetails(
      orderId: json['orderId'] ?? 0,
      userId: json['userId'] ?? 0,
      userName: json['userName'] ?? '',
      userPhone: json['userPhone'] ?? '',

      pickupLatitude: (json['pickupLatitude'] ?? 0).toDouble(),
      pickupLongitude: (json['pickupLongitude'] ?? 0).toDouble(),
      pickupAddress: json['pickupAddress'] ?? '',

      dropLatitude: (json['dropLatitude'] ?? 0).toDouble(),
      dropLongitude: (json['dropLongitude'] ?? 0).toDouble(),
      dropAddress: json['dropAddress'] ?? '',

      vehicleStatus: json['vehicleStatus'] ?? '',
      vehicleType: json['vehicleType'] ?? '',

      fare: (json['fare'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),

      partnerId: json['partnerId'],
      partnerName: json['partnerName'],
      partnerPhone: json['partnerPhone'],
      partnerLatitude: json['partnerLatitude'] != null
          ? (json['partnerLatitude']).toDouble()
          : null,
      partnerLongitude: json['partnerLongitude'] != null
          ? (json['partnerLongitude']).toDouble()
          : null,
      partnerAddress: json['partnerAddress'],

      pickupOtp: json['pickupOtp'],

      appType: json['appType'] ?? '',
      status: json['status'] ?? '',

      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "orderId": orderId,
      "userId": userId,
      "userName": userName,
      "userPhone": userPhone,
      "pickupLatitude": pickupLatitude,
      "pickupLongitude": pickupLongitude,
      "pickupAddress": pickupAddress,
      "dropLatitude": dropLatitude,
      "dropLongitude": dropLongitude,
      "dropAddress": dropAddress,
      "vehicleStatus": vehicleStatus,
      "vehicleType": vehicleType,
      "fare": fare,
      "distanceKm": distanceKm,
      "partnerId": partnerId,
      "partnerName": partnerName,
      "partnerPhone": partnerPhone,
      "partnerLatitude": partnerLatitude,
      "partnerLongitude": partnerLongitude,
      "partnerAddress": partnerAddress,
      "pickupOtp": pickupOtp,
      "appType": appType,
      "status": status,
      "createdAt": createdAt.toIso8601String(),
      "updatedAt": updatedAt.toIso8601String(),
    };
  }
}


class OrderStatus {
  static const pending = "PENDING";
  static const searchingPartner = "SEARCHING_PARTNER";
  static const partnerAssigned = "PARTNER_ASSIGNED";
  static const partnerAccepted = "PARTNER_ACCEPTED";
  static const arrived = "ARRIVED";
  static const pickedUp = "PICKED_UP";
  static const ongoing = "ONGOING";
  static const completed = "COMPLETED";
  static const cancelled = "CANCELLED";
}