class SeatingDetails {
  final int id;
  final String arrivalStatus;
  final String types;
  final int capacity;
  final String guestName;
  final String phoneNumber;
  final String startTime;
  final int durationMinutes;

  final String bookingDate;
  final int seatingId;
  final String createdAt;

  final Seating seating;

  SeatingDetails({
    required this.id,
    required this.arrivalStatus,
    required this.types,
    required this.capacity,
    required this.guestName,
    required this.phoneNumber,
    required this.startTime,
    required this.durationMinutes,
    required this.bookingDate,
    required this.seatingId,
    required this.createdAt,
    required this.seating,
  });

  factory SeatingDetails.fromJson(Map<String, dynamic> json) {
    return SeatingDetails(
      id: json["id"] ?? 0,
      arrivalStatus: json["arrivalStatus"] ?? "",
      types: json["types"] ?? "",
      capacity: json["capacity"] ?? 0,
      guestName: json["guestName"] ?? "",
      phoneNumber: json["phoneNumber"] ?? "",
      startTime: json["startTime"] ?? "",
      durationMinutes: json["durationMinutes"] ?? 0,

      bookingDate: json["bookingDate"] ?? "",
      seatingId: json["seatingId"] ?? 0,
      createdAt: json["createdAt"] ?? "",

      seating: Seating.fromJson(json["seating"] ?? {}),
    );
  }
}

class Seating {
  final int id;
  final String name;
  final String seatingStatus;
  final String code;
  final int capacity;
  final bool manuallyUpdated;

  Seating({
    required this.id,
    required this.name,
    required this.seatingStatus,
    required this.code,
    required this.capacity,
    required this.manuallyUpdated,
  });

  factory Seating.fromJson(Map<String, dynamic> json) {
    return Seating(
      id: json["id"] ?? 0,
      name: json["name"] ?? "",
      seatingStatus: json["seatingStatus"] ?? "",
      code: json["code"] ?? "",
      capacity: json["capacity"] ?? 0,
      manuallyUpdated: json["manuallyUpdated"] ?? false,
    );
  }
}
