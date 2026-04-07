class WaitingItem {
  final int id;
  final String? floorName;
  final String phoneNumber;
  final int capacity;
  final int durationMinutes;
  final String requestTime;
  final String bookingDate;
  final String guestName;
  final String code;
  final String types;
  final int userId;
  final int vendorId;

  WaitingItem({
    required this.id,
    this.floorName,
    required this.phoneNumber,
    required this.capacity,
    required this.durationMinutes,
    required this.requestTime,
    required this.bookingDate,
    required this.guestName,
    required this.code,
    required this.types,
    required this.userId,
    required this.vendorId,
  });

  factory WaitingItem.fromJson(Map<String, dynamic> json) {
    return WaitingItem(
      id: json["id"],
      floorName: json["floorName"],
      phoneNumber: json["phoneNumber"] ?? "",
      capacity: json["capacity"] ?? 0,
      durationMinutes: json["durationMinutes"] ?? 0,
      requestTime: json["requestTime"] ?? "",
      bookingDate: json["bookingDate"] ?? "",
      guestName: json["guestName"] ?? "",
      code: json["code"] ?? "",
      types: json["types"] ?? "",
      userId: json["userId"] ?? 0,
      vendorId: json["vendorId"] ?? 0,
    );
  }
}
