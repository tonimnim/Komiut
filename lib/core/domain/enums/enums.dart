/// Core application enums.
///
/// Defines all enums used across the application matching
/// the API schema definitions.
library;

// ─────────────────────────────────────────────────────────────────────────────
// User Enums
// ─────────────────────────────────────────────────────────────────────────────

/// User roles in the application.
enum UserRole {
  /// Regular passenger using the transport service.
  passenger,

  /// Driver operating a vehicle.
  driver,

  /// Tout/conductor assisting with passengers.
  tout,

  /// Administrator with full access.
  admin,
}

/// Extension methods for UserRole.
extension UserRoleX on UserRole {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Display label for UI.
  String get label {
    switch (this) {
      case UserRole.passenger:
        return 'Passenger';
      case UserRole.driver:
        return 'Driver';
      case UserRole.tout:
        return 'Tout';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  /// Whether this role is a crew member (driver/tout).
  bool get isCrew => this == UserRole.driver || this == UserRole.tout;

  /// Whether this role can manage vehicles.
  bool get canManageVehicle =>
      this == UserRole.driver || this == UserRole.admin;
}

/// Parse UserRole from string.
UserRole userRoleFromString(String value) {
  return UserRole.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => UserRole.passenger,
  );
}

/// User account status.
enum UserStatus {
  /// Active and can use the app.
  active,

  /// Deactivated and cannot use the app.
  inactive,
}

/// Extension methods for UserStatus.
extension UserStatusX on UserStatus {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Whether the user can access the app.
  bool get canAccess => this == UserStatus.active;
}

// ─────────────────────────────────────────────────────────────────────────────
// Organization Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Type of organization.
enum OrganizationType {
  /// Sacco (Savings and Credit Cooperative).
  sacco,

  /// Private company.
  company,
}

/// Extension methods for OrganizationType.
extension OrganizationTypeX on OrganizationType {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Display label for UI.
  String get label {
    switch (this) {
      case OrganizationType.sacco:
        return 'Sacco';
      case OrganizationType.company:
        return 'Company';
    }
  }
}

/// Organization status.
enum OrganizationStatus {
  /// Active and operational.
  active,

  /// Inactive/suspended.
  inactive,
}

// ─────────────────────────────────────────────────────────────────────────────
// Vehicle Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Vehicle operational status.
enum VehicleStatus {
  /// Active and can operate.
  active,

  /// Inactive/out of service.
  inactive,
}

/// Extension methods for VehicleStatus.
extension VehicleStatusX on VehicleStatus {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Whether the vehicle can operate.
  bool get canOperate => this == VehicleStatus.active;
}

// ─────────────────────────────────────────────────────────────────────────────
// Trip Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Trip status.
enum TripStatus {
  /// Trip is scheduled but not started.
  scheduled,

  /// Trip is currently in progress.
  inProgress,

  /// Trip has been completed.
  completed,

  /// Trip was cancelled.
  cancelled,
}

/// Extension methods for TripStatus.
extension TripStatusX on TripStatus {
  /// Convert to API string value.
  String toApiValue() {
    switch (this) {
      case TripStatus.scheduled:
        return 'scheduled';
      case TripStatus.inProgress:
        return 'inProgress';
      case TripStatus.completed:
        return 'completed';
      case TripStatus.cancelled:
        return 'cancelled';
    }
  }

  /// Display label for UI.
  String get label {
    switch (this) {
      case TripStatus.scheduled:
        return 'Scheduled';
      case TripStatus.inProgress:
        return 'In Progress';
      case TripStatus.completed:
        return 'Completed';
      case TripStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Whether the trip is active (can be modified).
  bool get isActive =>
      this == TripStatus.scheduled || this == TripStatus.inProgress;
}

/// Parse TripStatus from string.
TripStatus tripStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'scheduled':
      return TripStatus.scheduled;
    case 'inprogress':
    case 'in_progress':
      return TripStatus.inProgress;
    case 'completed':
      return TripStatus.completed;
    case 'cancelled':
      return TripStatus.cancelled;
    default:
      return TripStatus.scheduled;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Booking Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Booking status.
enum BookingStatus {
  /// Booking is pending confirmation.
  pending,

  /// Booking has been confirmed.
  confirmed,

  /// Booking was cancelled.
  cancelled,

  /// Booking was completed (trip finished).
  completed,
}

/// Extension methods for BookingStatus.
extension BookingStatusX on BookingStatus {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Display label for UI.
  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'Pending';
      case BookingStatus.confirmed:
        return 'Confirmed';
      case BookingStatus.cancelled:
        return 'Cancelled';
      case BookingStatus.completed:
        return 'Completed';
    }
  }

  /// Whether the booking is active.
  bool get isActive =>
      this == BookingStatus.pending || this == BookingStatus.confirmed;

  /// Whether the booking can be cancelled.
  bool get canCancel =>
      this == BookingStatus.pending || this == BookingStatus.confirmed;
}

/// Parse BookingStatus from string.
BookingStatus bookingStatusFromString(String value) {
  return BookingStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => BookingStatus.pending,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Payment Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Payment status.
enum PaymentStatus {
  /// Payment is pending processing.
  pending,

  /// Payment was successful.
  completed,

  /// Payment failed.
  failed,

  /// Payment was refunded.
  refunded,
}

/// Extension methods for PaymentStatus.
extension PaymentStatusX on PaymentStatus {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Display label for UI.
  String get label {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.completed:
        return 'Completed';
      case PaymentStatus.failed:
        return 'Failed';
      case PaymentStatus.refunded:
        return 'Refunded';
    }
  }

  /// Whether the payment was successful.
  bool get isSuccessful => this == PaymentStatus.completed;
}

/// Parse PaymentStatus from string.
PaymentStatus paymentStatusFromString(String value) {
  return PaymentStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => PaymentStatus.pending,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Personnel Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Personnel status.
enum PersonnelStatus {
  /// Active and can work.
  active,

  /// Inactive/suspended.
  inactive,
}

/// Personnel role.
enum PersonnelRole {
  /// Vehicle driver.
  driver,

  /// Tout/conductor.
  tout,
}

/// Extension methods for PersonnelRole.
extension PersonnelRoleX on PersonnelRole {
  /// Display label for UI.
  String get label {
    switch (this) {
      case PersonnelRole.driver:
        return 'Driver';
      case PersonnelRole.tout:
        return 'Tout';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Domain Enums
// ─────────────────────────────────────────────────────────────────────────────

/// Domain status.
enum DomainStatus {
  /// Domain is active.
  active,

  /// Domain is inactive.
  inactive,
}

// ─────────────────────────────────────────────────────────────────────────────
// Currency
// ─────────────────────────────────────────────────────────────────────────────

/// Supported currencies.
enum Currency {
  /// Kenyan Shilling.
  KES,

  /// US Dollar.
  USD,

  /// Ugandan Shilling.
  UGX,

  /// Tanzanian Shilling.
  TZS,
}

/// Extension methods for Currency.
extension CurrencyX on Currency {
  /// Currency symbol.
  String get symbol {
    switch (this) {
      case Currency.KES:
        return 'KSH';
      case Currency.USD:
        return '\$';
      case Currency.UGX:
        return 'USh';
      case Currency.TZS:
        return 'TSh';
    }
  }

  /// Format amount with currency.
  String format(double amount) {
    return '$symbol ${amount.toStringAsFixed(2)}';
  }
}

/// Parse Currency from string.
Currency currencyFromString(String value) {
  return Currency.values.firstWhere(
    (e) => e.name.toUpperCase() == value.toUpperCase(),
    orElse: () => Currency.KES,
  );
}
