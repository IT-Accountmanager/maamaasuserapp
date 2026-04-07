class Campaign {
  final int campaignId;
  final String? campaignName;
  final ApprovalStatus? approvalStatus;
  final String? description;
  final Goal? goal;
  final Medium? medium;
  final DateTime? startDate;
  final DateTime? endDate;
  final PaymentStatus? paymentStatus;
  final AppType? appType;
  final Status? status;
  final String? customerId;
  final String? imageUrl;
  final String? deepLink;
  final DateTime? createdAt;
  final double? totalBudget;
  final double? calculatedAmount;
  final List<Interest>? interests;
  final String? city;
  final double? centerLatitude;
  final double? centerLongitude;
  final int? radiusKm;
  final int? dishId;
  final int? vendorId;
  final AddDisplayPosition? addDisplayPosition;
  final String? resolution;
  final double? discountPercentage;
  final String? mediaType;
  int? likesCount;
  int? viewsCount;
  int? sharesCount;
  int? savesCount;
  bool? likedByCurrentUser;
  bool? viewedByCurrentUser;

  Campaign({
    required this.campaignId,
    this.campaignName,
    this.approvalStatus,
    this.description,
    this.goal,
    this.medium,
    this.startDate,
    this.endDate,
    this.paymentStatus,
    this.appType,
    this.status,
    this.customerId,
    this.imageUrl,
    this.deepLink,
    this.createdAt,
    this.totalBudget,
    this.calculatedAmount,
    this.interests,
    this.city,
    this.centerLatitude,
    this.centerLongitude,
    this.radiusKm,
    this.dishId,
    this.vendorId,
    this.addDisplayPosition,
    this.resolution,
    this.discountPercentage,
    this.mediaType,
    this.likesCount,
    this.savesCount,
    this.sharesCount,
    this.viewsCount,
    this.likedByCurrentUser,
    this.viewedByCurrentUser,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    campaignId: json["id"],
    campaignName: json["campaignName"],
    approvalStatus: approvalStatusValues.map[json["approvalStatus"]],
    description: json["description"],
    goal: goalValues.map[json["goal"]],
    medium: mediumValues.map[json["medium"]],
    startDate: json["startDate"] != null
        ? DateTime.parse(json["startDate"])
        : null,
    endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
    paymentStatus: paymentStatusValues.map[json["paymentStatus"]],
    appType: appTypeValues.map[json["appType"]],
    status: statusValues.map[json["status"]],
    customerId: json["customerId"],
    imageUrl: json["imageUrl"],
    deepLink: json["mediaLink"], // API sends mediaLink not deepLink
    createdAt: json["createdAt"] != null
        ? DateTime.parse(json["createdAt"])
        : null,
    totalBudget: (json["totalBudget"] as num?)?.toDouble(),
    calculatedAmount: (json["calculatedAmount"] as num?)?.toDouble(),
    interests: json["interests"] == null
        ? []
        : List<Interest>.from(
            json["interests"]
                .map((x) => interestValues.map[x])
                .where((e) => e != null),
          ),
    city: json["city"],
    centerLatitude: (json["centerLatitude"] as num?)?.toDouble(),
    centerLongitude: (json["centerLongitude"] as num?)?.toDouble(),
    radiusKm: json["radiusKm"],
    dishId: json["dishId"],
    vendorId: json["vendorId"],
    addDisplayPosition:
        addDisplayPositionValues.map[json["addDisplayPosition"]],
    resolution: json["resolution"],
    discountPercentage: (json["discountPercentage"] as num?)?.toDouble(),
    mediaType: json["mediaType"] as String?, // ✅ SAFE
    likesCount: (json['likesCount'] as num?)?.toInt(),
    viewsCount: (json['viewsCount'] as num?)?.toInt(),
    savesCount: (json['savesCount'] as num?)?.toInt(),
    sharesCount: (json['sharesCount'] as num?)?.toInt(),
    likedByCurrentUser: _parseBool(json['likedByCurrentUser']),
    viewedByCurrentUser: _parseBool(json['viewedByCurrentUser']),
  );

  Map<String, dynamic> toJson() => {
    "campaignName": campaignName,
    "approvalStatus": approvalStatusValues.reverse[approvalStatus],
    "description": description,
    "goal": goalValues.reverse[goal],
    "medium": mediumValues.reverse[medium],
    "startDate": startDate?.toIso8601String(),
    "endDate": endDate?.toIso8601String(),
    "paymentStatus": paymentStatusValues.reverse[paymentStatus],
    "appType": appTypeValues.reverse[appType],
    "status": statusValues.reverse[status],
    "customerId": customerId,
    "imageUrl": imageUrl,
    "deepLink": deepLink,
    "createdAt": createdAt?.toIso8601String(),
    "totalBudget": totalBudget,
    "calculatedAmount": calculatedAmount,
    "interests": interests == null
        ? []
        : List<dynamic>.from(interests!.map((x) => interestValues.reverse[x])),
    "city": city,
    "centerLatitude": centerLatitude,
    "centerLongitude": centerLongitude,
    "radiusKm": radiusKm,
    "dishId": dishId,
    "vendorId": vendorId,
    "addDisplayPosition": addDisplayPositionValues.reverse[addDisplayPosition],
    "resolution": resolution,
    "discountPercentage": discountPercentage,
    "mediaType": mediaType,
    "sharesCount": sharesCount,
    "savesCount": savesCount,
    "viewsCount": viewsCount,
    "likesCount": likesCount,
  };
}

bool _parseBool(dynamic value) {
  if (value == null) return false;
  if (value is bool) return value;
  if (value is int) return value == 1;
  if (value is String) return value.toLowerCase() == 'true';
  return false;
}

// ignore: constant_identifier_names
enum ApprovalStatus { PENDING, APPROVED, REJECTED }

// ignore: constant_identifier_names
enum Goal { BRANDING, DISCOUNT, LEADS, EVENTS, SPONSORSHIP }

// ignore: constant_identifier_names
enum Medium { APP, DIGITAL, PHYSICAL }

// ignore: constant_identifier_names
enum PaymentStatus { PENDING, PAID }

enum AppType {
  // ignore: constant_identifier_names
  FOOD_AND_BEVERAGES,
  // ignore: constant_identifier_names
  CATERINGS_SERVICES,
  // ignore: constant_identifier_names
  LOGISTICS_SUPPLY,
  // ignore: constant_identifier_names
  FRESH_GROCERIES,
}

enum Status {
  // ignore: constant_identifier_names
  DRAFT,
  // ignore: constant_identifier_names
  SCHEDULED,
  // ignore: constant_identifier_names
  ACTIVE,
  // ignore: constant_identifier_names
  PAUSED,
  // ignore: constant_identifier_names
  COMPLETED,
  // ignore: constant_identifier_names
  CANCELLED,
}

enum Interest {
  // ignore: constant_identifier_names
  JOBS,
  // ignore: constant_identifier_names
  FOOD,
  // ignore: constant_identifier_names
  EDUCATION,
  OFFERS,
  REAL_ESTATE,
  ONLINE_COURSES,
  BAKERY,
  HEALTH,
  TRAVEL,
  ENTERTAINMENT,
}

enum AddDisplayPosition {
  ADD_SCREEN,
  HOMEPAGE_BANNER,
  PRODUCT_PAGE,
  CHECKOUT_PAGE,
  IN_APP_POPUP,
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

final approvalStatusValues = EnumValues({
  "PENDING": ApprovalStatus.PENDING,
  "APPROVED": ApprovalStatus.APPROVED,
  "REJECTED": ApprovalStatus.REJECTED,
});

final goalValues = EnumValues({
  "BRANDING": Goal.BRANDING,
  "DISCOUNT": Goal.DISCOUNT,
  "LEADS": Goal.LEADS,
  "EVENTS": Goal.EVENTS,
  "SPONSORSHIP": Goal.SPONSORSHIP,
});

final mediumValues = EnumValues({
  "APP": Medium.APP,
  "DIGITAL": Medium.DIGITAL,
  "PHYSICAL": Medium.PHYSICAL,
});

final paymentStatusValues = EnumValues({
  "PENDING": PaymentStatus.PENDING,
  "PAID": PaymentStatus.PAID,
});

final appTypeValues = EnumValues({
  "FOOD_AND_BEVERAGES": AppType.FOOD_AND_BEVERAGES,
  "CATERINGS_SERVICES": AppType.CATERINGS_SERVICES,
  "LOGISTICS_SUPPLY": AppType.LOGISTICS_SUPPLY,
  "FRESH_GROCERIES": AppType.FRESH_GROCERIES,
});

final statusValues = EnumValues({
  "DRAFT": Status.DRAFT,
  "SCHEDULED": Status.SCHEDULED,
  "ACTIVE": Status.ACTIVE,
  "PAUSED": Status.PAUSED,
  "COMPLETED": Status.COMPLETED,
  "CANCELLED": Status.CANCELLED,
});

final interestValues = EnumValues({
  "JOBS": Interest.JOBS,
  "FOOD": Interest.FOOD,
  "EDUCATION": Interest.EDUCATION,
  "OFFERS": Interest.OFFERS,
  "REAL_ESTATE": Interest.REAL_ESTATE,
  "ONLINE_COURSES": Interest.ONLINE_COURSES,
  "BAKERY": Interest.BAKERY,
  "HEALTH": Interest.HEALTH,
  "TRAVEL": Interest.TRAVEL,
  "ENTERTAINMENT": Interest.ENTERTAINMENT,
});

final addDisplayPositionValues = EnumValues({
  "ADD_SCREEN": AddDisplayPosition.ADD_SCREEN,
  "HOMEPAGE_BANNER": AddDisplayPosition.HOMEPAGE_BANNER,
  "PRODUCT_PAGE": AddDisplayPosition.PRODUCT_PAGE,
  "CHECKOUT_PAGE": AddDisplayPosition.CHECKOUT_PAGE,
  "IN_APP_POPUP": AddDisplayPosition.IN_APP_POPUP,
});
