// class UserProfile_model {
//   final String userName;
//   final String emailId;
//   final String mobileNumber;
//   final String image;
//   final String referralCode;
//   final int totalReferals;
//   final String userType;
//   final String companyName;
//   final double totalCashBack;
//
//   UserProfile_model({
//     required this.userName,
//     required this.emailId,
//     required this.mobileNumber,
//     required this.image,
//     required this.referralCode,
//     required this.totalReferals,
//     required this.userType,
//     required this.companyName,
//     required this.totalCashBack,
//   });
//
//   factory UserProfile_model.fromJson(Map<String, dynamic> json) {
//     return UserProfile_model(
//       // ✅ SAFE STRING PARSING
//       userName: json['userName']?.toString() ?? '',
//       emailId: json['emailId']?.toString() ?? '',
//       mobileNumber: json['mobileNumber']?.toString() ?? '',
//       image: json['image']?.toString() ?? '',
//       referralCode: json['referralCode']?.toString() ?? '',
//
//       // ✅ SAFE INT
//       totalReferals: json['totalReferals'] is int
//           ? json['totalReferals']
//           : int.tryParse(json['totalReferals']?.toString() ?? '0') ?? 0,
//
//       // ✅ SAFE OPTIONAL STRINGS
//       userType: json['userType']?.toString() ?? '',
//       companyName: json['companyName']?.toString() ?? '',
//
//       // ✅ SAFE DOUBLE (NO CRASH)
//       totalCashBack: json['totalCashBack'] is num
//           ? (json['totalCashBack'] as num).toDouble()
//           : double.tryParse(json['totalCashBack']?.toString() ?? '0') ?? 0.0,
//     );
//   }
// }
