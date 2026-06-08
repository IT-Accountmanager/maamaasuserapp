class BookingModel {
  final int id;
  final int? vendorId;

  final String guestName;
  final String phoneNumber;
  final String bookingDate;
  final String startTime;
  final String arrivalStatus;
  final SeatingModel? seating;
  final int capacity;

  BookingModel({
    required this.id,
    this.vendorId,

    required this.guestName,
    required this.phoneNumber,
    required this.bookingDate,
    required this.startTime,
    required this.arrivalStatus,
    this.seating,
    required this.capacity,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'],
      vendorId: json['vendorId'],
      guestName: json['guestName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      startTime: json['startTime'] ?? '',
      arrivalStatus: json['arrivalStatus'] ?? '',
      seating: json['seating'] != null
          ? SeatingModel.fromJson(json['seating'])
          : null,
      capacity: json['capacity'] ?? 0,
    );
  }
}

class SeatingModel {
  final int id;
  final String name;
  final String code;
  final int capacity;
  final String seatingStatus;

  SeatingModel({
    required this.id,
    required this.name,
    required this.code,
    required this.capacity,
    required this.seatingStatus,
  });

  factory SeatingModel.fromJson(Map<String, dynamic> json) {
    return SeatingModel(
      id: json['id'],
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      capacity: json['capacity'] ?? 0,
      seatingStatus: json['seatingStatus'] ?? '',
    );
  }
}
