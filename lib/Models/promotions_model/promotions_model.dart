
class Campaign {
  final int campaignId;
  final ApprovalStatus? approvalStatus;
  final String? campaignName;
  final String? description;
  final Goal? goal;
  final Medium? medium;
  final CampaignStatus? status ;

  final AppType? appType;
  final String? customerId;
  final String? imageUrl;
  final String? mediaLink;

  final List<Interest>? interests;

  final int? vendorId;
  final AddDisplayPosition? addDisplayPosition;

  final String? mediaType;
  int? likesCount;
  int? viewsCount;
  int? sharesCount;
  int? savesCount;
  bool? likedByCurrentUser;
  bool? viewedByCurrentUser;
  final String? campaignCode;

  final int? commentsCount;

  final String? mobileNumber;

  final SubGoal? subGoal;
  final CallToAction? callToAction;

  Campaign({
    required this.campaignId,
    this.campaignName,
    this.approvalStatus,
    this.status,

    this.description,
    this.goal,
    this.medium,

    this.appType,

    this.customerId,
    this.imageUrl,
    this.mediaLink,

    this.interests,

    this.vendorId,
    this.addDisplayPosition,

    this.mediaType,
    this.likesCount,
    this.savesCount,
    this.sharesCount,
    this.viewsCount,
    this.likedByCurrentUser,
    this.viewedByCurrentUser,
    this.campaignCode,

    this.commentsCount,

    this.mobileNumber,

    this.subGoal,
    this.callToAction,
  });

  factory Campaign.fromJson(Map<String, dynamic> json) => Campaign(
    campaignId: json["id"],
    campaignName: json["campaignName"],
    description: json["description"],
    approvalStatus: approvalStatusValues.map[json["approvalStatus"]],
    goal: goalValues.map[json["goal"]],
    medium: mediumValues.map[json["medium"]],
    status:statusvalues.map[json["status"]],

    appType: appTypeValues.map[json["appType"]],
    // status: statusValues.map[json["status"]],
    customerId: json["customerId"],
    imageUrl: json["imageUrl"],
    mediaLink: json["mediaLink"], // API sends mediaLink not deepLink

    interests: json["interests"] == null
        ? []
        : List<Interest>.from(
            json["interests"]
                .map((x) => interestValues.map[x])
                .where((e) => e != null),
          ),

    vendorId: json["vendorId"],
    addDisplayPosition:
        addDisplayPositionValues.map[json["addDisplayPosition"]],

    mediaType: json["mediaType"] as String?, // ✅ SAFE
    likesCount: (json['likesCount'] as num?)?.toInt(),
    viewsCount: (json['viewsCount'] as num?)?.toInt(),
    savesCount: (json['savesCount'] as num?)?.toInt(),
    sharesCount: (json['sharesCount'] as num?)?.toInt(),
    likedByCurrentUser: _parseBool(json['likedByCurrentUser']),
    viewedByCurrentUser: _parseBool(json['viewedByCurrentUser']),
    campaignCode: json["campaignCode"],

    commentsCount: (json['commentsCount'] as num?)?.toInt(),

    mobileNumber: json["mobileNumber"],

    subGoal: subGoalValues.map[json["subGoal"]],
    callToAction: callToActionValues.map[json["callToAction"]],
  );

  Map<String, dynamic> toJson() => {
    "campaignName": campaignName,
    "approvalStatus": approvalStatus,
    "description": description,
    "goal": goalValues.reverse[goal],
    "medium": mediumValues.reverse[medium],
    "status":statusvalues.reverse[status],

    "appType": appTypeValues.reverse[appType],

    "customerId": customerId,
    "imageUrl": imageUrl,
    "mediaLink": mediaLink,

    "interests": interests == null
        ? []
        : List<dynamic>.from(interests!.map((x) => interestValues.reverse[x])),

    "vendorId": vendorId,
    "addDisplayPosition": addDisplayPositionValues.reverse[addDisplayPosition],

    "mediaType": mediaType,
    "sharesCount": sharesCount,
    "savesCount": savesCount,
    "viewsCount": viewsCount,
    "likesCount": likesCount,
    "campaignCode": campaignCode,

    "commentsCount": commentsCount,

    "mobileNumber": mobileNumber,

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
enum Goal { BRANDING, DISCOUNT, LEADS, EVENTS, SPONSORSHIP }

enum ApprovalStatus { PENDING, APPROVED, REJECTED}
enum CampaignStatus {DRAFT,SCHEDULED,ACTIVE,PAUSED,COMPLETED,CANCELLED }

// ignore: constant_identifier_names
enum Medium { APP, DIGITAL, PHYSICAL }

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
  // ignore: constant_identifier_names
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
  ENQUIRE_NOW,
  ORDER_NOW,
  REFER_AND_EARN,
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

final goalValues = EnumValues({
  "BRANDING": Goal.BRANDING,
  "DISCOUNT": Goal.DISCOUNT,
  "LEADS": Goal.LEADS,
  "EVENTS": Goal.EVENTS,
  "SPONSORSHIP": Goal.SPONSORSHIP,
});
final approvalStatusValues = EnumValues({
  "PENDING": ApprovalStatus.PENDING,
  "APPROVED": ApprovalStatus.APPROVED,
  "REJECTED": ApprovalStatus.REJECTED,
});
final statusvalues =EnumValues({
  "DRAFT":CampaignStatus .DRAFT,
  "ACTIVE" :CampaignStatus .ACTIVE,
  "SCHEDULED":CampaignStatus .SCHEDULED,
  "PAUSED":CampaignStatus .PAUSED,
  "COMPLETED":CampaignStatus .COMPLETED,
  "CANCELLED ":CampaignStatus .CANCELLED,
});

final mediumValues = EnumValues({
  "APP": Medium.APP,
  "DIGITAL": Medium.DIGITAL,
  "PHYSICAL": Medium.PHYSICAL,
});

final appTypeValues = EnumValues({
  "FOOD_AND_BEVERAGES": AppType.FOOD_AND_BEVERAGES,
  "CATERINGS_SERVICES": AppType.CATERINGS_SERVICES,
  "LOGISTICS_SUPPLY": AppType.LOGISTICS_SUPPLY,
  "FRESH_GROCERIES": AppType.FRESH_GROCERIES,
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
  "ORDER_NOW": CallToAction.ORDER_NOW,
  "REFER_AND_EARN": CallToAction.REFER_AND_EARN,
});
