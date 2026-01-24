/// Trip API model for passenger trips.
///
/// This model converts between API JSON and the home feature's TripEntity.
/// It bridges the core Trip model with the simplified TripEntity used in home/activity screens.
library;

import '../../../home/domain/entities/trip_entity.dart';

/// Trip API model that converts to TripEntity for home/activity screens.
class TripApiModel {
  /// Creates a new TripApiModel instance.
  const TripApiModel({
    required this.id,
    required this.passengerId,
    required this.tripId,
    this.routeName,
    this.pickupStopName,
    this.dropoffStopName,
    required this.amount,
    required this.currency,
    required this.status,
    this.tripStartTime,
    this.createdAt,
  });

  /// Creates from booking JSON (passenger's view of trip).
  ///
  /// Bookings represent a passenger's trip, containing route, pickup/dropoff info.
  factory TripApiModel.fromBookingJson(Map<String, dynamic> json) {
    return TripApiModel(
      id: json['bookingId'] as String? ?? json['id'] as String,
      passengerId: json['passengerId'] as String,
      tripId: json['tripId'] as String,
      routeName: json['routeName'] as String?,
      pickupStopName: json['pickupStopName'] as String?,
      dropoffStopName: json['dropoffStopName'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'KES',
      status: _parseStatus(json['status']),
      tripStartTime: json['tripStartTime'] != null
          ? DateTime.parse(json['tripStartTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  /// Creates from trip JSON (vehicle trip data).
  factory TripApiModel.fromTripJson(Map<String, dynamic> json, {
    required String passengerId,
    String? pickupStopName,
    String? dropoffStopName,
    double? fare,
  }) {
    return TripApiModel(
      id: json['id'] as String,
      passengerId: passengerId,
      tripId: json['id'] as String,
      routeName: json['routeName'] as String?,
      pickupStopName: pickupStopName,
      dropoffStopName: dropoffStopName,
      amount: fare ?? 0.0,
      currency: 'KES',
      status: _parseTripStatus(json['status']),
      tripStartTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'] as String)
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  final String id;
  final String passengerId;
  final String tripId;
  final String? routeName;
  final String? pickupStopName;
  final String? dropoffStopName;
  final double amount;
  final String currency;
  final String status;
  final DateTime? tripStartTime;
  final DateTime? createdAt;

  /// Converts to TripEntity for home/activity screens.
  ///
  /// Maps API model fields to the simpler TripEntity structure used by UI.
  TripEntity toEntity() {
    // Generate a numeric ID from the string ID for compatibility
    final numericId = id.hashCode.abs();
    final passengerNumericId = passengerId.hashCode.abs();

    return TripEntity(
      id: numericId,
      userId: passengerNumericId,
      routeName: routeName ?? 'Unknown Route',
      fromLocation: pickupStopName ?? 'Unknown',
      toLocation: dropoffStopName ?? 'Unknown',
      fare: amount,
      status: status,
      tripDate: tripStartTime ?? createdAt ?? DateTime.now(),
    );
  }

  /// Converts to JSON map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'passengerId': passengerId,
        'tripId': tripId,
        if (routeName != null) 'routeName': routeName,
        if (pickupStopName != null) 'pickupStopName': pickupStopName,
        if (dropoffStopName != null) 'dropoffStopName': dropoffStopName,
        'amount': amount,
        'currency': currency,
        'status': status,
        if (tripStartTime != null) 'tripStartTime': tripStartTime!.toIso8601String(),
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
      };

  /// Parse booking status to string.
  static String _parseStatus(dynamic status) {
    if (status is int) {
      // API returns: 0=pending, 1=confirmed, 2=cancelled, 3=completed
      switch (status) {
        case 0:
          return 'pending';
        case 1:
          return 'confirmed';
        case 2:
          return 'cancelled';
        case 3:
          return 'completed';
        default:
          return 'pending';
      }
    }
    return (status as String?)?.toLowerCase() ?? 'pending';
  }

  /// Parse trip status to string.
  static String _parseTripStatus(dynamic status) {
    if (status is int) {
      // API returns: 0=scheduled, 1=inProgress, 2=completed, 3=cancelled
      switch (status) {
        case 0:
          return 'scheduled';
        case 1:
          return 'inProgress';
        case 2:
          return 'completed';
        case 3:
          return 'cancelled';
        default:
          return 'scheduled';
      }
    }
    return (status as String?)?.toLowerCase() ?? 'scheduled';
  }
}

/// Filter options for fetching trips.
class TripsFilter {
  const TripsFilter({
    this.passengerId,
    this.status,
    this.pageNumber,
    this.pageSize,
  });

  final String? passengerId;
  final String? status;
  final int? pageNumber;
  final int? pageSize;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TripsFilter &&
          runtimeType == other.runtimeType &&
          passengerId == other.passengerId &&
          status == other.status &&
          pageNumber == other.pageNumber &&
          pageSize == other.pageSize;

  @override
  int get hashCode =>
      passengerId.hashCode ^
      status.hashCode ^
      pageNumber.hashCode ^
      pageSize.hashCode;
}
