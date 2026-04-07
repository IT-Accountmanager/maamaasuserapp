class ConfirmedList {
  final int id;
  final String phoneNumber;
  final int capacity;
  final int durationMinutes;
  final String bookingDate;
  final String guestName;
  final String code;
  final String types;
  final int userId;
  final int vendorId;
  final int seatingId;
  final String arrivalStatus;

  ConfirmedList({
    required this.id,
    required this.phoneNumber,
    required this.capacity,
    required this.durationMinutes,
    required this.bookingDate,
    required this.guestName,
    required this.code,
    required this.types,
    required this.userId,
    required this.vendorId,
    required this.arrivalStatus,
    required this.seatingId,

  });

  factory ConfirmedList.fromJson(Map<String, dynamic> json) {
    return ConfirmedList(
      id: json["id"],
      phoneNumber: json["phoneNumber"] ?? "",
      capacity: json["capacity"] ?? 0,
      durationMinutes: json["durationMinutes"] ?? 0,
      bookingDate: json["bookingDate"] ?? "",
      guestName: json["guestName"] ?? "",
      code: json["code"] ?? "",
      types: json["types"] ?? "",
      userId: json["userId"] ?? 0,
      vendorId: json["vendorId"] ?? 0,
      seatingId: json["seatingId"],
      arrivalStatus: json["arrivalStatus"] ?? "NOT_ARRIVED",
    );
  }
}
