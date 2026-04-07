class Advertisement {
  final int advertisementId;
  final String title;
  final String type; // IMAGE or VIDEO
  final String description;
  final String mediaUrl;
  int duration;
  final String startDate;
  final String endDate;
  final double amount;
  final int vendorId;
  final String resolution;
  final int? adminId;         // Nullable
  final String? paymentStatus; // Nullable
  final String? transactionId; // Nullable
  final String? orderId;       // Nullable
  final String advertisementType;


  Advertisement({
    required this.advertisementId,
    required this.title,
    required this.type,
    required this.description,
    required this.mediaUrl,
    this.duration = 10,
    required this.startDate,
    required this.endDate,
    required this.amount,
    required this.vendorId,
    required this.resolution,
    this.adminId,
    this.paymentStatus,
    this.transactionId,
    this.orderId,
    required this.advertisementType,

  });

  factory Advertisement.fromJson(Map<String, dynamic> json) {
    return Advertisement(
      advertisementId: json['advertisementId'] ?? 0,
      title: json['title'] ?? '',
      type: json['type'] ?? 'IMAGE',
      description: json['description'] ?? '',
      mediaUrl: json['mediaUrl'] ?? '',
      duration: 10,
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0, // safe cast
      vendorId: json['vendorId'] ?? 0,
      resolution: json['resolution'] ?? '',
      adminId: json['adminId'],           // nullable
      paymentStatus: json['paymentStatus'], // nullable
      transactionId: json['transactionId'], // nullable
      orderId: json['orderId'],           // nullable
      advertisementType: json['advertisementType'] ?? 'ALL',
    );
  }
}
