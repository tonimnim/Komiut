/// Local notification service implementation.
///
/// Uses flutter_local_notifications package to show and schedule
/// local notifications on Android and iOS.
library;

import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

import 'notification_service.dart';

/// Callback for handling notification taps.
typedef NotificationTapCallback = void Function(NotificationPayload? payload);

/// Implementation of [NotificationService] using flutter_local_notifications.
///
/// Handles platform-specific configuration for Android and iOS,
/// including notification channels, icons, and permissions.
class LocalNotificationService implements NotificationService {
  /// Creates a new local notification service.
  LocalNotificationService({
    this.onNotificationTapped,
  });

  /// Callback when a notification is tapped.
  final NotificationTapCallback? onNotificationTapped;

  /// The flutter_local_notifications plugin instance.
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Whether the service has been initialized.
  bool _isInitialized = false;

  /// Android notification channel ID for queue notifications.
  static const String _queueChannelId = 'komiut_queue';

  /// Android notification channel name.
  static const String _queueChannelName = 'Queue Notifications';

  /// Android notification channel description.
  static const String _queueChannelDescription =
      'Notifications about queue position and vehicle status';

  /// Android notification channel ID for trip notifications.
  static const String _tripChannelId = 'komiut_trips';

  /// Android notification channel name for trips.
  static const String _tripChannelName = 'Trip Notifications';

  /// Android notification channel description for trips.
  static const String _tripChannelDescription =
      'Notifications about your ongoing trips';

  /// Android notification channel ID for general notifications.
  static const String _generalChannelId = 'komiut_general';

  /// Android notification channel name for general.
  static const String _generalChannelName = 'General Notifications';

  /// Android notification channel description for general.
  static const String _generalChannelDescription =
      'General app notifications and announcements';

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize timezone for scheduled notifications
    tz_data.initializeTimeZones();

    // Android initialization settings
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // iOS initialization settings
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Combined initialization settings
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize the plugin
    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onBackgroundNotificationResponse,
    );

    // Create Android notification channels
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }

    _isInitialized = true;
    debugPrint('LocalNotificationService: Initialized successfully');
  }

  /// Creates notification channels for Android.
  Future<void> _createNotificationChannels() async {
    final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin == null) return;

    // Queue notifications channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _queueChannelId,
        _queueChannelName,
        description: _queueChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // Trip notifications channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _tripChannelId,
        _tripChannelName,
        description: _tripChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    // General notifications channel
    await androidPlugin.createNotificationChannel(
      const AndroidNotificationChannel(
        _generalChannelId,
        _generalChannelName,
        description: _generalChannelDescription,
        importance: Importance.defaultImportance,
        playSound: true,
      ),
    );
  }

  /// Handles notification tap.
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('LocalNotificationService: Notification tapped: ${response.id}');
    if (response.payload != null) {
      try {
        final payload =
            NotificationPayload.fromPayloadString(response.payload!);
        onNotificationTap(payload);
      } catch (e) {
        debugPrint('LocalNotificationService: Error parsing payload: $e');
      }
    }
  }

  /// Handles background notification tap.
  @pragma('vm:entry-point')
  static void _onBackgroundNotificationResponse(NotificationResponse response) {
    // Handle background notification tap
    // This runs in an isolate, so we can only do limited operations
    debugPrint(
        'LocalNotificationService: Background notification tapped: ${response.id}');
  }

  @override
  Future<bool> areNotificationsEnabled() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      return await androidPlugin?.areNotificationsEnabled() ?? false;
    } else if (Platform.isIOS) {
      // For iOS, check current notification settings
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final settings = await iosPlugin?.checkPermissions();
      return settings?.isEnabled ?? false;
    }
    return false;
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      final granted = await androidPlugin?.requestNotificationsPermission();
      return granted ?? false;
    } else if (Platform.isIOS) {
      final iosPlugin = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      final granted = await iosPlugin?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return granted ?? false;
    }
    return false;
  }

  @override
  Future<void> showLocalNotification({
    required int id,
    required String title,
    required String body,
    NotificationPayload? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    final channelId = _getChannelId(payload?.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: payload?.toPayloadString(),
    );

    debugPrint('LocalNotificationService: Showed notification: $title');
  }

  @override
  Future<void> scheduleNotification({
    required int id,
    required DateTime scheduledTime,
    required String title,
    required String body,
    NotificationPayload? payload,
  }) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Don't schedule if the time has passed
    if (scheduledTime.isBefore(DateTime.now())) {
      debugPrint(
          'LocalNotificationService: Cannot schedule notification in the past');
      return;
    }

    final channelId = _getChannelId(payload?.type);

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload?.toPayloadString(),
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );

    debugPrint(
        'LocalNotificationService: Scheduled notification for $scheduledTime: $title');
  }

  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('LocalNotificationService: Cancelled notification: $id');
  }

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('LocalNotificationService: Cancelled all notifications');
  }

  @override
  Future<List<int>> getPendingNotificationIds() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.map((n) => n.id).toList();
  }

  @override
  void onNotificationTap(NotificationPayload? payload) {
    if (payload == null) return;

    debugPrint(
        'LocalNotificationService: Handling notification tap: ${payload.type}');
    onNotificationTapped?.call(payload);
  }

  /// Gets the appropriate channel ID based on notification type.
  String _getChannelId(String? type) {
    switch (type) {
      case 'queue':
        return _queueChannelId;
      case 'trip':
        return _tripChannelId;
      default:
        return _generalChannelId;
    }
  }

  /// Gets channel name from channel ID.
  String _getChannelName(String channelId) {
    switch (channelId) {
      case _queueChannelId:
        return _queueChannelName;
      case _tripChannelId:
        return _tripChannelName;
      default:
        return _generalChannelName;
    }
  }

  /// Gets channel description from channel ID.
  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case _queueChannelId:
        return _queueChannelDescription;
      case _tripChannelId:
        return _tripChannelDescription;
      default:
        return _generalChannelDescription;
    }
  }
}
