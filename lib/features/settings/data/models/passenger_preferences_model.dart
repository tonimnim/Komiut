/// Passenger preferences model for JSON serialization.
///
/// Data transfer object for passenger preferences with JSON support.
library;

import '../../domain/entities/passenger_preferences.dart';

/// Model for passenger preferences with JSON serialization.
class PassengerPreferencesModel {
  /// Creates a passenger preferences model.
  const PassengerPreferencesModel({
    required this.defaultPaymentMethod,
    required this.notifications,
    required this.accessibility,
    this.defaultPickupLocation,
    required this.preferredLanguage,
  });

  /// Creates a model from a domain entity.
  factory PassengerPreferencesModel.fromEntity(PassengerPreferences entity) {
    return PassengerPreferencesModel(
      defaultPaymentMethod: entity.defaultPaymentMethod.name,
      notifications: NotificationPreferencesModel.fromEntity(entity.notifications),
      accessibility: AccessibilityOptionsModel.fromEntity(entity.accessibility),
      defaultPickupLocation: entity.defaultPickupLocation,
      preferredLanguage: entity.preferredLanguage,
    );
  }

  /// Creates a model from JSON.
  factory PassengerPreferencesModel.fromJson(Map<String, dynamic> json) {
    return PassengerPreferencesModel(
      defaultPaymentMethod: json['defaultPaymentMethod'] as String? ?? 'mpesa',
      notifications: json['notifications'] != null
          ? NotificationPreferencesModel.fromJson(
              json['notifications'] as Map<String, dynamic>)
          : const NotificationPreferencesModel(),
      accessibility: json['accessibility'] != null
          ? AccessibilityOptionsModel.fromJson(
              json['accessibility'] as Map<String, dynamic>)
          : const AccessibilityOptionsModel(),
      defaultPickupLocation: json['defaultPickupLocation'] as String?,
      preferredLanguage: json['preferredLanguage'] as String? ?? 'en',
    );
  }

  /// Default payment method name.
  final String defaultPaymentMethod;

  /// Notification preferences.
  final NotificationPreferencesModel notifications;

  /// Accessibility options.
  final AccessibilityOptionsModel accessibility;

  /// Default pickup location.
  final String? defaultPickupLocation;

  /// Preferred language code.
  final String preferredLanguage;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'defaultPaymentMethod': defaultPaymentMethod,
        'notifications': notifications.toJson(),
        'accessibility': accessibility.toJson(),
        if (defaultPickupLocation != null)
          'defaultPickupLocation': defaultPickupLocation,
        'preferredLanguage': preferredLanguage,
      };

  /// Converts to domain entity.
  PassengerPreferences toEntity() {
    return PassengerPreferences(
      defaultPaymentMethod: _parsePaymentMethod(defaultPaymentMethod),
      notifications: notifications.toEntity(),
      accessibility: accessibility.toEntity(),
      defaultPickupLocation: defaultPickupLocation,
      preferredLanguage: preferredLanguage,
    );
  }

  /// Parses payment method from string.
  static PaymentMethod _parsePaymentMethod(String value) {
    switch (value.toLowerCase()) {
      case 'mpesa':
        return PaymentMethod.mpesa;
      case 'wallet':
        return PaymentMethod.wallet;
      case 'cash':
        return PaymentMethod.cash;
      case 'card':
        return PaymentMethod.card;
      default:
        return PaymentMethod.mpesa;
    }
  }
}

/// Model for notification preferences with JSON serialization.
class NotificationPreferencesModel {
  /// Creates a notification preferences model.
  const NotificationPreferencesModel({
    this.tripUpdates = true,
    this.promotions = false,
    this.queueAlerts = true,
    this.paymentReceipts = true,
    this.destinationAlerts = true,
  });

  /// Creates a model from a domain entity.
  factory NotificationPreferencesModel.fromEntity(NotificationPreferences entity) {
    return NotificationPreferencesModel(
      tripUpdates: entity.tripUpdates,
      promotions: entity.promotions,
      queueAlerts: entity.queueAlerts,
      paymentReceipts: entity.paymentReceipts,
      destinationAlerts: entity.destinationAlerts,
    );
  }

  /// Creates a model from JSON.
  factory NotificationPreferencesModel.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesModel(
      tripUpdates: json['tripUpdates'] as bool? ?? true,
      promotions: json['promotions'] as bool? ?? false,
      queueAlerts: json['queueAlerts'] as bool? ?? true,
      paymentReceipts: json['paymentReceipts'] as bool? ?? true,
      destinationAlerts: json['destinationAlerts'] as bool? ?? true,
    );
  }

  final bool tripUpdates;
  final bool promotions;
  final bool queueAlerts;
  final bool paymentReceipts;
  final bool destinationAlerts;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'tripUpdates': tripUpdates,
        'promotions': promotions,
        'queueAlerts': queueAlerts,
        'paymentReceipts': paymentReceipts,
        'destinationAlerts': destinationAlerts,
      };

  /// Converts to domain entity.
  NotificationPreferences toEntity() {
    return NotificationPreferences(
      tripUpdates: tripUpdates,
      promotions: promotions,
      queueAlerts: queueAlerts,
      paymentReceipts: paymentReceipts,
      destinationAlerts: destinationAlerts,
    );
  }
}

/// Model for accessibility options with JSON serialization.
class AccessibilityOptionsModel {
  /// Creates an accessibility options model.
  const AccessibilityOptionsModel({
    this.largeText = false,
    this.highContrast = false,
    this.screenReaderOptimized = false,
    this.reducedMotion = false,
  });

  /// Creates a model from a domain entity.
  factory AccessibilityOptionsModel.fromEntity(AccessibilityOptions entity) {
    return AccessibilityOptionsModel(
      largeText: entity.largeText,
      highContrast: entity.highContrast,
      screenReaderOptimized: entity.screenReaderOptimized,
      reducedMotion: entity.reducedMotion,
    );
  }

  /// Creates a model from JSON.
  factory AccessibilityOptionsModel.fromJson(Map<String, dynamic> json) {
    return AccessibilityOptionsModel(
      largeText: json['largeText'] as bool? ?? false,
      highContrast: json['highContrast'] as bool? ?? false,
      screenReaderOptimized: json['screenReaderOptimized'] as bool? ?? false,
      reducedMotion: json['reducedMotion'] as bool? ?? false,
    );
  }

  final bool largeText;
  final bool highContrast;
  final bool screenReaderOptimized;
  final bool reducedMotion;

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'largeText': largeText,
        'highContrast': highContrast,
        'screenReaderOptimized': screenReaderOptimized,
        'reducedMotion': reducedMotion,
      };

  /// Converts to domain entity.
  AccessibilityOptions toEntity() {
    return AccessibilityOptions(
      largeText: largeText,
      highContrast: highContrast,
      screenReaderOptimized: screenReaderOptimized,
      reducedMotion: reducedMotion,
    );
  }
}
