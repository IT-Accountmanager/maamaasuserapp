class ConfirmedList {
  final int id;
  final int userId;
  final String startTime;
  final int durationMinutes;
  final String phoneNumber;
  final String guestName;
  final String bookingDate;
  final String arrivalStatus;
  final String types;
  final int capacity;
  final Seating? seating; // ✅ nested object
  final int seatingId;
  final int vendorId;
  final String code;

  ConfirmedList({
    required this.id,
    required this.userId,
    required this.startTime,
    required this.durationMinutes,
    required this.phoneNumber,
    required this.guestName,
    required this.bookingDate,
    required this.arrivalStatus,
    required this.types,
    required this.capacity,
    required this.seating,
    required this.seatingId,
    required this.vendorId,
    required this.code,
  });

  factory ConfirmedList.fromJson(Map<String, dynamic> json) {
    return ConfirmedList(
      id: json["id"] ?? 0,
      userId: json["userId"] ?? 0,
      startTime: json["requestTime"] ?? "",
      durationMinutes: json["durationMinutes"] ?? 0,
      phoneNumber: json["phoneNumber"] ?? "",
      guestName: json["guestName"] ?? "",
      bookingDate: json["bookingDate"] ?? "",
      arrivalStatus: json["arrivalStatus"] ?? "NOT_ARRIVED",
      types: json["types"] ?? "",
      capacity: json["capacity"] ?? 0,
      seating: json["seating"] != null
          ? Seating.fromJson(json["seating"])
          : null,
      seatingId: json["seatingId"] ?? 0,
      vendorId: json["vendorId"] ?? 0,
      code: json["code"] ?? "",
    );
  }
}

class Seating {
  final int id;
  final String name;
  final String seatingStatus;
  final String code;
  final int capacity;
  final String? description;
  final String? remarks;
  final String? cleanTime;
  final bool manuallyUpdated;

  Seating({
    required this.id,
    required this.name,
    required this.seatingStatus,
    required this.code,
    required this.capacity,
    this.description,
    this.remarks,
    this.cleanTime,
    required this.manuallyUpdated,
  });

  factory Seating.fromJson(Map<String, dynamic> json) {
    return Seating(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      seatingStatus: json["seatingStatus"] ?? "",
      code: json["code"] ?? "",
      capacity: json["capacity"] ?? 0,
      description: json["description"],
      remarks: json["remarks"],
      cleanTime: json["cleanTime"],
      manuallyUpdated: json["manuallyUpdated"] ?? false,
    );
  }
}
