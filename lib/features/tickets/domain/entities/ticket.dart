/// Ticket entity.
///
/// Represents a passenger's boarding ticket for a trip.
library;

import 'package:equatable/equatable.dart';

/// Ticket status enum.
enum TicketStatus {
  /// Ticket is valid and can be used for boarding.
  valid,

  /// Ticket has been used (passenger boarded).
  used,

  /// Ticket has expired (past valid time).
  expired,

  /// Ticket was cancelled.
  cancelled,
}

/// Extension methods for TicketStatus.
extension TicketStatusX on TicketStatus {
  /// Convert to API string value.
  String toApiValue() => name;

  /// Display label for UI.
  String get label {
    switch (this) {
      case TicketStatus.valid:
        return 'Valid';
      case TicketStatus.used:
        return 'Used';
      case TicketStatus.expired:
        return 'Expired';
      case TicketStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Whether the ticket can be used for boarding.
  bool get canBoard => this == TicketStatus.valid;

  /// Whether the ticket is still active (not used or cancelled).
  bool get isActive => this == TicketStatus.valid;
}

/// Parse TicketStatus from string.
TicketStatus ticketStatusFromString(String value) {
  return TicketStatus.values.firstWhere(
    (e) => e.name.toLowerCase() == value.toLowerCase(),
    orElse: () => TicketStatus.valid,
  );
}

/// Route info embedded in ticket.
class RouteInfo extends Equatable {
  /// Creates a new RouteInfo instance.
  const RouteInfo({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
  });

  /// Route ID.
  final String id;

  /// Route name.
  final String name;

  /// Starting point name.
  final String startPoint;

  /// Ending point name.
  final String endPoint;

  /// Route summary.
  String get summary => '$startPoint → $endPoint';

  @override
  List<Object?> get props => [id, name, startPoint, endPoint];
}

/// Trip info embedded in ticket.
class TripInfo extends Equatable {
  /// Creates a new TripInfo instance.
  const TripInfo({
    required this.id,
    required this.vehicleRegistration,
    this.driverName,
    this.driverPhone,
    required this.departureTime,
    this.estimatedArrival,
  });

  /// Trip ID.
  final String id;

  /// Vehicle registration number.
  final String vehicleRegistration;

  /// Driver name.
  final String? driverName;

  /// Driver phone.
  final String? driverPhone;

  /// Scheduled departure time.
  final DateTime departureTime;

  /// Estimated arrival time.
  final DateTime? estimatedArrival;

  @override
  List<Object?> get props => [
        id,
        vehicleRegistration,
        driverName,
        driverPhone,
        departureTime,
        estimatedArrival,
      ];
}

/// Ticket entity representing a boarding pass.
class Ticket extends Equatable {
  /// Creates a new Ticket instance.
  const Ticket({
    required this.id,
    required this.bookingId,
    required this.passengerId,
    required this.qrCode,
    required this.ticketNumber,
    required this.status,
    required this.routeInfo,
    required this.tripInfo,
    required this.pickupStop,
    required this.dropoffStop,
    this.seatNumber,
    required this.fare,
    required this.currency,
    required this.validFrom,
    required this.validUntil,
    this.usedAt,
    this.passengerName,
    this.passengerPhone,
    this.createdAt,
  });

  /// Unique ticket identifier.
  final String id;

  /// Associated booking ID.
  final String bookingId;

  /// Passenger ID.
  final String passengerId;

  /// QR code data for scanning (encoded ticket data).
  final String qrCode;

  /// Human-readable ticket number (e.g., KMT-XXXXXX).
  final String ticketNumber;

  /// Current ticket status.
  final TicketStatus status;

  /// Route information.
  final RouteInfo routeInfo;

  /// Trip information.
  final TripInfo tripInfo;

  /// Pickup stop name.
  final String pickupStop;

  /// Dropoff stop name.
  final String dropoffStop;

  /// Assigned seat number (if applicable).
  final int? seatNumber;

  /// Fare amount paid.
  final double fare;

  /// Currency code (e.g., KES).
  final String currency;

  /// Ticket validity start time.
  final DateTime validFrom;

  /// Ticket validity end time.
  final DateTime validUntil;

  /// When the ticket was used for boarding.
  final DateTime? usedAt;

  /// Passenger name (for display).
  final String? passengerName;

  /// Passenger phone (for contact).
  final String? passengerPhone;

  /// When the ticket was created.
  final DateTime? createdAt;

  /// Whether the ticket is valid for boarding now.
  bool get isValidNow {
    final now = DateTime.now();
    return status == TicketStatus.valid &&
        now.isAfter(validFrom) &&
        now.isBefore(validUntil);
  }

  /// Whether the ticket has been used.
  bool get isUsed => status == TicketStatus.used;

  /// Whether the ticket is expired.
  bool get isExpired =>
      status == TicketStatus.expired || DateTime.now().isAfter(validUntil);

  /// Whether the ticket is cancelled.
  bool get isCancelled => status == TicketStatus.cancelled;

  /// Format fare with currency.
  String get formattedFare => '$currency ${fare.toStringAsFixed(0)}';

  /// Format seat number for display.
  String get formattedSeat => seatNumber != null ? 'Seat $seatNumber' : 'Any Seat';

  /// Route summary.
  String get routeSummary => routeInfo.summary;

  /// Trip summary.
  String get tripSummary => '$pickupStop → $dropoffStop';

  /// Creates a copy with modified fields.
  Ticket copyWith({
    String? id,
    String? bookingId,
    String? passengerId,
    String? qrCode,
    String? ticketNumber,
    TicketStatus? status,
    RouteInfo? routeInfo,
    TripInfo? tripInfo,
    String? pickupStop,
    String? dropoffStop,
    int? seatNumber,
    double? fare,
    String? currency,
    DateTime? validFrom,
    DateTime? validUntil,
    DateTime? usedAt,
    String? passengerName,
    String? passengerPhone,
    DateTime? createdAt,
  }) {
    return Ticket(
      id: id ?? this.id,
      bookingId: bookingId ?? this.bookingId,
      passengerId: passengerId ?? this.passengerId,
      qrCode: qrCode ?? this.qrCode,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      status: status ?? this.status,
      routeInfo: routeInfo ?? this.routeInfo,
      tripInfo: tripInfo ?? this.tripInfo,
      pickupStop: pickupStop ?? this.pickupStop,
      dropoffStop: dropoffStop ?? this.dropoffStop,
      seatNumber: seatNumber ?? this.seatNumber,
      fare: fare ?? this.fare,
      currency: currency ?? this.currency,
      validFrom: validFrom ?? this.validFrom,
      validUntil: validUntil ?? this.validUntil,
      usedAt: usedAt ?? this.usedAt,
      passengerName: passengerName ?? this.passengerName,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingId,
        passengerId,
        qrCode,
        ticketNumber,
        status,
        routeInfo,
        tripInfo,
        pickupStop,
        dropoffStop,
        seatNumber,
        fare,
        currency,
        validFrom,
        validUntil,
        usedAt,
        passengerName,
        passengerPhone,
        createdAt,
      ];
}
