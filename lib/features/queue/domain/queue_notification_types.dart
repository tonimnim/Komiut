/// Queue notification types and messages.
///
/// Defines all notification types related to queue and trip events,
/// along with message templates for each notification type.
library;

import '../../../core/services/notification_service.dart';

/// Types of queue-related notifications.
enum QueueNotificationType {
  /// Vehicle has moved to first position in queue.
  vehicleApproaching,

  /// Vehicle will depart in a few minutes.
  timeToBoard,

  /// Vehicle is departing now.
  vehicleDeparting,

  /// Trip has started.
  tripStarted,

  /// Approaching destination stop.
  nearingDestination,

  /// Queue position has changed.
  queuePositionChanged,
}

/// Extension methods for [QueueNotificationType].
extension QueueNotificationTypeExtension on QueueNotificationType {
  /// Gets the notification ID for this type.
  int get notificationId {
    switch (this) {
      case QueueNotificationType.vehicleApproaching:
        return NotificationIds.vehicleApproaching;
      case QueueNotificationType.timeToBoard:
        return NotificationIds.timeToBoard;
      case QueueNotificationType.vehicleDeparting:
        return NotificationIds.vehicleDeparting;
      case QueueNotificationType.tripStarted:
        return NotificationIds.tripStarted;
      case QueueNotificationType.nearingDestination:
        return NotificationIds.nearingDestination;
      case QueueNotificationType.queuePositionChanged:
        return NotificationIds.queuePositionChanged;
    }
  }

  /// Gets the payload type for this notification.
  String get payloadType {
    switch (this) {
      case QueueNotificationType.vehicleApproaching:
      case QueueNotificationType.timeToBoard:
      case QueueNotificationType.vehicleDeparting:
      case QueueNotificationType.queuePositionChanged:
        return 'queue';
      case QueueNotificationType.tripStarted:
      case QueueNotificationType.nearingDestination:
        return 'trip';
    }
  }
}

/// Queue notification message templates.
///
/// Provides static methods for generating notification titles and bodies
/// for various queue and trip events.
class QueueNotificationMessages {
  const QueueNotificationMessages._();

  // ─────────────────────────────────────────────────────────────────────────
  // Vehicle Approaching
  // ─────────────────────────────────────────────────────────────────────────

  /// Title for vehicle approaching notification.
  static const String vehicleApproachingTitle = 'Your Vehicle is Ready!';

