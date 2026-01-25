/// Abstract notification service interface.
///
/// Defines the contract for notification services in the app.
/// Implementations handle platform-specific notification delivery.
library;

/// Payload data for notifications.
///
/// Contains metadata about the notification for handling taps.
class NotificationPayload {
  /// Creates a new notification payload.
  const NotificationPayload({
    required this.type,
    this.routeId,
    this.tripId,
    this.vehicleId,
    this.data,
  });

  /// Type of notification (e.g., 'queue', 'trip', 'payment').
  final String type;

  /// Route ID associated with the notification.
  final String? routeId;

  /// Trip ID associated with the notification.
  final String? tripId;

  /// Vehicle ID associated with the notification.
  final String? vehicleId;

  /// Additional data as key-value pairs.
  final Map<String, dynamic>? data;

  /// Converts payload to JSON map.
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      if (routeId != null) 'routeId': routeId,
      if (tripId != null) 'tripId': tripId,
      if (vehicleId != null) 'vehicleId': vehicleId,
      if (data != null) 'data': data,
    };
  }

  /// Creates payload from JSON map.
  factory NotificationPayload.fromJson(Map<String, dynamic> json) {
    return NotificationPayload(
      type: json['type'] as String,
      routeId: json['routeId'] as String?,
      tripId: json['tripId'] as String?,
      vehicleId: json['vehicleId'] as String?,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  /// Converts payload to string for storage.
  String toPayloadString() {
    final parts = <String>['type:$type'];
    if (routeId != null) parts.add('routeId:$routeId');
    if (tripId != null) parts.add('tripId:$tripId');
    if (vehicleId != null) parts.add('vehicleId:$vehicleId');
    return parts.join('|');
  }

  /// Creates payload from string.
  factory NotificationPayload.fromPayloadString(String payload) {
    final parts = payload.split('|');
    final map = <String, String>{};
    for (final part in parts) {
      final keyValue = part.split(':');
      if (keyValue.length == 2) {
        map[keyValue[0]] = keyValue[1];
      }
    }
    return NotificationPayload(
      type: map['type'] ?? 'unknown',
      routeId: map['routeId'],
      tripId: map['tripId'],
      vehicleId: map['vehicleId'],
    );
  }
}

/// Abstract interface for notification services.
///
/// Provides methods for showing, scheduling, and canceling notifications.
/// Implementations should handle platform-specific configuration.
abstract class NotificationService {
  /// Initializes the notification service.
  ///
  /// Must be called before using any other notification methods.
  /// Sets up platform-specific configurations and permissions.
  Future<void> initialize();

  /// Checks if notifications are enabled/permitted.
  Future<bool> areNotificationsEnabled();

  /// Requests notification permissions from the user.
  ///
  /// Returns true if permission was granted, false otherwise.
  Future<bool> requestPermission();

  /// Shows a local notification immediately.
  ///
  /// [id] - Unique identifier for the notification.
  /// [title] - Notification title text.
  /// [body] - Notification body/content text.
  /// [payload] - Optional payload for handling notification taps.
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    NotificationPayload? payload,
  });

  /// Schedules a notification to be shown at a specific time.
  ///
  /// [id] - Unique identifier for the notification.
  /// [scheduledTime] - When to show the notification.
  /// [title] - Notification title text.
  /// [body] - Notification body/content text.
  /// [payload] - Optional payload for handling notification taps.
  Future<void> scheduleNotification({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
    NotificationPayload? payload,
  });

  /// Cancels a specific notification by ID.
  ///
  /// [id] - The ID of the notification to cancel.
  Future<void> cancelNotification(int id);

  /// Cancels all pending and shown notifications.
  Future<void> cancelAllNotifications();

  /// Gets pending notification requests.
  ///
  /// Returns a list of notification IDs that are pending.
  Future<List<int>> getPendingNotificationIds();

  /// Called when a notification is tapped.
  ///
  /// Override to handle notification tap navigation.
  void onNotificationTap(NotificationPayload? payload);
}

/// Notification IDs used throughout the app.
///
/// Uses a structured numbering system to avoid conflicts:
/// - 1xxx: Queue notifications
/// - 2xxx: Trip notifications
/// - 3xxx: Payment notifications
/// - 4xxx: System notifications
class NotificationIds {
  const NotificationIds._();

  // Queue notifications (1xxx)
  static const int vehicleApproaching = 1001;
  static const int timeToBoard = 1002;
  static const int vehicleDeparting = 1003;
  static const int queuePositionChanged = 1004;

  // Trip notifications (2xxx)
  static const int tripStarted = 2001;
  static const int nearingDestination = 2002;
  static const int tripCompleted = 2003;
  static const int tripCancelled = 2004;

  // Payment notifications (3xxx)
  static const int paymentSuccessful = 3001;
  static const int paymentFailed = 3002;
  static const int walletTopUp = 3003;

  // System notifications (4xxx)
  static const int appUpdate = 4001;
  static const int promo = 4002;
  static const int announcement = 4003;

  /// Generates a unique ID for a specific queue/route combination.
  static int queueNotificationId(String queueId) {
    return 1000 + queueId.hashCode.abs() % 1000;
  }

  /// Generates a unique ID for a specific trip.
  static int tripNotificationId(String tripId) {
    return 2000 + tripId.hashCode.abs() % 1000;
  }
}
