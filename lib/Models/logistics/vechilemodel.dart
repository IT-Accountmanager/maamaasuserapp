class VehicleModel {
  final String vehicleStatus;
  final String vehicleType;
  final double estimatedFare;
  final double distanceKm;
  final int availablePartners;
  final int etaMinutes;


  VehicleModel({
    required this.vehicleStatus,
    required this.vehicleType,
    required this.estimatedFare,
    required this.distanceKm,
    required this.availablePartners,
    required this.etaMinutes,
  });


  factory VehicleModel.fromJson(Map<String,dynamic> json){
    return VehicleModel(
      vehicleStatus: json['vehicleStatus'] ?? '',
      vehicleType: json['vehicleType'] ?? '',
      estimatedFare: (json['estimatedFare'] ?? 0).toDouble(),
      distanceKm: (json['distanceKm'] ?? 0).toDouble(),
      availablePartners: json['availablePartners'] ?? 0,
      etaMinutes: json['etaMinutes'] ?? 0,
    );
  }
}