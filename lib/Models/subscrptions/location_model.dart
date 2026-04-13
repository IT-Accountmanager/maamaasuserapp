class UserLocationModel {
  final int id;
  final int userId;
  final double latitude;
  final double longitude;
  final String address;
  final String? category;
  UserLocationModel({
    required this.id,
    required this.userId,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.category,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> json) {
    return UserLocationModel(
      id: json["id"],
      userId: json["userId"],
      latitude: (json["latitude"] as num).toDouble(),
      longitude: (json["longitude"] as num).toDouble(),
      address: json["address"] ?? '',
      category: json['category'], // can be null safely
    );
  }
}
