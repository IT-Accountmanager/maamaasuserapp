class Ticket {
  final int id;
  final int userId;
  final String ticketNumber;
  final int? orderId;
  final String issueType;       // maps to backend `issueType`
  final String status;
  final String description;     // maps to backend `description`
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime? resolvedAt;
  final String? adminResponse;

  Ticket({
    required this.id,
    required this.userId,
    required this.ticketNumber,
    this.orderId,
    required this.issueType,
    required this.status,
    required this.description,
    this.attachmentUrl,
    required this.createdAt,
    this.resolvedAt,
    this.adminResponse,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['ticketId'] as int? ?? 0,
      userId: json['userId'] as int? ?? 0,
      orderId: json['orderId'] as int?,
      issueType: json['issueType'] as String? ?? '',
      status: json['status'] as String? ?? '',
      description: json['description'] as String? ?? '',
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt']) ?? DateTime.now()
          : DateTime.now(),
      resolvedAt: json['resolvedAt'] != null
          ? DateTime.tryParse(json['resolvedAt'])
          : null,
      adminResponse: json['adminResponse'] as String?,
      ticketNumber: json['ticketNumber'] as String? ?? 'N/A',
    );
  }
}