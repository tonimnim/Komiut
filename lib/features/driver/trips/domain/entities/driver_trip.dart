import 'package:equatable/equatable.dart';

/// Status of a driver's trip.
enum DriverTripStatus {
  pending,
  active,
  completed,
  cancelled,
}

/// Represents a trip from the driver's perspective.
class DriverTrip extends Equatable {
  const DriverTrip({
    required this.id,
    required this.routeId,
    required this.routeName,
    required this.status,
    required this.startTime,
    this.endTime,
    this.passengerCount = 0,
    this.maxCapacity,
    this.fare = 0.0,
    this.startStopId,
    this.startStopName,
    this.endStopId,
    this.endStopName,
    this.currentStopIndex,
    this.totalStops,
    this.vehicleRegistration,
    this.currency = 'KES',
  });

  final String id;
  final String routeId;
  final String routeName;
  final DriverTripStatus status;
  final DateTime startTime;
  final DateTime? endTime;
  final int passengerCount;
  final int? maxCapacity;
  final double fare;
  final String? startStopId;
  final String? startStopName;
  final String? endStopId;
  final String? endStopName;
  final int? currentStopIndex;
  final int? totalStops;
  final String? vehicleRegistration;
  final String currency;

  /// Whether the trip is currently active.
  bool get isActive => status == DriverTripStatus.active;

  /// Whether the trip is completed.
  bool get isCompleted => status == DriverTripStatus.completed;

  /// Whether the trip is pending.
  bool get isPending => status == DriverTripStatus.pending;

  /// Whether the vehicle is at full capacity.
  bool get isFull => maxCapacity != null && passengerCount >= maxCapacity!;

  /// Available seats remaining.
  int get availableSeats =>
      maxCapacity != null ? maxCapacity! - passengerCount : 0;

  /// Trip duration if completed.
  Duration? get duration => endTime?.difference(startTime);

  /// Formatted duration for display.
  String get displayDuration {
    final d = duration;
    if (d == null) return 'In Progress';
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }

  /// Formatted fare for display.
  String get displayFare => '$currency ${fare.toStringAsFixed(2)}';

  /// Progress through the route (0.0 to 1.0).
  double get progress {
    if (currentStopIndex == null || totalStops == null || totalStops == 0) {
      return 0.0;
    }
    return currentStopIndex! / totalStops!;
  }

  /// Human-readable status name.
  String get statusName {
    switch (status) {
      case DriverTripStatus.pending:
        return 'Pending';
      case DriverTripStatus.active:
        return 'Active';
      case DriverTripStatus.completed:
        return 'Completed';
      case DriverTripStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  List<Object?> get props => [
        id,
        routeId,
        routeName,
        status,
        startTime,
        endTime,
        passengerCount,
        maxCapacity,
        fare,
        startStopId,
        startStopName,
        endStopId,
        endStopName,
        currentStopIndex,
        totalStops,
        vehicleRegistration,
        currency,
      ];

  DriverTrip copyWith({
    String? id,
    String? routeId,
    String? routeName,
    DriverTripStatus? status,
    DateTime? startTime,
    DateTime? endTime,
    int? passengerCount,
    int? maxCapacity,
    double? fare,
    String? startStopId,
    String? startStopName,
    String? endStopId,
    String? endStopName,
    int? currentStopIndex,
    int? totalStops,
    String? vehicleRegistration,
    String? currency,
  }) {
    return DriverTrip(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      routeName: routeName ?? this.routeName,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      passengerCount: passengerCount ?? this.passengerCount,
      maxCapacity: maxCapacity ?? this.maxCapacity,
      fare: fare ?? this.fare,
      startStopId: startStopId ?? this.startStopId,
      startStopName: startStopName ?? this.startStopName,
      endStopId: endStopId ?? this.endStopId,
      endStopName: endStopName ?? this.endStopName,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      totalStops: totalStops ?? this.totalStops,
      vehicleRegistration: vehicleRegistration ?? this.vehicleRegistration,
      currency: currency ?? this.currency,
    );
  }
}
