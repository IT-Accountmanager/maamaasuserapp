class ReferralUsageModel {
  final int id;
  final int? partnerId;
  final int? vendorId;
  final int userId;
  final int? usedByPartnerId;
  final int? usedByVendorId;
  final int? usedByUserId;
  final String referralCode;
  final double bonusAmount;
  final bool rewardGiven;
  final DateTime createdAt;
  final String name;
  final String email;
  final String phoneNumber;

  ReferralUsageModel({
    required this.id,
    this.partnerId,
    this.vendorId,
    required this.userId,
    this.usedByPartnerId,
    this.usedByVendorId,
    this.usedByUserId,
    required this.referralCode,
    required this.bonusAmount,
    required this.rewardGiven,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory ReferralUsageModel.fromJson(Map<String, dynamic> json) {
    return ReferralUsageModel(
      id: json['id'],
      partnerId: json['partnerId'],
      vendorId: json['vendorId'],
      userId: json['userId'],
      usedByPartnerId: json['usedByPartnerId'],
      usedByVendorId: json['usedByVendorId'],
      usedByUserId: json['usedByUserId'],
      referralCode: json['referralCode'] ?? '',
      bonusAmount: (json['bonusAmount'] ?? 0).toDouble(),
      rewardGiven: json['rewardGiven'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'vendorId': vendorId,
      'userId': userId,
      'usedByPartnerId': usedByPartnerId,
      'usedByVendorId': usedByVendorId,
      'usedByUserId': usedByUserId,
      'referralCode': referralCode,
      'bonusAmount': bonusAmount,
      'rewardGiven': rewardGiven,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  static List<ReferralUsageModel> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((e) => ReferralUsageModel.fromJson(e))
        .toList();
  }
}