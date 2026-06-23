class ReferralHistoryResponse {
  final double totalReferralAmount;
  final List<ReferralResponse> referrals;

  ReferralHistoryResponse({
    required this.totalReferralAmount,
    required this.referrals,
  });

  factory ReferralHistoryResponse.fromJson(Map<String, dynamic> json) {
    return ReferralHistoryResponse(
      totalReferralAmount:
      (json['totalReferralAmount'] ?? 0).toDouble(),

      referrals: (json['referrals'] as List<dynamic>? ?? [])
          .map(
            (e) => ReferralResponse.fromJson(
          e as Map<String, dynamic>,
        ),
      )
          .toList(),
    );
  }
}

class ReferralResponse {
  final int id;
  final int? partnerId;
  final int? vendorId;
  final int userId;
  final int? usedByPartnerId;
  final int? usedByVendorId;
  final int? usedByUserId;
  final String referralCode;
  final double bonusAmount;
  final double totalCashback;
  final bool rewardGiven;
  final DateTime createdAt;
  final String name;
  final String email;
  final String phoneNumber;

  ReferralResponse({
    required this.id,
    this.partnerId,
    this.vendorId,
    required this.userId,
    this.usedByPartnerId,
    this.usedByVendorId,
    this.usedByUserId,
    required this.referralCode,
    required this.bonusAmount,
    required this.totalCashback,
    required this.rewardGiven,
    required this.createdAt,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  factory ReferralResponse.fromJson(Map<String, dynamic> json) {
    return ReferralResponse(
      id: json['id'],
      partnerId: json['partnerId'],
      vendorId: json['vendorId'],
      userId: json['userId'],
      usedByPartnerId: json['usedByPartnerId'],
      usedByVendorId: json['usedByVendorId'],
      usedByUserId: json['usedByUserId'],
      referralCode: json['referralCode'] ?? '',
      bonusAmount: (json['bonusAmount'] ?? 0).toDouble(),
      totalCashback: (json['totalcashback'] ?? 0).toDouble(),
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
      'totalCashback': totalCashback,
      'createdAt': createdAt.toIso8601String(),
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
    };
  }

  static List<ReferralResponse> listFromJson(List<dynamic> jsonList) {
    return jsonList.map((e) => ReferralResponse.fromJson(e)).toList();
  }
}
