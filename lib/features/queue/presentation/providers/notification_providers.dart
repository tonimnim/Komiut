/// Notification providers for queue and trip notifications.
///
/// Provides Riverpod providers for managing notifications:
/// - notificationServiceProvider - Core notification service
/// - queueNotificationHandlerProvider - Handles queue update notifications
/// - notificationSettingsProvider - User notification preferences
library;

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/local_notification_service.dart';
import '../../domain/entities/queued_vehicle.dart';
import '../../domain/entities/vehicle_queue.dart';
import '../../domain/queue_notification_types.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Notification Service Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Global router reference for notification navigation.
/// Must be set during app initialization.
GoRouter? _appRouter;

/// Sets the router for notification navigation.
void setNotificationRouter(GoRouter router) {
  _appRouter = router;
}

/// Provider for the notification service.
///
/// Initializes and provides access to the local notification service.
final notificationServiceProvider = Provider<NotificationService>((ref) {
  final service = LocalNotificationService(
    onNotificationTapped: (payload) {
      if (payload == null || _appRouter == null) return;

      // Navigate based on notification type
      switch (payload.type) {
        case 'queue':
          if (payload.routeId != null) {
            _appRouter!.go(RouteConstants.driverQueue);
          }
          break;
        case 'trip':
          if (payload.tripId != null) {
            _appRouter!.go(
              RouteConstants.driverTripDetailPath(payload.tripId!),
            );
          }
          break;
        default:
          _appRouter!.go(RouteConstants.sharedNotifications);
      }
    },
  );

  // Initialize the service
  service.initialize();

  return service;
});

/// Provider for checking if notifications are enabled on the device.
final areNotificationsEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(notificationServiceProvider);
  return service.areNotificationsEnabled();
});

// ─────────────────────────────────────────────────────────────────────────────
// Notification Settings Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Keys for notification settings in SharedPreferences.
class _NotificationSettingsKeys {
  static const String queueNotificationsEnabled = 'notifications_queue_enabled';
  static const String tripNotificationsEnabled = 'notifications_trip_enabled';
  static const String soundEnabled = 'notifications_sound_enabled';
  static const String vibrationEnabled = 'notifications_vibration_enabled';
}

