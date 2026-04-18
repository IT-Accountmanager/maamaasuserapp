class Campaign {
  final int campaignId;
  final String? campaignName;
  // final ApprovalStatus? approvalStatus;
  final String? description;
  final Goal? goal;
  final Medium? medium;
  // final DateTime? startDate;
  // final DateTime? endDate;
  // final PaymentStatus? paymentStatus;
  final AppType? appType;
  // final Status? status;
  final String? customerId;
  final String? imageUrl;
  final String? mediaLink;
  // final DateTime? createdAt;
  // final double? totalBudget;
  // final double? calculatedAmount;
  final List<Interest>? interests;
  // final String? city;
  // final double? centerLatitude;
  // final double? centerLongitude;
  // final int? radiusKm;
  // final int? dishId;
  final int? vendorId;
  final AddDisplayPosition? addDisplayPosition;
  // final String? resolution;
  // final double? discountPercentage;
  final String? mediaType;
  int? likesCount;
  int? viewsCount;
  int? sharesCount;
  int? savesCount;
  bool? likedByCurrentUser;
  bool? viewedByCurrentUser;
  final String? campaignCode;
  // final DateTime? updatedAt;
  // final int? leadsCount;
  final int? commentsCount;
  // final List<int>? dishIds;
  // final String? rejectionReason;
  final String? mobileNumber;
  // final Gender? gender;
  // final int? minAge;
  // final int? maxAge;
  final SubGoal? subGoal;
  final CallToAction? callToAction;
  // final TimeCategory? timeCategory;
  // final double? gst;

  Campaign({
    required this.campaignId,
    this.campaignName,
    // this.approvalStatus,
    this.description,
    this.goal,
    this.medium,
    // this.startDate,
    // this.endDate,
    // this.paymentStatus,
    this.appType,
    // this.status,
    this.customerId,
    this.imageUrl,
    this.mediaLink,
    // this.createdAt,
    // this.totalBudget,
    // this.calculatedAmount,
    this.interests,
    // this.city,
    // this.centerLatitude,
    // this.centerLongitude,
    // this.radiusKm,
    // this.dishId,
    this.vendorId,
    this.addDisplayPosition,
    // this.resolution,
    // this.discountPercentage,
    this.mediaType,
    this.likesCount,
    this.savesCount,
    this.sharesCount,
    this.viewsCount,
    this.likedByCurrentUser,
    this.viewedByCurrentUser,
    this.campaignCode,
    // this.updatedAt,
    // this.leadsCount,
    this.commentsCount,
    // this.dishIds,
    // this.rejectionReason,
    this.mobileNumber,
    // this.gender,
    // this.minAge,
    // this.maxAge,
    this.subGoal,
    this.callToAction,
    // this.timeCategory,
    // this.gst,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    campaignId: json["id"],
    campaignName: json["campaignName"],
    // approvalStatus: approvalStatusValues.map[json["approvalStatus"]],
    description: json["description"],
    goal: goalValues.map[json["goal"]],
    medium: mediumValues.map[json["medium"]],
    // startDate: json["startDate"] != null
    //     ? DateTime.parse(json["startDate"])
    //     : null,
    // endDate: json["endDate"] != null ? DateTime.parse(json["endDate"]) : null,
    // paymentStatus: paymentStatusValues.map[json["paymentStatus"]],
    appType: appTypeValues.map[json["appType"]],
    // status: statusValues.map[json["status"]],
    customerId: json["customerId"],
    imageUrl: json["imageUrl"],
    mediaLink: json["mediaLink"], // API sends mediaLink not deepLink
    // createdAt: json["createdAt"] != null
    //     ? DateTime.parse(json["createdAt"])
    //     : null,
    // totalBudget: (json["totalBudget"] as num?)?.toDouble(),
    // calculatedAmount: (json["calculatedAmount"] as num?)?.toDouble(),
    interests: json["interests"] == null
        ? []
        : List<Interest>.from(
            json["interests"]
                .map((x) => interestValues.map[x])
                .where((e) => e != null),
          ),
    // city: json["city"],
    // centerLatitude: (json["centerLatitude"] as num?)?.toDouble(),
    // centerLongitude: (json["centerLongitude"] as num?)?.toDouble(),
    // radiusKm: json["radiusKm"],
    // dishId: json["dishId"],
    vendorId: json["vendorId"],
    addDisplayPosition:
        addDisplayPositionValues.map[json["addDisplayPosition"]],
    // resolution: json["resolution"],
    // discountPercentage: (json["discountPercentage"] as num?)?.toDouble(),
    mediaType: json["mediaType"] as String?, // ✅ SAFE
    likesCount: (json['likesCount'] as num?)?.toInt(),
    viewsCount: (json['viewsCount'] as num?)?.toInt(),
    savesCount: (json['savesCount'] as num?)?.toInt(),
    sharesCount: (json['sharesCount'] as num?)?.toInt(),
    likedByCurrentUser: _parseBool(json['likedByCurrentUser']),
    viewedByCurrentUser: _parseBool(json['viewedByCurrentUser']),
    campaignCode: json["campaignCode"],
    // updatedAt: json["updatedAt"] != null
    //     ? DateTime.parse(json["updatedAt"])
    //     : null,
    // leadsCount: (json['leadsCount'] as num?)?.toInt(),
    commentsCount: (json['commentsCount'] as num?)?.toInt(),
    // dishIds: json["dishIds"] == null ? [] : List<int>.from(json["dishIds"]),
    // rejectionReason: json["rejectionReason"],
    mobileNumber: json["mobileNumber"],
    // gender: genderValues.map[json["gender"]],
    // minAge: json["minAge"],
    // maxAge: json["maxAge"],
    subGoal: subGoalValues.map[json["subGoal"]],
    callToAction: callToActionValues.map[json["callToAction"]],
    // timeCategory: timeCategoryValues.map[json["timeCategory"]],
    // gst: (json["gst"] as num?)?.toDouble(),
  );

  Map<String, dynamic> toJson() => {
    "campaignName": campaignName,
    // "approvalStatus": approvalStatusValues.reverse[approvalStatus],
    "description": description,
    "goal": goalValues.reverse[goal],
    "medium": mediumValues.reverse[medium],
    // "startDate": startDate?.toIso8601String(),
    // "endDate": endDate?.toIso8601String(),
    // "paymentStatus": paymentStatusValues.reverse[paymentStatus],
    "appType": appTypeValues.reverse[appType],
    // "status": statusValues.reverse[status],
    "customerId": customerId,
    "imageUrl": imageUrl,
    "mediaLink": mediaLink,
    // "createdAt": createdAt?.toIso8601String(),
    // "totalBudget": totalBudget,
    // "calculatedAmount": calculatedAmount,
    "interests": interests == null
        ? []
        : List<dynamic>.from(interests!.map((x) => interestValues.reverse[x])),
    // "city": city,
    // "centerLatitude": centerLatitude,
    // "centerLongitude": centerLongitude,
    // "radiusKm": radiusKm,
    // "dishId": dishId,
    "vendorId": vendorId,
    "addDisplayPosition": addDisplayPositionValues.reverse[addDisplayPosition],
    // "resolution": resolution,
    // "discountPercentage": discountPercentage,
    "mediaType": mediaType,
    "sharesCount": sharesCount,
    "savesCount": savesCount,
    "viewsCount": viewsCount,
    "likesCount": likesCount,
    "campaignCode": campaignCode,
    // "updatedAt": updatedAt?.toIso8601String(),
    // "leadsCount": leadsCount,
    "commentsCount": commentsCount,
    // "dishIds": dishIds,
    // "rejectionReason": rejectionReason,
    "mobileNumber": mobileNumber,
    // "gender": genderValues.reverse[gender],
    // "minAge": minAge,
    // "maxAge": maxAge,
    "subGoal": subGoalValues.reverse[subGoal],
    "callToAction": callToActionValues.reverse[callToAction],
    // "timeCategory": timeCategoryValues.reverse[timeCategory],
    // "gst": gst,
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
// enum ApprovalStatus { PENDING, APPROVED, REJECTED }

// ignore: constant_identifier_names
enum Goal { BRANDING, DISCOUNT, LEADS, EVENTS, SPONSORSHIP }

// ignore: constant_identifier_names
enum Medium { APP, DIGITAL, PHYSICAL }
//
// // ignore: constant_identifier_names
// enum PaymentStatus { PENDING, PAID }

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

// enum Status {
//   // ignore: constant_identifier_names
//   DRAFT,
//   // ignore: constant_identifier_names
//   SCHEDULED,
//   // ignore: constant_identifier_names
//   ACTIVE,
//   // ignore: constant_identifier_names
//   PAUSED,
//   // ignore: constant_identifier_names
//   COMPLETED,
//   // ignore: constant_identifier_names
//   CANCELLED,
// }

enum Interest {
  // ignore: constant_identifier_names
  JOBS,
  // ignore: constant_identifier_names
  FOOD,
  // ignore: constant_identifier_names
  EDUCATION,
  // ignore: constant_identifier_names
  OFFERS,
  // ignore: constant_identifier_names
  REAL_ESTATE,
  // ignore: constant_identifier_names
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

// enum Gender { MALE, FEMALE, OTHER, ALL }

enum SubGoal {
  BRAND_AWARENESS,
  BRAND_RECALL,
  PREMIUM_POSTING,
  NEW_CUSTOMER,
  EXISTING_CUSTOMER,
  HIGH_VALUE_CUSTOMER,
  GET_MORE_MESSAGES,
  GET_MORE_CALLS,
  GET_MORE_WHATSAPP_MESSAGE,
  GET_MORE_PAGE_LIKES,
  GET_MORE_LEADS,
  GET_MORE_WEBSITE_VISITORS,
}

enum CallToAction {
  APPLY_NOW,
  BOOK_NOW,
  CONTACT_US,
  DOWNLOAD,
  LEARN_MORE,
  REQUEST_TIME,
  SEE_MENU,
  SHOP_NOW,
  SIGN_UP,
  WATCH_MORE,
  SEND_MESSAGE,
  GET_QUOTE,
  GET_DIRECTIONS,
  LISTEN_NOW,
  BUY_TICKETS,
  CALL_NOW,
}

// enum TimeCategory {
//   PEAK_HOURS,
//   RAINING_TIME,
//   HAPPY_HOURS,
//   LUNCH_TIME,
//   DINNER_TIME,
//   EARLY_MORNING,
//   LATE_NIGHT,
//   WEEKEND_SPECIAL,
// }

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

// final approvalStatusValues = EnumValues({
//   "PENDING": ApprovalStatus.PENDING,
//   "APPROVED": ApprovalStatus.APPROVED,
//   "REJECTED": ApprovalStatus.REJECTED,
// });

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

// final paymentStatusValues = EnumValues({
//   "PENDING": PaymentStatus.PENDING,
//   "PAID": PaymentStatus.PAID,
// });

final appTypeValues = EnumValues({
  "FOOD_AND_BEVERAGES": AppType.FOOD_AND_BEVERAGES,
  "CATERINGS_SERVICES": AppType.CATERINGS_SERVICES,
  "LOGISTICS_SUPPLY": AppType.LOGISTICS_SUPPLY,
  "FRESH_GROCERIES": AppType.FRESH_GROCERIES,
});

// final statusValues = EnumValues({
//   "DRAFT": Status.DRAFT,
//   "SCHEDULED": Status.SCHEDULED,
//   "ACTIVE": Status.ACTIVE,
//   "PAUSED": Status.PAUSED,
//   "COMPLETED": Status.COMPLETED,
//   "CANCELLED": Status.CANCELLED,
// });

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

// final genderValues = EnumValues({
//   "MALE": Gender.MALE,
//   "FEMALE": Gender.FEMALE,
//   "OTHER": Gender.OTHER,
//   "ALL": Gender.ALL,
// });

final subGoalValues = EnumValues({
  "BRAND_AWARENESS": SubGoal.BRAND_AWARENESS,
  "BRAND_RECALL": SubGoal.BRAND_RECALL,
  "PREMIUM_POSTING": SubGoal.PREMIUM_POSTING,
  "NEW_CUSTOMER": SubGoal.NEW_CUSTOMER,
  "EXISTING_CUSTOMER": SubGoal.EXISTING_CUSTOMER,
  "HIGH_VALUE_CUSTOMER": SubGoal.HIGH_VALUE_CUSTOMER,
  "GET_MORE_MESSAGES": SubGoal.GET_MORE_MESSAGES,
  "GET_MORE_CALLS": SubGoal.GET_MORE_CALLS,
  "GET_MORE_WHATSAPP_MESSAGE": SubGoal.GET_MORE_WHATSAPP_MESSAGE,
  "GET_MORE_PAGE_LIKES": SubGoal.GET_MORE_PAGE_LIKES,
  "GET_MORE_LEADS": SubGoal.GET_MORE_LEADS,
  "GET_MORE_WEBSITE_VISITORS": SubGoal.GET_MORE_WEBSITE_VISITORS,
});

final callToActionValues = EnumValues({
  "APPLY_NOW": CallToAction.APPLY_NOW,
  "BOOK_NOW": CallToAction.BOOK_NOW,
  "CONTACT_US": CallToAction.CONTACT_US,
  "DOWNLOAD": CallToAction.DOWNLOAD,
  "LEARN_MORE": CallToAction.LEARN_MORE,
  "REQUEST_TIME": CallToAction.REQUEST_TIME,
  "SEE_MENU": CallToAction.SEE_MENU,
  "SHOP_NOW": CallToAction.SHOP_NOW,
  "SIGN_UP": CallToAction.SIGN_UP,
  "WATCH_MORE": CallToAction.WATCH_MORE,
  "SEND_MESSAGE": CallToAction.SEND_MESSAGE,
  "GET_QUOTE": CallToAction.GET_QUOTE,
  "GET_DIRECTIONS": CallToAction.GET_DIRECTIONS,
  "LISTEN_NOW": CallToAction.LISTEN_NOW,
  "BUY_TICKETS": CallToAction.BUY_TICKETS,
  "CALL_NOW": CallToAction.CALL_NOW,
});

// final timeCategoryValues = EnumValues({
//   "PEAK_HOURS": TimeCategory.PEAK_HOURS,
//   "RAINING_TIME": TimeCategory.RAINING_TIME,
//   "HAPPY_HOURS": TimeCategory.HAPPY_HOURS,
//   "LUNCH_TIME": TimeCategory.LUNCH_TIME,
//   "DINNER_TIME": TimeCategory.DINNER_TIME,
//   "EARLY_MORNING": TimeCategory.EARLY_MORNING,
//   "LATE_NIGHT": TimeCategory.LATE_NIGHT,
//   "WEEKEND_SPECIAL": TimeCategory.WEEKEND_SPECIAL,
// });