  /// Body for vehicle approaching notification.
  static String vehicleApproachingBody({
    required String vehicleNumber,
    String? routeName,
  }) {
    if (routeName != null) {
      return 'Vehicle $vehicleNumber is now 1st in queue for $routeName. Head to the stage!';
    }
    return 'Vehicle $vehicleNumber is now 1st in queue. Head to the stage!';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Time to Board
  // ─────────────────────────────────────────────────────────────────────────

  /// Title for time to board notification.
  static const String timeToBoardTitle = 'Time to Board';

  /// Body for time to board notification.
  static String timeToBoardBody({
    required String vehicleNumber,
    required int minutesUntilDeparture,
  }) {
    return 'Vehicle $vehicleNumber departing in $minutesUntilDeparture minutes. Please board now!';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Vehicle Departing
  // ─────────────────────────────────────────────────────────────────────────

  /// Title for vehicle departing notification.
  static const String vehicleDepartingTitle = 'Vehicle Departing Now';

  /// Body for vehicle departing notification.
  static String vehicleDepartingBody({
    required String vehicleNumber,
    String? routeName,
  }) {
    if (routeName != null) {
      return 'Vehicle $vehicleNumber to $routeName is departing now!';
    }
    return 'Vehicle $vehicleNumber is departing now!';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Trip Started
  // ─────────────────────────────────────────────────────────────────────────

  /// Title for trip started notification.
  static const String tripStartedTitle = 'Trip Started';

  /// Body for trip started notification.
  static String tripStartedBody({
    required String routeName,
    required String destination,
  }) {
    return 'Your trip on $routeName has started. Destination: $destination';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Nearing Destination
  // ─────────────────────────────────────────────────────────────────────────

  /// Title for nearing destination notification.
  static const String nearingDestinationTitle = 'Almost There!';

  /// Body for nearing destination notification.
  static String nearingDestinationBody({
    required String stopName,
    required int minutesAway,
  }) {
    return 'Arriving at $stopName in $minutesAway minutes. Get ready to alight.';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Queue Position Changed
  // ─────────────────────────────────────────────────────────────────────────

  /// Title for queue position changed notification.
  static const String queuePositionChangedTitle = 'Queue Update';

  /// Body for queue position changed notification.
  static String queuePositionChangedBody({
    required int newPosition,
    required int totalVehicles,
    int? estimatedMinutes,
  }) {
    final positionText = 'You are now #$newPosition of $totalVehicles in queue.';
    if (estimatedMinutes != null) {
      return '$positionText Est. departure: $estimatedMinutes min.';
    }
    return positionText;
  }
}

/// A queue notification event.
///
/// Encapsulates all data needed to show a queue notification.
class QueueNotificationEvent {
  /// Creates a new queue notification event.
  const QueueNotificationEvent({
    required this.type,
    required this.title,
    required this.body,
    this.routeId,
    this.tripId,
    this.vehicleId,
    this.scheduledTime,
    this.data,
  });

  /// Type of the notification.
  final QueueNotificationType type;

  /// Notification title.
  final String title;

  /// Notification body text.
  final String body;

  /// Associated route ID.
  final String? routeId;

  /// Associated trip ID.
  final String? tripId;

  /// Associated vehicle ID.
  final String? vehicleId;

  /// Time to show the notification (for scheduled notifications).
  final DateTime? scheduledTime;

  /// Additional data.
  final Map<String, dynamic>? data;

  /// Gets the notification ID.
  int get notificationId => type.notificationId;

  /// Creates the notification payload.
  NotificationPayload get payload => NotificationPayload(
    type: type.payloadType,
    routeId: routeId,
    tripId: tripId,
    vehicleId: vehicleId,
    data: data,
  );

  /// Creates a vehicle approaching notification event.
  factory QueueNotificationEvent.vehicleApproaching({
    required String vehicleId,
    required String vehicleNumber,
    String? routeId,
    String? routeName,
  }) {
    return QueueNotificationEvent(
      type: QueueNotificationType.vehicleApproaching,
      title: QueueNotificationMessages.vehicleApproachingTitle,
      body: QueueNotificationMessages.vehicleApproachingBody(
        vehicleNumber: vehicleNumber,
        routeName: routeName,
      ),
      routeId: routeId,
      vehicleId: vehicleId,
    );
  }

  /// Creates a time to board notification event.
  factory QueueNotificationEvent.timeToBoard({
    required String vehicleId,
    required String vehicleNumber,
    required int minutesUntilDeparture,
    String? routeId,
  }) {
    return QueueNotificationEvent(
      type: QueueNotificationType.timeToBoard,
      title: QueueNotificationMessages.timeToBoardTitle,
      body: QueueNotificationMessages.timeToBoardBody(
        vehicleNumber: vehicleNumber,
        minutesUntilDeparture: minutesUntilDeparture,
      ),
      routeId: routeId,
      vehicleId: vehicleId,
    );
  }

  /// Creates a vehicle departing notification event.
  factory QueueNotificationEvent.vehicleDeparting({
    required String vehicleId,
    required String vehicleNumber,
    String? routeId,
    String? routeName,
  }) {
    return QueueNotificationEvent(
      type: QueueNotificationType.vehicleDeparting,
      title: QueueNotificationMessages.vehicleDepartingTitle,
      body: QueueNotificationMessages.vehicleDepartingBody(
        vehicleNumber: vehicleNumber,
        routeName: routeName,
      ),
      routeId: routeId,
      vehicleId: vehicleId,
    );
  }

  /// Creates a trip started notification event.
  factory QueueNotificationEvent.tripStarted({
    required String tripId,
    required String routeName,
    required String destination,
    String? routeId,
    String? vehicleId,
  }) {
    return QueueNotificationEvent(
      type: QueueNotificationType.tripStarted,
      title: QueueNotificationMessages.tripStartedTitle,
      body: QueueNotificationMessages.tripStartedBody(
        routeName: routeName,
        destination: destination,
      ),
      tripId: tripId,
      routeId: routeId,
      vehicleId: vehicleId,
    );
  }

  /// Creates a nearing destination notification event.
  factory QueueNotificationEvent.nearingDestination({
    required String tripId,
    required String stopName,
    required int minutesAway,
    String? routeId,
  }) {
    return QueueNotificationEvent(
      type: QueueNotificationType.nearingDestination,
      title: QueueNotificationMessages.nearingDestinationTitle,
      body: QueueNotificationMessages.nearingDestinationBody(
        stopName: stopName,
        minutesAway: minutesAway,
      ),
      tripId: tripId,
      routeId: routeId,
    );
  }

  /// Creates a queue position changed notification event.
  factory QueueNotificationEvent.queuePositionChanged({
    required int newPosition,
    required int totalVehicles,
    int? estimatedMinutes,
    String? routeId,
    String? vehicleId,
  }) {
    return QueueNotificationEvent(
      type: QueueNotificationType.queuePositionChanged,
      title: QueueNotificationMessages.queuePositionChangedTitle,
      body: QueueNotificationMessages.queuePositionChangedBody(
        newPosition: newPosition,
        totalVehicles: totalVehicles,
        estimatedMinutes: estimatedMinutes,
      ),
      routeId: routeId,
      vehicleId: vehicleId,
    );
  }
}
