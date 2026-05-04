class Address {
  final int id;
  final int userId;
  final String doorNumber;
  final String addressLine;
  final String landMark;
  final String city;
  final String state;
  final int pincode;
  final String name;
  final String phoneNumber;
  final double latitude;
  final double longitude;
  final String category;
  final String address;
  final DateTime createdAt;
  final DateTime updatedAt;

  Address({
    required this.id,
    required this.userId,
    required this.doorNumber,
    required this.addressLine,
    required this.landMark,
    required this.city,
    required this.state,
    required this.pincode,
    required this.name,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.address,
  });

  // Factory constructor to parse JSON
  factory Address.fromJson(Map<String, dynamic> json) => Address(
    id: json['id'] ?? 0,
    userId: json['userId'] ?? 0,

    doorNumber: json['doorNumber']?.toString() ?? '',
    addressLine: json['addressLine'] ?? '',
    landMark: json['landMark'] ?? '',
    city: json['city'] ?? '',
    state: json['state'] ?? '',

    pincode: int.tryParse(json['pincode'].toString()) ?? 0,

    name: json['name'] ?? '',
    phoneNumber: json['phoneNumber']?.toString() ?? '',

    latitude: (json['latitude'] ?? 0).toDouble(),
    longitude: (json['longitude'] ?? 0).toDouble(),

    category: json['category'] ?? 'Other',

    createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),

    address: json['address']?.toString().trim() ?? '',
  );

  // Convert model back to JSON if needed
  Map<String, dynamic> toJson({bool isUpdate = false}) => {
    if (!isUpdate) 'id': id,
    'userId': userId,
    'doorNumber': doorNumber,
    'addressLine': addressLine,
    'landMark': landMark,
    'city': city,
    'state': state,
    'pincode': pincode,
    'name': name,
    'phoneNumber': phoneNumber,
    'latitude': latitude,
    'longitude': longitude,
    'category': category,
    'address': address,

    // Only send updatedAt if required
    if (isUpdate) 'updatedAt': DateTime.now().toIso8601String(),
  };
}
