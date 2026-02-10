enum NotificationType {
  trip,
  payment,
  promo,
  system,
  queue,
  assignment,
}

class NotificationEntity {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime createdAt;
  final bool isRead;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.createdAt,
    this.isRead = false,
  });

  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    NotificationType? type,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }

  IconType get iconType {
    switch (type) {
      case NotificationType.trip:
        return IconType.trip;
      case NotificationType.payment:
        return IconType.payment;
      case NotificationType.promo:
        return IconType.promo;
      case NotificationType.system:
        return IconType.system;
      case NotificationType.queue:
        return IconType.system; // Fallback or add new icon type
      case NotificationType.assignment:
        return IconType.trip;
    }
  }
}

enum IconType { trip, payment, promo, system }
