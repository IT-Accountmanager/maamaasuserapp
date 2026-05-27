class RestaurantSchedule {
  final int id;
  final int vendorId;
  final String day;
  final String startTime;
  final String lastTime;

  RestaurantSchedule({
    required this.id,
    required this.vendorId,
    required this.day,
    required this.startTime,
    required this.lastTime,
  });

  factory RestaurantSchedule.fromJson(Map<String, dynamic> json) {
    return RestaurantSchedule(
      id: json['id'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      day: json['day']?.toString() ?? '',
      startTime: json['startTime']?.toString() ?? '',
      lastTime: json['lastTime']?.toString() ?? '',
    );
  }
}