/// Notification settings state.
class NotificationSettings {
  const NotificationSettings({
    this.queueNotificationsEnabled = true,
    this.tripNotificationsEnabled = true,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  /// Whether queue notifications are enabled.
  final bool queueNotificationsEnabled;

  /// Whether trip notifications are enabled.
  final bool tripNotificationsEnabled;

  /// Whether notification sound is enabled.
  final bool soundEnabled;

  /// Whether vibration is enabled.
  final bool vibrationEnabled;

  /// Creates a copy with modified values.
  NotificationSettings copyWith({
    bool? queueNotificationsEnabled,
    bool? tripNotificationsEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      queueNotificationsEnabled:
          queueNotificationsEnabled ?? this.queueNotificationsEnabled,
      tripNotificationsEnabled:
          tripNotificationsEnabled ?? this.tripNotificationsEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

/// Notifier for managing notification settings.
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  NotificationSettingsNotifier() : super(const NotificationSettings()) {
    _loadSettings();
  }

  SharedPreferences? _prefs;

  /// Loads settings from SharedPreferences.
  Future<void> _loadSettings() async {
    _prefs = await SharedPreferences.getInstance();

    state = NotificationSettings(
      queueNotificationsEnabled: _prefs?.getBool(
            _NotificationSettingsKeys.queueNotificationsEnabled,
          ) ??
          true,
      tripNotificationsEnabled: _prefs?.getBool(
            _NotificationSettingsKeys.tripNotificationsEnabled,
          ) ??
          true,
      soundEnabled:
          _prefs?.getBool(_NotificationSettingsKeys.soundEnabled) ?? true,
      vibrationEnabled:
          _prefs?.getBool(_NotificationSettingsKeys.vibrationEnabled) ?? true,
    );
  }

  /// Enables or disables queue notifications.
  Future<void> setQueueNotificationsEnabled(bool enabled) async {
    state = state.copyWith(queueNotificationsEnabled: enabled);
    await _prefs?.setBool(
      _NotificationSettingsKeys.queueNotificationsEnabled,
      enabled,
    );
  }

  /// Enables or disables trip notifications.
  Future<void> setTripNotificationsEnabled(bool enabled) async {
    state = state.copyWith(tripNotificationsEnabled: enabled);
    await _prefs?.setBool(
      _NotificationSettingsKeys.tripNotificationsEnabled,
      enabled,
    );
  }

  /// Enables or disables notification sound.
  Future<void> setSoundEnabled(bool enabled) async {
    state = state.copyWith(soundEnabled: enabled);
    await _prefs?.setBool(_NotificationSettingsKeys.soundEnabled, enabled);
  }

  /// Enables or disables vibration.
  Future<void> setVibrationEnabled(bool enabled) async {
    state = state.copyWith(vibrationEnabled: enabled);
    await _prefs?.setBool(_NotificationSettingsKeys.vibrationEnabled, enabled);
  }
}

/// Provider for notification settings.
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
  (ref) => NotificationSettingsNotifier(),
);

// ─────────────────────────────────────────────────────────────────────────────
// Queue Notification Handler Provider
// ─────────────────────────────────────────────────────────────────────────────

/// Handler for queue-related notifications.
///
/// Monitors queue updates and triggers appropriate notifications
/// based on vehicle position changes and departure times.
class QueueNotificationHandler {
  QueueNotificationHandler({
    required this.notificationService,
    required this.settings,
  });

  /// The notification service to use.
  final NotificationService notificationService;

  /// Current notification settings.
  final NotificationSettings settings;

  /// Previously tracked queue state (for detecting changes).
  VehicleQueue? _previousQueue;

  /// Previously tracked position.
  int? _previousPosition;

  /// Handles a queue update.
  ///
  /// Compares with previous state and triggers notifications for:
  /// - Vehicle reaching position 1
  /// - Vehicle about to depart
  /// - Position changes
  Future<void> handleQueueUpdate(VehicleQueue queue, String? myVehicleId) async {
    if (!settings.queueNotificationsEnabled || myVehicleId == null) return;

    // Find my vehicle in the queue
    final myVehicle = queue.vehicles.cast<QueuedVehicle?>().firstWhere(
          (v) => v?.vehicleId == myVehicleId,
          orElse: () => null,
        );

    if (myVehicle == null) {
      _previousQueue = queue;
      _previousPosition = null;
      return;
    }

    final currentPosition = myVehicle.position;

    // Check for position 1 (vehicle approaching)
    if (currentPosition == 1 &&
        _previousPosition != null &&
        _previousPosition != 1) {
      await _showVehicleApproachingNotification(myVehicle, queue);
    }

    // Check for status change to boarding
    if (myVehicle.isBoarding && _previousQueue != null) {
      final previousVehicle = _previousQueue!.vehicles.cast<QueuedVehicle?>().firstWhere(
            (v) => v?.vehicleId == myVehicleId,
            orElse: () => null,
          );
      if (previousVehicle != null && !previousVehicle.isBoarding) {
        await _showTimeToBoardNotification(myVehicle);
      }
    }

    // Check for status change to departing
    if (myVehicle.isDeparting && _previousQueue != null) {
      final previousVehicle = _previousQueue!.vehicles.cast<QueuedVehicle?>().firstWhere(
            (v) => v?.vehicleId == myVehicleId,
            orElse: () => null,
          );
      if (previousVehicle != null && !previousVehicle.isDeparting) {
        await _showVehicleDepartingNotification(myVehicle, queue);
      }
    }

    // Check for significant position changes
    if (_previousPosition != null && currentPosition != _previousPosition) {
      // Only notify if moving forward in queue
      if (currentPosition < _previousPosition!) {
        await _showQueuePositionChangedNotification(
          currentPosition,
          queue.vehicleCount,
          myVehicle.estimatedDepartureTime,
        );
      }
    }

    // Update previous state
    _previousQueue = queue;
    _previousPosition = currentPosition;
  }

  /// Shows a vehicle approaching notification.
  Future<void> _showVehicleApproachingNotification(
    QueuedVehicle vehicle,
    VehicleQueue queue,
  ) async {
    final event = QueueNotificationEvent.vehicleApproaching(
      vehicleId: vehicle.vehicleId,
      vehicleNumber: vehicle.registrationNumber,
      routeId: queue.routeId,
      routeName: queue.routeName,
    );

    await notificationService.showLocalNotification(
      id: event.notificationId,
      title: event.title,
      body: event.body,
      payload: event.payload,
    );

    debugPrint('QueueNotificationHandler: Showed vehicle approaching notification');
  }

  /// Shows a time to board notification.
  Future<void> _showTimeToBoardNotification(QueuedVehicle vehicle) async {
    const defaultMinutes = 5;
    final event = QueueNotificationEvent.timeToBoard(
      vehicleId: vehicle.vehicleId,
      vehicleNumber: vehicle.registrationNumber,
      minutesUntilDeparture: defaultMinutes,
    );

    await notificationService.showLocalNotification(
      id: event.notificationId,
      title: event.title,
      body: event.body,
      payload: event.payload,
    );

    debugPrint('QueueNotificationHandler: Showed time to board notification');
  }

  /// Shows a vehicle departing notification.
  Future<void> _showVehicleDepartingNotification(
    QueuedVehicle vehicle,
    VehicleQueue queue,
  ) async {
    final event = QueueNotificationEvent.vehicleDeparting(
      vehicleId: vehicle.vehicleId,
      vehicleNumber: vehicle.registrationNumber,
      routeId: queue.routeId,
      routeName: queue.routeName,
    );

    await notificationService.showLocalNotification(
      id: event.notificationId,
      title: event.title,
      body: event.body,
      payload: event.payload,
    );

    debugPrint('QueueNotificationHandler: Showed vehicle departing notification');
  }

  /// Shows a queue position changed notification.
  Future<void> _showQueuePositionChangedNotification(
    int newPosition,
    int totalVehicles,
    DateTime? estimatedDeparture,
  ) async {
    int? estimatedMinutes;
    if (estimatedDeparture != null) {
      final diff = estimatedDeparture.difference(DateTime.now());
      if (diff.isNegative) {
        estimatedMinutes = 0;
      } else {
        estimatedMinutes = diff.inMinutes;
      }
    }

    final event = QueueNotificationEvent.queuePositionChanged(
      newPosition: newPosition,
      totalVehicles: totalVehicles,
      estimatedMinutes: estimatedMinutes,
    );

    await notificationService.showLocalNotification(
      id: event.notificationId,
      title: event.title,
      body: event.body,
      payload: event.payload,
    );

    debugPrint('QueueNotificationHandler: Showed position changed notification');
  }

  /// Schedules a nearing destination notification.
  Future<void> scheduleNearingDestinationNotification({
    required String tripId,
    required String stopName,
    required DateTime arrivalTime,
    required int minutesBefore,
    String? routeId,
  }) async {
    if (!settings.tripNotificationsEnabled) return;

    final scheduledTime = arrivalTime.subtract(Duration(minutes: minutesBefore));

    // Don't schedule if already in the past
    if (scheduledTime.isBefore(DateTime.now())) return;

    final event = QueueNotificationEvent.nearingDestination(
      tripId: tripId,
      stopName: stopName,
      minutesAway: minutesBefore,
      routeId: routeId,
    );

    await notificationService.scheduleNotification(
      id: event.notificationId,
      scheduledTime: scheduledTime,
      title: event.title,
      body: event.body,
      payload: event.payload,
    );

    debugPrint('QueueNotificationHandler: Scheduled nearing destination notification for $scheduledTime');
  }

  /// Shows a trip started notification.
  Future<void> showTripStartedNotification({
    required String tripId,
    required String routeName,
    required String destination,
    String? routeId,
    String? vehicleId,
  }) async {
    if (!settings.tripNotificationsEnabled) return;

    final event = QueueNotificationEvent.tripStarted(
      tripId: tripId,
      routeName: routeName,
      destination: destination,
      routeId: routeId,
      vehicleId: vehicleId,
    );

    await notificationService.showLocalNotification(
      id: event.notificationId,
      title: event.title,
      body: event.body,
      payload: event.payload,
    );

    debugPrint('QueueNotificationHandler: Showed trip started notification');
  }

  /// Cancels all queue-related notifications.
  Future<void> cancelQueueNotifications() async {
    await notificationService.cancelNotification(NotificationIds.vehicleApproaching);
    await notificationService.cancelNotification(NotificationIds.timeToBoard);
    await notificationService.cancelNotification(NotificationIds.vehicleDeparting);
    await notificationService.cancelNotification(NotificationIds.queuePositionChanged);
    debugPrint('QueueNotificationHandler: Cancelled all queue notifications');
  }

  /// Cancels all trip-related notifications.
  Future<void> cancelTripNotifications() async {
    await notificationService.cancelNotification(NotificationIds.tripStarted);
    await notificationService.cancelNotification(NotificationIds.nearingDestination);
    debugPrint('QueueNotificationHandler: Cancelled all trip notifications');
  }

  /// Resets the handler state.
  void reset() {
    _previousQueue = null;
    _previousPosition = null;
  }
}

/// Provider for the queue notification handler.
final queueNotificationHandlerProvider = Provider<QueueNotificationHandler>((ref) {
  final notificationService = ref.watch(notificationServiceProvider);
  final settings = ref.watch(notificationSettingsProvider);

  return QueueNotificationHandler(
    notificationService: notificationService,
    settings: settings,
  );
});

// ─────────────────────────────────────────────────────────────────────────────
// Convenience Providers
// ─────────────────────────────────────────────────────────────────────────────

/// Provider for checking if queue notifications are enabled.
final queueNotificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).queueNotificationsEnabled;
});

/// Provider for checking if trip notifications are enabled.
final tripNotificationsEnabledProvider = Provider<bool>((ref) {
  return ref.watch(notificationSettingsProvider).tripNotificationsEnabled;
});
