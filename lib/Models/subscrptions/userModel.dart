class UserModel {
  final String userName;
  final String emailId;
  final String mobileNumber;
  final String referralCode;
  final int totalReferals;
  final String userType;
  final String? companyName;
  final String? image;
  final double totalCashBack;

  UserModel({
    required this.userName,
    required this.emailId,
    required this.mobileNumber,
    required this.referralCode,
    required this.totalReferals,
    required this.userType,
    this.companyName,
    this.image,
    required this.totalCashBack,
  });

  // From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userName: json['userName'] ?? '',
      emailId: json['emailId'] ?? '',
      mobileNumber: json['mobileNumber'] ?? '',
      referralCode: json['referralCode'] ?? '',
      totalReferals: json['totalReferals'] ?? 0,
      userType: json['userType'] ?? '',
      companyName: json['companyName'],
      image: json['image'],
      totalCashBack: (json['totalCashBack'] ?? 0).toDouble(), // ✅ SAFE
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'emailId': emailId,
      'mobileNumber': mobileNumber,
      'referralCode': referralCode,
      'totalReferals': totalReferals,
      'userType': userType,
      'companyName': companyName,
      'image': image,
      'totalCashBack': totalCashBack,
    };
  }
}
