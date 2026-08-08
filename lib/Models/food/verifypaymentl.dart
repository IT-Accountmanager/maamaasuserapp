class PaymentVerifyModel {
  final String? status;
  final bool captured;

  PaymentVerifyModel({
     this.status,
    required this.captured,
  });

  factory PaymentVerifyModel.fromJson(Map<String, dynamic> json) {
    return PaymentVerifyModel(
      status: json["status"] ?? "",
      captured: json["captured"] ?? false,
    );
  }
}