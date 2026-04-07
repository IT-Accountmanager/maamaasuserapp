class CateringEnquiry {
  final int id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String eventType;
  final String eventDate;
  final String eventTime;
  final String fullAddress;
  final String city;
  final String state;
  final String country;
  final int vegPlates;
  final int nonVegPlates;
  final int mixedPlates;
  final String additionalRequests;
  final bool adminPermission;
  final String leadStatus;
  final Map<String, List<String>> items;
  final List<int> dishId;
  final double budget;
  final double paymentAmount;
  final String createdAt;
  final String updatedAt;
  final List<AddOn> addOns;

  CateringEnquiry({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.eventType,
    required this.eventDate,
    required this.eventTime,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.country,
    required this.vegPlates,
    required this.nonVegPlates,
    required this.mixedPlates,
    required this.additionalRequests,
    required this.adminPermission,
    required this.leadStatus,
    required this.items,
    required this.dishId,
    required this.budget,
    required this.paymentAmount,
    required this.createdAt,
    required this.updatedAt,
    required this.addOns,
  });

  List<String> get flattenedItems =>
      items.values.expand((list) => list).toList();

  factory CateringEnquiry.fromJson(Map<String, dynamic> json) {
    // 🛠 Helper to safely parse int values
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    // 🛠 Helper to safely parse double values
    double safeDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // 🛠 Helper for list of ints
    List<int> safeIntList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.where((e) => e != null).map((e) => safeInt(e)).toList();
      }
      return [];
    }

    // 🛠 Helper for list of strings

    List<AddOn> safeAddOnList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value
            .where((e) => e != null)
            .map((e) => AddOn.fromJson(e))
            .toList();
      }
      return [];
    }

    Map<String, List<String>> safeItemMap(dynamic value) {
      if (value == null || value is! Map) return {};

      return Map<String, List<String>>.from(
        value.map(
              (key, val) => MapEntry(
            key.toString(),
            (val as List).map((e) => e.toString()).toList(),
          ),
        ),
      );
    }

    return CateringEnquiry(
      id: safeInt(json['id']),
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      eventType: json['eventType'] ?? '',
      eventDate: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '',
      fullAddress: json['fullAddress'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
      vegPlates: safeInt(json['vegPlates']),
      nonVegPlates: safeInt(json['nonVegPlates']),
      mixedPlates: safeInt(json['mixedPlates']),
      additionalRequests: json['additionalRequests'] ?? '',
      adminPermission: json['adminPermision'] ?? false,
      leadStatus: json['leadStatus'] ?? '',
      items: safeItemMap(json['items']),
      dishId: safeIntList(json['dishId']),
      budget: safeDouble(json['budget']),
      paymentAmount: safeDouble(json['paymentAmount']),
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
      addOns: safeAddOnList(json['addOns']),
    );
  }
}

class AddOn {
  final int id;
  final String addOnType;
  final int quantity;
  final bool selected;
  final String menuEnquiry;

  AddOn({
    required this.id,
    required this.addOnType,
    required this.quantity,
    required this.selected,
    required this.menuEnquiry,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) {
    int safeInt(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      return int.tryParse(value.toString()) ?? 0;
    }

    bool safeBool(dynamic value) {
      if (value == null) return false;
      if (value is bool) return value;
      return value.toString().toLowerCase() == 'true';
    }

    return AddOn(
      id: safeInt(json['id']),
      addOnType: json['addOnType'] ?? '',
      quantity: safeInt(json['quantity']),
      selected: safeBool(json['selected']),
      menuEnquiry: json['menuEnquiry'] ?? '',
    );
  }
}

enum LeadStatus { pending, approved, paymentReceived, assigned, closed }
