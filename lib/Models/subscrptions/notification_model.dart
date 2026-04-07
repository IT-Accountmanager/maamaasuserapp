class NotificationModel {
  final String id;
  final int userId;
  final String title;
  final String body;
  final String notificationType;
  final Map<String, dynamic>? data;
  final bool isRead;
  final String createdAt;
  final String? readAt;
  final String? deletedAt;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    required this.notificationType,
    required this.data,
    required this.isRead,
    required this.createdAt,
    this.readAt,
    this.deletedAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? 0,
      title: json['title'] ?? '',
      body: json['body'] ?? '',
      notificationType: json['notificationType'] ?? '',
      data: json['data'] != null ? Map<String, dynamic>.from(json['data']) : null,
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] ?? '',
      readAt: json['readAt'],
      deletedAt: json['deletedAt'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'body': body,
    'notificationType': notificationType,
    'data': data,
    'isRead': isRead,
    'createdAt': createdAt,
    'readAt': readAt,
    'deletedAt': deletedAt,
  };
}
