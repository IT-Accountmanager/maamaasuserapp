class DeliveryPartnerReview {
  final int orderId;
  final int partnerId;
  final int userId;
  final String userName;
  final int rating;
  final String review;
  final String appType;
  final DateTime createdAt;

  DeliveryPartnerReview({
    required this.orderId,
    required this.partnerId,
    required this.userId,
    required this.userName,
    required this.rating,
    required this.review,
    required this.appType,
    required this.createdAt,
  });

  factory DeliveryPartnerReview.fromJson(Map<String, dynamic> json) {
    return DeliveryPartnerReview(
      orderId: json["orderId"],
      partnerId: json["partnerId"],
      userId: json["userId"],
      userName: json["userName"] ?? "",
      rating: json["rating"],
      review: json["review"] ?? "",
      appType: json["appType"] ?? "",
      createdAt: DateTime.parse(json["createdAt"]),
    );
  }
}