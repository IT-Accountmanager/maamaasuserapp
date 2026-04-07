class Wallet {
  final double totalBalance;
  final double selfLoadedAmount;
  final double companyLoadedAmount;
  final double cashbackAmount;
  final double postPaidUsage;
  final double creditLimit;
  final bool postPaid; // ✅ New boolean field

  Wallet({
    required this.totalBalance,
    required this.selfLoadedAmount,
    required this.companyLoadedAmount,
    required this.cashbackAmount,
    required this.postPaidUsage,
    required this.creditLimit,
    required this.postPaid, // ✅ Include in constructor
  });

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(
      totalBalance: json['totalBalance']?.toDouble() ?? 0.0,
      selfLoadedAmount: json['selfLoadedAmount']?.toDouble() ?? 0.0,
      companyLoadedAmount: json['companyLoadedAmount']?.toDouble() ?? 0.0,
      cashbackAmount: json['cashbackAmount']?.toDouble() ?? 0.0,
      postPaidUsage: json['postPaidUsage']?.toDouble() ?? 0.0,
      creditLimit: json['creditLimit']?.toDouble() ?? 0.0,
      postPaid: json['postPaid'] ?? false, // ✅ Safely parse boolean
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalBalance': totalBalance,
      'selfLoadedAmount': selfLoadedAmount,
      'companyLoadedAmount': companyLoadedAmount,
      'cashbackAmount': cashbackAmount,
      'postPaidUsage': postPaidUsage,
      'creditLimit': creditLimit,
      'postPaid': postPaid, // ✅ Include in JSON output
    };
  }
}
