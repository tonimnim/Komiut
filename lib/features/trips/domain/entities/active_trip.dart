/// Active trip entity.
///
/// Represents an active/in-progress trip for a passenger with real-time tracking.
library;

import 'package:equatable/equatable.dart';

import '../../../../core/domain/entities/route_stop.dart';

/// Status of an active trip from the passenger's perspective.
enum ActiveTripStatus {
  /// Passenger is boarding the vehicle.
  boarding,

  /// Trip is in progress.
  inProgress,

  /// Passenger is nearing their destination.
  nearingDestination,

  /// Passenger has arrived at destination.
  arrived,

  /// Trip was cancelled.
  cancelled,
}

/// Extension methods for ActiveTripStatus.
extension ActiveTripStatusX on ActiveTripStatus {
  /// Display label for UI.
  String get label {
    switch (this) {
      case ActiveTripStatus.boarding:
        return 'Boarding';
      case ActiveTripStatus.inProgress:
        return 'In Progress';
      case ActiveTripStatus.nearingDestination:
        return 'Nearing Destination';
      case ActiveTripStatus.arrived:
        return 'Arrived';
      case ActiveTripStatus.cancelled:
        return 'Cancelled';
    }
  }

  /// Whether the trip is still active.
  bool get isActive =>
      this == ActiveTripStatus.boarding ||
      this == ActiveTripStatus.inProgress ||
      this == ActiveTripStatus.nearingDestination;

  /// Color indicator for the status.
  String get colorName {
    switch (this) {
      case ActiveTripStatus.boarding:
        return 'warning';
      case ActiveTripStatus.inProgress:
        return 'info';
      case ActiveTripStatus.nearingDestination:
        return 'success';
      case ActiveTripStatus.arrived:
        return 'success';
      case ActiveTripStatus.cancelled:
        return 'error';
    }
  }
}

/// Parse ActiveTripStatus from string.
ActiveTripStatus activeTripStatusFromString(String value) {
  switch (value.toLowerCase()) {
    case 'boarding':
      return ActiveTripStatus.boarding;
    case 'inprogress':
    case 'in_progress':
      return ActiveTripStatus.inProgress;
    case 'nearingdestination':
    case 'nearing_destination':
      return ActiveTripStatus.nearingDestination;
    case 'arrived':
      return ActiveTripStatus.arrived;
    case 'cancelled':
      return ActiveTripStatus.cancelled;
    default:
      return ActiveTripStatus.boarding;
  }
}

/// Represents the current position of a vehicle.
class VehiclePosition extends Equatable {
  /// Creates a new VehiclePosition instance.
  const VehiclePosition({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    this.updatedAt,
  });

  /// Latitude coordinate.
  final double latitude;

  /// Longitude coordinate.
  final double longitude;

  /// Direction the vehicle is heading (0-360 degrees).
  final double? heading;

  /// Speed in km/h.
  final double? speed;

  /// When the position was last updated.
  final DateTime? updatedAt;

