class BookRideResponse {
  final int orderId;
  final String status;
  final String appType;
  final String vehicleStatus;
  final String vehicleType;
  final double fare;
  final double distanceKm;
  final String pickupAddress;
  final String dropAddress;
  final DateTime createdAt;
  final String message;

  BookRideResponse({
    required this.orderId,
    required this.status,
    required this.appType,
    required this.vehicleStatus,
    required this.vehicleType,
    required this.fare,
    required this.distanceKm,
    required this.pickupAddress,
    required this.dropAddress,
    required this.createdAt,
    required this.message,
  });

  factory BookRideResponse.fromJson(Map<String, dynamic> json) {
    return BookRideResponse(
      orderId: json['orderId'] ?? 0,
      status: json['status'] ?? '',
      appType: json['appType'] ?? '',
      vehicleStatus: json['vehicleStatus'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      fare: (json['fare'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      pickupAddress: json['pickupAddress'] ?? '',
      dropAddress: json['dropAddress'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      message: json['message'] ?? '',
    );
  }
}