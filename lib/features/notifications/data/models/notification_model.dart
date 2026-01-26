import '../../domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.type,
    required super.createdAt,
    super.isRead = false,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String? ?? json['body'] as String? ?? '',
      type: _parseType(json['type'] as String?),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      isRead: json['isRead'] as bool? ?? json['read'] as bool? ?? false,
    );
  }

  factory NotificationModel.fromEntity(NotificationEntity entity) {
    return NotificationModel(
      id: entity.id,
      title: entity.title,
      message: entity.message,
      type: entity.type,
      createdAt: entity.createdAt,
      isRead: entity.isRead,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
    };
  }

  static NotificationType _parseType(String? type) {
    switch (type?.toLowerCase()) {
      case 'trip':
        return NotificationType.trip;
      case 'payment':
        return NotificationType.payment;
      case 'promo':
      case 'promotion':
        return NotificationType.promo;
      case 'system':
      default:
        return NotificationType.system;
    }
  }
}