  /// Creates a copy with modified fields.
  VehiclePosition copyWith({
    double? latitude,
    double? longitude,
    double? heading,
    double? speed,
    DateTime? updatedAt,
  }) {
    return VehiclePosition(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      heading: heading ?? this.heading,
      speed: speed ?? this.speed,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [latitude, longitude, heading, speed, updatedAt];
}

/// Vehicle information for display during trip.
class TripVehicleInfo extends Equatable {
  /// Creates a new TripVehicleInfo instance.
  const TripVehicleInfo({
    required this.id,
    required this.registrationNumber,
    this.make,
    this.model,
    this.color,
    this.capacity,
    this.imageUrl,
  });

  /// Vehicle ID.
  final String id;

  /// Registration/plate number.
  final String registrationNumber;

  /// Vehicle make (e.g., Toyota).
  final String? make;

  /// Vehicle model (e.g., Hiace).
  final String? model;

  /// Vehicle color.
  final String? color;

  /// Passenger capacity.
  final int? capacity;

  /// URL to vehicle image.
  final String? imageUrl;

  /// Display name combining make and model.
  String get displayName {
    if (make != null && model != null) {
      return '$make $model';
    }
    return registrationNumber;
  }

  @override
  List<Object?> get props => [
        id,
        registrationNumber,
        make,
        model,
        color,
        capacity,
        imageUrl,
      ];
}

/// Driver information for display during trip.
class TripDriverInfo extends Equatable {
  /// Creates a new TripDriverInfo instance.
  const TripDriverInfo({
    required this.id,
    required this.name,
    this.phone,
    this.rating,
    this.photoUrl,
  });

  /// Driver ID.
  final String id;

  /// Driver name.
  final String name;

  /// Driver phone number.
  final String? phone;

  /// Driver rating (1-5).
  final double? rating;

  /// URL to driver photo.
  final String? photoUrl;

  @override
  List<Object?> get props => [id, name, phone, rating, photoUrl];
}

/// Route information for the active trip.
class TripRouteInfo extends Equatable {
  /// Creates a new TripRouteInfo instance.
  const TripRouteInfo({
    required this.id,
    required this.name,
    required this.startPoint,
    required this.endPoint,
    required this.stops,
  });

  /// Route ID.
  final String id;

  /// Route name.
  final String name;

  /// Route starting point.
  final String startPoint;

  /// Route ending point.
  final String endPoint;

  /// List of stops on the route.
  final List<RouteStop> stops;

  /// Number of stops.
  int get stopsCount => stops.length;

  /// Route summary (start -> end).
  String get summary => '$startPoint - $endPoint';

  @override
  List<Object?> get props => [id, name, startPoint, endPoint, stops];
}

/// Active trip entity representing an ongoing trip for a passenger.
class ActiveTrip extends Equatable {
  /// Creates a new ActiveTrip instance.
  const ActiveTrip({
    required this.tripId,
    required this.bookingId,
    required this.vehicle,
    this.driver,
    required this.route,
    required this.pickupStop,
    required this.dropoffStop,
    this.currentVehiclePosition,
    required this.status,
    this.currentStopIndex,
    this.estimatedArrival,
    this.distanceRemaining,
    this.fare,
    this.currency = 'KES',
    this.bookingReference,
    this.startedAt,
    this.createdAt,
  });

  /// Unique trip identifier.
  final String tripId;

  /// Associated booking identifier.
  final String bookingId;

  /// Vehicle information.
  final TripVehicleInfo vehicle;

  /// Driver information (if available).
  final TripDriverInfo? driver;

  /// Route information with stops.
  final TripRouteInfo route;

  /// Passenger's pickup stop.
  final RouteStop pickupStop;

  /// Passenger's dropoff stop.
  final RouteStop dropoffStop;

  /// Current vehicle GPS position.
  final VehiclePosition? currentVehiclePosition;

  /// Current trip status.
  final ActiveTripStatus status;

  /// Index of the current stop (0-based).
  final int? currentStopIndex;

  /// Estimated arrival time at destination.
  final DateTime? estimatedArrival;

  /// Distance remaining to destination in kilometers.
  final double? distanceRemaining;

  /// Trip fare amount.
  final double? fare;

  /// Currency for fare.
  final String currency;

  /// Booking reference code.
  final String? bookingReference;

  /// When the trip started.
  final DateTime? startedAt;

  /// When the trip was created.
  final DateTime? createdAt;

  /// Whether the trip is still active.
  bool get isActive => status.isActive;

  /// Whether the trip has arrived.
  bool get hasArrived => status == ActiveTripStatus.arrived;

  /// Whether vehicle position is available.
  bool get hasVehiclePosition => currentVehiclePosition != null;

  /// Number of stops remaining until destination.
  int get stopsRemaining {
    if (currentStopIndex == null) return 0;
    final dropoffIndex = route.stops.indexWhere((s) => s.id == dropoffStop.id);
    if (dropoffIndex < 0) return 0;
    return dropoffIndex - currentStopIndex!;
  }

  /// Calculate progress percentage (0.0 to 1.0).
  double get progressPercentage {
    if (currentStopIndex == null) return 0.0;
    final pickupIndex = route.stops.indexWhere((s) => s.id == pickupStop.id);
    final dropoffIndex = route.stops.indexWhere((s) => s.id == dropoffStop.id);
    if (pickupIndex < 0 || dropoffIndex < 0 || pickupIndex >= dropoffIndex) {
      return 0.0;
    }
    final totalStops = dropoffIndex - pickupIndex;
    final stopsCompleted = currentStopIndex! - pickupIndex;
    return (stopsCompleted / totalStops).clamp(0.0, 1.0);
  }

  /// Get the next stop on the route.
  RouteStop? get nextStop {
    if (currentStopIndex == null) return null;
    final nextIndex = currentStopIndex! + 1;
    if (nextIndex >= route.stops.length) return null;
    return route.stops[nextIndex];
  }

  /// Get the current stop.
  RouteStop? get currentStop {
    if (currentStopIndex == null) return null;
    if (currentStopIndex! >= route.stops.length) return null;
    return route.stops[currentStopIndex!];
  }

  /// Format the fare with currency.
  String get formattedFare {
    if (fare == null) return '';
    return '$currency ${fare!.toStringAsFixed(0)}';
  }

  /// Format ETA as remaining time string.
  String get formattedETA {
    if (estimatedArrival == null) return '--';
    final remaining = estimatedArrival!.difference(DateTime.now());
    if (remaining.isNegative) return 'Arriving';
    if (remaining.inHours > 0) {
      return '${remaining.inHours}h ${remaining.inMinutes % 60}m';
    }
    return '${remaining.inMinutes} min';
  }

  /// Format distance remaining.
  String get formattedDistance {
    if (distanceRemaining == null) return '--';
    if (distanceRemaining! < 1) {
      return '${(distanceRemaining! * 1000).toStringAsFixed(0)} m';
    }
    return '${distanceRemaining!.toStringAsFixed(1)} km';
  }

  /// Creates a copy with modified fields.
  ActiveTrip copyWith({
    String? tripId,
    String? bookingId,
    TripVehicleInfo? vehicle,
    TripDriverInfo? driver,
    TripRouteInfo? route,
    RouteStop? pickupStop,
    RouteStop? dropoffStop,
    VehiclePosition? currentVehiclePosition,
    ActiveTripStatus? status,
    int? currentStopIndex,
    DateTime? estimatedArrival,
    double? distanceRemaining,
    double? fare,
    String? currency,
    String? bookingReference,
    DateTime? startedAt,
    DateTime? createdAt,
  }) {
    return ActiveTrip(
      tripId: tripId ?? this.tripId,
      bookingId: bookingId ?? this.bookingId,
      vehicle: vehicle ?? this.vehicle,
      driver: driver ?? this.driver,
      route: route ?? this.route,
      pickupStop: pickupStop ?? this.pickupStop,
      dropoffStop: dropoffStop ?? this.dropoffStop,
      currentVehiclePosition:
          currentVehiclePosition ?? this.currentVehiclePosition,
      status: status ?? this.status,
      currentStopIndex: currentStopIndex ?? this.currentStopIndex,
      estimatedArrival: estimatedArrival ?? this.estimatedArrival,
      distanceRemaining: distanceRemaining ?? this.distanceRemaining,
      fare: fare ?? this.fare,
      currency: currency ?? this.currency,
      bookingReference: bookingReference ?? this.bookingReference,
      startedAt: startedAt ?? this.startedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        tripId,
        bookingId,
        vehicle,
        driver,
        route,
        pickupStop,
        dropoffStop,
        currentVehiclePosition,
        status,
        currentStopIndex,
        estimatedArrival,
        distanceRemaining,
        fare,
        currency,
        bookingReference,
        startedAt,
        createdAt,
      ];
}
