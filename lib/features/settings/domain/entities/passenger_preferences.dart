/// Passenger preferences entity.
///
/// Represents user preferences for the Komiut passenger app.
/// Includes default payment method, notification settings, and accessibility options.
library;

import 'package:equatable/equatable.dart';

/// Supported payment methods for passengers.
enum PaymentMethod {
  /// Pay using M-Pesa mobile money.
  mpesa,

  /// Pay using in-app wallet balance.
  wallet,

  /// Pay with cash to driver.
  cash,

  /// Pay using credit/debit card.
  card,
}

/// Extension to convert PaymentMethod to display string.
extension PaymentMethodX on PaymentMethod {
  /// Returns a human-readable label for the payment method.
  String get label {
    switch (this) {
      case PaymentMethod.mpesa:
        return 'M-Pesa';
      case PaymentMethod.wallet:
        return 'Wallet';
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.card:
        return 'Card';
    }
  }

  /// Returns an icon name for the payment method.
  String get iconName {
    switch (this) {
      case PaymentMethod.mpesa:
        return 'phone_android';
      case PaymentMethod.wallet:
        return 'account_balance_wallet';
      case PaymentMethod.cash:
        return 'payments';
      case PaymentMethod.card:
        return 'credit_card';
    }
  }
}

/// Notification preferences for passengers.
class NotificationPreferences extends Equatable {
  /// Creates notification preferences.
  const NotificationPreferences({
    this.tripUpdates = true,
    this.promotions = false,
    this.queueAlerts = true,
    this.paymentReceipts = true,
    this.destinationAlerts = true,
  });

  /// Whether to receive trip update notifications.
  final bool tripUpdates;

  /// Whether to receive promotional notifications.
  final bool promotions;

  /// Whether to receive queue position alerts.
  final bool queueAlerts;

  /// Whether to receive payment receipt notifications.
  final bool paymentReceipts;

  /// Whether to receive destination approaching alerts.
  final bool destinationAlerts;

  /// Creates a copy with modified fields.
  NotificationPreferences copyWith({
    bool? tripUpdates,
    bool? promotions,
    bool? queueAlerts,
    bool? paymentReceipts,
    bool? destinationAlerts,
  }) {
    return NotificationPreferences(
      tripUpdates: tripUpdates ?? this.tripUpdates,
      promotions: promotions ?? this.promotions,
      queueAlerts: queueAlerts ?? this.queueAlerts,
      paymentReceipts: paymentReceipts ?? this.paymentReceipts,
      destinationAlerts: destinationAlerts ?? this.destinationAlerts,
    );
  }

  @override
  List<Object?> get props => [
        tripUpdates,
        promotions,
        queueAlerts,
        paymentReceipts,
        destinationAlerts,
      ];
}

/// Accessibility options for passengers.
class AccessibilityOptions extends Equatable {
  /// Creates accessibility options.
  const AccessibilityOptions({
    this.largeText = false,
    this.highContrast = false,
    this.screenReaderOptimized = false,
    this.reducedMotion = false,
  });

  /// Whether to use larger text sizes.
  final bool largeText;

  /// Whether to use high contrast colors.
  final bool highContrast;

  /// Whether to optimize for screen readers.
  final bool screenReaderOptimized;

  /// Whether to reduce animations and motion.
  final bool reducedMotion;

  /// Creates a copy with modified fields.
  AccessibilityOptions copyWith({
    bool? largeText,
    bool? highContrast,
    bool? screenReaderOptimized,
    bool? reducedMotion,
  }) {
    return AccessibilityOptions(
      largeText: largeText ?? this.largeText,
      highContrast: highContrast ?? this.highContrast,
      screenReaderOptimized: screenReaderOptimized ?? this.screenReaderOptimized,
      reducedMotion: reducedMotion ?? this.reducedMotion,
    );
  }

  @override
  List<Object?> get props => [
        largeText,
        highContrast,
        screenReaderOptimized,
        reducedMotion,
      ];
}

/// Passenger preferences entity.
///
/// Contains all user preferences including payment, notifications,
/// and accessibility settings.
class PassengerPreferences extends Equatable {
  /// Creates passenger preferences with default values.
  const PassengerPreferences({
    this.defaultPaymentMethod = PaymentMethod.mpesa,
    this.notifications = const NotificationPreferences(),
    this.accessibility = const AccessibilityOptions(),
    this.defaultPickupLocation,
    this.preferredLanguage = 'en',
  });

  /// The default payment method for trips.
  final PaymentMethod defaultPaymentMethod;

  /// Notification preferences.
  final NotificationPreferences notifications;

  /// Accessibility options.
  final AccessibilityOptions accessibility;

  /// User's default pickup location (optional).
  final String? defaultPickupLocation;

  /// User's preferred language code.
  final String preferredLanguage;

  /// Creates a copy with modified fields.
  PassengerPreferences copyWith({
    PaymentMethod? defaultPaymentMethod,
    NotificationPreferences? notifications,
    AccessibilityOptions? accessibility,
    String? defaultPickupLocation,
    String? preferredLanguage,
  }) {
    return PassengerPreferences(
      defaultPaymentMethod: defaultPaymentMethod ?? this.defaultPaymentMethod,
      notifications: notifications ?? this.notifications,
      accessibility: accessibility ?? this.accessibility,
      defaultPickupLocation: defaultPickupLocation ?? this.defaultPickupLocation,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
    );
  }

  @override
  List<Object?> get props => [
        defaultPaymentMethod,
        notifications,
        accessibility,
        defaultPickupLocation,
        preferredLanguage,
      ];
}
