class Transactions {
  final String? transactionId;
  final int userId;
  final double amount;
  final String transactionType;
  final String description;
  final DateTime transactionDate;

  Transactions({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.transactionType,
    required this.description,
    required this.transactionDate,
  });

  factory Transactions.fromJson(Map<String, dynamic> json) {
    return Transactions(
      transactionId: json['paymentId']?.toString() ?? 'N/A',
      userId: json['userId'] ?? 0,
      amount: (json['amount'] ?? 0).toDouble(),
        description: json['description']?? '',
      transactionType: json['transactionType']?.toString() ?? 'UNKNOWN',
      transactionDate: DateTime.tryParse(json['transactionTime'] ?? '') ?? DateTime.now(),
    );
  }
}
