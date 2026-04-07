class EnquiryOrder {
  final int id;
  final int leadId;
  final int quotationId;
  final int vendorId;
  final int userId;
  final double amount;
  final String paymentMethod;
  final String paymentType;
  final List<String> walletTypes;
  final String paymentStatus;
  final String createdAt;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String eventType;
  final String eventDate;
  final String eventTime; // Changed from Map<String, dynamic> to String
  final String city;
  final String state;
  final int vegPlates;
  final int nonVegPlates;
  final int mixedPlates;
  final String additionalRequests;
  final List<String> items;
  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String orderStatus;

  EnquiryOrder({
    required this.id,
    required this.leadId,
    required this.quotationId,
    required this.vendorId,
    required this.userId,
    required this.amount,
    required this.paymentMethod,
    required this.paymentType,
    required this.walletTypes,
    required this.paymentStatus,
    required this.createdAt,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.eventType,
    required this.eventDate,
    required this.eventTime, // Changed type
    required this.city,
    required this.state,
    required this.vegPlates,
    required this.nonVegPlates,
    required this.mixedPlates,
    required this.additionalRequests,
    required this.items,
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.orderStatus,
  });

  factory EnquiryOrder.fromJson(Map<String, dynamic> json) {
    return EnquiryOrder(
      id: json['id'] ?? 0,
      leadId: json['leadId'] ?? 0,
      quotationId: json['quotationId'] ?? 0,
      vendorId: json['vendorId'] ?? 0,
      userId: json['userId'] ?? 0,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['paymentMethod'] ?? '',
      paymentType: json['paymentType'] ?? '',
      walletTypes: List<String>.from(json['walletTypes'] ?? []),
      paymentStatus: json['paymentStatus'] ?? '',
      createdAt: json['createdAt'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      eventType: json['eventType'] ?? '',
      eventDate: json['eventDate'] ?? '',
      eventTime: json['eventTime'] ?? '', // Direct string assignment
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      vegPlates: json['vegPlates'] ?? 0,
      nonVegPlates: json['nonVegPlates'] ?? 0,
      mixedPlates: json['mixedPlates'] ?? 0,
      additionalRequests: json['additionalRequests'] ?? '',
      items: List<String>.from(json['items'] ?? []),
      razorpayPaymentId: json['razorpayPaymentId'] ?? '',
      razorpayOrderId: json['razorpayOrderId'] ?? '',
      orderStatus: json['orderStatus'] ?? '',
    );
  }

  String get formattedEventTime {
    try {
      // Handle time string in format "HH:mm:ss"
      final parts = eventTime.split(':');
      if (parts.length >= 2) {
        final hour = int.tryParse(parts[0]) ?? 0;
        final minute = int.tryParse(parts[1]) ?? 0;
        final period = hour >= 12 ? 'PM' : 'AM';
        final displayHour = hour % 12 == 0 ? 12 : hour % 12;
        return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
      }
      return eventTime; // Return original if parsing fails
    } catch (e) {
      return eventTime; // Return original string on error
    }
  }
}